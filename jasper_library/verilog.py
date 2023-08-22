"""
Lots of code in this file could be shared between methods
and the VerilogInstance/Module classes. Maybe distill
at some point.
"""


import os
import re
from math import ceil, floor, log
import logging
import inspect
import operator
from memory import Register
import pdb
from yellow_blocks.yellow_block_typecodes import *

logger = logging.getLogger('jasper.verilog')

class ImmutableWithComments(object):
    """
    A class which you can add attributes to, but
    you can't change them once they're set. You are allowed
    to try and set them to the same value again.
    The ``comment`` attribute is special. Each time you
    try to set it, the comment string is appended to the
    existing comment attribute.
    """
    def __init__(self):
        self.name = 'default_name'
    def __setattr__(self, x, y):
        if not hasattr(self, x):
            object.__setattr__(self, x, y)
        elif self.__getattribute__(x) is None:
            object.__setattr__(self, x, y)
        elif x == 'comment':
            object.__setattr__(self, x, self.__getattribute__(x) + ' | ', + y)
        elif self.__getattribute__(x) == y:
            pass
        else:
            logger.error('Tried to change attribute %s of %s from %s to %s'%(x, self.name, self.__getattribute__(x), y))
            raise Exception('Tried to change attribute %s of %s from %s to %s'%(x, self.name, self.__getattribute__(x), y))

class WbDevice(object):
    """
    A class to encapsulate the parameters (name, size, etc.) of a wishbone slave device.
    """
    def __init__(self, regname, nbytes, mode, hdl_suffix='', hdl_candr_suffix='', memory_map=[], typecode=0xff, req_offset=-1, id=''):
        """
        Class constructor.

        :param regname: Name of register (this name is the string used to access the register from software)
        :type regname: str
        :param nbytes: Number of bytes in this slave's memory space.
        :type nbytes: int
        :param mode: Permissions ('r': readable, 'w': writable, 'rw': read/writeable)
        :type mode: str
        :param hdl_suffix: Suffix given to wishbone port names. Eg. if ``hdl_suffix = foo``, ports have the form ``wbs_dat_i_foo``
        :type hdl_suffix: str
        :param hdl_candr_suffix: Suffix given to wishbone clock and reset port names. Eg. if ``hdl_suffix = foo``, ports have the form ``wbs_clk_i_foo``
        :type hdl_candr_suffix: str
        :param memory_map: A list or ``Register`` instances defining the contents of sub-blocks of this device's memory.
        :type memory_map: list
        :param typecode: Typecode number (0-255) identifying the type of this block. See ``yellow_block_typecodes.py``
        :type typecode: int
        :param req_offset: Requsted offset (0-0xFFFFFFF) used to request a particular address on the memory map, please only use this if really requred``
        :type typecode: int or hex
        """
        self.typecode = typecode
        self.regname = regname
        self.nbytes = nbytes
        self.mode=mode
        #: Start (lowest) address of the memory space used by this device, in bytes.
        self.base_addr = None
        #: End (highest) address of the memory space used by this device, in bytes.
        self.high_addr = None
        self.hdl_suffix = hdl_suffix
        self.hdl_candr_suffix = hdl_candr_suffix
        self.memory_map = memory_map
        #: If using multiple bus arbiters, which arbiter should this slave attach to?
        self.sub_arb_id = 0
        self.req_offset = req_offset

# TODO: This class is the same as the Wishbone class? What's the point of it?
class AXI4LiteDevice(object):
    """
    A class to encapsulate the parameters (name, size, etc.) of a AXI4-Lite slave device.
    """
    def __init__(self, regname, nbytes, mode,
                hdl_suffix='', hdl_candr_suffix='',
                memory_map=[], typecode=0xff,
                data_width=32, axi4lite_mode=''):
        """
        Class constructor.

        :param regname: Name of register (this name is the string used to access the register from software).
        :type regname: String
        :param nbytes: Number of bytes in this slave's memory space.
        :type nbytes: Integer
        :param mode: Permissions ('r': readable, 'w': writable, 'rw': read/writeable).
        :type mode: String
        :param hdl_suffix: Suffix given to wishbone port names. Eg. if `hdl_suffix = foo`, ports have the form `wbs_dat_i_foo`.
        :type hdl_suffix: String
        :param hdl_candr_suffix: Suffix given to wishbone clock and reset port names. Eg. if `hdl_suffix = foo`, ports have the form `wbs_clk_i_foo`.
        :type hdl_candr_suffix: String
        :param memory_map: A list or `Register` instances defining the contents of sub-blocks of this device's memory.
        :type memory_map: list
        :param typecode: Typecode number (0-255) identifying the type of this block. See `yellow_block_typecodes.py`.
        :type typecode: Integer
        :param data_width: Width of the data to be stored in this device.
        :type data_width: Integer
        :param axi4lite_mode: Mode of the axi4lite interface. Eg. axi4lite_mode = 'raw', instantiates a raw axi4lite device.
        :type axi4lite_mode: String
        """
        self.typecode = typecode
        self.regname = regname
        self.nbytes = nbytes
        # Need this for variable-width BRAMs (in snapshot blocks)
        self.data_width = data_width

        self.mode = mode
        #: Start (lowest) address of the memory space used by this device, in bytes.
        self.base_addr = None
        #: End (highest) address of the memory space used by this device, in bytes.
        self.high_addr = None
        self.hdl_suffix = hdl_suffix
        self.hdl_candr_suffix = hdl_candr_suffix
        self.memory_map = memory_map
        self.axi4lite_mode = axi4lite_mode

class Port(ImmutableWithComments):
    """
    A simple class to hold port attributes. It is immutable, and will throw an error if
    multiple manipulation attempts are incompatible.
    """
    def __init__(self, name, signal=None, parent_port=False, parent_sig=True, width=0, **kwargs):
        """
        Create a ``Port`` instance.

        :param name: Name of the port
        :type port: str
        :param signal: Signal to which this port is attached
        :type signal: str
        :param parent_port: When module 'A' instantiates the module to which this port is attached, should this port be connected to a similar port on 'A'.
        :type parent_port: bool
        :param parent_sig: When module 'A' instantiates the module to which this port is attached, should 'A' also instantiate a signal matching the one connected to this port.
        :type parent_sig: bool
        :param width: Bitwidth of the port (0 for non-vector ports)
        :type width: bool
        :param kwargs: Other keywords which should become attributes of this instance.
        """
        self.update_attrs(name, signal=signal, parent_port=parent_port, parent_sig=parent_sig, width=width, **kwargs)

    def update_attrs(self, name, signal=None, parent_port=False, parent_sig=True, width=0, **kwargs):
        """
        Update the attributes of this block.

        :param name: Name of the port
        :type port: str
        :param signal: Signal to which this port is attached
        :type signal: str
        :param parent_port: When module 'A' instantiates the module to which this port is attached, should this port be connected to a similar port on 'A'.
        :type parent_port: bool
        :param parent_sig: When module 'A' instantiates the module to which this port is attached, should 'A' also instantiate a signal matching the one connected to this port.
        :type parent_sig: bool
        :param width: Bitwidth of the port (0 for non-vector ports)
        :type width: bool
        :param kwargs: Other keywords which should become attributes of this instance.
        """
        self.name = name.rstrip(' ')
        self.parent_sig = parent_sig and not parent_port
        self.parent_port = parent_port
        self.width = width
        if type(signal) is str:
            signal.rstrip(' ')
        self.signal = signal
        for kw, val in list(kwargs.items()):
            self.__setattr__(kw, val)

class Parameter(ImmutableWithComments):
    """
    A simple class to hold parameter attributes. It is immutable, and will throw an error if
    its attributes are changed after being set.
    """
    def __init__(self, name, value, comment=None):
        """
        Create a ``Parameter`` instance.

        :param name: Name of this parameter
        :type name: str
        :param value: Value this parameter should be set to.
        :type value: Varies
        :param comment: User-assisting comment string to attach to this parameter.
        :type comment: str
        """
        self.update_attrs(name, value=value, comment=comment)

    def update_attrs(self, name, value, comment=None):
        """
        Update the attributes of this block.

        :param name: Name of this parameter
        :type name: str
        :param value: Value this parameter should be set to.
        :type value: Varies
        :param comment: User-assisting comment string to attach to this parameter.
        :type comment: str
        """
        self.name = name.rstrip(' ')
        self.value = value
        if type(comment) is str:
            self.comment = comment.rstrip(' ')
        self.comment = comment

class Signal(ImmutableWithComments):
    """
    A simple class to hold signal attributes. It is immutable, and will throw an error if
    its attributes are changed after being set.
    """
    def __init__(self, name, signal='', width=0, **kwargs):
        """
        Create a 'Signal' instance.

        :param name: Name of this signal
        :type name: str
        :param signal: Name of this signal
        :type signal: str
        :param width: Bitwidth of this signal
        :type signal: int
        :param kwargs: Other keywords which should become attributes of this instance.
        """
        self.update_attrs(name, width=width, **kwargs)

    def update_attrs(self, name, width=0, **kwargs):
        self.name  = name.rstrip(' ')
        self.width = width
        for kw, val in list(kwargs.items()):
            self.__setattr__(kw, val)


