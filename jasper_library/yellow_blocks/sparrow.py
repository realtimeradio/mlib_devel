from .yellow_block import YellowBlock
from constraints import ClockConstraint, ClockGroupConstraint, PortConstraint, RawConstraint
from os import environ as env
from .hardware_typecodes import *

class sparrow(YellowBlock):
    enable_wishbone = True
    def initialize(self):
        board, fpga = self.hw_sys.split(':')
        # override FPGA model in platform yaml file
        self.platform.fpga = fpga + 'ffg676-2'
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

        if self.enable_wishbone:
            # For controlling PLL
            self.add_source('spi_master/spi_master.v')
            self.add_source('spi_master/wb_spi_master.v')
            self.use_pll_ctrl = True
            self.pll_port_base = 'adc_pll_ctrl_'
        else:
            self.use_pll_ctrl = False

    def modify_top(self,top):
        inst = top.get_instance('sparrow_bd', 'sparrow_bd_inst')
        inst.add_port('axil_aclk',    'axil_clk')
        inst.add_port('axil_aclk90',  'axil_clk90')
        inst.add_port('axil_aclk180', 'axil_clk180')
        inst.add_port('axil_aclk270', 'axil_clk270')
        inst.add_port('axil_aresetn',   'axil_rst_n')
        inst.add_port('clk_200',   'clk_200')
        inst.add_port('clk_10',    'clk_10')
        inst.add_port('UART1_rxd', 'wr_uart_tx')
        inst.add_port('UART1_txd', 'wr_uart_rx')

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

        if self.use_pll_ctrl:
            pllctrl = top.get_instance(entity='wb_spi_master', name='sparrow_pll_ctrl_wbspi')
            # Configure SPI settings.
            # Watch out for wishbone timeouts! The core assumes the spi response comes
            # before the wishbone arbitration core times out.
            # If the delay needs to be longer, the wb_spi_master core should be modified so it
            # acks the WB bus immediately, and then lets the user poll a register to see if the SPI transaction
            # has finished.
            pllctrl.add_parameter("NBITS", 32)
            pllctrl.add_parameter("NCSBITS", 1)
            pllctrl.add_parameter("NCLKDIVBITS", 6)
            pllctrl.add_wb_interface(nbytes=4*4, regname='sparrow_pll_ctrl', mode='rw', typecode=self.typecode)
            pllctrl.add_port('cs',   self.pll_port_base + 'cs',   dir='out', parent_port=True)
            pllctrl.add_port('sclk', self.pll_port_base + 'sclk', dir='out', parent_port=True)
            pllctrl.add_port('mosi', self.pll_port_base + 'mosi', dir='out', parent_port=True)
            pllctrl.add_port('miso', self.pll_port_base + 'miso', dir='in',  parent_port=True)

            # PSU enable
            top.add_port(self.pll_port_base + 'adc_en', dir='out')
            top.assign_signal(self.pll_port_base + 'adc_en', '%s_sparrow_adc_en_user_data_out[0]' % self.name)

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

        # Always enable WR oscillators. Necessary if not using an external
        # clock reference for the Silabs PLL
        top.add_port('wr_osc_en', dir='out')
        top.assign_signal('wr_osc_en', "1'b1")
        
    def gen_children(self):
        children = []
        sys_block =  YellowBlock.make_block(
                   		{'fullpath': self.fullpath, 'tag': 'xps:sys_block',
                   		 'board_id': str(HWTYPE_SPARROW), 'rev_maj': '1', 'rev_min': '0',
                   		 'rev_rcs': '1'},
                      self.platform
                    )
        children += [sys_block]
        adc_en_reg = YellowBlock.make_block(
                      {'tag':'xps:sw_reg_sync',
                       'fullpath':'%s/sparrow_adc_en'%(self.name),
                       'io_dir':'From Processor',
                       'name':'sparrow_adc_en'},
                      self.platform)
        if self.use_pll_ctrl:
            children += [adc_en_reg]
        return children

    def gen_constraints(self):
        cons = []
        # We don't need IO constraints for any of the PS ports, because the IP
        # will generate these for us.
        cons.append(PortConstraint('wr_osc_en', 'wr_osc_en'))

        if self.use_pll_ctrl:
            cons.append(PortConstraint(self.pll_port_base + 'cs',   'pll_sen'))
            cons.append(PortConstraint(self.pll_port_base + 'sclk', 'pll_sclk'))
            cons.append(PortConstraint(self.pll_port_base + 'mosi', 'pll_sdi'))
            cons.append(PortConstraint(self.pll_port_base + 'miso', 'pll_sdo'))
            cons.append(PortConstraint(self.pll_port_base + 'adc_en', 'adc_en'))
            cons.append(RawConstraint('set_property SLEW SLOW [get_ports %scs]' % (self.pll_port_base)))
            cons.append(RawConstraint('set_property SLEW SLOW [get_ports %ssclk]' % (self.pll_port_base)))
            cons.append(RawConstraint('set_property SLEW SLOW [get_ports %smosi]' % (self.pll_port_base)))
            cons.append(RawConstraint('set_property SLEW SLOW [get_ports %sadc_en]' % (self.pll_port_base)))

        cons.append(RawConstraint('set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]'))
        cons.append(RawConstraint("set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN Enable [current_design]"))
        return cons

    def gen_tcl_cmds(self):
        tcl_cmds = {}
        tcl_cmds['pre_synth'] = []
        tcl_cmds['promgen'] = []
        tcl_cmds['pre_synth'] += ['source {}'.format(self.hdl_root + '/infrastructure/sparrow_bd.tcl')]
        #force byte swap
        tcl_cmds['promgen'] += ['write_cfgmem -force -format bin -interface SMAPx32 -disablebitswap -loadbit "up 0x0 $bit_file" $bin_file']
        return tcl_cmds
