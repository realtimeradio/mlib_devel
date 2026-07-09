from .yellow_block import YellowBlock
from .yellow_block_typecodes import *


class axi4_bram(YellowBlock):
    """
    A shared BRAM which is accessed by the CPU over a dedicated, burst-capable
    AXI4 interface, rather than via the CASPER AXI4-Lite interconnect.

    Rather than generating an xml2vhdl AXI4-Lite slave, this block drops an
    ``axi_bram_ctrl`` + standalone ``blk_mem_gen`` pair into the top-level
    Vivado block design, connected to the MPSoC's M_AXI_HPM1_FPD port (which
    this block enables). The RAM lives at a fixed address, which is recorded
    in core_info.tab (and hence the .fpg file) via
    ``add_xil_axi4lite_interface`` -- a bookkeeping-only entry which generates
    no HDL and does not involve xml2vhdl.

    The AXI side is 128 bits wide by default. *** THIS IS NOT A FREE CHOICE:
    the HPM port's fabric width is realised inside the PS hard block by the
    FPD_SLCR.AFI_FS register (0xFD615000, bits [11:10] for HPM1), which is
    programmed by psu_init in the BOOT FIRMWARE, not by the bitstream. The
    PSU__MAXIGP1__DATA_WIDTH setting this block emits only takes effect if
    the FSBL/boot image is regenerated from the design's .xsa. The silicon
    power-on default is 128-bit, so building the PL side 128-bit works even
    under a stale FSBL; any other ``axi_data_width`` requires regenerating
    the boot firmware or poking AFI_FS at runtime, or the PS and PL disagree
    about byte-lane placement and accesses silently corrupt: writes off the
    first lane are dropped and reads of them return 0, at exactly
    (PS width / 32)-word granularity. ***

    The BMG is used in stand-alone mode (NOT "BRAM controller" mode) so that
    its fabric-facing port B may be a different width from the AXI-side
    port A. Two consequences, both verified against Vivado 2021.2:

    * The controller cannot be wired to the BMG with an interface-level
      connection: the controller emits *byte* addresses while a stand-alone
      BMG is *word* addressed, and Vivado silently connects the mismatched
      widths LSB-aligned, scrambling the addressing. Instead the interface
      member pins are individually wired (legal; Vivado warns BD 41-1306),
      with an ``xlslice`` dropping the byte-offset address bits.
    * Byte-write enables are enabled on the BMG (``Use_Byte_Write_Enable`` +
      ``Byte_Size 8``) so port A's ``wea`` matches the controller's
      per-byte ``bram_we_a`` strobes -- essential on a wide port, where
      narrow CPU accesses arrive as strobed lanes. Port B's write enable is
      ``data_width/8`` bits wide; the single-bit user ``we`` is replicated
      across it in top.v, so fabric writes are always full words.

    The fabric side of the RAM (BMG port B) is exported from the block design
    and connected in top.v to the same ``<name>_addr/_data_in/_data_out/_we``
    signals a regular shared BRAM would use, so the Simulink interface is
    identical to the standard shared_bram block. Note that for data widths
    other than 32, the 32-bit word packing order within a wide fabric word is
    the BMG's native (LSB-first) order -- word (re)ordering is expected to be
    handled in Simulink.

    Expected mask parameters (clone of shared_bram):
      * ``addr_width``      -- log2 of the RAM depth in fabric-side words
      * ``data_width``      -- fabric-side word width in bits. Any power of 2
                               within a factor of 4 of the AXI-side width
                               (the BMG's port-asymmetry limit when
                               byte-write enables are on): 32-512 for the
                               default 128-bit AXI side; 8/16-bit fabric
                               ports need axi_data_width=32
      * ``axi_data_width``  -- (optional) AXI-side width in bits: 32, 64 or
                               128. Default 128, matching the PS power-on
                               default -- see the AFI_FS warning above
                               before changing this. All instances in a
                               design must agree (they share one HPM port
                               and crossbar).
      * ``reg_prim_output`` -- register the BRAM primitive outputs (adds 1
                               cycle of read latency, on both ports; the AXI
                               controller's READ_LATENCY is set to match)
      * ``reg_core_output`` -- register the BRAM core outputs (adds 1 cycle,
                               likewise on both ports)
                               NB: enabling either register option forfeits
                               the controller's read-command optimization
                               (back-to-back read pipelining, useful to DMA
                               masters), which the core only supports at
                               READ_LATENCY=1.
      * ``base_addr``       -- (optional) fixed AXI address of the RAM. Must be
                               aligned to the RAM size (min 4KiB). Defaults to
                               0xB0000000 + 16MiB * instance number, safely
                               clear of the CASPER AXI4-Lite window at
                               mmbus_base_address (0xA0000000 + 16MiB on
                               krm4zuxx). RAMs larger than 16MiB must set
                               base_addr explicitly so the default staggering
                               can't overlap.
      * ``ram_primitive``   -- (optional) 'block' (default) or 'ultra'.
                               Selects the BMG memory primitive.
                               NB: 'ultra' is currently DISABLED (selecting
                               it is a toolflow error) because the fabric
                               port would have to run on axil_clk -- see
                               below. The implementation is kept as a
                               validated placeholder for a future design
                               that can accept that clocking.
                               UltraRAM mode carries three constraints, all
                               enforced or handled here (empirically, the
                               BMG silently overrides rather than erroring):
                                 - ports must be symmetric, so data_width
                                   must equal axi_data_width;
                                 - URAM is a single-clock primitive
                                   (Assume_Synchronous_Clk is forced), so
                                   the fabric port is clocked by axil_clk
                                   (the AXI-side clock), NOT user_clk. The
                                   Simulink design must run this interface
                                   in that domain or handle the CDC itself;
                                 - the BMG ignores Enable_B=Always_Enabled,
                                   so an en port appears (tied high in
                                   top.v).

    Multiple instances are supported. A lone instance's BRAM controller
    connects straight to HPM1_FPD; with more than one, the first instance
    additionally drops in an ``axi_crossbar`` and every instance's controller
    hangs off one of its master ports. A crossbar is used rather than an
    ``axi_smartconnect`` because CPU accesses via /dev/mem are serialised,
    single-outstanding round trips: with no pipelining to hide it, every
    cycle of switch latency comes straight off the read throughput, and the
    crossbar (a plain address-decode switch, no ID/width/clock conversion) is
    several times shallower than a smartconnect. Address overlap between
    instances is checked at toolflow time.

    Limitations of this first implementation:
      * Zynq UltraScale+ block-design platforms only (the block finds the
        ``zynq_ultra_ps_e`` cell in the BD and claims HPM1_FPD for itself).
    """
    # Name of the shared crossbar cell added to the block design when
    # more than one instance exists
    xbar_name = 'axi4_bram_xbar'
    # Registry of (name, base_addr, range) over all instances, used to catch
    # address collisions at toolflow time rather than deep in the Vivado run
    _assigned_addrs = []
    # (name, axi_data_width) of the first instance; all instances share one
    # HPM port and crossbar, so they must agree
    _design_axi_width = None

    def initialize(self):
        if 'AXI4-Lite' not in self.platform.mmbus_architecture:
            self.throw_error('axi4_bram is only supported on AXI4-Lite (block '
                             'design) platforms')

        self.typecode = TYPECODE_BRAM
        # axil_clk / pl_sys_clk are provided by the platform / MPSoC blocks --
        # a proxy check that this design contains a block design with a PS
        self.requires = ['axil_clk', 'pl_sys_clk']

        self.addr_width = int(self.addr_width)
        self.data_width = int(self.data_width)
        if (self.data_width & (self.data_width - 1)) or not (8 <= self.data_width <= 1024):
            self.throw_error('axi4_bram data_width must be a power of 2 '
                             'between 8 and 1024 (got %s)' % self.data_width)

        # AXI-side width. 128 (the default) matches the PS hard block's
        # power-on fabric width for the HPM port; anything else only works if
        # the boot firmware is regenerated (or FPD_SLCR.AFI_FS poked) to
        # match -- see the class docstring
        self.axi_data_width = int(getattr(self, 'axi_data_width', 128))
        if self.axi_data_width not in (32, 64, 128):
            self.throw_error('axi4_bram axi_data_width must be 32, 64 or 128 '
                             '(got %s)' % self.axi_data_width)
        if type(self)._design_axi_width is None:
            type(self)._design_axi_width = (self.unique_name, self.axi_data_width)
        elif type(self)._design_axi_width[1] != self.axi_data_width:
            self.throw_error('axi4_bram %s axi_data_width=%d conflicts with '
                             '%s axi_data_width=%d: all instances share one '
                             'HPM port and must agree' % (
                                 self.unique_name, self.axi_data_width,
                                 type(self)._design_axi_width[0],
                                 type(self)._design_axi_width[1]))
        self.axi_lane_bytes = self.axi_data_width // 8
        # With byte-write enables the BMG only allows a 4:1 width ratio
        # between its ports (empirically: port A 128 limits port B to
        # 32..512), tighter than the 32:1 of plain asymmetric mode
        ratio = max(self.data_width, self.axi_data_width) // min(self.data_width, self.axi_data_width)
        if ratio > 4:
            self.throw_error('axi4_bram %s: data_width %d vs axi_data_width '
                             '%d exceeds the BMG 4:1 port asymmetry limit '
                             'that applies with byte-write enables'
                             % (self.unique_name, self.data_width, self.axi_data_width))

        # Memory primitive selection. Mask values are tolerant of common
        # spellings; anything unrecognised is an error, not a guess
        prim_str = str(getattr(self, 'ram_primitive', 'block')).strip().lower()
        if prim_str in ('block', 'blockram', 'bram'):
            self.ram_primitive = 'block'
        elif prim_str in ('ultra', 'ultraram', 'uram'):
            self.ram_primitive = 'ultra'
        else:
            self.throw_error('axi4_bram %s: ram_primitive must be "block" or '
                             '"ultra" (got %r)' % (self.unique_name, prim_str))
        # The 'ultra' plumbing below (BMG config, axil_clk port B, en tie) is
        # complete and BD-validated, but disabled: URAM is a single-clock
        # primitive, so the fabric port would have to run on axil_clk instead
        # of user_clk, which no current Simulink design does. Remove this
        # check when a design is ready to take that on.
        if self.ram_primitive == 'ultra':
            self.throw_error('axi4_bram %s: UltraRAM is not currently '
                             'supported. URAM is a single-clock primitive, so '
                             'the fabric port would be clocked by axil_clk '
                             'rather than user_clk; the implementation exists '
                             'as a placeholder but is disabled until a design '
                             'can accommodate that.' % self.unique_name)
        if self.ram_primitive == 'ultra' and self.data_width != self.axi_data_width:
            self.throw_error('axi4_bram %s: UltraRAM ports must be symmetric; '
                             'data_width (%d) must equal axi_data_width (%d)'
                             % (self.unique_name, self.data_width, self.axi_data_width))

        self.we_width = self.data_width // 8
        self.depth = 2**self.addr_width
        self.nbytes = self.depth * self.we_width
        if self.nbytes < 2 * self.axi_lane_bytes:
            self.throw_error('axi4_bram %s is too small (%d bytes)'
                             % (self.unique_name, self.nbytes))
        if self.nbytes > 2**28:
            self.throw_error('axi4_bram %s is too large (%d bytes)'
                             % (self.unique_name, self.nbytes))

        # Optional mask parameter; may arrive as an int or a hex string.
        # Instances without an explicit base_addr are staggered at 16MiB
        # intervals, which caps their size at 16MiB
        if hasattr(self, 'base_addr'):
            self.base_addr = int(str(self.base_addr), 0)
        else:
            if self.nbytes > 0x01000000:
                self.throw_error('axi4_bram %s: RAMs larger than 16MiB must '
                                 'set base_addr explicitly' % self.unique_name)
            self.base_addr = 0xB0000000 + self.inst_id * 0x01000000
        # Vivado address segments are a minimum of 4KiB and must be aligned
        # to their size
        self.assign_range = max(self.nbytes, 4096)
        if self.base_addr % self.assign_range != 0:
            self.throw_error('axi4_bram base_addr 0x%X is not aligned to the '
                             'RAM size (0x%X)' % (self.base_addr, self.assign_range))
        for other_name, other_base, other_range in self._assigned_addrs:
            if (self.base_addr < other_base + other_range and
                    other_base < self.base_addr + self.assign_range):
                self.throw_error('axi4_bram %s at 0x%X-0x%X overlaps %s at '
                                 '0x%X-0x%X' % (
                                     self.unique_name, self.base_addr,
                                     self.base_addr + self.assign_range - 1,
                                     other_name, other_base,
                                     other_base + other_range - 1))
        self._assigned_addrs.append(
            (self.unique_name, self.base_addr, self.assign_range))

        # Names used for the cells added to the block design and the exported
        # port B interface (which determines the BD wrapper's port names)
        self.ctrl_name = '%s_axi_ctrl' % self.unique_name
        self.ram_name = '%s_ram' % self.unique_name
        self.slice_name = '%s_addr_slice' % self.unique_name
        self.portb_name = '%s_portb' % self.unique_name

    def modify_top(self, top):
        # Software-facing entry: record this RAM as a "xilinx" AXI4-Lite
        # device. This lands in core_info.tab (and so the .fpg header) but
        # generates no HDL and is invisible to xml2vhdl / the CASPER AXI4-Lite
        # interconnect, whose inputs come from top.memory_map only.
        dev = top.add_xil_axi4lite_interface(regname=self.unique_name,
                                             mode='rw', nbytes=self.nbytes,
                                             typecode=self.typecode)
        dev.base_addr = self.base_addr

        # Fabric-side signals, named as the Simulink-compiled user module
        # expects (same convention as the standard bram block)
        top.add_signal('%s_addr' % self.fullname, width=self.addr_width)
        top.add_signal('%s_data_in' % self.fullname, width=self.data_width)
        top.add_signal('%s_data_out' % self.fullname, width=self.data_width)
        top.add_signal('%s_we' % self.fullname, width=1)

        # Hook up the exported BRAM port B on the block design instance.
        # A stand-alone-mode BMG port is word-addressed and, with byte-write
        # enables, has a data_width/8-bit write-enable bus.
        # BlockRAM: port B is dual-clock (user_clk) and "Always Enabled",
        # so there are no en/rst ports.
        # UltraRAM: the primitive is single-clock, so port B is clocked by
        # axil_clk (the same clock as the AXI side -- Simulink-side logic
        # must live in, or CDC into, that domain), and the BMG forces an
        # enable pin, tied high here.
        blkdesign = '{:s}_bd'.format(self.platform.conf['name'])
        bd_inst = top.get_instance(blkdesign, '{:s}_inst'.format(blkdesign))
        portb_clk = 'axil_clk' if self.ram_primitive == 'ultra' else 'user_clk'
        bd_inst.add_port('%s_addr' % self.portb_name, '%s_addr' % self.fullname, width=self.addr_width)
        bd_inst.add_port('%s_clk' % self.portb_name, portb_clk, parent_sig=False)
        bd_inst.add_port('%s_din' % self.portb_name, '%s_data_in' % self.fullname, width=self.data_width)
        bd_inst.add_port('%s_dout' % self.portb_name, '%s_data_out' % self.fullname, width=self.data_width)
        if self.ram_primitive == 'ultra':
            bd_inst.add_port('%s_en' % self.portb_name, "1'b1")
        if self.we_width == 1:
            bd_inst.add_port('%s_we' % self.portb_name, '%s_we' % self.fullname, width=1)
        else:
            bd_inst.add_port('%s_we' % self.portb_name, "{%d{%s_we}}" % (self.we_width, self.fullname))

    def gen_constraints(self):
        return []

    def gen_tcl_cmds(self):
        """
        All block design surgery happens here, in the pre_synth stage. This
        runs after the block design has been assembled (create_bd stage) and
        the MPSoC's presets applied, but before the backend's
        validate_bd_design / make_wrapper calls -- the same trick the rfdc and
        krm4zuxx blocks use. Doing this in modify_bd() instead would be
        order-fragile: this block appears in periph_objs before the MPSoC
        child block, so its build_bd commands would run before the PS exists.
        """
        reg_prim = bool(int(getattr(self, 'reg_prim_output', 0)))
        reg_core = bool(int(getattr(self, 'reg_core_output', 0)))
        prim = 'true' if reg_prim else 'false'
        core = 'true' if reg_core else 'false'
        # RAM read latency, on both ports: 1 + one cycle per output register
        read_latency = 1 + int(reg_prim) + int(reg_core)
        ps = '%s_ps' % self.unique_name  # tcl variable holding the PS cell
        # All instances have been constructed by the time this runs, so the
        # class instance counter gives the design-wide instance count
        n_inst = type(self)._count + 1

        # The controller's BRAM-side address bus is byte-addressed, with width
        # set by the assigned segment; the stand-alone BMG's port A is
        # word-addressed in units of the AXI-side width. An xlslice bridges
        # the two: addra = byte_addr[hi : log2(bytes-per-word)].
        # For RAMs smaller than the 4KiB minimum segment, the surplus upper
        # address bits are dropped (the RAM aliases within its segment).
        lane_bits = self.axi_lane_bytes.bit_length() - 1      # log2(bytes/word)
        ctrl_addr_width = self.assign_range.bit_length() - 1  # log2(range)
        slice_from = self.nbytes.bit_length() - 2             # log2(nbytes) - 1
        addra_width = slice_from - lane_bits + 1              # log2(port A depth)

        cmds = []
        cmds.append('# --- %s: burst-capable AXI4 RAM on MPSoC HPM1_FPD (%d of %d) ---'
                    % (self.unique_name, self.inst_id + 1, n_inst))
        cmds.append('set %s [get_bd_cells -filter {VLNV =~ "xilinx.com:ip:zynq_ultra_ps_e:*"}]' % ps)
        if self.i_am_the_first:
            # Shared infrastructure, emitted once. Instance tcl is emitted in
            # instance order, so this runs before any other instance's
            # commands.
            # Enable the second full-power-domain AXI HPM master and clock it
            # from the same PL clock as the rest of the CPU-facing
            # infrastructure. NB: the DATA_WIDTH here only reaches the PS
            # silicon via psu_init in a REGENERATED boot image; the hardware
            # default is 128-bit (see class docstring)
            cmds.append('set_property -dict [list CONFIG.PSU__USE__M_AXI_GP1 {1} CONFIG.PSU__MAXIGP1__DATA_WIDTH {%d}] $%s' % (self.axi_data_width, ps))
            cmds.append('connect_bd_net [get_bd_pins pl_sys_clk] [get_bd_pins ${%s}/maxihpm1_fpd_aclk]' % ps)
            if n_inst > 1:
                # Fan HPM1 out to one master port per instance. An
                # axi_crossbar (not a smartconnect) keeps the added latency
                # to a couple of cycles -- CPU reads are single-outstanding
                # round trips, so switch latency comes straight off the
                # throughput
                cmds.append('create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:* %s' % self.xbar_name)
                cmds.append('set_property -dict [list CONFIG.NUM_SI {1} CONFIG.NUM_MI {%d}] [get_bd_cells %s]' % (n_inst, self.xbar_name))
                cmds.append('connect_bd_net [get_bd_pins pl_sys_clk] [get_bd_pins %s/aclk]' % self.xbar_name)
                cmds.append('connect_bd_net [get_bd_pins axil_arst_n] [get_bd_pins %s/aresetn]' % self.xbar_name)
                cmds.append('connect_bd_intf_net [get_bd_intf_pins ${%s}/M_AXI_HPM1_FPD] [get_bd_intf_pins %s/S00_AXI]' % (ps, self.xbar_name))
        # AXI4 (burst-capable) BRAM controller, using only BRAM port A so
        # port B is free for the fabric. READ_LATENCY must match the RAM's
        # actual port A read latency (1 + output registers) or CPU reads
        # return stale data. RD_CMD_OPTIMIZATION pipelines back-to-back read
        # commands -- irrelevant for serialised CPU reads but it helps any
        # future DMA master. The core only supports it at READ_LATENCY=1
        # (the parameter is disabled and ignored at higher latencies), so
        # enabling the mask's output-register options forfeits it.
        rd_opt = ' CONFIG.RD_CMD_OPTIMIZATION {1}' if read_latency == 1 else ''
        cmds.append('create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:* %s' % self.ctrl_name)
        cmds.append('set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1} CONFIG.DATA_WIDTH {%d} CONFIG.READ_LATENCY {%d}%s] [get_bd_cells %s]' % (self.axi_data_width, read_latency, rd_opt, self.ctrl_name))
        if n_inst > 1:
            cmds.append('connect_bd_intf_net [get_bd_intf_pins %s/M%02d_AXI] [get_bd_intf_pins %s/S_AXI]' % (self.xbar_name, self.inst_id, self.ctrl_name))
        else:
            cmds.append('connect_bd_intf_net [get_bd_intf_pins ${%s}/M_AXI_HPM1_FPD] [get_bd_intf_pins %s/S_AXI]' % (ps, self.ctrl_name))
        cmds.append('connect_bd_net [get_bd_pins pl_sys_clk] [get_bd_pins %s/s_axi_aclk]' % self.ctrl_name)
        cmds.append('connect_bd_net [get_bd_pins axil_arst_n] [get_bd_pins %s/s_axi_aresetn]' % self.ctrl_name)
        # Assign the address before wiring the BRAM side, so the controller's
        # byte-address bus width has settled to log2(range)
        cmds.append('assign_bd_address -offset 0x%08X -range %d'
                    ' -target_address_space [get_bd_addr_spaces ${%s}/Data]'
                    ' [get_bd_addr_segs %s/S_AXI/Mem0] -force'
                    % (self.base_addr, self.assign_range, ps, self.ctrl_name))
        # The RAM itself: stand-alone mode (so port B width is free), byte
        # write enables (so port A's wea matches the controller's per-byte
        # strobes -- required for narrow CPU accesses on a wide port),
        # port B always enabled.
        # The mask's register settings apply identically to both ports, so
        # read latency everywhere = 1 + reg_prim_output + reg_core_output
        # (the standard shared bram convention on the fabric side, matched by
        # the controller's READ_LATENCY on the AXI side). Both ports' register
        # settings must always be set explicitly: reconfiguring the BMG
        # geometry silently flips the primitive registers on by default, and
        # any mismatch between real port A latency and the controller's
        # READ_LATENCY corrupts all CPU reads.
        if self.ram_primitive == 'ultra':
            # URAM is a single-clock primitive: the BMG forces
            # Assume_Synchronous_Clk and an ENB pin, and requires symmetric
            # ports (enforced in initialize()). Set what it forces
            # explicitly, so a future IP version that behaves differently
            # fails loudly instead of silently diverging.
            prim_cfg = (' CONFIG.PRIM_type_to_Implement {URAM}'
                        ' CONFIG.Assume_Synchronous_Clk {true}'
                        ' CONFIG.Enable_B {Use_ENB_Pin}')
        else:
            prim_cfg = (' CONFIG.PRIM_type_to_Implement {BRAM}'
                        ' CONFIG.Assume_Synchronous_Clk {false}'
                        ' CONFIG.Enable_B {Always_Enabled}')
        cmds.append('create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:* %s' % self.ram_name)
        cmds.append('set_property -dict [list'
                    ' CONFIG.Memory_Type {True_Dual_Port_RAM}'
                    ' CONFIG.use_bram_block {Stand_Alone}'
                    '%s'
                    ' CONFIG.Use_Byte_Write_Enable {true}'
                    ' CONFIG.Byte_Size {8}'
                    ' CONFIG.Write_Width_A {%d}'
                    ' CONFIG.Read_Width_A {%d}'
                    ' CONFIG.Write_Depth_A {%d}'
                    ' CONFIG.Write_Width_B {%d}'
                    ' CONFIG.Read_Width_B {%d}'
                    ' CONFIG.Enable_A {Use_ENA_Pin}'
                    ' CONFIG.Register_PortA_Output_of_Memory_Primitives {%s}'
                    ' CONFIG.Register_PortA_Output_of_Memory_Core {%s}'
                    ' CONFIG.Register_PortB_Output_of_Memory_Primitives {%s}'
                    ' CONFIG.Register_PortB_Output_of_Memory_Core {%s}'
                    '] [get_bd_cells %s]'
                    % (prim_cfg,
                       self.axi_data_width, self.axi_data_width,
                       self.nbytes // self.axi_lane_bytes,
                       self.data_width, self.data_width,
                       prim, core, prim, core, self.ram_name))
        cmds.append('create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:* %s' % self.slice_name)
        cmds.append('set_property -dict [list CONFIG.DIN_WIDTH {%d} CONFIG.DIN_FROM {%d} CONFIG.DIN_TO {%d} CONFIG.DOUT_WIDTH {%d}] [get_bd_cells %s]'
                    % (ctrl_addr_width, slice_from, lane_bits, addra_width, self.slice_name))
        # Wire the controller to the BMG pin-by-pin, overriding the BRAM_PORTA
        # interface grouping (Vivado warns BD 41-1306; this is expected). An
        # interface-level connection here would LSB-align the byte address
        # onto the word address and silently scramble the addressing.
        cmds.append('connect_bd_net [get_bd_pins %s/bram_addr_a] [get_bd_pins %s/Din]' % (self.ctrl_name, self.slice_name))
        cmds.append('connect_bd_net [get_bd_pins %s/Dout] [get_bd_pins %s/addra]' % (self.slice_name, self.ram_name))
        cmds.append('connect_bd_net [get_bd_pins %s/bram_wrdata_a] [get_bd_pins %s/dina]' % (self.ctrl_name, self.ram_name))
        cmds.append('connect_bd_net [get_bd_pins %s/douta] [get_bd_pins %s/bram_rddata_a]' % (self.ram_name, self.ctrl_name))
        cmds.append('connect_bd_net [get_bd_pins %s/bram_we_a] [get_bd_pins %s/wea]' % (self.ctrl_name, self.ram_name))
        cmds.append('connect_bd_net [get_bd_pins %s/bram_clk_a] [get_bd_pins %s/clka]' % (self.ctrl_name, self.ram_name))
        cmds.append('connect_bd_net [get_bd_pins %s/bram_en_a] [get_bd_pins %s/ena]' % (self.ctrl_name, self.ram_name))
        # Export the RAM's port B to the block design boundary, so it appears
        # as <portb_name>_addr/_clk/_din/_dout/_we ports on the BD wrapper,
        # which modify_top connects to the user design
        cmds.append('make_bd_intf_pins_external [get_bd_intf_pins %s/BRAM_PORTB]' % self.ram_name)
        cmds.append('set_property NAME %s [get_bd_intf_ports BRAM_PORTB_0]' % self.portb_name)

        return {'pre_synth': cmds}
