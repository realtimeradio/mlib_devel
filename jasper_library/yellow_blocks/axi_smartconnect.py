import os
import re
from six import iteritems
from os import path, environ as env

from .yellow_block import YellowBlock

AXI_OUTPUT_PIN_NAME = 'M_AXI'
WB_ADDR_WIDTH = 32
AXI_ADDR_WIDTH = 40

class axi_smartconnect(YellowBlock):
  attr_map = {
    'num_mi'      : {'param': 'NUM_MI',     'fmt': "{{:d}}", 'default': 1},
    'num_si'      : {'param': 'NUM_SI',     'fmt': "{{:d}}", 'default': 1},
    'num_clk'     : {'param': 'NUM_CLKS',   'fmt': "{{:d}}", 'default': 1},
    'has_rst'     : {'param': 'HAS_ARESETN','fmt': "{{:d}}", 'default': 0},
  }

  class axi_interface(object):
    def __init__(self, mode, interface_idx=None, dest=None, protocol=None):
      self.protocol = protocol
      self.mode = mode
      self.idx = interface_idx
      self.dest = dest

      self.clk_src = 'pl_sys_clk'
      self.rst_src = 'axil_arst_n'
      self.clk_net_name = 'aclk'
      self.rst_net_name = 'aresetn'
      self.port_net_name = 'S00_AXI'

  def initialize(self):
    self.ips = []
    # deserialize block from its parameter attribute map
    for attr, _ in iteritems(self.attr_map):
      try:
        v = self.blk[attr]
      except KeyError:
        if not hasattr(self, attr):
          try:
            v = self.attr_map[attr]['default']
          except KeyError:
            self.throw_error(f'No attribute or default provided for {attr}')
      setattr(self, attr, v)

    self.num_mi = len(self.maxi_intfs)
    if self.num_si != 1:
        raise NotImplementedError('Only num_mi=1 is supported!')

    self.saxi = self.axi_interface('Slave', 0, dest=self.saxi_intf['dest'])

    self.maxis = []
    use_wb = False
    for mi, maxi in enumerate(self.maxi_intfs):
        self.maxis += [self.axi_interface('Master', mi, dest=maxi['dest'], protocol=maxi['protocol'])]
        if maxi['protocol'] == 'wishbone':
            use_wb = True

    if use_wb:
      self.ips += [{'path':'%s/axi_wb_bridge/ip_repo' % env['HDL_ROOT'],
           'name':'axi_slave_wishbone_classic_master',
           'vendor':'peralex.com',
           'library':'user',
           'version':'1.0',
          }]

    # provides
    for maxi in self.maxis:
        self.provides.append(maxi.dest)

    # requires
    self.requires.append(self.saxi.clk_src)
    self.requires.append(self.saxi.rst_src)
    self.requires.append(self.saxi.dest)

  def modify_top(self, top):
    blkdesign = '{:s}_bd'.format(self.platform.conf['name'])
    bd_inst = top.get_instance(blkdesign, '{:s}_inst'.format(blkdesign))

    # if the path for the connection is not in the current block design a port
    # must be made and the top module must expose it
    for mi, maxi in enumerate(self.maxis):
      if len(maxi.dest.split('/')) == 1:
        top_intf_prefix = maxi.dest.lower()
        bd_intf_prefix = maxi.dest
        if maxi.protocol != 'wishbone':
          bd_inst.add_port('{:s}_awaddr'.format(top_intf_prefix), '{:s}_awaddr'.format(bd_intf_prefix),  width=AXI_ADDR_WIDTH)
          bd_inst.add_port('{:s}_awprot'.format(top_intf_prefix), '{:s}_awprot'.format(bd_intf_prefix),  width=3)
          bd_inst.add_port('{:s}_awvalid'.format(top_intf_prefix), '{:s}_awvalid'.format(bd_intf_prefix))
          bd_inst.add_port('{:s}_awready'.format(top_intf_prefix), '{:s}_awready'.format(bd_intf_prefix))
          bd_inst.add_port('{:s}_wdata'.format(top_intf_prefix), '{:s}_wdata'.format(bd_intf_prefix),  width=32)
          bd_inst.add_port('{:s}_wstrb'.format(top_intf_prefix), '{:s}_wstrb'.format(bd_intf_prefix),  width=4)
          bd_inst.add_port('{:s}_wvalid'.format(top_intf_prefix), '{:s}_wvalid'.format(bd_intf_prefix))
          bd_inst.add_port('{:s}_wready'.format(top_intf_prefix), '{:s}_wready'.format(bd_intf_prefix))
          bd_inst.add_port('{:s}_bresp'.format(top_intf_prefix), '{:s}_bresp'.format(bd_intf_prefix),  width=2)
          bd_inst.add_port('{:s}_bvalid'.format(top_intf_prefix), '{:s}_bvalid'.format(bd_intf_prefix))
          bd_inst.add_port('{:s}_bready'.format(top_intf_prefix), '{:s}_bready'.format(bd_intf_prefix))
          bd_inst.add_port('{:s}_araddr'.format(top_intf_prefix), '{:s}_araddr'.format(bd_intf_prefix),  width=AXI_ADDR_WIDTH)
          bd_inst.add_port('{:s}_arprot'.format(top_intf_prefix), '{:s}_arprot'.format(bd_intf_prefix),  width=3)
          bd_inst.add_port('{:s}_arvalid'.format(top_intf_prefix), '{:s}_arvalid'.format(bd_intf_prefix))
          bd_inst.add_port('{:s}_arready'.format(top_intf_prefix), '{:s}_arready'.format(bd_intf_prefix))
          bd_inst.add_port('{:s}_rdata'.format(top_intf_prefix), '{:s}_rdata'.format(bd_intf_prefix),  width=32)
          bd_inst.add_port('{:s}_rresp'.format(top_intf_prefix), '{:s}_rresp'.format(bd_intf_prefix),  width=2)
          bd_inst.add_port('{:s}_rvalid'.format(top_intf_prefix), '{:s}_rvalid'.format(bd_intf_prefix))
          bd_inst.add_port('{:s}_rready'.format(top_intf_prefix), '{:s}_rready'.format(bd_intf_prefix))
        else:
          bd_inst.add_port('CYC_O_0', 'wbm_cyc_o')
          bd_inst.add_port('STB_O_0', 'wbm_stb_o')
          bd_inst.add_port('WE_O_0 ', 'wbm_we_o ')
          bd_inst.add_port('SEL_O_0', 'wbm_sel_o', width=4)
          bd_inst.add_port('ADR_O_0', 'wbm_adr_o', width=WB_ADDR_WIDTH)
          bd_inst.add_port('DAT_O_0', 'wbm_dat_o', width=32)
          bd_inst.add_port('DAT_I_0', 'wbm_dat_i', width=32)
          bd_inst.add_port('ACK_I_0', 'wbm_ack_i')
          bd_inst.add_port('RST_O_0', 'wbm_rst_o')
          top.add_signal('wb_clk_i')
          top.add_signal('wb_rst_i')
          top.assign_signal('wb_clk_i', 'axil_clk')
          top.assign_signal('wb_rst_i', '~axil_rst_n')

  def modify_bd(self, bd):
    bd.create_cell('smartconnect', self.name)

    # apply configurations
    bd.add_raw_cmd('set_property -dict [list \\')
    bd.build_config_cmd(self, self.attr_map, None)
    bd.add_raw_cmd('] [get_bd_cells {:s}]'.format(self.name))

    # Connect clk/rst & S side
    bd.connect_net(self.saxi.clk_src, '{:s}/{:s}'.format(self.name, self.saxi.clk_net_name))
    if self.has_rst:
      bd.connect_net(self.saxi.rst_src, '{:s}/{:s}'.format(self.name, self.saxi.rst_net_name))
    bd.connect_intf_net(self.saxi.dest, '{:s}/{:s}'.format(self.name, self.saxi.port_net_name))

    # Instantiate Wishbone bridges as necessary
    for mi, maxi in enumerate(self.maxis):
      if maxi.protocol == 'wishbone':
        a2w_instname = f'{self.name}_wb{mi}'
        bd.create_cell('axi_slave_wishbone_classic_master', a2w_instname, vendor='peralex.com', library='user', version='1.0')
        bd.add_raw_cmd(f'set_property -dict [list CONFIG.C_S_AXI_ADDR_WIDTH {{{WB_ADDR_WIDTH}}}] [get_bd_cells {a2w_instname}]')
        bd.connect_intf_net(f'{self.name}/M{mi:02d}_AXI', f'{a2w_instname}/S_AXI')
        bd.connect_net(self.saxi.rst_src, f'{a2w_instname}/S_AXI_ARESETN')
        bd.connect_net(self.saxi.clk_src, f'{a2w_instname}/S_AXI_ACLK')

    # make M AXI external
    for mi, maxi in enumerate(self.maxis):
      if len(maxi.dest.split('/')) == 1: # assumption used to know when to make pins external to bd
        intf_pin_name = f'{self.name}/M{mi:02d}_AXI'
        ext_intf_name = maxi.dest

        if maxi.protocol != 'wishbone':
          bd.create_intf_port(ext_intf_name, 'Master', 'axi4')
          bd.connect_intf_net(ext_intf_name, intf_pin_name)
          bd.add_raw_cmd(f'set_property CONFIG.PROTOCOL {maxi.protocol} [get_bd_intf_ports /{ext_intf_name}]')
          bd.add_raw_cmd(f'set_property CONFIG.ASSOCIATED_BUSIF {{{ext_intf_name}}} [get_bd_ports /{maxi.clk_src}]')
          #bd.add_raw_cmd('set_property -dict [list \\')
          #bd.add_raw_cmd('CONFIG.PROTOCOL [get_property CONFIG.PROTOCOL {:s} [get_bd_intf_pins {:s}]] \\'.format(maxi.protocol, intf_pin_name))
          #bd.add_raw_cmd('CONFIG.ADDR_WIDTH [get_property CONFIG.ADDR_WIDTH [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name))
          #bd.add_raw_cmd('CONFIG.DATA_WIDTH [get_property CONFIG.DATA_WIDTH [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name))
          #bd.add_raw_cmd('CONFIG.HAS_BURST [get_property CONFIG.HAS_BURST [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name))
          #bd.add_raw_cmd('CONFIG.HAS_LOCK [get_property CONFIG.HAS_LOCK [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name))
          #bd.add_raw_cmd('CONFIG.HAS_PROT [get_property CONFIG.HAS_PROT [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name))
          #bd.add_raw_cmd('CONFIG.HAS_CACHE [get_property CONFIG.HAS_CACHE [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name))
          #bd.add_raw_cmd('CONFIG.HAS_QOS [get_property CONFIG.HAS_QOS [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name))
          #bd.add_raw_cmd('CONFIG.HAS_REGION [get_property CONFIG.HAS_REGION [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name))
          #bd.add_raw_cmd('CONFIG.SUPPORTS_NARROW_BURST [get_property CONFIG.SUPPORTS_NARROW_BURST [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name))
          #bd.add_raw_cmd('CONFIG.MAX_BURST_LENGTH [get_property CONFIG.MAX_BURST_LENGTH [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name))
          ## there is a bug, ideally this would have worked, but the parameter propagation has not happened for the clock field
          ##bd.add_raw_cmd('CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_intf_pins {:s}]] \\'.format(intf_pin_name)))
          #bd.add_raw_cmd('CONFIG.FREQ_HZ $ps_freq_hz \\') # TODO ASSUMES $ps_freq_hz is defined
          #bd.add_raw_cmd('] [get_bd_intf_ports {:s}]'.format(ext_intf_name))
        else:
          a2w_instname = f'{self.name}_wb{mi}'
          wb_pins = ['DAT_I', 'ACK_I', 'RST_O', 'DAT_O', 'ADR_O', 'CYC_O', 'SEL_O', 'STB_O', 'WE_O']
          for pin in wb_pins:
              bd.add_raw_cmd(f'make_bd_pins_external [get_bd_pins {a2w_instname}/{pin}]')
          bd.assign_address('mpsoc/Data', f'{a2w_instname}/S_AXI/reg0', '0xA0100000', '0x00100000')