def wrap_instance(wrapper_name, instance):
    wrapper = VerilogModule(wrapper_name)
    newinst = wrapper.get_instance(instance.name, instance.name + "_inst")
    instance.instantiate_child_ports()
    for categories, ports in instance.ports.items():
        for portname, port in ports.items():
            newinst.add_port(portname, signal=portname, dir=port.dir, width=port.width, parent_port=True)
    wrapper.instantiate_child_ports()
    return wrapper

def gen_wbs_master_arbiter(arbiters, max_devices_per_arb=32):
    """
    Deliver a string defining the top level of a 
    hierarchical Wishbone arbiter. This can be written to a file
    and then imported into an HDL project.
    Ideally (maybe) this instantiation would be made via a VerilogModule
    class.
    """

    # Count up the devices on all the arbiters
    n_devices = 0
    for arbiter in arbiters:
        n_devices += len(arbiter)
    n_sub_arbs = len(arbiters)

    #device_sizes =[slave_high[i]-slave_addr[i] for i in xrange(len(slave_addr))]
    #device_sizes = slave_addr - slave_high
    #total_addr_space = sum(device_sizes)

    ADDR = 0
    HIGH = 1

    wbs_parent_arbiter = '// AUTOMATICALLY GENERATED BY PYTHON\n\
    // Please do not commit this file into git \n\n\
    module wbs_master_arbiter #(\n\
        parameter N_SLAVES   = 7,\n\
        parameter N_SUB_ARBS = 4,\n\
        parameter SLAVE_ADDR   = 0,\n\
        parameter SLAVE_HIGH   = 0,\n\
        parameter TIMEOUT      = 10\n\
      ) (\n\
        input  wb_clk_i, wb_rst_i,\n\
    \n\
        input             wbm_cyc_i,\n\
        input             wbm_stb_i,\n\
        input             wbm_we_i,\n\
        input       [3:0] wbm_sel_i,\n\
        input      [31:0] wbm_adr_i,\n\
        input      [31:0] wbm_dat_i,\n\
        output     [31:0] wbm_dat_o,\n\
        output            wbm_ack_o,\n\
        output            wbm_err_o,\n\
    \n\
        output     [N_SLAVES - 1:0] wbs_cyc_o,\n\
        output     [N_SLAVES - 1:0] wbs_stb_o,\n\
        output                        wbs_we_o,\n\
        output                  [3:0] wbs_sel_o,\n\
        output  [N_SUB_ARBS*32-1:0] wbs_adr_o,\n\
        output                 [31:0] wbs_dat_o,\n\
        input   [N_SLAVES*32 - 1:0] wbs_dat_i,\n\
        input   [N_SLAVES    - 1:0] wbs_ack_i,\n\
        input   [N_SLAVES    - 1:0] wbs_err_i\n\
      );\n\
    \n'
   
    # ensure that the base address for each arbiter is actually the lowest address in the range
    # this is caused by the non-deterministic nature of lists in python. Meaning that the 1st
    # device on the arbiter is not garunteed to be the 1st in the address range supplied to that
    # arbiter.
    arbiter_base_addresses = [] 
    for i, arbiter in enumerate(arbiters):
        arbiter_base_addresses += [0xFFFFFFFF]
        for dev in arbiter:
            if dev.base_addr < arbiter_base_addresses[i]:
                arbiter_base_addresses[i] = dev.base_addr

    # add the SUBARB localparams
    for i in range(n_sub_arbs):
        wbs_parent_arbiter += '  localparam SUBARB_%s = %s;\n' %(i,i)
    
    # add a new line
    wbs_parent_arbiter += '\n'
    
    # add the N_SLAVES_ARB localparams
    for i in range(n_sub_arbs):
        if i != n_sub_arbs-1:
            wbs_parent_arbiter += '  localparam N_SLAVES_ARB%s = %s;\n' %(i,max_devices_per_arb)
        else:
            # last one has only the remaining devices, not the max amount of devices
            wbs_parent_arbiter += '  localparam N_SLAVES_ARB%s = %s;\n\n' %(i,max_devices_per_arb if n_devices%max_devices_per_arb == 0 else n_devices%max_devices_per_arb)
    
    # add the SLAVE_ADDR_ARB localparams for each arbiter
    for i, arbiter in enumerate(arbiters):
        wbs_parent_arbiter += '  localparam SLAVE_ADDR_ARB%s = { ' %i
        for j, device in enumerate(reversed(arbiter)):
            wbs_parent_arbiter += '32\'h%s - 32\'h%s,' %(str(hex(device.base_addr))[2:], str(hex(arbiter_base_addresses[i]))[2:])
            if j == len(arbiter)-1:
                wbs_parent_arbiter = wbs_parent_arbiter[:-1]
                wbs_parent_arbiter += '}; //%s\n' %(device.regname)
            else:
                wbs_parent_arbiter += '//%s\n' %(device.regname)
        wbs_parent_arbiter += '  localparam SLAVE_HIGH_ARB%s = { ' %i
        for j, device in enumerate(reversed(arbiter)):
            wbs_parent_arbiter += '32\'h%s - 32\'h%s,' %(str(hex(device.high_addr))[2:], str(hex(arbiter_base_addresses[i])[2:]))
            if j == len(arbiter)-1:
                wbs_parent_arbiter = wbs_parent_arbiter[:-1]
                wbs_parent_arbiter += '}; //%s\n' %(device.regname)
            else:
                wbs_parent_arbiter += '//%s\n' %(device.regname)
    
    # add the wires for the parent arbiter
    wbs_parent_arbiter +='\n  wire     [N_SUB_ARBS - 1:0] wb_cyc_o;\n\
      wire     [N_SUB_ARBS - 1:0] wb_stb_o;\n\
      wire                          wb_we_o;\n\
      wire                    [3:0] wb_sel_o;\n\
      wire                   [31:0] wb_adr_o;\n\
      wire                   [31:0] wb_dat_o;\n\
      wire  [N_SUB_ARBS*32 - 1:0] wb_dat_i;\n\
      wire  [N_SUB_ARBS    - 1:0] wb_ack_i;\n\
      wire  [N_SUB_ARBS    - 1:0] wb_err_i;\n'
    
    # add the wires for the sub arbiters
    # I have used format here rather than %s as I can insert the same string into multiple locations more easily
    for i, arbiter in enumerate(arbiters):
        wbs_parent_arbiter += '\n  wire     [N_SLAVES_ARB{0} - 1:0] wbs_cyc_o_arb{0};\n\
      wire     [N_SLAVES_ARB{0} - 1:0] wbs_stb_o_arb{0};\n\
      wire                             wbs_we_o_arb{0};\n\
      wire                       [3:0] wbs_sel_o_arb{0};\n\
      wire                      [31:0] wbs_adr_o_arb{0};\n\
      wire                      [31:0] wbs_dat_o_arb{0};\n\
      wire  [N_SLAVES_ARB{0}*32 - 1:0] wbs_dat_i_arb{0};\n\
      wire  [N_SLAVES_ARB{0}    - 1:0] wbs_ack_i_arb{0};\n\
      wire  [N_SLAVES_ARB{0}    - 1:0] wbs_err_i_arb{0};\n\n'.format(i)
    
    
    # add the output signal assign statements
    output_signals = ['wbs_cyc_o', 'wbs_stb_o', 'wbs_we_o', 'wbs_sel_o', 'wbs_adr_o', 'wbs_dat_o']
    for signal in output_signals:
        wbs_parent_arbiter += '  assign %s = {' %signal
        for i, arbiter in enumerate(arbiters):
            wbs_parent_arbiter += '%s_arb%s, ' %(signal, len(arbiters)-1-i)
        wbs_parent_arbiter = wbs_parent_arbiter[:-2]
        wbs_parent_arbiter += '};\n'
    
    # add the input signal assign statements
    input_signals = ['wbs_dat_i', 'wbs_ack_i', 'wbs_err_i']
    for signal in input_signals:
        wbs_parent_arbiter += '  assign {'
        for i, arbiter in enumerate(arbiters):
            wbs_parent_arbiter += '%s_arb%s, ' %(signal, len(arbiters)-1-i)
        wbs_parent_arbiter = wbs_parent_arbiter[:-2]
        wbs_parent_arbiter += '} = %s;\n' %(signal)
    
    
    # add the master wbs_arbiter
    wbs_parent_arbiter += '\n  wbs_arbiter #(\n\
        .N_SLAVES(N_SUB_ARBS),\n\
        .SLAVE_ADDR(SLAVE_ADDR),\n\
        .SLAVE_HIGH(SLAVE_HIGH),\n\
        .TIMEOUT(4096)\n\
      ) wbs_arbiter_primary (\n\
        .wb_clk_i(wb_clk_i),\n\
        .wb_rst_i(wb_rst_i),\n\
    \n\
        .wbm_ack_o(wbm_ack_o),\n\
        .wbm_adr_i(wbm_adr_i),\n\
        .wbm_cyc_i(wbm_cyc_i),\n\
        .wbm_dat_o(wbm_dat_o),\n\
        .wbm_we_i ( wbm_we_i),\n\
        .wbm_dat_i(wbm_dat_i),\n\
        .wbm_sel_i(wbm_sel_i),\n\
        .wbm_stb_i(wbm_stb_i),\n\
        .wbm_err_o(wbm_err_o),\n\
    \n\
        .wbs_cyc_o(wb_cyc_o),\n\
        .wbs_ack_i(wb_ack_i),\n\
        .wbs_err_i(wb_err_i),\n\
        .wbs_dat_i(wb_dat_i),\n\
        .wbs_stb_o(wb_stb_o),\n\
        .wbs_we_o ( wb_we_o),\n\
        .wbs_sel_o(wb_sel_o),\n\
        .wbs_dat_o(wb_dat_o),\n\
        .wbs_adr_o(wb_adr_o)\n\
      );\n'
    
    for i, arbiter in enumerate(arbiters):
        wbs_parent_arbiter += '\n  wbs_arbiter #(\n\
        .N_SLAVES(N_SLAVES_ARB{0}),\n\
        .SLAVE_ADDR(SLAVE_ADDR_ARB{0}),\n\
        .SLAVE_HIGH(SLAVE_HIGH_ARB{0}),\n\
        .TIMEOUT(4096)\n\
      ) wbs_arbiter_{0} (\n\
        .wb_clk_i(wb_clk_i),\n\
        .wb_rst_i(wb_rst_i),\n\
    \n\
        .wbm_we_i (wb_we_o),\n\
        .wbm_sel_i(wb_sel_o),\n\
        .wbm_ack_o(wb_ack_i[SUBARB_{0}]),\n\
        .wbm_err_o(wb_err_i[SUBARB_{0}]),\n\
        .wbm_stb_i(wb_stb_o[SUBARB_{0}]),\n\
        .wbm_cyc_i(wb_cyc_o[SUBARB_{0}]),\n\
        .wbm_dat_i(wb_dat_o),\n\
        .wbm_dat_o(wb_dat_i[(SUBARB_{0}+1)*32-1:(SUBARB_{0})*32]),\n\
        .wbm_adr_i(wb_adr_o),\n\
    \n\
        .wbs_adr_o(wbs_adr_o_arb{0}),\n\
        .wbs_cyc_o(wbs_cyc_o_arb{0}),\n\
        .wbs_ack_i(wbs_ack_i_arb{0}),\n\
        .wbs_err_i(wbs_err_i_arb{0}),\n\
        .wbs_dat_i(wbs_dat_i_arb{0}),\n\
        .wbs_stb_o(wbs_stb_o_arb{0}),\n\
        .wbs_we_o ( wbs_we_o_arb{0}),\n\
        .wbs_sel_o(wbs_sel_o_arb{0}),\n\
        .wbs_dat_o(wbs_dat_o_arb{0})\n\
      );\n\n'.format(i)
    
    wbs_parent_arbiter += 'endmodule'
    
    return wbs_parent_arbiter

