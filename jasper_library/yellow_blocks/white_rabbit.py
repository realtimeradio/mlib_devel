import os

from .yellow_block import YellowBlock
from constraints import PortConstraint, ClockGroupConstraint

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
        version = '1.2'
        self.module_name = 'wrc_board_quabo_Light_ip'
        self.add_source('white_rabbit/white_rabbit_quabo.v')
        self.ips = [{'path': path,
                     'name': ip_name,
                     'module_name': self.module_name,
                     'vendor': vendor,
                     'library': library,
                     'version': version,
                     }]
        
    def gen_children(self):
        """
        Add software registers connected to counters
        """
        ybs = []
        ybs += [YellowBlock.make_block({'tag':'xps:sw_reg_sync', 'io_dir':'To Processor', 'name':'wr_clk_counter'}, self.platform)]
        ybs += [YellowBlock.make_block({'tag':'xps:sw_reg_sync', 'io_dir':'To Processor', 'name':'wr_pps_counter'}, self.platform)]
        return ybs

    def modify_top(self,top):
        inst = top.get_instance(entity=self.top_module, name=self.fullname)
        # 20 MHz reference VCXO
        inst.add_port('clk_20m_vcxo_i', 'wr_20m_vcxo', dir='in', parent_port=True)
        # 125 MHz GT refclk, which should be driven by a VCXO
        inst.add_port('clk_125m_gtx_p_i', 'wr_125m_gtrefclk_p', dir='in', parent_port=True)
        inst.add_port('clk_125m_gtx_n_i', 'wr_125m_gtrefclk_n', dir='in', parent_port=True)
        # Active-low reset
        inst.add_port('reset_i', '~sys_rst')
        # External 10MHz reference. WL says not needed if this device is always a WR slave
        inst.add_port('clk_ext_10m', "1'b1")

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
        inst.add_port('sfp_tx_fault_i', 'wr_sfp_tx_fault', dir='in', parent_port=True)
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
        inst.add_port('plldac_sclk_o', 'wr_dac_sclk', dir='out', parent_port=True)
        inst.add_port('plldac_din_o', 'wr_dac_mosi', dir='out', parent_port=True)
        inst.add_port('pll25dac_cs_n_o', 'wr_dac_25m_cs_n', dir='out', parent_port=True)
        inst.add_port('pll20dac_cs_n_o', 'wr_dac_20m_cs_n', dir='out', parent_port=True)
        # onewire to ???
        inst.add_port('onewire_b', 'wr_onewire', dir='inout', parent_port=True)
        # Recovered PPS
        inst.add_port('pps_o', 'wr_pps')
        # Recovered clock (62.5 MHz). Manually add this signal so we can
        # add the keep attribute and use it as a clock identifier in constraints
        inst.add_port('clk_sys_o', 'wr_clk', parent_signal=False)
        top.add_signal('wr_clk', attributes={'keep':'"true"'})
        # Counters to software registers
        inst.add_port('clk_counter_o', 'wr_clk_counter_user_data_in', width=32)
        inst.add_port('pps_counter_o', 'wr_pps_counter_user_data_in', width=32)


    def gen_constraints(self):
        cons = []
        cons += [PortConstraint('wr_20m_vcxo', 'wr_20m_vcxo')]
        cons += [PortConstraint('wr_125m_gtrefclk_p', 'wr_125m_gtrefclk_p')]
        cons += [PortConstraint('wr_125m_gtrefclk_n', 'wr_125m_gtrefclk_n')]
        cons += [PortConstraint('wr_sfp_tx_p', 'wr_sfp_tx_p')]
        cons += [PortConstraint('wr_sfp_tx_n', 'wr_sfp_tx_n')]
        cons += [PortConstraint('wr_sfp_rx_p', 'wr_sfp_rx_p')]
        cons += [PortConstraint('wr_sfp_rx_n', 'wr_sfp_rx_n')]

        cons += [PortConstraint('wr_sfp_mod_def1', 'wr_sfp_mod_def1')]
        cons += [PortConstraint('wr_sfp_mod_def2', 'wr_sfp_mod_def2')]
        cons += [PortConstraint('wr_sfp_tx_fault', 'wr_sfp_tx_fault')]
        cons += [PortConstraint('wr_sfp_los', 'wr_sfp_los')]

        cons += [PortConstraint('wr_uart_rx', 'wr_uart_rx')]
        cons += [PortConstraint('wr_uart_tx', 'wr_uart_tx')]
                                                
        cons += [PortConstraint('wr_spi_cs_n', 'wr_spi_cs_n')]
        cons += [PortConstraint('wr_spi_miso', 'wr_spi_miso')]
        cons += [PortConstraint('wr_spi_mosi', 'wr_spi_mosi')]
        cons += [PortConstraint('wr_spi_sclk', 'wr_spi_sclk')]
                                                
        cons += [PortConstraint('wr_dac_sclk', 'wr_dac_sclk')]
        cons += [PortConstraint('wr_dac_mosi', 'wr_dac_mosi')]
        cons += [PortConstraint('wr_dac_25m_cs_n', 'wr_dac_25m_cs_n')]
        cons += [PortConstraint('wr_dac_20m_cs_n', 'wr_dac_20m_cs_n')]

        cons += [PortConstraint('wr_onewire', 'wr_onewire')]

        cons += [ClockGroupConstraint('-include_generated_clocks -of_objects [get_nets wr_clk]',
                                      '-include_generated_clocks -of_objects [get_nets sys_clk]',
                                      'asynchronous')]
        cons += [ClockGroupConstraint('-include_generated_clocks -of_objects [get_nets wr_clk]',
                                      '-include_generated_clocks -of_objects [get_nets user_clk]',
                                      'asynchronous')]

        return cons

    def gen_tcl_cmds(self):
        cmds = {}
        cmds['pre_synth'] = ['set_property -dict [list CONFIG.g_dpram_initf {%s}] [get_ips %s]' % (self.init_ram, self.module_name)]
        return cmds

