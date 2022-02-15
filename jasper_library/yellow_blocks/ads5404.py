from .yellow_block import YellowBlock
from verilog import VerilogModule
from constraints import PortConstraint, ClockConstraint, RawConstraint, InputDelayConstraint, ClockGroupConstraint
from .yellow_block_typecodes import *


class ads5404(YellowBlock):
    NBITS = 12
    def initialize(self):
        self.add_source('ads5404/ads5404_top.v')
        self.add_source('ads5404/ads5404_single.v')
        self.add_source('ads5404/fifo_36x128.xci')
        self.add_source('spi_master/spi_master.v')
        self.add_source('spi_master/wb_spi_master.v')
        self.provides = ['adc_clk', 'adc_clk90', 'adc_clk180', 'adc_clk270'] # lies
        # Create a prefix for top-level ports which is independent of changes
        # in simulink yellow block name
        self.port_prefix = self.blocktype
        self.rst_regname = 'ads5404_hardware_rst'
        self.lock_regname = 'ads5404_pll_lock'
        self.idelay_val_regname = 'ads5404_delay_val'
        self.idelay_ctrl_regname = 'ads5404_delay_ctrl'
        self.clk_period_ns = 1./(self.sample_rate * 1e6) * 1e9 * 2
        # PLL frequency must be between 800 and 1866 MHz
        self.pllmult = int(1800. / self.sample_rate) * 2

    def gen_children(self):
        # A reset register. Add here so that we can reset regardless
        # of whether we have an ADC clock present
        rst_reg = YellowBlock.make_block(
                    {'tag':'xps:sw_reg_sync',
                    'fullpath': '%s/%s' % (self.name, self.rst_regname),
                    'io_dir':'From Processor',
                    'name': self.rst_regname},
                    self.platform
                  )
        lock_reg= YellowBlock.make_block(
                    {'tag':'xps:sw_reg_sync',
                    'fullpath': '%s/%s' % (self.name, self.lock_regname),
                    'io_dir':'To Processor',
                    'name': self.lock_regname},
                    self.platform
                  )
        idelay_val_reg = YellowBlock.make_block(
                    {'tag':'xps:sw_reg_sync',
                    'fullpath': '%s/%s' % (self.name, self.idelay_val_regname),
                    'io_dir':'From Processor',
                    'name': self.idelay_val_regname},
                    self.platform
                  )
        idelay_ctrl_reg = YellowBlock.make_block(
                    {'tag':'xps:sw_reg_sync',
                    'fullpath': '%s/%s' % (self.name, self.idelay_ctrl_regname),
                    'io_dir':'From Processor',
                    'name': self.idelay_ctrl_regname},
                    self.platform
                  )
        return [rst_reg, lock_reg, idelay_val_reg, idelay_ctrl_reg]

    def modify_top(self,top):
        module = 'ads5404_top'
        adc = top.get_instance(entity=module, name=self.fullname)
        adc.add_parameter('NBITS', self.NBITS)
        adc.add_parameter('CLKPERIOD', self.clk_period_ns)
        adc.add_parameter('PLLMULT', self.pllmult)

        # User interfaces
        adc.add_port('user_sync', self.fullname + '_sync')
        # reset from embedded register
        adc.add_port('user_rst', self.name + '_%s_user_data_out[0]' % self.rst_regname, parent_sig=False)
        # PLL lock to embedded register
        adc.add_port('pll_locked', self.name + '_%s_user_data_in[0]' % self.lock_regname, parent_sig=False)
        # Delay controls from embedded registers
        adc.add_port('idelay_val', self.name + '_%s_user_data_out' % self.idelay_val_regname, parent_sig=False)
        adc.add_port('idelay_ctrl', self.name + '_%s_user_data_out' % self.idelay_ctrl_regname, parent_sig=False)
        adc.add_port('idelay_clk', 'wb_clk_i')
        # Hard code the enable to 1. We might want control of this,
        # but need to be careful if driving it form a source which
        # requires the ADC clock to be running
        adc.add_port('user_enable', '1\'b1')
        adc.add_port('sync_out_0', self.fullname + '_sync_out_0')
        adc.add_port('sync_out_1', self.fullname + '_sync_out_1')
        adc.add_port('ovra_0', self.fullname + '_overrange_a_0')
        adc.add_port('ovra_1', self.fullname + '_overrange_a_1')
        adc.add_port('ovrb_0', self.fullname + '_overrange_b_0')
        adc.add_port('ovrb_1', self.fullname + '_overrange_b_1')
        adc.add_port('da_0', self.fullname + '_data_a_0', width=self.NBITS)
        adc.add_port('da_1', self.fullname + '_data_a_1', width=self.NBITS)
        adc.add_port('db_0', self.fullname + '_data_b_0', width=self.NBITS)
        adc.add_port('db_1', self.fullname + '_data_b_1', width=self.NBITS)

        # Internal clock
        adc.add_port('clkout', 'adc_clk')

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
        add_ext_port('dbclk_p', 'in')
        add_ext_port('dbclk_n', 'in')
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
        add_con('dbclk_p')
        add_con('dbclk_n')
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
                                    name='ads5404a_clk',
                                    freq=self.sample_rate // 2))
        cons.append(ClockGroupConstraint('-include_generated_clocks -of_objects [get_nets sys_clk]',
                      '-include_generated_clocks ads5404a_clk', 'asynchronous'))

        cons.append(ClockConstraint(self.port_prefix + '_' + 'dbclk_p',
                                    name='ads5404b_clk',
                                    freq=self.sample_rate // 2))
        cons.append(ClockGroupConstraint('-include_generated_clocks -of_objects [get_nets sys_clk]',
                      '-include_generated_clocks ads5404b_clk', 'asynchronous'))

        # SPI interface
        cons.append(PortConstraint(self.port_prefix + '_cs',   'ads5404_sdenb'))
        cons.append(PortConstraint(self.port_prefix + '_sclk', 'ads5404_sclk'))
        cons.append(PortConstraint(self.port_prefix + '_mosi', 'ads5404_sdio'))
        cons.append(PortConstraint(self.port_prefix + '_miso', 'ads5404_sdo'))

        cons.append(RawConstraint('set_property DIFF_TERM TRUE [get_ports %s_daclk_p]' % self.port_prefix))
        cons.append(RawConstraint('set_property DIFF_TERM TRUE [get_ports %s_syncout_p]' % self.port_prefix))
        cons.append(RawConstraint('set_property DIFF_TERM TRUE [get_ports %s_ovra_p]' % self.port_prefix))
        cons.append(RawConstraint('set_property DIFF_TERM TRUE [get_ports %s_ovrb_p]' % self.port_prefix))
        cons.append(RawConstraint('set_property DIFF_TERM TRUE [get_ports %s_da_p[*]]' % self.port_prefix))

        # See https://support.xilinx.com/s/question/0D52E00006hpPQ9SAM/setinputdelay-ddr-constraints-confusion-clear-definition-of-xdc-syntax?language=en_US
        # A little more relaxed than typical cases from ADS5404 data sheet, to get timing to close
        # Will need dynamic link training. Worst cases don't meet timing at all
        tsu_a = 0.8   # data valid to zero crossing of DACLK
        th_a  = 0.79  # zero crossing of DACLK to data invalid
        tsu_b = 0.95   # data valid to zero crossing of DBCLK. Data sheet says 0.9 typical. But make timing close
        th_b  = 0.65   # zero crossing of DBCLK to data invalid. The data sheet says 0.6 typical. But make timing close
        trace_delay_margin = 0.0 # Should be length matched
        # The minimum time after a clock for data to change. (i.e., it is stable for times < min)
        delay_min_a = th_a - trace_delay_margin
        delay_min_b = th_b - trace_delay_margin
        # The maximum time after a clock for data to change. (i.e., it is stable for times > max)
        delay_max_a = (self.clk_period_ns / 2) - (tsu_a - trace_delay_margin) # one bit time less margin
        delay_max_b = (self.clk_period_ns / 2) - (tsu_b - trace_delay_margin) # one bit time less margin
        
        cons.append(RawConstraint('set_input_delay -clock ads5404a_clk -max %.3f [get_ports %s_*a_*]' % (delay_max_a, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock ads5404a_clk -min %.3f [get_ports %s_*a_*]' % (delay_min_a, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock ads5404a_clk -max %.3f -clock_fall -add_delay [get_ports %s_*a_*]' % (delay_max_a, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock ads5404a_clk -min %.3f -clock_fall -add_delay [get_ports %s_*a_*]' % (delay_min_a, self.port_prefix)))

        cons.append(RawConstraint('set_input_delay -clock ads5404a_clk -max %.3f [get_ports %s_syncout_*]' % (delay_max_a, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock ads5404a_clk -min %.3f [get_ports %s_syncout_*]' % (delay_min_a, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock ads5404a_clk -max %.3f -clock_fall -add_delay [get_ports %s_syncout_*]' % (delay_max_a, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock ads5404a_clk -min %.3f -clock_fall -add_delay [get_ports %s_syncout_*]' % (delay_min_a, self.port_prefix)))

        cons.append(RawConstraint('set_input_delay -clock ads5404b_clk -max %.3f [get_ports %s_*b_*]' % (delay_max_b, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock ads5404b_clk -min %.3f [get_ports %s_*b_*]' % (delay_min_b, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock ads5404b_clk -max %.3f -clock_fall -add_delay [get_ports %s_*b_*]' % (delay_max_b, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock ads5404b_clk -min %.3f -clock_fall -add_delay [get_ports %s_*b_*]' % (delay_min_b, self.port_prefix)))

        cons.append(RawConstraint('set_clock_uncertainty -from ads5404b_clk -to ads5404a_clk 0.2'))
        cons.append(RawConstraint('set_clock_uncertainty -from ads5404a_clk -to ads5404b_clk 0.2')) # This might be redundant?

        # Annoyingly, vivado seems to try to place the PLL in an impossible location which the BUFR can't reach.
        pll = '%s/mmcm_inst' % self.fullname
        pc = 'create_pblock ads5404_pblock\n'
        pc += 'resize_pblock [get_pblocks ads5404_pblock] -add {CLOCKREGION_X1Y3:CLOCKREGION_X1Y3}\n'
        pc += 'add_cells_to_pblock [get_pblocks ads5404_pblock] [get_cells -quiet [list %s]]\n' % pll
        cons.append(RawConstraint(pc))
        return cons