def instantiate_wb_arb_module(module, n_slaves, n_sub_arbs=None):
    """
    Instantiate a Wishbone Arbiter into a module.

    :param module: Module into which the arbiter should be instantiated.
    :type module: VerilogModule instance
    :param n_slaves: Number of slaves this arbiter is connected to.
    :type n_slaves: int
    :param n_sub_arbs: Number of sub-arbiters beneath the arbiter being instantiated here.
                       If None, a non-hierarchical arbiter will be used.
    :type n_sub_arbs: int or None
    """
    if n_sub_arbs is not None:
        inst = module.get_instance('wbs_master_arbiter', 'wbs_arbiter_inst')
        inst.add_parameter('N_SUB_ARBS', 'N_SUB_ARBS')
    else:
        inst = module.get_instance('wbs_arbiter', 'wbs_arbiter_inst')
    inst.add_parameter('N_SLAVES', 'N_WB_SLAVES')
    inst.add_parameter('SLAVE_ADDR', 'SLAVE_ADDR')
    inst.add_parameter('SLAVE_HIGH', 'SLAVE_HIGH')
    inst.add_parameter('TIMEOUT', 1024)
    inst.add_port('wb_clk_i' , 'wb_clk_i' , width=0)
    inst.add_port('wb_rst_i ', 'wb_rst_i' , width=0)
    inst.add_port('wbm_cyc_i', 'wbm_cyc_o', width=0)
    inst.add_port('wbm_stb_i', 'wbm_stb_o', width=0)
    inst.add_port('wbm_we_i ', 'wbm_we_o' , width=0)
    inst.add_port('wbm_sel_i', 'wbm_sel_o', width=4)
    inst.add_port('wbm_adr_i', 'wbm_adr_o', width=32)
    inst.add_port('wbm_dat_i', 'wbm_dat_o', width=32)
    inst.add_port('wbm_dat_o', 'wbm_dat_i', width=32)
    inst.add_port('wbm_ack_o', 'wbm_ack_i', width=0)
    inst.add_port('wbm_err_o', 'wbm_err_i', width=0)
    inst.add_port('wbs_cyc_o', 'wbs_cyc_o', width=n_slaves)
    inst.add_port('wbs_stb_o', 'wbs_stb_o', width=n_slaves)
    inst.add_port('wbs_we_o ', 'wbs_we_o' , width=0)
    inst.add_port('wbs_sel_o', 'wbs_sel_o', width=4)
    inst.add_port('wbs_adr_o', 'wbs_adr_o', width=32*(n_sub_arbs or 1))
    inst.add_port('wbs_dat_o', 'wbs_dat_o', width=32)
    inst.add_port('wbs_dat_i', 'wbs_dat_i', width=32*n_slaves)
    inst.add_port('wbs_ack_i', 'wbs_ack_i', width=n_slaves)
    inst.add_port('wbs_err_i', 'wbs_err_i', width=n_slaves)
    # Don't optimize away wb_clk_i since it probably gets
    # used for timing constraints
    module.add_signal('wb_clk_i', attributes={'keep': '"true"'})


