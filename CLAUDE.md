# mlib_devel / JASPER toolflow — orientation for Claude sessions

This repo is the CASPER toolflow: it turns a Simulink design (`.slx`) containing CASPER
"yellow blocks" into a Vivado project and ultimately an `.fpg` FPGA image loadable with
`casperfpga`. The upstream `README.md` covers user-facing docs; this file describes how
the Python compile machinery in `jasper_library/` actually works.

## Entry point

`jasper_library/exec_flow.py -m <model.slx> -c <builddir> [--perfile --frontend --middleware --backend --software]`

Usually invoked from MATLAB (`jasper.m` / `jasper_frontend.m`) inside the environment set up
by `./startsg` (which sources `startsg.local` to set `MLIB_DEVEL_PATH`, `HDL_ROOT`,
`XILINX_PATH`, etc.). Each flag runs one stage; a full compile runs all of them in order.

## The pipeline (all in `jasper_library/toolflow.py` unless noted)

1. **Frontend** (`SimulinkFrontend`, `--perfile`/`--frontend`): MATLAB introspects the model
   and writes `<builddir>/jasper.per` — a YAML file with a `yellow_blocks` dict (each block's
   mask parameters plus a `tag` like `xps:sw_reg`) and a `user_modules` dict (the user's DSP
   logic, compiled to HDL by System Generator in the `--frontend` step).

2. **Middleware** (`Toolflow`, `--middleware`) — this is where YellowBlocks do their work:
   - `gen_periph_objs()`: parses `jasper.per`; the block tagged `xps:xsg` names the platform,
     which becomes a `casper_platform.Platform` loaded from `jasper_library/platforms/<name>.yaml`
     (FPGA part, pin locations, `mmbus_architecture`, project mode, etc.). Every other
     `xps:<tag>` entry is passed to `YellowBlock.make_block()`
     (`jasper_library/yellow_blocks/yellow_block.py`), which dynamically imports
     `jasper_library/yellow_blocks/<tag>.py` and instantiates the class named `<tag>` (or calls
     its `factory()` classmethod for platform-specific subclasses). Blocks may spawn more blocks
     via `gen_children()` (expanded recursively), then each block's `initialize()` runs, then a
     DRC checks every block's `requires`/`exc_requires` list against the `provides` lists of the
     platform and other blocks.
   - `build_top()` + `generate_hdl()`: builds `self.top`, a `verilog.VerilogModule`
     representing `top.v`. Each yellow block's `modify_top(top)` adds its instances, signals,
     top-level ports, and memory-mapped bus devices (wishbone or AXI4-Lite, per the platform's
     `mmbus_architecture`). User sysgen modules are instantiated with ports connected 1:1 to
     same-named signals that yellow blocks are expected to have created. Then `finalize_top()`
     hooks run, the wishbone interconnect/addressing is computed (`top.wb_compute`), and
     `top.v` is written to the build dir. AXI4-Lite platforms additionally get an
     `axi4lite_interconnect` block appended and register HDL generated via xml2vhdl.
     Blocks can also emit whole generated source files via `gen_custom_hdl()`.
   - `generate_consts()`: collects each block's `gen_constraints()` — abstract
     `PortConstraint`/`ClockConstraint`/... objects (`jasper_library/constraints.py`) that are
     physicalized (pin locations, IO standards) against the platform YAML.
   - `write_core_info()`: writes `core_info.tab`, the register/memory map baked into the
     `.fpg` header that `casperfpga` uses at runtime.
   - `dump_castro()`: serializes everything the backend needs — source list, IP list,
     constraints — into `<builddir>/castro.yml` (`jasper_library/castro.py`). Castro is the
     deliberate interface boundary between the vendor-agnostic middleware and vendor backends.

