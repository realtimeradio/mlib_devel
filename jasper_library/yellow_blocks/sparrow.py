from .yellow_block import YellowBlock
from constraints import ClockConstraint, ClockGroupConstraint, PortConstraint, RawConstraint
from os import environ as env
from .hardware_typecodes import *

class sparrow(YellowBlock):
    enable_wishbone = True
    def initialize(self):
        if self.enable_wishbone:
            self.ips = [{'path':'%s/axi_wb_bridge/ip_repo' % env['HDL_ROOT'],
                 'name':'axi_slave_wishbone_classic_master',
                 'vendor':'peralex.com',
                 'library':'user',
                 'version':'1.0',
                }]
        # For AXI CDCs -- shouldn't need importing here!
        self.add_source('utils/cdc_synchroniser.vhd')
        # For WB -- shouldn't need importing here!
        self.add_source('wbs_arbiter')

        self.provides.append('sys_clk')
        self.provides.append('sys_clk90')
        self.provides.append('sys_clk180')
        self.provides.append('sys_clk270')

    def modify_top(self,top):
        inst = top.get_instance('sparrow_bd', 'sparrow_bd_inst')
        inst.add_port('axil_aclk',    'axil_clk')
        inst.add_port('axil_aclk90',  'axil_clk90')
        inst.add_port('axil_aclk180', 'axil_clk180')
        inst.add_port('axil_aclk270', 'axil_clk270')
        inst.add_port('axil_aresetn',   'axil_rst_n')

        inst.add_port('m_axil_araddr', 'M_AXI_araddr', width=32)
        inst.add_port('m_axil_arprot', 'M_AXI_arprot', width=3)
        inst.add_port('m_axil_arready', 'M_AXI_arready')
        inst.add_port('m_axil_arvalid', 'M_AXI_arvalid')
        inst.add_port('m_axil_awaddr', 'M_AXI_awaddr', width=32)
        inst.add_port('m_axil_awprot', 'M_AXI_awprot', width=3)
        inst.add_port('m_axil_awready', 'M_AXI_awready')
        inst.add_port('m_axil_awvalid', 'M_AXI_awvalid')
        inst.add_port('m_axil_bready', 'M_AXI_bready')
        inst.add_port('m_axil_bresp', 'M_AXI_bresp', width=2)
        inst.add_port('m_axil_bvalid', 'M_AXI_bvalid')
        inst.add_port('m_axil_rdata', 'M_AXI_rdata', width=32)
        inst.add_port('m_axil_rready', 'M_AXI_rready')
        inst.add_port('m_axil_rresp', 'M_AXI_rresp', width=2)
        inst.add_port('m_axil_rvalid', 'M_AXI_rvalid')
        inst.add_port('m_axil_wdata', 'M_AXI_wdata', width=32)
        inst.add_port('m_axil_wready', 'M_AXI_wready')
        inst.add_port('m_axil_wstrb', 'M_AXI_wstrb', width=4)
        inst.add_port('m_axil_wvalid', 'M_AXI_wvalid')

        if self.enable_wishbone:
            # Wishbone ports
            inst.add_port('CYC_O', 'wbm_cyc_o')
            inst.add_port('STB_O', 'wbm_stb_o')
            inst.add_port('WE_O ', 'wbm_we_o ')
            inst.add_port('SEL_O', 'wbm_sel_o', width=4)
            inst.add_port('ADR_O', 'wbm_adr_o', width=32)
            inst.add_port('DAT_O', 'wbm_dat_o', width=32)
            inst.add_port('DAT_I', 'wbm_dat_i', width=32)
            inst.add_port('ACK_I', 'wbm_ack_i')
            inst.add_port('RST_O', 'wbm_rst_o')

        # PS IO to top-level
        # shortcut port add & propagate
        def add_port(name, iodir, width=0):
            inst.add_port(name, name, dir=iodir, width=width, parent_port=True)

        # DRAM and MIO (the block diagram makes all the ports bidirectional)
        add_port('DDR_addr', 'inout', 15)
        add_port('DDR_ba', 'inout', 3)
        add_port('DDR_cas_n', 'inout')
        add_port('DDR_ck_n', 'inout')
        add_port('DDR_ck_p', 'inout')
        add_port('DDR_cke', 'inout')
        add_port('DDR_cs_n', 'inout')
        add_port('DDR_dm', 'inout', 4)
        add_port('DDR_dq', 'inout', 32)
        add_port('DDR_dqs_n', 'inout', 4)
        add_port('DDR_dqs_p', 'inout', 4)
        add_port('DDR_odt', 'inout')
        add_port('DDR_ras_n', 'inout')
        add_port('DDR_reset_n', 'inout')
        add_port('DDR_we_n', 'inout')
        add_port('FIXED_IO_ddr_vrn', 'inout')
        add_port('FIXED_IO_ddr_vrp', 'inout')
        add_port('FIXED_IO_mio', 'inout', 54)
        add_port('FIXED_IO_ps_clk', 'inout')
        add_port('FIXED_IO_ps_porb', 'inout')
        add_port('FIXED_IO_ps_srstb', 'inout')
  
        # USB stuff which we're not using for now
        inst.add_port('USBIND_0_port_indctl', '', width=2, dir='out')
        inst.add_port('USBIND_0_vbus_pwrselect', '', dir='out')
        inst.add_port('USBIND_0_vbus_pwrfault', '1\'b0', dir='in')

        inst.add_port('pll_locked', '', dir='out')

        # Reset / Clock renaming
        top.add_signal('axil_rst')
        top.add_signal('sys_rst')
        top.add_signal('sys_clk')
        top.add_signal('sys_clk90')
        top.add_signal('sys_clk180')
        top.add_signal('sys_clk270')
        top.assign_signal('axil_rst',   '~axil_rst_n')
        top.assign_signal('sys_rst',    '~axil_rst_n')
        top.assign_signal('sys_clk',    'axil_clk')
        top.assign_signal('sys_clk90',  'axil_clk90')
        top.assign_signal('sys_clk180', 'axil_clk180')
        top.assign_signal('sys_clk270', 'axil_clk270')
        if self.enable_wishbone:
            top.add_signal('wb_clk_i')
            top.add_signal('wb_rst_i')
            top.assign_signal('wb_clk_i', 'axil_clk')
            top.assign_signal('wb_rst_i', '~axil_rst_n')
        
    def gen_children(self):
        children = [YellowBlock.make_block({
                                            'fullpath': self.fullpath, 'tag': 'xps:sys_block',
                                            'board_id': str(HWTYPE_SPARROW), 'rev_maj': '1', 'rev_min': '0',
                                            'rev_rcs': '1'}, self.platform)]
        return children

    def gen_constraints(self):
        cons = []
        # We don't need IO constraints for any of the PS ports, because the IP
        # will generate these for us.
        cons.append(RawConstraint('set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]'))
        cons.append(RawConstraint("set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable [current_design]"))
        return cons

    def gen_tcl_cmds(self):
        tcl_cmds = {}
        tcl_cmds['pre_synth'] = []
        """
        Add a block design to project with wrapper via its exported tcl script.
        1. Source the tcl script.
        2. Generate the block design via generate_target.
        3. Have vivado make an HDL wrapper around the block design.
        4. Add the wrapper HDL file to project.
        """
        tcl_cmds['pre_synth'] += ['source {}'.format(self.hdl_root + '/infrastructure/sparrow_bd.tcl')]
        return tcl_cmds
