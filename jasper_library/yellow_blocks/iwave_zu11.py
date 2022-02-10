from .yellow_block import YellowBlock
from constraints import ClockConstraint, ClockGroupConstraint, PortConstraint, RawConstraint
from os import environ as env

class iwave_zu11(YellowBlock):
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
        inst = top.get_instance('iwave_zu11_bd', 'iwave_zu11_bd_inst')
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
            top.add_signal('wb_clk_i')
            top.add_signal('wb_rst_i')
            top.assign_signal('wb_clk_i', 'axil_clk')
            top.assign_signal('wb_rst_i', '~axil_rst_n')

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
		
    def gen_children(self):
        children = [YellowBlock.make_block({
											'fullpath': self.fullpath, 'tag': 'xps:sys_block',
											'board_id': '50', 'rev_maj': '1', 'rev_min': '0',
											'rev_rcs': '1'}, self.platform)]
        return children

    def gen_constraints(self):
        cons = []
        cons.append(RawConstraint('set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]'))
        #cons.append(RawConstraint('set_property BITSTREAM.CONFIG_VOLTAGE %s [current_design]'))
        #cons.append(RawConstraint('set_property BITSTREAM.CFGBVS %s [current_design]'))
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
        tcl_cmds['pre_synth'] += ['source {}'.format(self.hdl_root + '/infrastructure/iwave_zu11_bd.tcl')]
        #tcl_cmds['pre_synth'] += ['generate_target all [get_files [get_property directory [current_project]]/myproj.srcs/sources_1/bd/iwave_zu11_bd/iwave_zu11_bd.bd]']        
        #tcl_cmds['pre_synth'] += ['make_wrapper -files [get_files [get_property directory [current_project]]/myproj.srcs/sources_1/bd/iwave_zu11_bd/iwave_zu11_bd.bd] -top']
        #tcl_cmds['pre_synth'] += ['add_files -force -norecurse [get_property directory [current_project]]/myproj.srcs/sources_1/bd/iwave_zu11_bd/hdl/iwave_zu11_bd_wrapper.vhd']
        #tcl_cmds['pre_synth'] += ['update_compile_order -fileset sources_1']
        return tcl_cmds