class VerilogModule(object):
    """
    A Python object which knows how to represent itself in Verilog.
    """
    def __init__(self, name='', topfile=None, comment=''):
        """
        Construct a new module, named ``name``.
        You can either start with an empty module
        and add ports/signals/instances to it,
        or you can specify an existing top-level file
        topfile, which will be modified.
        If doing the latter, the construction of
        wishbone interconnect demands that the
        topfile has a ``localparam N_WB_SLAVES``,
        which specifies the number of wishbone
        slaves in the un-modified topfile. And 
        ``SLAVE_BASE`` and ``SLAVE_HIGH`` localparams
        definiting the slave addresses.

        Eg:

        .. code-block:: verilog

            localparam N_WB_SLAVES = 2;

            localparam SLAVE_BASE = {
            32'h00010000, // slave_1
            32'h00000000  // slave_0
            };
        
            localparam SLAVE_HIGH = {
            32'h00010003, // slave_1
            32'hFFFFFFFF  // slave_0
            };

            // This module will only tolerate
            // i/o declarations like:
            
            module top (
                input sysclk_n,
                input sysclk_p,
                ...
                );

            // I.e, NOT

            module top(
                sysclk_n,
                sysclk_p,
                ...
                );
                input sysclk_n;
                input sysclk_p;
                ...

            // YMMV if your topfile doesn't use linebreaks as
            // shown above. I.e., for best chance of success don't do

            module top( sysclk_n,
            sysclk_p);

            localparam SLAVE_BASE = {32'h00000000};

        :param name: Name of this module
        :type name: str
        :param topfile: The filename of an existing verilog file, if any, to which this module should add.
        :type topfile: str or None
        :param comment: A user-friendly comment to be inserted in Verilog where this module is instantiated.
        :type comment: str
        """

        if len(name) != 0:
            self.name = name
        else:
            raise ValueError("'name' must be a string of non-zero length")
        
        self.topfile = topfile
        self.ports = {}         # top-level ports
        self.parameters = {}    # top-level parameters
        self.localparams = {}   # top-level localparams
        self.signals = {}       # top-level wires
        self.instances = {}     # top-level instances
        self.assignments = {}   # top-level assign statements
        self.raw_str = ''       # the verilog text describing this module
        self.comment = comment
        self.set_cur_blk(cur_blk='default')
        # wishbone stuff
        # number of wishbone slaves in the model. It will be overwritten
        # based on the N_WB_SLAVES localparam of a provided topfile,
        # and incremented when adding wishbone-enabled instances
        self.n_sub_arbs = 0     # sub arbiters added to this module programmatically
        self.n_wb_slaves = 0     # wb slaves added to this module programmatically
        self.wb_devices = []
        self.n_wb_interfaces = 0 # wishbone interfaces to this module
        self.wb_ids = []
        # Default to allowing as many devices on a WB arbiter as are necessary.
        # Change this to an integer to invoke a hierarchical arbiter
        self.max_devices_per_arb = None
        #self.wb_names = []
        #self.wb_bytes = []
        #self.wb_readable = []
        #self.wb_writable = []
        if self.topfile is not None:
            self.get_base_wb_slaves()
        else:
            self.base_wb_slaves = 0 #wb slaves in the topfile
        self.wb_base = []
        self.wb_high = []
        self.wb_name = []
        # AXI4-Lite stuff
        self.n_axi4lite_slaves = 0 # axi4lite slaves added to this module programmatically
        self.axi4lite_devices = []
        self.n_axi4lite_interfaces = 0 # axi4lite interfaces to this module
        self.memory_map = {}
        self.rfdc_devices = [] #this is for rfdc core on RFSOC, such as zcu111 platform
        self.n_rfdc_interfaces = 0
        # this is for xilinx axi4lite devices.
        # in some applications, we add some axi-spi or axi-gpio, which are not casper axi4lite devices
        self.xil_axi4lite_devices = []      
        self.n_xil_axi4lite_devices = 0
        # sourcefiles required by the module (this is currently NOT
        # how the jasper toolflow implements source management)
        self.sourcefiles = []
        # Gnerated submodules. A dictionary of module names and the verilog strings
        # which, if written to file, could be used to define them
        self.generated_sub_modules = {}

    def set_cur_blk(self, cur_blk):
        """
        Set the name of the block currently driving code generation. This is useful
        for grouping and commenting the ports / instances / signals associated with
        particular instances, so that the output Verilog is prettier.

        :param cur_blk: The name of the current block driving code generation.
        :type cur_blk: str
        """
        self.cur_blk = cur_blk
        if cur_blk not in list(sorted(self.ports.keys())):
            logger.debug('Initializing second-layer dictionairies for: %s'%cur_blk)
            self.ports[cur_blk] = {}
            self.parameters[cur_blk] = {}
            self.localparams[cur_blk] = {}
            self.signals[cur_blk] = {}
            self.instances[cur_blk] = {}
            self.assignments[cur_blk] = {}
    
    def has_instance(self, name):
        """
        Check if this module has an instance called <name>. If so return True
        """
        return name in list(sorted(self.instances.keys()))

    def wb_compute(self, base_addr=0x10000, alignment=4):
        """
        Compute the appropriate wishbone address limits,
        based on the current wishbone-using instances
        instantiated in the module.

        Will NOT take into account wishbone memory space
        used by the template verilog file (but see base_addr, below)

        :param base_addr: The address from which indexing of instance wishbone interfaces will begin. Any memory space required by the template verilog file should be below this address.
        :type base_addr: int
        :param alignment: Alignment required by all memory start addresses.
        :type alignment: int
        """
        # Now we have an instance name, we can assign the wb ports to
        # real signals

        #TODO: check that requested offsets dont overlap

        wb_device_num = 0
        wb_offset = base_addr

        # 1st iteration adds devices that have requested an offset
        for block in list(sorted(self.instances.keys())):
            for instname, inst in list(self.instances[block].items()):
                logger.debug("Looking for WB slaves for instance %s"%inst.name)
                # loop through devices and assign to sub_arbiters
                for n, wb_dev in enumerate(inst.wb_devices):
                    if wb_dev.req_offset != -1:
                        logger.debug("Assigning interface %d (%s)"%(n, wb_dev.regname))
                        if self.max_devices_per_arb is not None:
                            wb_dev.sub_arb_id = wb_device_num // self.max_devices_per_arb
                        wb_device_num += 1
                        inst.assign_wb_interface(instname, id=n, suffix=wb_dev.hdl_suffix, candr_suffix=wb_dev.hdl_candr_suffix, sub_arb_id=wb_dev.sub_arb_id)
    
                # loop through devices and assign requested offsets
                for n, wb_dev in enumerate(inst.wb_devices):
                    #print(hex(wb_dev.req_offset))
                    if wb_dev.req_offset != -1:
                        logger.debug("Found new WB slave for instance %s"%inst.name)
                        wb_dev.base_addr = wb_offset + wb_dev.req_offset
                        wb_dev.high_addr = wb_offset + wb_dev.req_offset + (alignment*int(ceil(wb_dev.nbytes/float(alignment)))) - 1
                        wb_dev.id = inst.wb_ids[n]
                        if wb_dev.high_addr > base_addr:
                            print(hex(base_addr))
                            print(hex(wb_dev.high_addr))
                            base_addr = wb_dev.high_addr + 1
                        self.n_wb_slaves += 1
                        self.wb_devices += [wb_dev]
                        print("Req offset: %s Base addr: %s High Addr: %s"%(hex(wb_dev.req_offset), hex(base_addr), hex(wb_dev.high_addr)))
        
        # 2nd iteration adds devices that have not requested an offset
        for block in list(sorted(self.instances.keys())):
            for instname, inst in list(self.instances[block].items()):
                logger.debug("Looking for WB slaves for instance %s"%inst.name)
                for n, wb_dev in enumerate(inst.wb_devices):
                    if wb_dev.req_offset == -1:
                        logger.debug("Assigning interface %d (%s)"%(n, wb_dev.regname))
                        if self.max_devices_per_arb is not None:
                            wb_dev.sub_arb_id = wb_device_num // self.max_devices_per_arb
                        wb_device_num += 1
                        inst.assign_wb_interface(instname, id=n, suffix=wb_dev.hdl_suffix, candr_suffix=wb_dev.hdl_candr_suffix, sub_arb_id=wb_dev.sub_arb_id)
    
                # loop through devices and assign non requested offsets
                for n, wb_dev in enumerate(inst.wb_devices):
                    #print(hex(wb_dev.req_offset))
                    if wb_dev.req_offset == -1:
                        logger.debug("Found new WB slave for instance %s"%inst.name)
                        wb_dev.base_addr = base_addr
                        wb_dev.high_addr = base_addr + (alignment*int(ceil(wb_dev.nbytes/float(alignment)))) - 1
                        wb_dev.id = inst.wb_ids[n]
                        base_addr = wb_dev.high_addr + 1
                        self.n_wb_slaves += 1
                        self.wb_devices += [wb_dev]

        # sort the wb_devices by descending order of addresses, otherwise the 
        # arbiter could get the addresses out of order and it doesnt like that.
        self.wb_devices = sorted(self.wb_devices, key = lambda i:i.base_addr)  
        
        # add the localparams wishbone IDs to top.v for each wb_device
        # this used to be done in the for loops above but since we are now sorting
        # the list before using them further we need to generate it after the sort
        for n, wb_dev in enumerate(self.wb_devices):
            self.add_localparam(name=wb_dev.id, value=n)

        # If we are starting a file from scratch, we need the wishbone parameters
        # otherwise we assume they are in the file and rewrite_module_file will
        # modify them.
        if self.topfile is None:
            self.add_localparam('N_WB_SLAVES', self.n_wb_slaves)
            # If we are using a hierarchical arbiter, cut up the WB devices into blocks
            # and instantiate the appropriate address ranges in a top level arbiter
            if self.max_devices_per_arb is not None:
                arbiters = [self.wb_devices[i:i+self.max_devices_per_arb] for i in range(0, len(self.wb_devices), self.max_devices_per_arb)]
                self.add_localparam('N_SUB_ARBS',  len(arbiters))
                base_addrs = '{\n'
                high_addrs = '{\n'
                for i, arbiter in enumerate(reversed(arbiters)):
                    if i < len(arbiters) - 1:
                        base_addrs += "    32'h%08x,\n"%(arbiter[0].base_addr)
                        high_addrs += "    32'h%08x,\n"%(arbiter[-1].high_addr)
                    else:
                        base_addrs += "    32'h%08x\n"%(arbiter[0].base_addr)
                        high_addrs += "    32'h%08x\n"%(arbiter[-1].high_addr)
                base_addrs += '    }'
                high_addrs += '    }'
                instantiate_wb_arb_module(self, self.n_wb_slaves, len(arbiters))
                self.generated_sub_modules['wbs_master_arbiter'] = gen_wbs_master_arbiter(arbiters, self.max_devices_per_arb)
            else:
                base_addrs = '{\n'
                high_addrs = '{\n'
                for sn, slave in enumerate(self.wb_devices[::-1]):
                    if sn < len(self.wb_devices) - 1:
                        base_addrs += "    32'h%08x, // %s\n"%(slave.base_addr, slave.regname)
                        high_addrs += "    32'h%08x, // %s\n"%(slave.high_addr, slave.regname)
                    else:
                        base_addrs += "    32'h%08x // %s\n"%(slave.base_addr, slave.regname)
                        high_addrs += "    32'h%08x // %s\n"%(slave.high_addr, slave.regname)
                base_addrs += '    }'
                high_addrs += '    }'
                instantiate_wb_arb_module(self, self.n_wb_slaves)
            self.add_localparam('SLAVE_ADDR', base_addrs)
            self.add_localparam('SLAVE_HIGH', high_addrs)

    def axi4lite_memory_map(self, base_addr=0x10000, alignment=4):
        """
        This function is only to be called by the 'top' verilog module after all other yellow blocks have called 'modify_top', but
        before the axi4lite_interconnect yellow block class has called 'modify_top' as that class requires the memory map this creates.

        :param base_addr: The address from which indexing of instance axi4lite interfaces will begin. Any memory space required by the template verilog file should be below this address.
        :type base_addr: int
        :param alignment: Alignment required by all memory start addresses.
        :type alignment: int

        memory map: 
        keys: name of AXI4-Lite interfaces.
        values: 
         - 'memory_map': internal memory map for this interface
         - 'size': size of internal memory map in bytes
         - 'absolute_address': actual address in memory determined by base_addr
         - 'relative_address': address relative to base_addr
         - 'axi4lite_devices': List of AXI4LiteDevice objects for core_info backwards compatibility
        """
        #TODO: WHOEVER WROTE THIS CODE -- WHAT IS IT SUPPOSED TO DO?
        # Need to get the register map in size order for xmltovhdl
        # For this use odict

        import odict

        # I'm just going to go ahead and guess. :-S

        # All software registers get ganged together in one self.memory_map entry,
        # called 'sw_reg'. These ultimately become a bunch of ports in the AXI interconnect
        # Each Bram gets its own memory_map entry, with a name matching the one provided
        # when the ram was instantiated via YellowBlock.add_axi4lite_interface.
        
        for dev in self.axi4lite_devices:
            # add all software registers to one memory mapped AXI4-Lite interface
            #FIXME Switching on the typecode and then on mode seems odd.
            # typecodes were never intended to be used for toolflow decision making.
            # Probably the swich should be if axi4lite_mode = reg|bram|raw
            if dev.typecode == TYPECODE_SWREG:
                # check to see if this is the first sw_reg in the memory_map dict
                if 'sw_reg' not in self.memory_map:
                    # Make new interface dict for software registers
                    self.memory_map['sw_reg'] = {}
                    interface = self.memory_map['sw_reg']
                    interface['size'] = dev.nbytes
                    interface['memory_map'] = dev.memory_map
                    # erase dev.memory_map so that core_info doesn't add sw_regs twice
                    # ?????
                    dev.memory_map = []
                    interface['axi4lite_devices'] = [dev]
                else:
                    # add another sw_reg to this interface dict
                    interface = self.memory_map['sw_reg']
                    # adjust offset of register
                    dev.memory_map[0].offset = interface['size']
                    # grow size of interface
                    interface['size'] += dev.nbytes
                    # append device memory_map
                    interface['memory_map'] += dev.memory_map
                    # # erase dev.memory_map so that core_info doesn't add sw_regs twice
                    dev.memory_map = []
                    interface['axi4lite_devices'] += [dev]
            elif dev.typecode == TYPECODE_BRAM:
                # tell the axi_ic to generate a bram
                self.memory_map[dev.regname] = {}
                interface = self.memory_map[dev.regname]
                interface['size'] = dev.nbytes # seems brams need to be sized in bytes not words
                interface['memory_map'] = dev.memory_map
                interface['axi4lite_devices'] = [dev]
                # erase dev.memory_map so that core_info doesn't add brams twice
                # only a mad man would attempt to debug this!
                # And here I am. Please document this code better.
                dev.memory_map = []
            elif dev.axi4lite_mode == 'raw':
                 # tell the axi_ic to generate a raw axi device
                self.memory_map[dev.regname] = {}
                interface = self.memory_map[dev.regname]
                interface['size'] = dev.nbytes 
                interface['memory_map'] = dev.memory_map
                interface['axi4lite_devices'] = [dev]
                # erase dev.memory_map so that core_info doesn't add raw axi device twice
                dev.memory_map = [] 
            else:
                # add all other yellow blocks to their own interface and make xml memory map
                self.memory_map[dev.regname] = {}
                interface = self.memory_map[dev.regname]
                interface['size'] = dev.nbytes
                interface['memory_map'] = dev.memory_map
                interface['axi4lite_devices'] = [dev]

        relative_address = 0
        # Now loop over interfaces in memory_map to determine addresses.
        # A limitation / feature of the xml2vhdl axi generation code is that it expects
        # all memory-mapped devices of size N-bytes to by aligned on N-byte boundaries.
        # Thus, we can't put a 4-byte register at address 0x0, and then a 1kiB bram at address 0x4.
        # Though not foolproof, we try and coerce an acceptable layout by placing the devices
        # in size order with the largest first. Hopefully all the devices are 2^n bytes in size --
        # this seems to be enforced by the xml2vhdl generator

        # First *we* round up the sizes so we agree with xml2vhdl
        for key in self.memory_map.keys():
            self.memory_map[key]['size'] = 2**int(ceil(log(self.memory_map[key]['size'], 2)))

        ordered_memory_map = odict.odict()
        # quick sort be damned. Go slow.
        while(len(self.memory_map) > 0):
            max_size = 0
            for key,val in list(self.memory_map.items()):
                if val['size'] > max_size:
                    max_size = val['size']
                    max_key = key
            ordered_memory_map[max_key] = self.memory_map.pop(max_key)

        # Now replace the memory map with the ordered one and continue
        self.memory_map = ordered_memory_map.copy()

        # Now loop over interfaces in memory_map to determine addresses
        for key,val in list(self.memory_map.items()):
            val['relative_address'] = hex(relative_address)
            # this is really gross, but didn't want to rewrite anything in core_info... Sorry.
            if key == 'sw_reg':
                # loop over registers and axi4lite_devices, assign correct dev.base_addr for core_info
                # There could be a better python one-liner to do this but idk...
                for reg in val['memory_map']:
                    for dev in val['axi4lite_devices']:
                        # if names match, set base_addr from interface's base_addr + core addr + register offset
                        if reg.name == dev.regname:
                            dev.base_addr = base_addr + relative_address + reg.offset
            else:
                # 'base_addr' for interface (for core_info to reference later)
                val['axi4lite_devices'][0].base_addr = base_addr + relative_address
            # adjust addresses for next loop
            relative_address = relative_address + (alignment*int(ceil(val['size']/float(alignment))))



    def get_base_wb_slaves(self):
        """
        Look for the pattern ``localparam N_WB_SLAVES``
        in this module's topfile, and use it to extract the
        number of wishbone slaves in the module.
        Update the base_wb_slaves attribute accordingly.
        Also extract the addresses. Names are auto-generated
        """
        fh = open('%s'%self.topfile, 'r')
        while(True):
            line = fh.readline()
            if len(line) == 0:
                break
            elif line.lstrip(' ').startswith('localparam N_WB_SLAVES'):
                logger.debug('Found N_WB_SLAVES declaration: %s'%line)
                declaration = line.split('//')[0]
                self.base_wb_slaves = int(re.search('\d+',declaration).group(0))
                logger.debug('base_wb_slaves is now %d'%self.base_wb_slaves)
                fh.close()
                return

        # if we get to here something has gone wrong
        fh.close()
        logger.error('No N_WB_SLAVES localparam found in topfile %s!'%self.topfile)
        raise Exception('No N_WB_SLAVES localparam found in topfile %s!'%self.topfile)

    def add_port(self, name, signal=None, parent_port=False, parent_sig=True, width=0, **kwargs):
        """
        Add a port to the module. Only the parameter ``name`` is compulsory. Others may be required when instantiating
        this module in another.
        
        E.g., an instance of this module needs all ports to have a defined ``signal`` value.

        However, if this module is at the top level, this isn't necessary. Similarly, a port featuring in an
        instantiated module need not have a width or direction specified, but if you want to instantiate the module
        and propagate the port to the parent, the parent won't know what to do unless these port parameters are specified.

        :param name: name of the port
        :param signal: name of the signal to connect port to. Can include bit indexing, e.g. ``my_signal[15:8]``
        :param dir: direction of signal
        :param width: width of signal
        :param parent_port: When instantiating this module, promote this port to a port of the parent
        :param parent_sig: When instantiating this module, add a signal named ``signal`` to the parent
        :param comment: Use this to add a comment string which will end up in the generated verilog
        """
        name = name.rstrip(' ')
        # Catch cases where we don't want to infer either a parent port or signal declaration
        if (signal == '') or (signal is None):
            # port is not connected
            parent_port = False
            parent_sig = False
        elif signal[0].isdigit():
            # port is connected to a constant
            parent_port = False
            parent_sig = False
        elif not signal[0].isalpha():
            # port is assigned to an expression of another signal.
            # e.g. "~sys_rst"
            # Could try and be clever and decode the signal. But let's not.
            parent_port = False
            parent_sig = False
            
        logger.debug('Attempting to add port "%s" (parent sig: %s, parent port: %s)'%(name,parent_sig,parent_port))
        # check every nested dictionary to see if name is in it
        key = self.search_dict_for_name(self.ports, name)
        if (key is None):
            logger.debug('  Port "%s" is new'%name)
            self.ports[self.cur_blk][name] = Port(name, signal=signal, parent_port=parent_port, parent_sig=parent_sig, width=width, **kwargs)
        else:
            logger.debug('  Port "%s" already exists'%name)
            self.ports[key][name].update_attrs(name, signal=signal, parent_port=parent_port, parent_sig=parent_sig, width=width, **kwargs)

    def add_parameter(self, name, value, comment=None):
        """
        Add a parameter to the entity, with name ``parameter`` and value
        ``value``.
        
        You may add a comment that will end up in the generated verilog.
        """
        # check every nested dictionary to see if name is in it
        key = self.search_dict_for_name(self.parameters, name)
        if (key is None):
            logger.debug('  Parameter "%s" is new'%name)
            self.parameters[self.cur_blk][name] = Parameter(name, value=value, comment=comment)
        else:
            logger.debug('  Parameter "%s" already exists'%name)
            self.parameters[key][name].update_attrs(name, value=value, comment=comment)

    def add_localparam(self, name, value, comment=None):
        """
        Add a parameter to the entity, with name ``parameter`` and value
        ``value``.
        
        You may add a comment that will end up in the generated verilog.
        """
        # check every nested dictionary to see if name is in it
        key = self.search_dict_for_name(self.localparams, name)
        if (key is None):
            logger.debug('  Local Parameter "%s" is new'%name)
            self.localparams[self.cur_blk][name] = Parameter(name, value=value, comment=comment)
        else:
            logger.debug('  Local Parameter "%s" already exists'%name)
            self.localparams[key][name].update_attrs(name, value=value, comment=comment)

    def add_signal(self, name, width=0, **kwargs):
        """
        Add an internal signal to the entity, with name ``signal``
        and width ``width``.

        You may add a comment that will end up in the generated verilog using the `comment` kwarg.
        You may add special compiler directives using the `attributes` kwarg.
          For example, `attributes={'keep':'"true"'}` will generate a wire with a (* keep = "true" *) prefix
        """
        name = name.rstrip(' ')
        # check every nested dictionary to see if name is in it
        key = self.search_dict_for_name(self.signals, name)
        if (key is None):
            logger.debug('  Signal "%s" is new'%name)
            self.signals[self.cur_blk][name] = Signal(name, width=width, **kwargs)
        else:
            logger.debug('  Signal "%s" already exists'%name)
            self.signals[key][name].update_attrs(name, width=width, **kwargs)

    def assign_signal(self, lhs, rhs, comment=None):
        """
        Assign one signal to another, or one signal to a port.

        i.e., generate lines of verilog like: ``assign lhs = rhs;``

        ``lhs`` and ``rhs`` are strings that can represent port or signal
        names, and may include verilog-style indexing, eg ``[15:8]``

        You may add a comment that will end up in the generated verilog.
        """
        self.assignments[self.cur_blk][lhs] = {'lhs':lhs, 'rhs':rhs, 'comment':comment}

    def get_instance(self, entity, name, comment=None):
        """
        Instantiate and return a new instance of entity ``entity``, with instance name ``name``.

        You may add a comment that will end up in the generated verilog.
        """
        new_inst = VerilogModule(name=entity, comment=comment)
        # check every nested dictionary to see if name is in it
        key = self.search_dict_for_name(self.instances, name)
        if (key is None):
            self.instances[self.cur_blk][name] = new_inst
            return new_inst
        else:
            return self.instances[key][name]

    def add_sourcefile(self,file):
        self.sourcefiles.append(file)

    def instantiate_child_ports(self):
        """
        Add ports and signals associated with child instances
        """
        for block in list(sorted(self.instances.keys())):
            self.set_cur_blk(block)
            for instname, inst in list(self.instances[block].items()):
                logger.debug('Instantiating child ports for %s'%instname)
                for blk in list(sorted(inst.ports.keys())):
                    for pname, port in list(inst.ports[blk].items()):
                        if port.parent_sig:
                            logger.debug('  Adding instance port %s as signal %s to top'%(port.name, port.signal))
                            if not hasattr(port, 'width'):
                                port.width = 0 #default to non-vector signal
                            self.add_signal(port.signal, width=port.width)
                        if port.parent_port:
                            logger.debug('  Adding instance port %s to top'%port.name)
                            if not hasattr(port, 'width'):
                                port.width = 0 #default to non-vector signal
                            self.add_port(port.signal, dir=port.dir, width=port.width)
                    self.sourcefiles += inst.sourcefiles

    def add_raw_string(self,s):
        self.raw_str += s

    def gen_module_file(self, filename=None):
        self.instantiate_child_ports()
        if self.topfile is None:
            return self.write_new_module_file(filename=filename)
        else:
            return self.rewrite_module_file(filename=filename)

    def rewrite_module_file(self, filename=None):
        """
        Rewrite the intially supplied verilog file to
        include instance, signals, ports, assignments and
        wishbone interfaces added programmatically.

        The initial verilog file is backed up with a '.base' extension.
        """
        os.system('cp %s %s.base'%(self.topfile,self.topfile))
        fh_base = open('%s.base'%self.topfile,'r')
        fh_new = open('%s'%(filename or self.topfile), 'w')
        fh_new.write('// %s, AUTOMATICALLY MODIFIED BY PYTHON\n\n'%self.topfile)
        while(True):
            line = fh_base.readline()
            if len(line) == 0:
                break
            elif line.lstrip(' ').startswith('module'):
                logger.debug('Found module declaration')
                fh_new.write(line)
                fh_new.write(self.gen_port_list())
                fh_new.write(',\n')
            elif line.lstrip(' ').startswith('localparam N_WB_SLAVES'):
                logger.debug('Found N_WB_SLAVES declaration: %s'%line)
                declaration = line.split('//')[0]
                s = re.sub('\d+','%s'%(self.n_wb_slaves+self.base_wb_slaves),declaration)
                logger.debug('Replacing declaration with: %s'%s)
                fh_new.write(s)
            elif line.lstrip(' ').startswith('localparam SLAVE_ADDR = {'):
                logger.debug('Found slave_addr dec %s'%line)
                fh_new.write(line)
                for slave in self.wb_devices[::-1]:
                    fh_new.write("    32'h%08x, // %s\n"%(slave.base_addr, slave.regname))
            elif line.lstrip(' ').startswith('localparam SLAVE_HIGH = {'):
                logger.debug('Found slave_high dec: %s'%line)
                fh_new.write(line)
                for slave in self.wb_devices[::-1]:
                    fh_new.write("    32'h%08x, // %s\n"%(slave.high_addr, slave.regname))
            elif line.lstrip(' ').startswith('endmodule'):
                fh_new.write(self.gen_top_mod())
                fh_new.write(line)
            else:
                fh_new.write(line)
        fh_new.close()
        fh_base.close()

    def write_new_module_file(self, filename=None):
        """
        Write a verilog file from scratch, based on the
        programmatic additions of instances / signals / etc.
        to the VerilogModule instance.

        The jasper toolflow has been using ``rewrite_module_file()``
        rather than this method, so it may or may not still
        work correctly. It used to, at least...
        """
        default_nettype = self.gen_default_nettype_str()
        mod_dec        = self.gen_mod_dec_str()
        # declare inputs/outputs with the module dec
        port_dec       = ''#self.gen_ports_dec_str()
        param_dec      = self.gen_params_dec_str()
        localparam_dec = self.gen_localparams_dec_str()
        sig_dec        = self.gen_signals_dec_str()
        inst_dec       = self.gen_instances_dec_str()
        assignments    = self.gen_assignments_str()
        endmod         = self.gen_endmod_str()
        s = ''
        s += '// MODULE %s, AUTOMATICALLY GENERATED BY PYTHON\n\n'%self.name
        if(self.comment is not None):
            s += '/*'
            s += self.comment
            s += '*/'
            s += '\n'
        s += default_nettype
        s += '\n'
        s += '\n'
        s += mod_dec
        s += '\n'
        s += port_dec
        s += '\n'
        s += param_dec
        s += '\n'
        s += localparam_dec
        s += self.gen_signals_ascii_art()
        s += sig_dec
        s += self.gen_instances_ascii_art()                                
        s += inst_dec
        s += self.gen_assignments_ascii_art()
        s += assignments
        s += '\n'
        s += self.raw_str
        s += '\n'
        s += endmod
        if filename is not None:
            with open(filename, 'w') as fh:
                fh.write(s)
        return s

    def gen_top_mod(self):
        """
        Return the code that needs to go in a top level verilog file
        to incorporate this module. 
        
        I.e., everything except the module port declaration headers and endmodule lines.

        TODO: This is almost identical to write_new_module_file(). Combine?
        """        
        # don't need this if we declare ports with the module declaration
        port_dec         = ''#self.gen_ports_dec_str()
        param_dec        = self.gen_params_dec_str()
        localparam_dec   = self.gen_localparams_dec_str()
        sig_dec          = self.gen_signals_dec_str()
        inst_dec         = self.gen_instances_dec_str()
        assignments      = self.gen_assignments_str()
        s = '// INSTANCE %s, AUTOMATICALLY GENERATED BY PYTHON\n'%self.name
        s += '\n'
        s += port_dec
        s += '\n'
        s += param_dec
        s += '\n'
        s += localparam_dec
        s += '\n'
        s += sig_dec
        s += '\n'
        s += inst_dec
        s += '\n'
        s += assignments
        s += '\n'
        s += self.raw_str
        return s
        
    def gen_mod_dec_str(self):
        """
        Generate the verilog code required to start a module
        declaration.
        """
        kwm = {'in':'input','out':'output','inout':'inout'}
        s = 'module %s (\n'%self.name
        s += self.gen_port_list()
        s += '  );\n'
        return s

    def gen_params_dec_str(self):
        """
        Generate the verilog code required to
        declare parameters
        """
        s = ''
        for block in list(sorted(self.parameters.keys())):
            s += self.gen_cur_blk_comment(block, self.parameters[block])
            for pn, parameter in sorted(self.parameters[block].items()):
                s += '  parameter %s = %s;'%(parameter.name,parameter.value)
                if parameter.comment is not None:
                    s += ' // %s'%parameter.comment
                s += '\n'
        return s

    def gen_localparams_dec_str(self):
        """
        Generate the verilog code required to
        declare localparams
        """
        s = ''
        for block in list(sorted(self.localparams.keys())):
            s += self.gen_cur_blk_comment(block, self.localparams[block])
            for pn,parameter in sorted(self.localparams[block].items()):
                s += '  localparam %s = %s;'%(parameter.name,parameter.value)
                if parameter.comment is not None:
                    s += ' // %s'%parameter.comment
                s += '\n'
        return s

    def gen_port_list(self):
        """
        Generate the verilog code required to
        declare ports
        """
        s = ''
        kwm = {'in':'input','out':'output','inout':'inout'}
        n_ports = 0
        i = 1
        # get total number of ports
        for block in list(sorted(self.ports.keys())):
            n_ports += len(list(self.ports[block].keys()))

        for block in list(sorted(self.ports.keys())):
            s += self.gen_cur_blk_comment(block, self.ports[block])
            # sort by port type then alphabetically
            for port in sorted(list(self.ports[block].values()), key=operator.attrgetter('dir', 'name')):
                logger.debug('Generating port %s'%port.name)
                if port.width == 0:
                    s += '    %s %s'%(kwm[port.dir],port.name)
                else:
                    s += '    %s [%d:0] %s'%(kwm[port.dir], (port.width-1), port.name)
                if i < n_ports:
                    s += ','
                if hasattr(port, 'comment'):
                    s += ' // %s'%port.comment
                s += '\n'
                i += 1
        logger.debug('i: %d n_ports: %d'%(i,n_ports))
        return s

    def gen_ports_dec_str(self):
        """
        Generate the verilog code required to
        declare ports with special attributes, eg LOCS, etc.
        """
        # keyword map
        kwm = {'in':'input','out':'output','inout':'inout'}
        s = ''
        for block in list(sorted(self.ports.keys())):
            s += self.gen_cur_blk_comment(block, self.ports[block])
            # sort port type then alphabetically
            for port in sorted(list(self.ports[block].values()), key=operator.attrgetter('dir', 'name')):
                # set up indentation nicely
                s += '  '
                # first write attributes
                if hasattr(port, 'attr'):
                    s += '(* '
                    n_keys = len(list(port.attr.keys()))
                    for kn,key in enumerate(port.attr.keys()):
                        if kn != (n_keys-1):
                            s += '%s = "%s",'%(key,port.attr[key])
                        else:
                            s += '%s = "%s"'%(key,port.attr[key])
                    s += ' *)'
                # declare port
                if port.width == 0:
                    s += '%s %s;'%(kwm[port.dir], port.name)
                else:
                    s += '%s [%d:0] %s;'%(kwm[port.dir], (port.width-1), port.name)
                if hasattr(port, 'comment'):
                    s += ' // %s'%port.comment
                s += '\n'
        return s
       
    def gen_signals_dec_str(self):
        """
        Generate the verilog code required to
        declare signals
        """
        s = ''
        for block in list(sorted(self.signals.keys())):
            s += self.gen_cur_blk_comment(block, self.signals[block])
            for name, sig in sorted(self.signals[block].items()):
                logger.debug('Writing verilog for signal %s'%name)
                if hasattr(sig, 'attributes'):
                    s += '  '
                    for k, v in sig.attributes.items():
                        s += '(* %s = %s *) ' % (k, v)
                else:
                    s += '  '
                if sig.width == 0:
                    s += 'wire %s;'%(name)
                else:
                    s += 'wire [%d:0] %s;'%((sig.width-1), name)
                if hasattr(sig, 'comment'):
                    s += ' // %s'%sig.comment
                s += '\n'
        return s

    def gen_instances_dec_str(self):
        """
        Generate the verilog code required
        to instantiate the instances in this 
        module
        """
        s = ''
        for block in list(sorted(self.instances.keys())):
            n = 0
            n_inst = len(self.instances[block])
            s += self.gen_cur_blk_comment(block, self.instances[block])
            for instname, instance in sorted(self.instances[block].items()):
                s += instance.gen_instance_verilog(instname)
                if n != (n_inst - 1):
                    s += '\n'
                n += 1
        return s
    
    def gen_assignments_str(self):
        """
        Generate the verilog code required
        to assign a port or signal to another
        signal
        """
        s = ''
        for block in list(sorted(self.assignments.keys())):
            s += self.gen_cur_blk_comment(block, self.assignments[block])
            for n,assignment in sorted(self.assignments[block].items()):
                s += '  assign %s = %s;'%(assignment['lhs'], assignment['rhs'])
                if hasattr(assignment, 'comment'):
                    s += ' // %s'%assignment['comment']
                s += '\n'
        return s

    def gen_endmod_str(self):
        return 'endmodule'

    def gen_default_nettype_str(self):
        return "`default_nettype wire\n"

    def gen_instance_verilog(self, instname):
        """
        Generate a string corresponding to the instantiation of this instance,
        with instance name ``instname``
        """
        s = ''
        if self.comment is not None:
            s += '  // %s\n'%self.comment
        for block in list(sorted(self.parameters.keys())):
            n_params = len(self.parameters[block])
            if n_params > 0:
                s += '  %s #(\n' %self.name
                n = 0
                for paramname, parameter in sorted(self.parameters[block].items()):
                    s += '    .%s(%s)'%(parameter.name, parameter.value)
                    if n != (n_params - 1):
                        s += ',\n'
                    else:
                        s += '\n'
                    n += 1
                s += '  ) %s (\n'%instname
            else:
                s += '  %s  %s (\n'%(self.name, instname)
        for block in list(sorted(self.ports.keys())):
            n_ports = len(self.ports[block])
            n = 0

            for pn, port in sorted(self.ports[block].items()):
                try:
                    s += '    .%s(%s)'%(port.name, port.signal.rstrip(' '))
                except:
                    logger.error("Could't instantiate port %s connected to signal %s" % (port.name, port.signal))
                if n != (n_ports - 1):
                    s += ',\n'
                else:
                    s += '\n'
                n += 1
        s += '  );\n\n'
        return s

    def add_wb_interface(self, regname, mode, nbytes=4, suffix='', candr_suffix='', memory_map=[], typecode=0xff, req_offset=-1):
        """
        Add the ports necessary for a wishbone slave interface.
        Wishbone ports that depend on the slave index are identified by a parameter
        that matches the instance name. This parameter must be given a value in a higher level
        of the verilog code!

        This function returns the WbDevice object, so the caller can mess with it's memory map
        if they so desire.
        """
        if regname in [wb_dev.regname for wb_dev in self.wb_devices]:
            return
        else:
            wb_device = WbDevice(regname, nbytes=nbytes, mode=mode, hdl_suffix=suffix, hdl_candr_suffix=candr_suffix, memory_map=memory_map, typecode=typecode, req_offset=req_offset)
            self.wb_devices += [wb_device]
            self.n_wb_interfaces += 1
            self.sub_arb_id = 0
            self.add_port('wb_clk_i'+candr_suffix, parent_sig=False)
            self.add_port('wb_rst_i'+candr_suffix, parent_sig=False)
            self.add_port('wb_cyc_i'+suffix, parent_sig=False)
            self.add_port('wb_stb_i'+suffix, parent_sig=False)
            self.add_port('wb_we_i' +suffix, parent_sig=False)
            self.add_port('wb_sel_i'+suffix, width=4, parent_sig=False)
            self.add_port('wb_adr_i'+suffix, width=32, parent_sig=False)
            self.add_port('wb_dat_i'+suffix, width=32, parent_sig=False)
            self.add_port('wb_dat_o'+suffix, width=32, parent_sig=False)
            self.add_port('wb_ack_o'+suffix, parent_sig=False)
            self.add_port('wb_err_o'+suffix, parent_sig=False)
            return wb_device

    def assign_wb_interface(self,name,id=0,suffix='',candr_suffix='', sub_arb_id=0):
        """
        Add the ports necessary for a wishbone slave interface.
        Wishbone ports that depend on the slave index are identified by a parameter
        that matches the instance name. This parameter must be given a value in a higher level
        of the verilog code!
        """
        wb_id = name.upper() + '_WBID%d'%(id)
        #self.wb_names += [self.name]
        self.wb_ids += [wb_id]
        self.add_port('wb_clk_i'+candr_suffix, signal='wb_clk_i', parent_sig=False)
        self.add_port('wb_rst_i'+candr_suffix, signal='wb_rst_i', parent_sig=False)
        self.add_port('wb_cyc_i'+suffix, signal='wbs_cyc_o[%s]'%wb_id, parent_sig=False)
        self.add_port('wb_stb_i'+suffix, signal='wbs_stb_o[%s]'%wb_id, parent_sig=False)
        self.add_port('wb_we_i'+suffix,  signal='wbs_we_o', parent_sig=False)
        self.add_port('wb_sel_i'+suffix, signal='wbs_sel_o', width=4, parent_sig=False)
        self.add_port('wb_adr_i'+suffix, signal='wbs_adr_o[(%s+1)*32-1:(%s)*32]'%(sub_arb_id,sub_arb_id), width=32, parent_sig=False)
        self.add_port('wb_dat_i'+suffix, signal='wbs_dat_o', width=32, parent_sig=False)
        self.add_port('wb_dat_o'+suffix, signal='wbs_dat_i[(%s+1)*32-1:(%s)*32]'%(wb_id,wb_id), width=32, parent_sig=False)
        self.add_port('wb_ack_o'+suffix, signal='wbs_ack_i[%s]'%wb_id,parent_sig=False)
        self.add_port('wb_err_o'+suffix, signal='wbs_err_i[%s]'%wb_id,parent_sig=False)

    def add_axi4lite_interface(self, regname, mode, nbytes=4,
                               default_val=0, suffix='',
                               candr_suffix='', memory_map=[],
                               typecode=0xff, data_width=32, axi4lite_mode=''):
        """
        Add the ports necessary for a AXI4-Lite slave interface.

        This function returns the AXI4LiteDevice object, so the caller can mess with it's memory map
        if they so desire.

        Added the (optional) data_width parameter to make provision for variable-size BRAMs.
        Added the (optional) axi4lite_mode parameter. Eg. axi4lite_mode = 'raw' instantiates a raw axi4lite device.
              

        :param regname: Name of register (this name is the string used to access the register from software).
        :type regname: String
        :param nbytes: Number of bytes in this slave's memory space.
        :type nbytes: Integer
        :param mode: Permissions ('r': readable, 'w': writable, 'rw': read/writeable).
        :type mode: String
        :param suffix: Suffix given to port names.
        :type suffix: String
        :param candr_suffix: Suffix given to clock and reset port names.
        :type candr_suffix: String
        :param memory_map: A list or `Register` instances defining the contents of sub-blocks of this device's memory.
        :type memory_map: list
        :param typecode: Typecode number (0-255) identifying the type of this block. See `yellow_block_typecodes.py`.
        :type typecode: Integer
        :param data_width: Width of the data to be stored in this device.
        :type data_width: Integer
        :param axi4lite_mode: Mode of the axi4lite interface. Eg. axi4lite_mode = 'raw', instantiates a raw axi4lite device.
        :type axi4lite_mode: String

        """

        if regname in [axi_dev.regname for axi_dev in self.axi4lite_devices]:
            return
        else:
            # Make single register in memory_map if memory_map is empty
            if not memory_map:
                memory_map = [Register(regname, nbytes=nbytes, offset=0, mode=mode,
                                        default_val=default_val, data_width=data_width, axi4lite_mode=axi4lite_mode,
                                        ram_size=nbytes if typecode==4 else -1,
                                        ram=True if typecode==4 else False)]
            axi4lite_device = AXI4LiteDevice(regname, nbytes=nbytes, mode=mode,
                                            hdl_suffix=suffix, hdl_candr_suffix=candr_suffix,
                                            memory_map=memory_map, typecode=typecode,
                                            data_width=data_width, axi4lite_mode=axi4lite_mode)
            self.axi4lite_devices += [axi4lite_device]
            self.n_axi4lite_interfaces += 1
            return axi4lite_device

    def add_axi_interface(self, regname, mode, nbytes=4,
                               default_val=0, suffix='',
                               candr_suffix='', memory_map=[],
                               typecode=0xff, data_width=32, axi4lite_mode=''):

        if axi4lite_mode == 'raw':
                 # axi4l miso signals
           self.add_port('s_axi4lite_awready', signal='m_axi4lite_%s_awready' %regname, width=1, dir='out')
           self.add_port('s_axi4lite_wready', signal='m_axi4lite_%s_wready' %regname, width=1, dir='out')
           self.add_port('s_axi4lite_bresp',  signal='m_axi4lite_%s_bresp' %regname,  width=2, dir='out')
           self.add_port('s_axi4lite_bvalid', signal='m_axi4lite_%s_bvalid'%regname, width=1, dir='out')
           self.add_port('s_axi4lite_arready', signal='m_axi4lite_%s_arready'%regname, width=1, dir='out')
           self.add_port('s_axi4lite_rresp',  signal='m_axi4lite_%s_rresp' %regname,  width=2, dir='out')
           self.add_port('s_axi4lite_rdata',  signal='m_axi4lite_%s_rdata' %regname, width=32, dir='out')
           self.add_port('s_axi4lite_rvalid', signal='m_axi4lite_%s_rvalid' %regname, width=1, dir='out')
                # axi4l mosi signals
           self.add_port('s_axi4lite_awaddr', signal='m_axi4lite_%s_awaddr' %regname, width=32, dir='out')
           self.add_port('s_axi4lite_awvalid', signal='m_axi4lite_%s_awvalid' %regname, width=1, dir='out')
           self.add_port('s_axi4lite_wdata',  signal='m_axi4lite_%s_wdata' %regname, width=32, dir='out')
           self.add_port('s_axi4lite_wvalid', signal='m_axi4lite_%s_wvalid' %regname, width=1, dir='out')
           self.add_port('s_axi4lite_wstrb',  signal='m_axi4lite_%s_wstrb' %regname, width=4, dir='out')
           self.add_port('s_axi4lite_araddr', signal='m_axi4lite_%s_araddr' %regname, width=32, dir='out')
           self.add_port('s_axi4lite_arvalid', signal='m_axi4lite_%s_arvalid' %regname, width=1, dir='out')
           self.add_port('s_axi4lite_rready', signal='m_axi4lite_%s_rready' %regname, width=1, dir='out')
           self.add_port('s_axi4lite_bready', signal='m_axi4lite_%s_bready' %regname, width=1, dir='out')

    def add_rfdc_interface(self, regname, mode, nbytes=4, default_val=0, suffix='', candr_suffix='', memory_map=[], typecode=0xff):
        """
        Add the ports necessary for rfdc core, which is a special AXILite4 device

        This function returns the AXI4LiteDevice object, so the caller can mess with it's memory map
        if they so desire.
        """
        if regname in [axi_dev.regname for axi_dev in self.rfdc_devices]:
            return
        else:
            # Make single register in memory_map if memory_map is empty
            if not memory_map:
                memory_map = [Register(regname, nbytes=nbytes, offset=0, mode=mode, default_val=default_val, ram_size=nbytes if typecode==4 else -1, ram=True if typecode==4 else False)]
            rfdc_device = AXI4LiteDevice(regname, nbytes=nbytes, mode=mode, hdl_suffix=suffix, hdl_candr_suffix=candr_suffix, memory_map=memory_map, typecode=typecode)
            self.rfdc_devices += [rfdc_device]
            self.n_rfdc_interfaces += 1
            return rfdc_device

    def add_xil_axi4lite_interface(self, regname, mode, nbytes=4, default_val=0, suffix='', candr_suffix='', memory_map=[], typecode=0xff):
        """
        Add the ports necessary for xilinx axi4lite cores, which are not casper AXILite4 devices

        This function returns the AXI4LiteDevice object, so the caller can mess with it's memory map
        if they so desire.
        """
        if regname in [axi_dev.regname for axi_dev in self.xil_axi4lite_devices]:
            return
        else:
            # Make single register in memory_map if memory_map is empty
            #if not memory_map:
            #    memory_map = [Register(regname, nbytes=nbytes, offset=0, mode=mode, default_val=default_val, ram_size=nbytes if typecode==4 else -1, ram=True if typecode==4 else False)]
            xil_axi4lite_device = AXI4LiteDevice(regname, nbytes=nbytes, mode=mode, hdl_suffix=suffix, hdl_candr_suffix=candr_suffix, memory_map=memory_map, typecode=typecode)
            self.xil_axi4lite_devices += [xil_axi4lite_device]
            self.n_xil_axi4lite_devices += 1
            return xil_axi4lite_device
            
    def search_dict_for_name(self, dict, name):
        """
        This helper function searches each top level dictionary
        to see if it contains ``name`` and returns the key that does.
        """
        for top_dict_key, top_dict_value in list(dict.items()):
            # does the second level dict keys contain name?
            if name in list(sorted(top_dict_value.keys())):
                return top_dict_key
        # return key as None if not in any dictionary
        return None

    def gen_cur_blk_comment(self, cur_blk, dict):
        """
        This helper function returns the current block string,
        if the dictionary is not empty and the current block 
        is not ``default``.
        """
        # is the dictionary empty?
        if dict and cur_blk != 'default':
            return '  // %s\n'%cur_blk
        else:
            return ''

    def gen_signals_ascii_art(self):
        """
        :return: Pretty ascii art "Signals" string.
        """
        s = ""
        s += "\n/*\n"
        s += "  _____ _                   _     \n"
        s += " / ____(_)                 | |    \n"
        s += "| (___  _  __ _ _ __   __ _| |___ \n"
        s += " \___ \| |/ _` | '_ \ / _` | / __|\n"
        s += " ____) | | (_| | | | | (_| | \__ \ \n"
        s += "|_____/|_|\__, |_| |_|\__,_|_|___/\n"
        s += "          __/ |                  \n"
        s += "         |___/                   \n"
        s += "*/\n"
        return s

    def gen_instances_ascii_art(self):
        """
        :return: Pretty ascii art "Instances" string.
        """
        s = ""
        s += "\n/*\n"
        s += "  _____           _                            \n"
        s += " |_   _|         | |                           \n"
        s += "   | |  _ __  ___| |_ __ _ _ __   ___ ___  ___ \n"
        s += "   | | | '_ \/ __| __/ _` | '_ \ / __/ _ \/ __|\n"
        s += "  _| |_| | | \__ \ || (_| | | | | (_|  __/\__ \ \n"
        s += " |_____|_| |_|___/\__\__,_|_| |_|\___\___||___/\n"
        s += "*/\n"     
        return s

    def gen_assignments_ascii_art(self):
        """
        :return: Pretty ascii art "Assignments" string.
        """
        s = ""
        s += "\n/*\n"
        s += "                   _                                  _       \n"
        s += "     /\           (_)                                | |      \n"
        s += "    /  \   ___ ___ _  __ _ _ __  _ __ ___   ___ _ __ | |_ ___ \n"
        s += "   / /\ \ / __/ __| |/ _` | '_ \| '_ ` _ \ / _ \ '_ \| __/ __|\n"
        s += "  / ____ \\\\__ \__ \ | (_| | | | | | | | | |  __/ | | | |_\__ \ \n"
        s += " /_/    \_\___/___/_|\__, |_| |_|_| |_| |_|\___|_| |_|\__|___/\n"
        s += "                      __/ |                                   \n"
        s += "                     |___/                                    \n"
        s += "*/\n"
        return s
