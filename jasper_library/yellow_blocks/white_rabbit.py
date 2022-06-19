import os

from .yellow_block import YellowBlock
from constraints import PortConstraint, ClockGroupConstraint, ClockConstraint

class white_rabbit(YellowBlock):
    def initialize(self):
        self.requires = ['white_rabbit']
        try:
            path = os.environ['WR_QUABO_REPO_PATH']
        except KeyError:
            self.logger.error("White Rabbit yellow block requires the 'WR_QUABO_REPO_PATH' to be set")
            raise

        self.init_ram = os.path.join(path, 'ram_init/wrc_phy16_sdb.bram')
        self.top_module = 'white_rabbit_quabo'

        ip_name = 'wrc_board_quabo_Light'
        vendor = 'user.org'
        library = 'user'
        version = '1.5'
        self.module_name = 'wrc_board_quabo_Light_ip'
        self.add_source('white_rabbit/white_rabbit_quabo.v')
        self.ips = [{'path': path,
                     'name': ip_name,
                     'module_name': self.module_name,
                     'vendor': vendor,
                     'library': library,
                     'version': version,
                     }]

        try:
            self.conf = self.platform.conf["white_rabbit"]
        except KeyError:
            self.conf = {}
        self.separate_dac_i2c = self.conf.get("separate_dac_i2c", False)
        self.use_sfp_disable = self.conf.get("use_sfp_disable", False)
        self.use_osc_enable = self.conf.get("use_osc_enable", False)
        self.use_tx_fault = self.conf.get("use_tx_fault", True)
        self.use_flash_wp = self.conf.get("use_flash_wp", False)
        self.master_ref_signal = self.conf.get("master_ref_signal", "1'b1")
        self.vcxo_freq_mhz  = self.conf.get("vcxo_freq_mhz", 20.0)
        self.vcxo_period_ns = 1000.0 / self.vcxo_freq_mhz
        # Modify the default mult factors based on how far from
        # 20 MHz we have strayed
        assert (50 * 20) % self.vcxo_freq_mhz == 0
        self.vcxo_mult_factor = (50 * 20) // self.vcxo_freq_mhz
        
    def gen_children(self):
        """
        Add software registers connected to counters
        """
        ybs = []
        ybs += [YellowBlock.make_block({'tag':'xps:sw_reg_sync', 'io_dir':'To Processor',
                                        'fullpath':'%s/wr_clk_counter' % self.name,
                                        'name':'wr_clk_counter'}, self.platform)]
        ybs += [YellowBlock.make_block({'tag':'xps:sw_reg_sync', 'io_dir':'To Processor',
                                        'fullpath':'%s/wr_pps_counter' % self.name,
                                        'name':'wr_pps_counter'}, self.platform)]
        ybs += [YellowBlock.make_block({'tag':'xps:sw_reg_sync', 'io_dir':'To Processor',
                                        'fullpath':'%s/wr_tm_tai' % self.name,
                                        'name':'wr_tm_tai'}, self.platform)]
        return ybs

    def modify_top(self,top):
        inst = top.get_instance(entity=self.top_module, name=self.fullname)
        inst.add_parameter('g_dmdt_mult_factor', self.vcxo_mult_factor)
        inst.add_parameter('g_dmdt_period_ns', self.vcxo_period_ns)
        # 20 MHz reference VCXO
        inst.add_port('clk_20m_vcxo_i', 'wr_20m_vcxo', dir='in', parent_port=True)
        # 125 MHz GT refclk, which should be driven by a VCXO
        inst.add_port('clk_125m_gtx_p_i', 'wr_125m_gtrefclk_p', dir='in', parent_port=True)
        inst.add_port('clk_125m_gtx_n_i', 'wr_125m_gtrefclk_n', dir='in', parent_port=True)
        # Active-low reset
        inst.add_port('reset_n_i', '~sys_rst')
        # External 10MHz reference. WL says not needed if this device is always a WR slave
        inst.add_port('clk_ext_10m', self.master_ref_signal)

        # SFP ports
        # TODO: parameterize port number?
        inst.add_port('sfp_txp_o', 'wr_sfp_tx_p', dir='out', parent_port=True)
        inst.add_port('sfp_txn_o', 'wr_sfp_tx_n', dir='out', parent_port=True)
        inst.add_port('sfp_rxp_i', 'wr_sfp_rx_p', dir='in', parent_port=True)
        inst.add_port('sfp_rxn_i', 'wr_sfp_rx_n', dir='in', parent_port=True)
        # I2C
        inst.add_port('sfp_mod_def0_i', "1'b0")
        inst.add_port('sfp_mod_def1_b', 'wr_sfp_mod_def1', dir='inout', parent_port=True)
        inst.add_port('sfp_mod_def2_b', 'wr_sfp_mod_def2', dir='inout', parent_port=True)
        if self.use_tx_fault:
            inst.add_port('sfp_tx_fault_i', 'wr_sfp_tx_fault', dir='in', parent_port=True)
        else:
            inst.add_port('sfp_tx_fault_i', '1\'b0')
        inst.add_port('sfp_los_i', 'wr_sfp_los', dir='in', parent_port=True)
        # UART
        inst.add_port('uart_rxd_i', 'wr_uart_rx', dir='in', parent_port=True)
        inst.add_port('uart_txd_o', 'wr_uart_tx', dir='out', parent_port=True)
        # Flash
        inst.add_port('spi_ncs_o', 'wr_spi_cs_n', dir='out', parent_port=True)
        inst.add_port('spi_miso_i', 'wr_spi_miso', dir='in', parent_port=True)
        inst.add_port('spi_mosi_o', 'wr_spi_mosi', dir='out', parent_port=True)
        inst.add_port('spi_sclk_o', 'wr_spi_sclk', dir='out', parent_port=True)
        # PLL DACs
        if self.separate_dac_i2c:
            inst.add_port('plldac_sclk_o', 'wr_dac_sclk', parent_port=False, parent_signal=True)
            inst.add_port('plldac_din_o', 'wr_dac_mosi', parent_port=False, parent_signal=True)
            top.add_port('wr_dac_20m_sclk', 'wr_dac_sclk', dir='out', parent_port=True)
            top.add_port('wr_dac_20m_mosi', 'wr_dac_mosi', dir='out', parent_port=True)
            top.add_port('wr_dac_25m_sclk', 'wr_dac_sclk', dir='out', parent_port=True)
            top.add_port('wr_dac_25m_mosi', 'wr_dac_mosi', dir='out', parent_port=True)
        else:
            inst.add_port('plldac_sclk_o', 'wr_dac_sclk', dir='out', parent_port=True)
            inst.add_port('plldac_din_o', 'wr_dac_mosi', dir='out', parent_port=True)
        inst.add_port('pll25dac_cs_n_o', 'wr_dac_25m_cs_n', dir='out', parent_port=True)
        inst.add_port('pll20dac_cs_n_o', 'wr_dac_20m_cs_n', dir='out', parent_port=True)
        # onewire to temperature sensor (used for MAC address as well as temp)
        inst.add_port('onewire_b', 'wr_onewire', dir='inout', parent_port=True)
        # Recovered PPS -> Simulink
        inst.add_port('pps_o', self.fullname + '_pps')
        # Link LEDs -> Simulink
        inst.add_port('led_act_o', self.fullname + '_led_act')
        inst.add_port('led_link_o', self.fullname + '_led_link')
        # Recovered clock (62.5 MHz). Manually add this signal so we can
        # add the dont_touch attribute and use it as a clock identifier in constraints
        inst.add_port('clk_sys_o', 'wr_clk', parent_signal=False)
        top.add_signal('wr_clk', attributes={'dont_touch':'"true"'})
        # Counters / TAI to software registers
        inst.add_port('tm_tai_o', '%s_tm_tai' % self.name, width=10)
        top.assign_signal('%s_wr_tm_tai_user_data_in[9:0]' % self.name, '%s_tm_tai' % self.name)
        inst.add_port('clk_counter_o', '%s_wr_clk_counter_user_data_in' % self.name, width=32)
        inst.add_port('pps_counter_o', '%s_wr_pps_counter_user_data_in' % self.name, width=32)

        if self.use_sfp_disable:
            top.add_port('wr_sfp_disable', dir='out')
            top.assign_signal('wr_sfp_disable', "1'b0")
        if self.use_osc_enable:
            top.add_port('wr_osc_en', dir='out')
            top.assign_signal('wr_osc_en', '1\'b1')
        if self.use_flash_wp:
            top.add_port('wr_flash_wp', dir='out')
            top.assign_signal('wr_flash_wp', '1\'b1')


    def gen_constraints(self):
        cons = []
        if self.use_osc_enable:
            cons += [PortConstraint('wr_osc_en', 'wr_osc_en')]
        if self.use_sfp_disable:
            cons += [PortConstraint('wr_sfp_disable', 'wr_sfp_disable')]
        if self.use_flash_wp:
            cons += [PortConstraint('wr_flash_wp', 'wr_flash_wp')]
        cons += [PortConstraint('wr_20m_vcxo', 'wr_20m_vcxo')]
        cons += [PortConstraint('wr_125m_gtrefclk_p', 'wr_125m_gtrefclk_p')]
        cons += [PortConstraint('wr_125m_gtrefclk_n', 'wr_125m_gtrefclk_n')]
        cons += [PortConstraint('wr_sfp_tx_p', 'wr_sfp_tx_p')]
        cons += [PortConstraint('wr_sfp_tx_n', 'wr_sfp_tx_n')]
        cons += [PortConstraint('wr_sfp_rx_p', 'wr_sfp_rx_p')]
        cons += [PortConstraint('wr_sfp_rx_n', 'wr_sfp_rx_n')]

        cons += [PortConstraint('wr_sfp_mod_def1', 'wr_sfp_mod_def1')]
        cons += [PortConstraint('wr_sfp_mod_def2', 'wr_sfp_mod_def2')]
        if self.use_tx_fault:
            cons += [PortConstraint('wr_sfp_tx_fault', 'wr_sfp_tx_fault')]
        cons += [PortConstraint('wr_sfp_los', 'wr_sfp_los')]

        cons += [PortConstraint('wr_uart_rx', 'wr_uart_rx')]
        cons += [PortConstraint('wr_uart_tx', 'wr_uart_tx')]
                                                
        cons += [PortConstraint('wr_spi_cs_n', 'wr_spi_cs_n')]
        cons += [PortConstraint('wr_spi_miso', 'wr_spi_miso')]
        cons += [PortConstraint('wr_spi_mosi', 'wr_spi_mosi')]
        cons += [PortConstraint('wr_spi_sclk', 'wr_spi_sclk')]
                                                
        if self.separate_dac_i2c:
            cons += [PortConstraint('wr_dac_20m_sclk', 'wr_dac_20m_sclk')]
            cons += [PortConstraint('wr_dac_20m_mosi', 'wr_dac_20m_mosi')]
            cons += [PortConstraint('wr_dac_25m_sclk', 'wr_dac_25m_sclk')]
            cons += [PortConstraint('wr_dac_25m_mosi', 'wr_dac_25m_mosi')]
        else:
            cons += [PortConstraint('wr_dac_sclk', 'wr_dac_sclk')]
            cons += [PortConstraint('wr_dac_mosi', 'wr_dac_mosi')]
        cons += [PortConstraint('wr_dac_25m_cs_n', 'wr_dac_25m_cs_n')]
        cons += [PortConstraint('wr_dac_20m_cs_n', 'wr_dac_20m_cs_n')]

        cons += [PortConstraint('wr_onewire', 'wr_onewire')]

        cons += [ClockConstraint('wr_20m_vcxo', period=self.vcxo_period_ns)]
        cons += [ClockConstraint('wr_125m_gtrefclk_p', period=8.0)]

        # Might need to declare WR async to other clocks if there is crossing.
        cons += [ClockGroupConstraint('-include_generated_clocks -of_objects [get_ports wr_125m_gtrefclk_p]',
                                      '-include_generated_clocks -of_objects [get_nets sys_clk]',
                                      'asynchronous')]

        cons += [ClockGroupConstraint('-include_generated_clocks -of_objects [get_ports wr_125m_gtrefclk_p]',
                                      '-include_generated_clocks -of_objects [get_nets user_clk]',
                                      'asynchronous')]

        return cons

    def gen_tcl_cmds(self):
        cmds = {}
        cmds['pre_synth'] = ['set_property -dict [list CONFIG.g_dpram_initf {%s}] [get_ips %s]' % (self.init_ram, self.module_name)]
        cmds['pre_synth'] += ['set_property -dict [list CONFIG.g_dmdt_mult_factor {%d} CONFIG.g_dmdt_period_ns {%d}] [get_ips %s]' % (self.vcxo_mult_factor, self.vcxo_period_ns, self.module_name)]
        return cmds