3. **Backend** (`VivadoBackend`, `--backend`): consumes `castro.yml`; it never touches the
   `.per` file. The whole backend is a tcl-script generator:
   - `import_from_castro()`: turns every source/constraint/IP into tcl (`import_files`,
     `read_vhdl`, `create_ip`, ...) via `add_source`/`add_const_file`/`add_library`/`add_ip`.
   - `initialize()`: tcl to `create_project` (project mode, the default — project lives at
     `<builddir>/myproj/`) or `set_part` (non-project mode, `--nonprojectmode`), plus a
     block design (`blockdesign.BlockDesign`).
   - `compile()` → `add_compile_cmds()`: adds synth/impl/bitgen tcl (`launch_runs`,
     `write_bitstream`, timing checks), and crucially calls back into the yellow blocks:
     `gen_yellowblock_tcl_cmds()` collects each block's `gen_tcl_cmds()` and
     `gen_bd_tcl_cmds()` lets each block `modify_bd()` the block design. All tcl is
     accumulated in `self.tcl_cmds`, a dict of ordered stages:
     `init, post_init, create_bd, bd, pre_synth, synth, post_synth, pre_impl, impl,
     post_impl, pre_bitgen, bitgen, post_bitgen, promgen`.
     Everything is concatenated into `<builddir>/gogogo.tcl` and run with
     `vivado -mode batch -source gogogo.tcl`.
   - `--software`: packages `top.bin` + `core_info.tab`/`design_info.tab`/`git_info.tab`
     into a timestamped `.fpg` in `<builddir>/outputs/` (`mkfpg()`).
   - There is also a `VitisBackend` (`--vitis`) that generates a device-tree overlay
     (`.dtbo`) from the `.xsa` for RFSoC platforms, and partial-reconfiguration support via
     a yellow block `template_project` attribute (switches to `add_compile_cmds_pr`).

## Writing or modifying a yellow block

A yellow block class (subclass `YellowBlock` in `jasper_library/yellow_blocks/<tag>.py`,
class name == module name == the `xps:` tag) hooks into the flow by overriding:

- `initialize()` — set `self.sources` (paths relative to `$HDL_ROOT`, usually
  `jasper_library/hdl_sources/...`), `self.ips`, `self.provides`/`requires`/`exc_requires`,
  `self.typecode` (see `yellow_block_typecodes.py`).
- `gen_children()` — request supporting blocks (e.g. a clock infrastructure block).
- `modify_top(top)` — instantiate HDL in the `VerilogModule` top level; use
  `top.get_instance()`, `inst.add_port()`, `top.add_signal()`/`add_port()`, and
  `top.add_wb_interface()`/AXI equivalents for software-visible registers (see
  `sw_reg.py`, `bram.py`, `gpio.py` for canonical examples).
- `gen_constraints()` — return constraint objects; pin names map through the platform YAML.
- `gen_tcl_cmds()` — return `{stage: [tcl, ...]}` for vendor-specific setup (IP config, etc.).
- `modify_bd(bd)` / `gen_custom_hdl()` — block-design tcl and generated source files.

The matching Simulink mask lives in `xps_library/`; its mask parameters arrive verbatim as
attributes on the Python object (`copy_attrs()` copies every key of the `.per` dict).

## Debugging a build

Everything lands in the build directory (sibling of the `.slx` by default): `jasper.log`
(full DEBUG log), `jasper.per` (what the frontend saw), `top.v` and `top.pickle` (the
generated top level and a pickle of the `VerilogModule`), `castro.yml`, `gogogo.tcl`
(exact tcl Vivado ran), `vivado.log`, `core_info.tab`, `myproj/` (the Vivado project —
open it in the GUI to inspect), `outputs/*.fpg`.

## Repo map (compile-relevant parts)

- `jasper_library/toolflow.py` — Toolflow / frontends / backends (this whole document)
- `jasper_library/exec_flow.py` — CLI entry point
- `jasper_library/yellow_blocks/` — one Python class per yellow block type
- `jasper_library/verilog.py` — `VerilogModule`: programmatic top.v generation, WB interconnect
- `jasper_library/constraints.py`, `castro.py`, `blockdesign.py` — constraint objects,
  middleware↔backend interchange, Vivado block-design builder
- `jasper_library/platforms/*.yaml` — per-board FPGA part, pins, bus architecture
- `jasper_library/hdl_sources/` — HDL for toolflow-supplied IP (`$HDL_ROOT`)
- `casper_library/`, `xps_library/` — Simulink block libraries (MATLAB side)
