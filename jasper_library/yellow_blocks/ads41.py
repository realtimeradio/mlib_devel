from .yellow_block import YellowBlock
from verilog import VerilogModule
from constraints import PortConstraint, ClockConstraint, RawConstraint, InputDelayConstraint, ClockGroupConstraint
from .yellow_block_typecodes import *


class ads41(YellowBlock):
    NBITS = 12
    def initialize(self):
        self.add_source('ads41/ads41_top.v')
        self.add_source('ads41/ads41_single.v')
        self.add_source('ads41/fifo_16x32.xci')
        self.add_source('spi_master/spi_master.v')
        self.add_source('spi_master/wb_spi_master.v')
        self.clock = 'adc%d_clk' % self.chip_number
        if self.inc_pll:
            self.provides = [self.clock + x for x in ['', '90', '180', '270']] # lies
        # Create a prefix for top-level ports which is independent of changes
        # in simulink yellow block name
        self.port_prefix = self.blocktype + '_%d' % self.chip_number
        self.exc_requires = [self.port_prefix] # catch multiple blocks with same chip number
        self.rst_regname = 'ads41_hardware_rst%d' % self.chip_number
        self.lock_regname = 'ads41_pll_lock%d' % self.chip_number
        self.idelay_val_regname = 'ads41_delay_val%d' % self.chip_number
        self.idelay_ctrl_regname = 'ads41_delay_ctrl%d' % self.chip_number
        self.clk_period_ns = 1./(self.sample_rate * 1e6) * 1e9
        # PLL frequency must be between 800 and 1866 MHz
        self.pllmult = int(1800. / self.sample_rate)
        # PN pair flip map. bit=1 --> invert signal
        try:
            self.conf = self.platform.conf["ads41_%d" % self.chip_number]
        except KeyError:
            self.conf = {}
        self.flip_pn = self.conf.get('flip_pn', "16'b0")
        self.clock_region = self.conf.get('clock_region', None)

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
        module = 'ads41_top'
        adc = top.get_instance(entity=module, name=self.fullname)
        adc.add_parameter('NBITS', self.NBITS)
        adc.add_parameter('CLKPERIOD', self.clk_period_ns)
        adc.add_parameter('PLLMULT', self.pllmult)
        adc.add_parameter('FLIP_PN', self.flip_pn)
        if self.inc_pll:
            adc.add_parameter('INC_PLL', "1'b1")
        else:
            adc.add_parameter('INC_PLL', "1'b0")

        # User interfaces
        # reset from embedded register
        adc.add_port('user_rst', self.name + '_%s_user_data_out[0]' % self.rst_regname, parent_sig=False)
        # PLL lock to embedded register
        adc.add_port('pll_locked', self.name + '_%s_user_data_in[0]' % self.lock_regname, parent_sig=False)
        # Delay controls from embedded registers
        adc.add_port('idelay_val', self.name + '_%s_user_data_out' % self.idelay_val_regname, parent_sig=False)
        adc.add_port('idelay_ctrl', self.name + '_%s_user_data_out' % self.idelay_ctrl_regname, parent_sig=False)
        adc.add_port('idelay_clk', 'wb_clk_i')
        # Simulink outputs
        adc.add_port('ovr_out', self.fullname + '_overrange')
        adc.add_port('d_out', self.fullname + '_data', width=self.NBITS)
        # Internal clock
        if self.inc_pll:
            adc.add_port('clk_out', self.clock) # e.g. adc0_clk
        else:
            adc.add_port('clk_out', '')
        # Read clock (main simulink domain)
        adc.add_port('rd_clk', 'user_clk')

        # External interfaces
        def add_ext_port(name, iodir, width=0):
            adc.add_port(name, self.port_prefix + '_' + name,
                         dir=iodir, width=width, parent_port=True)

        add_ext_port('dclk_p', 'in')
        add_ext_port('dclk_n', 'in')
        add_ext_port('ovr', 'in')
        add_ext_port('d_p', 'in', width=self.NBITS//2)
        add_ext_port('d_n', 'in', width=self.NBITS//2)

        # Control lines tied to constants (to be overridden in software)
        top.add_port(self.port_prefix + '_dfs', dir='out')
        top.assign_signal(self.port_prefix + '_dfs', "1'b0") # DDR LVDS, 2's comp
        top.add_port(self.port_prefix + '_reset', dir='out')
        top.assign_signal(self.port_prefix + '_reset', "1'b0") # Must reset in software
        top.add_port(self.port_prefix + '_oe', dir='out')
        top.assign_signal(self.port_prefix + '_oe', "1'b1") # DDR LVDS, 2's comp


        # Add SPI interface
        spi = top.get_instance(entity='wb_spi_master', name='ads41_spi%d' % self.chip_number)
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
        spi.add_wb_interface(nbytes=4*4, regname='ads41_spi_controller%d' % self.chip_number,
                             mode='rw', typecode=self.typecode)
        spi.add_port('cs',   self.port_prefix + '_cs',   dir='out', parent_port=True, width=NCHIP)
        spi.add_port('sclk', self.port_prefix + '_sclk', dir='out', parent_port=True)
        spi.add_port('mosi', self.port_prefix + '_mosi', dir='out', parent_port=True)
        spi.add_port('miso', "1\'b0",  dir='in',  parent_port=False) # This is the same pin as ovr. Ignore for now

        if self.inc_pll:
            # Tie phased clocks to zero for now. TODO
            top.add_signal(self.clock + "90")
            top.add_signal(self.clock + "180")
            top.add_signal(self.clock + "270")
            top.assign_signal(self.clock + "90", "1'b0")
            top.assign_signal(self.clock + "180", "~" + self.clock)
            top.assign_signal(self.clock + "270", "1'b0")

    def gen_constraints(self):
        cons = []
        def add_con(name, width=0):
            if width == 0:
                c = PortConstraint(self.port_prefix + '_' + name, 'ads41_%d_' % self.chip_number + name)
            else:
                c = PortConstraint(self.port_prefix + '_' + name, 'ads41_%d_' % self.chip_number + name,
                                   port_index=list(range(width)),
                                   iogroup_index=list(range(width)))
            cons.append(c)

        add_con('dfs')
        add_con('reset')
        add_con('oe')

        add_con('dclk_p')
        add_con('dclk_n')
        add_con('ovr')
        add_con('d_p', width=self.NBITS//2)
        add_con('d_n', width=self.NBITS//2)

        # Clock rate
        clkconst = ClockConstraint(self.port_prefix + '_' + 'dclk_p',
                                   name='ads41_%d_clk' % self.chip_number,
                                   freq=self.sample_rate)
        clk = clkconst.name
        cons.append(clkconst)
        cons.append(ClockGroupConstraint('-include_generated_clocks -of_objects [get_nets sys_clk]',
                      '-include_generated_clocks %s' % clk, 'asynchronous'))

        # SPI interface
        cons.append(PortConstraint(self.port_prefix + '_cs',   'ads41_%d_sen' % self.chip_number))
        cons.append(PortConstraint(self.port_prefix + '_sclk', 'ads41_%d_sclk' % self.chip_number))
        cons.append(PortConstraint(self.port_prefix + '_mosi', 'ads41_%d_sdata' % self.chip_number))
        #cons.append(PortConstraint(self.port_prefix + '_miso', 'ads41_%d_ovr' % self.chip_number))

        cons.append(RawConstraint('set_property DIFF_TERM TRUE [get_ports %s_dclk_p]' % self.port_prefix))
        cons.append(RawConstraint('set_property DIFF_TERM TRUE [get_ports %s_d_p[*]]' % self.port_prefix))

        # See https://support.xilinx.com/s/question/0D52E00006hpPQ9SAM/setinputdelay-ddr-constraints-confusion-clear-definition-of-xdc-syntax?language=en_US
        # Typical cases from ADS41 data sheet
        # Worst cases from data sheet probably won't meet timing
        tsu = 1.1   # data valid to zero crossing of DCLK
        th  = 0.6   # zero crossing of DCLK to data invalid
        trace_delay_margin = 0.0 # Should be length matched
        # The minimum time after a clock for data to change. (i.e., it is stable for times < min)
        delay_min = th - trace_delay_margin
        # The maximum time after a clock for data to change. (i.e., it is stable for times > max)
        delay_max = (self.clk_period_ns / 2) - (tsu - trace_delay_margin) # one bit time less margin
        
        cons.append(RawConstraint('set_input_delay -clock %s -max %.3f [get_ports %s_d_*]' % (clk, delay_max, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock %s -min %.3f [get_ports %s_d_*]' % (clk, delay_min, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock %s -max %.3f -clock_fall -add_delay [get_ports %s_d_*]' % (clk, delay_max, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock %s -min %.3f -clock_fall -add_delay [get_ports %s_d_*]' % (clk, delay_min, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock %s -max %.3f [get_ports %s_ovr]' % (clk, delay_max, self.port_prefix)))
        cons.append(RawConstraint('set_input_delay -clock %s -min %.3f [get_ports %s_ovr]' % (clk, delay_min, self.port_prefix)))

        if self.clock_region is not None:
            pblock = 'ads41_%d_pblock' % self.chip_number
            pc = 'create_pblock %s\n' % pblock
            pc += 'resize_pblock [get_pblocks %s] -add {CLOCKREGION_%s:CLOCKREGION_%s}\n' % (pblock, self.clock_region, self.clock_region)
            pc += 'add_cells_to_pblock [get_pblocks %s] [get_cells -quiet [list %s]]\n' % (pblock, self.fullname)
            cons.append(RawConstraint(pc))

        return cons
