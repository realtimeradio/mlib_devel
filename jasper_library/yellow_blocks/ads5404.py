from .yellow_block import YellowBlock
from verilog import VerilogModule
from constraints import PortConstraint, ClockConstraint, RawConstraint, InputDelayConstraint, FalsePathConstraint
from .yellow_block_typecodes import *


class ads5404(YellowBlock):
    NBITS = 12
    def initialize(self):
        self.add_source('ads5404/ads5404_top.v')
        self.add_source('spi_master/spi_master.v')
        self.add_source('spi_master/wb_spi_master.v')
        self.provides = ['adc_clk', 'adc_clk90', 'adc_clk180', 'adc_clk270'] # lies
        # Create a prefix for top-level ports which is independent of changes
        # in simulink yellow block name
        self.port_prefix = self.blocktype

    def gen_children(self):
        # A reset register. Add here so that we can reset regardless
        # of whether we have an ADC clock present
        rst_reg = YellowBlock.make_block({'tag':'xps:sw_reg_sync',
                                        'fullpath':'%s/ads5404_hardware_rst'%(self.name),
                                        'io_dir':'From Processor',
                                        'name':'ads5404_hardware_rst'},
                                        self.platform)
        return [rst_reg]

    def modify_top(self,top):
        module = 'ads5404_top'
        adc = top.get_instance(entity=module, name=self.fullname)
        adc.add_parameter('NBITS', self.NBITS)

        # User interfaces
        adc.add_port('user_sync', self.fullname + '_sync')
        # reset from embedded register
        adc.add_port('user_rst', self.name + '_ads5404_hardware_reset_user_data_out[0]')
        # Hard code the enable to 1. We might want control of this,
        # but need to be careful if driving it form a source which
        # requires the ADC clock to be running
        adc.add_port('user_enable', '1\'b1')
        adc.add_port('sync_out_0', self.fullname + '_sync_out_0')
        adc.add_port('sync_out_1', self.fullname + '_sync_out_1')
        adc.add_port('ovra_0', self.fullname + '_a_overrange_0')
        adc.add_port('ovra_1', self.fullname + '_a_overrange_1')
        adc.add_port('ovrb_0', self.fullname + '_b_overrange_0')
        adc.add_port('ovrb_1', self.fullname + '_b_overrange_1')
        adc.add_port('da_0', self.fullname + '_a_data_0')
        adc.add_port('da_1', self.fullname + '_a_data_1')
        adc.add_port('db_0', self.fullname + '_b_data_0')
        adc.add_port('db_1', self.fullname + '_b_data_1')

        # External interfaces
        def add_ext_port(name, iodir, width=0):
            adc.add_port(name, self.port_prefix + '_' + name,
                         dir=iodir, width=width, parent_port=True)

        add_ext_port('sync_p', 'out')
        add_ext_port('sync_n', 'out')
        add_ext_port('sreset', 'out')
        add_ext_port('enable', 'out')
        add_ext_port('daclk_p', 'in')
        add_ext_port('daclk_n', 'in')
        add_ext_port('syncout_p', 'in')
        add_ext_port('syncout_n', 'in')
        add_ext_port('ovra_p', 'in')
        add_ext_port('ovra_n', 'in')
        add_ext_port('ovrb_p', 'in')
        add_ext_port('ovrb_n', 'in')
        add_ext_port('da_p', 'in', width=self.NBITS)
        add_ext_port('da_n', 'in', width=self.NBITS)
        add_ext_port('db_p', 'in', width=self.NBITS)
        add_ext_port('db_n', 'in', width=self.NBITS)

        # Add SPI interface

        spi = top.get_instance(entity='wb_spi_master', name='ads5404_spi')
        # Configure SPI settings.
        # NBITS=24 and NCLKDIVBITS=4 gives a latency on transactions of <500 clocks.
        # The toolflow currently uses a WB arbiter with a timeout of 1000.
        # Max ADC SPI clock rate is 25 MHz. wb_clk is 100 MHz --> using an SPI clock of 6.25MHz
        # If the delay needs to be longer, the wb_spi_master core should be modified so it
        # acks the WB bus immediately, and then lets the user poll a register to see if the SPI transaction
        # has finished.
        NCHIP = 1
        spi.add_parameter("NBITS", 24)
        spi.add_parameter("NCSBITS", NCHIP)
        spi.add_parameter("NCLKDIVBITS", 4)
        spi.add_wb_interface(nbytes=4*4, regname='ads5404_spi_controller', mode='rw', typecode=self.typecode)
        spi.add_port('cs',   self.port_prefix + '_cs',   dir='out', parent_port=True, width=NCHIP)
        spi.add_port('sclk', self.port_prefix + '_sclk', dir='out', parent_port=True)
        spi.add_port('mosi', self.port_prefix + '_mosi', dir='out', parent_port=True)
        spi.add_port('miso', self.port_prefix + '_miso', dir='in',  parent_port=True)

        # Tie phased clocks to zero for now. TODO
        top.add_signal("adc_clk90")
        top.add_signal("adc_clk180")
        top.add_signal("adc_clk270")
        top.assign_signal("adc_clk90", "1'b0")
        top.assign_signal("adc_clk180", "~adc_clk")
        top.assign_signal("adc_clk270", "1'b0")

    def gen_constraints(self):
        cons = []
        def add_con(name, width=0):
            if width == 0:
                c = PortConstraint(self.port_prefix + '_' + name, 'ads5404_'+name)
            else:
                c = PortConstraint(self.port_prefix + '_' + name, 'ads5404_'+name,
                                   port_index=list(range(width)),
                                   iogroup_index=list(range(width)))
            cons.append(c)

        add_con('sync_p')
        add_con('sync_n')
        add_con('sreset')
        add_con('enable')
        add_con('daclk_p')
        add_con('daclk_n')
        add_con('syncout_p')
        add_con('syncout_n')
        add_con('ovra_p')
        add_con('ovra_n')
        add_con('ovrb_p')
        add_con('ovrb_n')
        add_con('da_p', width=self.NBITS)
        add_con('da_n', width=self.NBITS)
        add_con('db_p', width=self.NBITS)
        add_con('db_n', width=self.NBITS)

        # Clock rate
        cons.append(ClockConstraint(self.port_prefix + '_' + 'daclk_p',
                                    name='ads5404_clk',
                                    freq=self.sample_rate // 2))

        # SPI interface
        cons.append(PortConstraint(self.port_prefix + '_cs',   'ads5404_sdenb'))
        cons.append(PortConstraint(self.port_prefix + '_sclk', 'ads5404_sclk'))
        cons.append(PortConstraint(self.port_prefix + '_mosi', 'ads5404_sdio'))
        cons.append(PortConstraint(self.port_prefix + '_miso', 'ads5404_sdo'))

        cons.append(RawConstraint('set_property DIFF_TERM_ADV TERM_100 [get_ports %s_da_clk_p]' % self.port_prefix))
        cons.append(RawConstraint('set_property DIFF_TERM_ADV TERM_100 [get_ports %s_syncout_p]' % self.port_prefix))
        cons.append(RawConstraint('set_property DIFF_TERM_ADV TERM_100 [get_ports %s_ovra_p]' % self.port_prefix))
        cons.append(RawConstraint('set_property DIFF_TERM_ADV TERM_100 [get_ports %s_ovrb_p]' % self.port_prefix))
        cons.append(RawConstraint('set_property DIFF_TERM_ADV TERM_100 [get_ports %s_da_p[*]]' % self.port_prefix))

        return cons
