from .yellow_block import YellowBlock
from constraints import PortConstraint, ClockConstraint, ClockGroupConstraint, RawConstraint
from helpers import to_int_list
from os import environ
from os.path import join

"""
mult clk domain
  - modify the infrastructure in platform to provide clock

  - thought about adding an mmcm to the ospfb to have it deal with its clock domain crossing. The only concern
    I have hear is clock routing by having the maxis input of the rfdc being clocked by one and then the ospfb
    saxis clk being another. But perhaps the rfdc adc clks can help here

  - rfdc provides adc clk outs, could use those but they may not provide the right frequency and would need another mmcm

  - I had other casper cdc block ideas with a "hierarchy" idea, should be in a photo from my whiteboard

"""

class ospfb_fir(YellowBlock):

  def initialize(self):
    try:
      self.hdl_path = environ['OSPFB_REPO_PATH']
    except KeyError:
      raise RuntimeError('OSPFB_REPO_PATH environment variable not defined')

    def add_source(*args):
        self.add_source(join(self.hdl_path, 'hdl', *args))

    print(self.coeffs_path)

    self.add_source(join(self.constants_path, 'alpaca_constants_pkg.sv'))
    self.add_source(join(self.coeffs_path, 'alpaca_ospfb_hann_2048_8_coeff_pkg.sv'))
    add_source('pkgs', 'alpaca_dtypes_pkg.sv')
    add_source('srcs', 'interfaces.sv')
    add_source('srcs', 'sample_delay.sv')
    add_source('srcs', 'alpaca_phasecomp.sv')
    add_source('srcs', 'alpaca_butterfly.sv')
    add_source('srcs', 'alpaca_cx_multadd_convrnd.sv')
    add_source('srcs', 'alpaca_multadd_convrnd.sv')
    add_source('srcs', 'xpm_buffer.sv')
    add_source('srcs', 'xpm_pe.sv')
    add_source('srcs', 'xpm_ospfb_fir_only_datapath.sv')
    add_source('srcs', 'xpm_ospfb_fir_only.sv')


  def modify_top(self, top):
    inst = top.get_instance(entity="xpm_ospfb_fir_only_top", name=self.fullname+'_inst')

    # the `xpm_ospfb_top` has no parameters, but `xpm_ospfb` does. The parameters there are reliant on
    # the configuration that is the pkgs files, this may cause me trouble?

    inst.add_port('s_axis_aclk', 'user_clk')
    inst.add_port('m_axis_aclk', 'user_clk')
    inst.add_port('m_rst', 'ospfb_m_rst')

    inst.add_port('s_axis_tdata',  self.fullname + '_din', width=16*2*self.samples_per_clock)
    inst.add_port('s_axis_tvalid', self.fullname + '_din_vld')
    inst.add_port('s_axis_tlast',  self.fullname + '_din_sync')
    inst.add_port('s_axis_tready', self.fullname + '_din_ready')

    inst.add_port('m_axis_tdata',  self.fullname + '_dout', width=16*2*self.samples_per_clock)
    inst.add_port('m_axis_tvalid', self.fullname + '_dout_vld')
    inst.add_port('m_axis_tlast',  self.fullname + '_dout_sync')
    inst.add_port('m_axis_tready', self.fullname + '_dout_ready')

  def gen_tcl_cmds(self):
    tcl_cmds = {}

    # this command is unique in a yb sense because this is just a wrapper to an hdl definition but perhaps ultimately would live in the
    # project 'init' section when targeting custom hdl libraries
    tcl_cmds['pre_synth'] = []
    tcl_cmds['pre_synth'] += ['set_property XPM_LIBRARIES XPM_FIFO [current_project]']
    return tcl_cmds

