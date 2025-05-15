from .yellow_block import YellowBlock
from six import iteritems

class axi_wb_bridge(YellowBlock):
    attr_map = {
    'id_wid'      : {'param': 'C_S_AXI_ID_WIDTH',       'fmt': "{{:d}}"},
    'data_wid'    : {'param': 'C_S_AXI_DATA_WIDTH',     'fmt': "{{:d}}"},
    'addr_wid'    : {'param': 'C_S_AXI_ADDR_WIDTH',     'fmt': "{{:d}}"},
    'awuser_wid'  : {'param': 'C_S_AXI_AWUSER_WIDTH',   'fmt': "{{:d}}"},
    'aruser_wid'  : {'param': 'C_S_AXI_ARUSER_WIDTH',   'fmt': "{{:d}}"},
    'wuser_wid'   : {'param': 'C_S_AXI_WUSER_WIDTH',    'fmt': "{{:d}}"},
    'ruser_wid'   : {'param': 'C_S_AXI_RUSER_WIDTH',    'fmt': "{{:d}}"},
    'buser_wid'   : {'param': 'C_S_AXI_BUSER_WIDTH',    'fmt': "{{:d}}"}
    }

    class axi_interface(object):
      def __init__(self, mode, interface_idx=None, dest=None):
        self.type = None
        self.mode = mode
        self.idx = interface_idx
        self.dest = dest

        self.clk_src = 'pl_sys_clk'
        self.rst_src = 'axil_arst_n'
        self.clk_net_name = 'S_AXI_ACLK'
        self.rst_net_name = 'S_AXI_ARESETN'
        self.port_net_name = 'S_AXI'

    def initialize(self):
        self.add_source('axi_wb_bridge/ip_repo/peralex.com_user_axi_slave_wishbone_classic_master_1.0/axi_slave_wishbone_classic_master.vhd')

        for attr, _ in iteritems(self.attr_map):
          setattr(self, attr, self.blk[attr])

        saxi_intf = self.blk['saxi_intf']
        self.saxi = self.axi_interface('Slave', 0, dest=saxi_intf['dest'])

        #maxi_intf = self.blk['maxi_intf']
        #self.maxi = self.axi_interface('Master', 0, dest=maxi_intf['dest'])

        # provides
        #self.provides.append(self.maxi.dest)

        # requires
        self.requires.append(self.saxi.clk_src)
        self.requires.append(self.saxi.rst_src)
        self.requires.append(self.saxi.dest)

    def modify_top(self, top):
        #inst = top.get_instance('axi_slave_wishbone_classic_master', 'axi_wb_bridge')

        blkdesign = '{:s}_bd'.format(self.platform.conf['name'])
        bd_inst = top.get_instance(blkdesign, '{:s}_inst'.format(blkdesign))

        bd_inst.add_port('CYC_O', 'wbm_cyc_o')
        bd_inst.add_port('STB_O', 'wbm_stb_o')
        bd_inst.add_port('WE_O ', 'wbm_we_o')
        bd_inst.add_port('SEL_O', 'wbm_sel_o', width=4)
        bd_inst.add_port('ADR_O', 'wbm_adr_o', width=self.blk['addr_wid'])
        bd_inst.add_port('DAT_O', 'wbm_dat_o', width=self.blk['data_wid'])
        bd_inst.add_port('DAT_I', 'wbm_dat_i', width=self.blk['data_wid'])
        bd_inst.add_port('ACK_I', 'wbm_ack_i')
        bd_inst.add_port('RST_O', 'wbm_rst_o')

        #bd_inst.add_port('CYC_O', 'CYC_O')
        #bd_inst.add_port('STB_O', 'STB_O')
        #bd_inst.add_port('WE_O', 'WE_O')
        #bd_inst.add_port('SEL_O', 'SEL_O')
        #bd_inst.add_port('ADR_O', 'ADR_O')
        #bd_inst.add_port('DAT_O', 'DAT_O')
        #bd_inst.add_port('DAT_I', 'DAT_I')
        #bd_inst.add_port('ACK_I', 'ACK_I')
        #bd_inst.add_port('RST_O', 'RST_O')
        #bd_inst.add_port('CYC_O', 'wbm_cyc_o')
        #bd_inst.add_port('STB_O', 'wbm_stb_o')
        #bd_inst.add_port('WE_O', 'wbm_we_o')
        #bd_inst.add_port('SEL_O', 'wbm_sel_o', width=4)
        #bd_inst.add_port('ADR_O', 'wbm_adr_o', width=32)
        #bd_inst.add_port('DAT_O', 'wbm_dat_o', width=32)
        #bd_inst.add_port('DAT_I', 'wbm_dat_i', width=32)
        #bd_inst.add_port('ACK_I', 'wbm_ack_i')
        #bd_inst.add_port('RST_O', 'wbm_rst_o')

        #inst.add_parameter('C_S_AXI_ADDR_WIDTH', 40)

        # These default to zero, giving negative port widths.
        # The ports associated with these parameters aren't
        # used anyway, so set them all to 1
        #inst.add_parameter('C_S_AXI_AWUSER_WIDTH', 16)
        #inst.add_parameter('C_S_AXI_ARUSER_WIDTH', 16)
        #inst.add_parameter('C_S_AXI_WUSER_WIDTH', 0)
        #inst.add_parameter('C_S_AXI_RUSER_WIDTH', 0)
        #inst.add_parameter('C_S_AXI_BUSER_WIDTH', 0)

        #top.add_signal('M1_AXI_araddr')
        #top.add_signal('M1_AXI_arprot')
        #top.add_signal('M1_AXI_arready')
        #top.add_signal('M1_AXI_arvalid')
        #top.add_signal('M1_AXI_awaddr')
        #top.add_signal('M1_AXI_awprot')
        #top.add_signal('M1_AXI_awready')
        #top.add_signal('M1_AXI_awvalid')
        #top.add_signal('M1_AXI_bready')
        #top.add_signal('M1_AXI_bresp')
        #top.add_signal('M1_AXI_bvalid')
        #top.add_signal('M1_AXI_rdata')
        #top.add_signal('M1_AXI_rready')
        #top.add_signal('M1_AXI_rresp')
        #top.add_signal('M1_AXI_rvalid')
        #top.add_signal('M1_AXI_wdata')
        #top.add_signal('M1_AXI_wready')
        #top.add_signal('M1_AXI_wstrb')
        #top.add_signal('M1_AXI_wvalid')
        #inst.add_port('S_AXI_ACLK',   'axil_clk')
        #inst.add_port('S_AXI_ARESETN', 'axil_rst_n')
        #inst.add_port('S_AXI_ARADDR', 'M1_AXI_araddr', width=40)
        #inst.add_port('S_AXI_ARPROT', 'M1_AXI_arprot', width=3)
        #inst.add_port('S_AXI_ARREADY', 'M1_AXI_arready')
        #inst.add_port('S_AXI_ARVALID', 'M1_AXI_arvalid')
        #inst.add_port('S_AXI_AWADDR', 'M1_AXI_awaddr', width=40)
        #inst.add_port('S_AXI_AWPROT', 'M1_AXI_awprot', width=3)
        #inst.add_port('S_AXI_AWREADY', 'M1_AXI_awready')
        #inst.add_port('S_AXI_AWVALID', 'M1_AXI_awvalid')
        #inst.add_port('S_AXI_BREADY', 'M1_AXI_bready')
        #inst.add_port('S_AXI_BRESP', 'M1_AXI_bresp', width=2)
        #inst.add_port('S_AXI_BVALID', 'M1_AXI_bvalid')
        #inst.add_port('S_AXI_RDATA', 'M1_AXI_rdata', width=32)
        #inst.add_port('S_AXI_RREADY', 'M1_AXI_rready')
        #inst.add_port('S_AXI_RRESP', 'M1_AXI_rresp', width=2)
        #inst.add_port('S_AXI_RVALID', 'M1_AXI_rvalid')
        #inst.add_port('S_AXI_WDATA', 'M1_AXI_wdata', width=32)
        #inst.add_port('S_AXI_WREADY', 'M1_AXI_wready')
        #inst.add_port('S_AXI_WSTRB', 'M1_AXI_wstrb', width=4)
        #inst.add_port('S_AXI_WVALID', 'M1_AXI_wvalid')

        #inst.add_port('CYC_O', 'wbm_cyc_o')
        #inst.add_port('STB_O', 'wbm_stb_o')
        #inst.add_port('WE_O', 'wbm_we_o')
        #inst.add_port('SEL_O', 'wbm_sel_o', width=4)
        #inst.add_port('ADR_O', 'wbm_adr_o', width=32)
        #inst.add_port('DAT_O', 'wbm_dat_o', width=32)
        #inst.add_port('DAT_I', 'wbm_dat_i', width=32)
        #inst.add_port('ACK_I', 'wbm_ack_i')
        #inst.add_port('RST_O', 'wbm_rst_o')

        top.add_signal('wb_clk_i')
        top.add_signal('wb_rst_i')
        top.assign_signal('wb_clk_i', 'axil_clk')
        top.assign_signal('wb_rst_i', '~axil_rst_n')
        
    def modify_bd(self, bd):
        bd.add_raw_cmd('set_property IP_REPO_PATHS {/opt/Xilinx/Vivado/2021.1/data/ip /home/casperlwa/mlib_devel/jasper_library/hdl_sources/axi_wb_bridge/ip_repo} [current_fileset]')
        bd.add_raw_cmd('update_ip_catalog -rebuild')
        #bd.create_cell(self.blocktype, self.name)

        #bd.add_raw_cmd('create_bd_cell -type ip -vlnv peralex.com:user:axi_slave_wishbone_classic_master:1.0 {:s}'.format(self.name))
        # apply configurations
        bd.add_raw_cmd('set_property -dict [list \\')
        bd.build_config_cmd(self, self.attr_map, None)
        bd.add_raw_cmd('] [get_bd_cells {:s}]'.format(self.name))

        bd.add_port('CYC_O', port_dir='out')
        bd.add_port('STB_O', port_dir='out')
        bd.add_port('WE_O ', port_dir='out')
        bd.add_port('SEL_O', port_dir='out', width=4)
        bd.add_port('ADR_O', port_dir='out', width=self.blk['addr_wid'])
        bd.add_port('DAT_O', port_dir='out', width=self.blk['data_wid'])
        bd.add_port('DAT_I', port_dir='in', width=self.blk['data_wid'])
        bd.add_port('ACK_I', port_dir='in')
        bd.add_port('RST_O', port_dir='out')
        #bd.add_raw_cmd('set CYC_O [ create_bd_port -dir O CYC_O ]')
        #bd.add_raw_cmd('set STB_O [ create_bd_port -dir O STB_O ]')
        #bd.add_raw_cmd('set WE_O [ create_bd_port -dir O WE_O ]')
        #bd.add_raw_cmd('set SEL_O [ create_bd_port -dir O -from {:s} -to 0 SEL_O ]'.format('3'))
        #bd.add_raw_cmd('set ADR_O [ create_bd_port -dir O -from {:s} -to 0 ADR_O ]'.format('31'))#self.blk['addr_wid']-1))
        #bd.add_raw_cmd('set DAT_O [ create_bd_port -dir O -from {:s} -to 0 DAT_O ]'.format('31'))#self.blk['data_wid']-1))
        #bd.add_raw_cmd('set DAT_I [ create_bd_port -dir I -from {:s} -to 0 DAT_I ]'.format('31'))#self.blk['data_wid']-1))
        #bd.add_raw_cmd('set ACK_I [ create_bd_port -dir I ACK_I ]')
        #bd.add_raw_cmd('set RST_O [ create_bd_port -dir O RST_O ]')

        bd.connect_net(self.saxi.clk_src, '{:s}/{:s}'.format(self.name, self.saxi.clk_net_name))
        bd.connect_net(self.saxi.rst_src, '{:s}/{:s}'.format(self.name, self.saxi.rst_net_name))

        bd.connect_intf_net(self.saxi.dest, '{:s}/{:s}'.format(self.name, self.saxi.port_net_name))

        bd.create_net('CYC_O')
        bd.connect_net('CYC_O','{:s}/{:s}'.format(self.name, 'CYC_O'))
        bd.connect_port('CYC_O','CYC_O')
        bd.create_net('STB_O')
        bd.connect_net('STB_O','{:s}/{:s}'.format(self.name, 'STB_O'))
        bd.connect_port('STB_O','STB_O')
        bd.create_net('WE_O')
        bd.connect_net('WE_O','{:s}/{:s}'.format(self.name, 'WE_O'))
        bd.connect_port('WE_O','WE_O')
        bd.create_net('SEL_O')
        bd.connect_net('SEL_O','{:s}/{:s}'.format(self.name, 'SEL_O'))
        bd.connect_port('SEL_O','SEL_O')
        bd.create_net('ADR_O')
        bd.connect_net('ADR_O','{:s}/{:s}'.format(self.name, 'ADR_O'))
        bd.connect_port('ADR_O','ADR_O')
        bd.create_net('DAT_O')
        bd.connect_net('DAT_O','{:s}/{:s}'.format(self.name, 'DAT_O'))
        bd.connect_port('DAT_O','DAT_O')
        bd.create_net('DAT_I')
        bd.connect_net('DAT_I','{:s}/{:s}'.format(self.name, 'DAT_I'))
        bd.connect_port('DAT_I','DAT_I')
        bd.create_net('ACK_I')
        bd.connect_net('ACK_I','{:s}/{:s}'.format(self.name, 'ACK_I'))
        bd.connect_port('ACK_I','ACK_I')
        bd.create_net('RST_O')
        bd.connect_net('RST_O','{:s}/{:s}'.format(self.name, 'RST_O'))
        bd.connect_port('RST_O','RST_O')
        
        #bd.assign_address('mpsoc/Data', 'axi_slave_wishbone_c_0/S_AXI/reg0', '0xB0000000', '0x00200000')
        bd.assign_address('mpsoc/Data', 'axi_slave_wishbone_c_0/S_AXI/reg0', '0xA0000000', '0x00200000')

    def gen_children(self):
        children = []
        return children

    def gen_constraints(self):
        cons = []
        return cons

    def gen_tcl_cmds(self):
        tcl_cmds = {}
        tcl_cmds['init'] = []
        tcl_cmds['create_bd'] = []
        tcl_cmds['pre_synth'] = []
        return tcl_cmds

