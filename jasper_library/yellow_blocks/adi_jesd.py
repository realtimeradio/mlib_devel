from .yellow_block import YellowBlock
from constraints import ClockConstraint, ClockGroupConstraint, PortConstraint, RawConstraint
from os import path, environ as env

class adi_jesd(YellowBlock):
    enable_wishbone = True
    block_diagram = 'adi_jesd_zynqusplus.tcl'
    fmc_port = 0
    RX_JESD_L = 8
    TX_JESD_L = 8
    RX_NUM_LINKS = 1
    TX_NUM_LINKS = 1
    JESD_M = 2
    JESD_N = 16
    def initialize(self):
        self.ips = []
        self.add_source('adi_jesd/adi_jesd_top.v')
        self.add_source(path.join(self.adi_ip_path, 'common', 'ad_iobuf.v'))
        self.add_source(path.join(self.adi_ip_path, 'common', 'ad_3w_spi.v'))
        self.sample_rate_mhz = 4500
        self.lane_mbps = 4500 * self.JESD_M * self.JESD_N / self.RX_JESD_L * 66 / 64
        if self.enable_wishbone:
            self.ips += [{'path':'%s/axi_wb_bridge/ip_repo' % env['HDL_ROOT'],
                 'name':'axi_slave_wishbone_classic_master',
                 'vendor':'peralex.com',
                 'library':'user',
                 'version':'1.0',
                }]
        if not path.exists(self.adi_ip_path):
            raise RuntimeError('ADI JESD library path %s does not exist' % self.adi_ip_path)
        self.ips += [{'path':self.adi_ip_path,
                 'name':'dontcare',
                 'vendor':'dontcare',
                 'library':'dontcare',
                 'version':'dontcare',
                }]
        # port prefix
        self.pp = 'jesd_fmc%d_' % self.fmc_port
        self.provides = []
        self.provides += ['adc_clk']
        self.provides += ['adc_clk90']  # lies
        self.provides += ['adc_clk180'] # lies
        self.provides += ['adc_clk270'] # lies

    def modify_top(self,top):
        inst = top.get_instance('adi_jesd_top', 'jesd_top_inst')
        # Internal ports (these would usually be provided by the
        # platform insfrastructure block
        inst.add_port('clk300',    'clk300mhz')
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

        # External ports, which should be accompanied by constraints
        def add_ext_port(inst, name, direction, width=0):
            port_name = self.pp + name
            inst.add_port(name, port_name, width=width, parent_port=True, dir=direction)
        #add_ext_port(inst, 'gpio_bd_o', 'out', 8)
        add_ext_port(inst, 'agc0', 'in', 2)
        add_ext_port(inst, 'agc1', 'in', 2)
        add_ext_port(inst, 'agc2', 'in', 2)
        add_ext_port(inst, 'agc3', 'in', 2)
        add_ext_port(inst, 'fpga_refclk_in_n', 'in')
        add_ext_port(inst, 'fpga_refclk_in_p', 'in')
        add_ext_port(inst, 'rx_data_n', 'in', self.RX_JESD_L*self.RX_NUM_LINKS)
        add_ext_port(inst, 'rx_data_p', 'in', self.RX_JESD_L*self.RX_NUM_LINKS)
        add_ext_port(inst, 'tx_data_n', 'out', self.TX_JESD_L*self.TX_NUM_LINKS)
        add_ext_port(inst, 'tx_data_p', 'out', self.TX_JESD_L*self.TX_NUM_LINKS)
        add_ext_port(inst, 'gpio', 'out', 11)
        add_ext_port(inst, 'hmc_gpio1', 'inout')
        add_ext_port(inst, 'hmc_sync', 'out')
        add_ext_port(inst, 'irqb', 'in', 2)
        add_ext_port(inst, 'rstb', 'out')
        add_ext_port(inst, 'rxen', 'out', 2)
        add_ext_port(inst, 'spi0_csb', 'out')
        add_ext_port(inst, 'spi0_miso', 'in')
        add_ext_port(inst, 'spi0_mosi', 'out')
        add_ext_port(inst, 'spi0_sclk', 'out')
        add_ext_port(inst, 'spi1_csb', 'out')
        add_ext_port(inst, 'spi1_sclk', 'out')
        add_ext_port(inst, 'spi1_sdio', 'inout')
        add_ext_port(inst, 'sysref2_n', 'in')
        add_ext_port(inst, 'sysref2_p', 'in')
        add_ext_port(inst, 'txen', 'out', 2)

        # ADC clock
        inst.add_port('adc_clk_out', 'adc_clk')

        # Ports to Simulink
        inst.add_port('dout', self.fullname + '_dout', width=512)
        inst.add_port('dout_vld', self.fullname + '_dout_vld')
        inst.add_port('dout_overflow', self.fullname + '_dout_overflow')
        inst.add_port('dout_sync', self.fullname + '_dout_sync')

    def gen_constraints(self):
        def add_con(conlist, name, pinname, iindex=[], oindex=[0]):
            portname = self.pp + name
            ioname = 'fmc%d_%s' % (self.fmc_port, pinname)
            conlist.append(PortConstraint(portname, ioname, port_index=iindex, iogroup_index=oindex))
            return conlist

        def add_con_se(conlist, name, pinname, iindex=[], oindex=[0]):
            portname = self.pp + name
            ioname = 'fmc%d_%s' % (self.fmc_port, pinname)
            conlist.append(PortConstraint(portname, ioname, port_index=iindex, iogroup_index=oindex, iostd='LVCMOS18'))
            return conlist
        cons = []
        #cons = add_con(cons, 'gpio_bd_o', '', [0], [])
        #cons = add_con(cons, 'gpio_bd_o', '', [1], [])
        #cons = add_con(cons, 'gpio_bd_o', '', [2], [])
        #cons = add_con(cons, 'gpio_bd_o', '', [3], [])
        #cons = add_con(cons, 'gpio_bd_o', '', [4], [])
        #cons = add_con(cons, 'gpio_bd_o', '', [5], [])
        #cons = add_con(cons, 'gpio_bd_o', '', [6], [])
        #cons = add_con(cons, 'gpio_bd_o', '', [7], [])
        cons = add_con_se(cons, 'agc0', 'la_p', [0], [17])
        cons = add_con_se(cons, 'agc0', 'la_n', [1], [17])
        cons = add_con_se(cons, 'agc1', 'la_p', [0], [18])
        cons = add_con_se(cons, 'agc1', 'la_n', [1], [18])
        cons = add_con_se(cons, 'agc2', 'la_p', [0], [20])
        cons = add_con_se(cons, 'agc2', 'la_n', [1], [20])
        cons = add_con_se(cons, 'agc3', 'la_p', [0], [21])
        cons = add_con_se(cons, 'agc3', 'la_n', [1], [21])
        cons = add_con(cons, 'fpga_refclk_in_n', 'gbtclk_n', [], [0])
        cons = add_con_se(cons, 'gpio', 'la_p', [0], [15])
        cons = add_con_se(cons, 'gpio', 'la_n', [1], [15])
        cons = add_con_se(cons, 'gpio', 'la_p', [2], [19])
        cons = add_con_se(cons, 'gpio', 'la_n', [3], [19])
        cons = add_con_se(cons, 'gpio', 'la_p', [4], [13])
        cons = add_con_se(cons, 'gpio', 'la_n', [5], [13])
        cons = add_con_se(cons, 'gpio', 'la_p', [6], [14])
        cons = add_con_se(cons, 'gpio', 'la_n', [7], [14])
        cons = add_con_se(cons, 'gpio', 'la_p', [8], [16])
        cons = add_con_se(cons, 'gpio', 'la_n', [9], [16])
        cons = add_con_se(cons, 'gpio', 'la_n', [10], [22])

        cons = add_con_se(cons, 'hmc_gpio1', 'la_n', [], [11])
        cons = add_con_se(cons, 'hmc_sync',  'la_n', [], [7])
        cons = add_con_se(cons, 'irqb', 'la_p', [0], [8])
        cons = add_con_se(cons, 'irqb', 'la_n', [1], [8])
        cons = add_con_se(cons, 'rstb', 'la_p', [], [7])
        cons = add_con_se(cons, 'rxen', 'la_p', [0], [10])
        cons = add_con_se(cons, 'rxen', 'la_n', [1], [10])
        cons = add_con_se(cons, 'spi0_csb',  'la_p', [], [5])
        cons = add_con_se(cons, 'spi0_miso', 'la_n', [], [5])
        cons = add_con_se(cons, 'spi0_mosi', 'la_p', [], [4])
        cons = add_con_se(cons, 'spi0_sclk', 'la_n', [], [4])
        cons = add_con_se(cons, 'spi1_csb',  'la_p', [], [12])
        cons = add_con_se(cons, 'spi1_sdio', 'la_n', [], [12])
        cons = add_con_se(cons, 'spi1_sclk', 'la_p', [], [11])
        cons = add_con(cons, 'sysref2_n', 'clk_n', [], [0])
        cons = add_con_se(cons, 'txen', 'la_p', [0], [9])
        cons = add_con_se(cons, 'txen', 'la_n', [1], [9])

        # Lane map scrambling is handled by the linux driver.
        # Here we simply hook up lanes in order of FMC pin
        # which satisfies the FPGA-side GT QUAD DRC
        #rxlanes = [2, 0, 7, 6, 5, 4, 3, 1]
        #txlanes = [0, 2, 7, 6, 1, 5, 4, 3]
        nrx = self.RX_JESD_L*self.RX_NUM_LINKS
        cons = add_con(cons, 'rx_data_n', 'dp_m2c_n', range(nrx), range(nrx))
        ntx = self.TX_JESD_L*self.TX_NUM_LINKS
        cons = add_con(cons, 'tx_data_n', 'dp_c2m_n', range(ntx), range(ntx))

        cons += [ClockConstraint(self.pp+'fpga_refclk_in_n', freq=self.lane_mbps/66.)]
        # The firmware allows dynamic clock source selection. Set the case
        # for the timing analysis based on what the driver will ultimately select
        cons += [RawConstraint('set_case_analysis -quiet 0 [get_pins -quiet -hier *_channel/TXSYSCLKSEL[0]]')]
        cons += [RawConstraint('set_case_analysis -quiet 1 [get_pins -quiet -hier *_channel/TXSYSCLKSEL[1]]')]
        cons += [RawConstraint('set_case_analysis -quiet 1 [get_pins -quiet -hier *_channel/TXOUTCLKSEL[0]]')]
        cons += [RawConstraint('set_case_analysis -quiet 1 [get_pins -quiet -hier *_channel/TXOUTCLKSEL[1]]')]
        cons += [RawConstraint('set_case_analysis -quiet 0 [get_pins -quiet -hier *_channel/TXOUTCLKSEL[2]]')]
        cons += [RawConstraint('set_case_analysis -quiet 0 [get_pins -quiet -hier *_channel/RXSYSCLKSEL[0]]')]
        cons += [RawConstraint('set_case_analysis -quiet 1 [get_pins -quiet -hier *_channel/RXSYSCLKSEL[1]]')]
        cons += [RawConstraint('set_case_analysis -quiet 1 [get_pins -quiet -hier *_channel/RXOUTCLKSEL[0]]')]
        cons += [RawConstraint('set_case_analysis -quiet 1 [get_pins -quiet -hier *_channel/RXOUTCLKSEL[1]]')]
        cons += [RawConstraint('set_case_analysis -quiet 0 [get_pins -quiet -hier *_channel/RXOUTCLKSEL[2]]')]

        return cons

    def gen_tcl_cmds(self):
        tcl_cmds = {}
        tcl_cmds['pre_synth'] = []
        tcl_cmds['pre_synth'] += ['source {}'.format(path.join(self.hdl_root, 'adi_jesd', self.block_diagram))]
        return tcl_cmds
