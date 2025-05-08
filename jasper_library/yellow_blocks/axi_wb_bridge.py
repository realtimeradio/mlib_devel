from .yellow_block import YellowBlock

DEFAULT_ADDR_WIDTH = 32
DEFAULT_ID_WIDTH = 1
DEFAULT_DATA_WIDTH = 32
DEFAULT_USER_WIDTH = 1

class axi_wb_bridge(YellowBlock):
    def initialize(self):
        # Get port prefix
        try:
            self.pp = self.axi_name + '_'
        except AttributeError:
            self.pp = 'M_AXI_'
        if not hasattr(self, 'addr_width'):
            self.addr_width = DEFAULT_ADDR_WIDTH
        if not hasattr(self, 'id_width'):
            self.id_width = DEFAULT_ID_WIDTH
        if not hasattr(self, 'data_width'):
            self.id_width = DEFAULT_ID_WIDTH
        if not hasattr(self, 'user_width'):
            self.id_width = DEFAULT_USER_WIDTH

        self.add_source('axi_wb_bridge/ip_repo/peralex.com_user_axi_slave_wishbone_classic_master_1.0/axi_slave_wishbone_classic_master.vhd')

    def modify_top(self, top):
        pass
        # shortcuts
        wi = self.id_width
        wa = self.addr_width
        wd = self.data_width
        wu = self.user_width

        inst = top.get_instance('axi_slave_wishbone_classic_master', 'axi_wb_bridge')

        inst.add_parameter('C_S_AXI_ADDR_WIDTH', wa)
        inst.add_parameter('C_S_AXI_ID_WIDTH', wi)
        inst.add_parameter('C_S_AXI_DATA_WIDTH', wd)

        # These default to zero, giving negative port widths.
        # The ports associated with these parameters aren't
        # used anyway
        inst.add_parameter('C_S_AXI_AWUSER_WIDTH', wu)
        inst.add_parameter('C_S_AXI_ARUSER_WIDTH', wu)
        inst.add_parameter('C_S_AXI_WUSER_WIDTH', wu)
        inst.add_parameter('C_S_AXI_RUSER_WIDTH', wu)
        inst.add_parameter('C_S_AXI_BUSER_WIDTH', wu)

        inst.add_port('S_AXI_ACLK', 'axil_clk')
        inst.add_port('S_AXI_ARESETN', 'axil_rst_n')
        inst.add_port('S_AXI_AWID    ', self.pp + 'awid            ', width=wi)
        inst.add_port('S_AXI_AWADDR  ', self.pp +f'awaddr[{wa}-1:0]', width=wa, parent_sig=False)
        inst.add_port('S_AXI_AWLEN   ', self.pp + 'awlen           ', width=8)
        inst.add_port('S_AXI_AWSIZE  ', self.pp + 'awsize          ', width=3)
        inst.add_port('S_AXI_AWBURST ', self.pp + 'awburst         ', width=2)
        inst.add_port('S_AXI_AWLOCK  ', self.pp + 'awlock          ')
        inst.add_port('S_AXI_AWCACHE ', self.pp + 'awcache         ', width=4)
        inst.add_port('S_AXI_AWPROT  ', self.pp + 'awprot          ', width=3)
        inst.add_port('S_AXI_AWQOS   ', self.pp + 'awqos           ', width=4)
        inst.add_port('S_AXI_AWREGION', self.pp + 'awregion        ', width=4)
        inst.add_port('S_AXI_AWUSER  ', self.pp + 'awuser          ', width=wu)
        inst.add_port('S_AXI_AWVALID ', self.pp + 'awvalid         ')
        inst.add_port('S_AXI_AWREADY ', self.pp + 'awready         ')
        inst.add_port('S_AXI_WDATA   ', self.pp + 'wdata           ', width=wd)
        inst.add_port('S_AXI_WSTRB   ', self.pp + 'wstrb           ', width=wd//8)
        inst.add_port('S_AXI_WLAST   ', self.pp + 'wlast           ')
        inst.add_port('S_AXI_WUSER   ', self.pp + 'wuser           ', width=wu)
        inst.add_port('S_AXI_WVALID  ', self.pp + 'wvalid          ')
        inst.add_port('S_AXI_WREADY  ', self.pp + 'wready          ')
        inst.add_port('S_AXI_BID     ', self.pp + 'bid             ', width=wi)
        inst.add_port('S_AXI_BRESP   ', self.pp + 'bresp           ', width=2)
        inst.add_port('S_AXI_BUSER   ', self.pp + 'buser           ', width=wu)
        inst.add_port('S_AXI_BVALID  ', self.pp + 'bvalid          ')
        inst.add_port('S_AXI_BREADY  ', self.pp + 'bready          ')
        inst.add_port('S_AXI_ARID    ', self.pp + 'arid            ', width=wi)
        inst.add_port('S_AXI_ARADDR  ', self.pp +f'araddr[{wa}-1:0]', width=wa, parent_sig=False)
        inst.add_port('S_AXI_ARLEN   ', self.pp + 'arlen           ', width=8)
        inst.add_port('S_AXI_ARSIZE  ', self.pp + 'arsize          ', width=3)
        inst.add_port('S_AXI_ARBURST ', self.pp + 'arburst         ', width=2)
        inst.add_port('S_AXI_ARLOCK  ', self.pp + 'arlock          ')
        inst.add_port('S_AXI_ARCACHE ', self.pp + 'arcache         ', width=4)
        inst.add_port('S_AXI_ARPROT  ', self.pp + 'arprot          ', width=3)
        inst.add_port('S_AXI_ARQOS   ', self.pp + 'arqos           ', width=4)
        inst.add_port('S_AXI_ARREGION', self.pp + 'arregion        ', width=4)
        inst.add_port('S_AXI_ARUSER  ', self.pp + 'aruser          ', width=wu)
        inst.add_port('S_AXI_ARVALID ', self.pp + 'arvalid         ')
        inst.add_port('S_AXI_ARREADY ', self.pp + 'arready         ')
        inst.add_port('S_AXI_RID     ', self.pp + 'rid             ', width=wi)
        inst.add_port('S_AXI_RDATA   ', self.pp + 'rdata           ', width=wd)
        inst.add_port('S_AXI_RRESP   ', self.pp + 'rresp           ', width=2)
        inst.add_port('S_AXI_RLAST   ', self.pp + 'rlast           ')
        inst.add_port('S_AXI_RUSER   ', self.pp + 'ruser           ', width=wu)
        inst.add_port('S_AXI_RVALID  ', self.pp + 'rvalid          ')
        inst.add_port('S_AXI_RREADY  ', self.pp + 'rready          ')

        # Always provide 32-bit port to connect to arbiter
        top.add_signal('wbm_adr_o', width=32)
        inst.add_port('CYC_O', 'wbm_cyc_o')
        inst.add_port('STB_O', 'wbm_stb_o')
        inst.add_port('WE_O ', 'wbm_we_o ')
        inst.add_port('SEL_O', 'wbm_sel_o', width=4)
        inst.add_port('ADR_O',f'wbm_adr_o[{wa}-1:0]', width=wa, parent_sig=False)
        inst.add_port('DAT_O', 'wbm_dat_o', width=wd)
        inst.add_port('DAT_I', 'wbm_dat_i', width=wd)
        inst.add_port('ACK_I', 'wbm_ack_i')
        inst.add_port('RST_O', 'wbm_rst_o')

        top.add_signal('wb_clk_i')
        top.add_signal('wb_rst_i')
        top.assign_signal('wb_clk_i', 'axil_clk')
        top.assign_signal('wb_rst_i', '~axil_rst_n')
