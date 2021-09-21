import os
from .yellow_block import YellowBlock
from verilog import VerilogModule
from constraints import PortConstraint, ClockConstraint, RawConstraint, ClockGroupConstraint

from math import ceil, floor

class htg_ad9213(YellowBlock):
    def initialize(self):
        print(self.source_path)
        if not self.source_path:
            self.source_path = os.path.join(os.environ['HDL_ROOT'], 'htg_ad9213')

        hdl_path = os.path.join(self.source_path, 'src', 'hdl')
        bd_path = os.path.join(self.source_path, 'src', 'bd')
        self.elf = os.path.join(self.source_path, 'src', 'sw', 'adc.elf')

        self.add_source('htg_ad9213/htg_ad9213_quad_top.v')
        self.add_source(os.path.join(hdl_path, 'd_ff.v'))
        self.add_source(os.path.join(hdl_path, 'ad_3w_spi.v'))
        self.add_source(os.path.join(hdl_path, 'jesd204_ad9213_demapper.v'))
        self.add_source(self.elf)

        self.provides = []
        # LIES: This core doesn't actually provide clocks other than 0-degrees
        if self.use_fmc_a:
            self.provides += ['fmc_a_clk', 'fmc_a_clk90', 'fmc_a_clk180', 'fmc_a_clk270']
            self.add_source(os.path.join(hdl_path, 'ad9213_fmc_a_top.v'))
        if self.use_fmc_b:
            self.provides += ['fmc_b_clk', 'fmc_b_clk90', 'fmc_b_clk180', 'fmc_b_clk270']
            self.add_source(os.path.join(hdl_path, 'ad9213_fmc_b_top.v'))
        if self.use_fmc_c:
            self.provides += ['fmc_c_clk', 'fmc_c_clk90', 'fmc_c_clk180', 'fmc_c_clk270']
            self.add_source(os.path.join(hdl_path, 'ad9213_fmc_c_top.v'))
        if self.use_fmc_d:
            self.provides += ['fmc_d_clk', 'fmc_d_clk90', 'fmc_d_clk180', 'fmc_d_clk270']
            self.add_source(os.path.join(hdl_path, 'ad9213_fmc_d_top.v'))

        self.bd = {
            'a': os.path.join(bd_path, 'adc_fmc_a.tcl'),
            'b': os.path.join(bd_path, 'adc_fmc_b.tcl'),
            'c': os.path.join(bd_path, 'adc_fmc_c.tcl'),
            'd': os.path.join(bd_path, 'adc_fmc_d.tcl'),
        }

    def _add_one_fmc_interface(self, inst, fmc):
        """
        Add all ports associated with ``fmc`` to VerilogModule ``inst``.

        :param inst: Verilog instance to which ports should be added.
        :type inst: VerilogModule

        :param fmc: FMC port. Either 'a', 'b', 'c', or 'd'
        :type fmc: str
        """

        assert fmc in ['a', 'b', 'c', 'd']

        # External Ports
        inst.add_port('hmc_' + fmc + '_sync',           self.expand_name('hmc_' + fmc + '_sync'),           parent_port=True, dir='out')
        inst.add_port('hmc_' + fmc + '_reset',          self.expand_name('hmc_' + fmc + '_reset'),          parent_port=True, dir='out')
        inst.add_port('hmc_' + fmc + '_gpio1',          self.expand_name('hmc_' + fmc + '_gpio1'),          parent_port=True, dir='inout')
        inst.add_port('hmc_' + fmc + '_gpio2',          self.expand_name('hmc_' + fmc + '_gpio2'),          parent_port=True, dir='inout')
        inst.add_port('hmc_' + fmc + '_gpio3',          self.expand_name('hmc_' + fmc + '_gpio3'),          parent_port=True, dir='inout')
        inst.add_port('hmc_' + fmc + '_gpio4',          self.expand_name('hmc_' + fmc + '_gpio4'),          parent_port=True, dir='inout')
        inst.add_port('spi_' + fmc + '_slen_hmc7044',   self.expand_name('spi_' + fmc + '_slen_hmc7044'),   parent_port=True, dir='out')
        inst.add_port('spi_' + fmc + '_cs_adf4371',     self.expand_name('spi_' + fmc + '_cs_adf4371'),     parent_port=True, dir='out')
        inst.add_port('spi_' + fmc + '_csb_ad9213',     self.expand_name('spi_' + fmc + '_csb_ad9213'),     parent_port=True, dir='out')
        inst.add_port('spi_' + fmc + '_clk',            self.expand_name('spi_' + fmc + '_clk'),            parent_port=True, dir='out')
        inst.add_port('spi_' + fmc + '_data',           self.expand_name('spi_' + fmc + '_data'),           parent_port=True, dir='inout')
        inst.add_port('adc_' + fmc + '_pdwn',           self.expand_name('adc_' + fmc + '_pdwn'),           parent_port=True, dir='out')
        inst.add_port('adc_' + fmc + '_rstb',           self.expand_name('adc_' + fmc + '_rstb'),           parent_port=True, dir='out')
        inst.add_port('adc_' + fmc + '_gpio0',          self.expand_name('adc_' + fmc + '_gpio0'),          parent_port=True, dir='inout')
        inst.add_port('adc_' + fmc + '_gpio1',          self.expand_name('adc_' + fmc + '_gpio1'),          parent_port=True, dir='inout')
        inst.add_port('adc_' + fmc + '_gpio2',          self.expand_name('adc_' + fmc + '_gpio2'),          parent_port=True, dir='inout')
        inst.add_port('adc_' + fmc + '_gpio3',          self.expand_name('adc_' + fmc + '_gpio3'),          parent_port=True, dir='inout')
        inst.add_port('adc_' + fmc + '_gpio4',          self.expand_name('adc_' + fmc + '_gpio4'),          parent_port=True, dir='inout')
        inst.add_port('jesd_' + fmc + '_ref_clk0_p',    self.expand_name('jesd_' + fmc + '_ref_clk0_p'),    parent_port=True, dir='in')
        inst.add_port('jesd_' + fmc + '_ref_clk0_n',    self.expand_name('jesd_' + fmc + '_ref_clk0_n'),    parent_port=True, dir='in')
        inst.add_port('jesd_' + fmc + '_ref_clk1_p',    self.expand_name('jesd_' + fmc + '_ref_clk1_p'),    parent_port=True, dir='in')
        inst.add_port('jesd_' + fmc + '_ref_clk1_n',    self.expand_name('jesd_' + fmc + '_ref_clk1_n'),    parent_port=True, dir='in')
        inst.add_port('jesd_' + fmc + '_sysref1_clk_p', self.expand_name('jesd_' + fmc + '_sysref1_clk_p'), parent_port=True, dir='in')
        inst.add_port('jesd_' + fmc + '_sysref1_clk_n', self.expand_name('jesd_' + fmc + '_sysref1_clk_n'), parent_port=True, dir='in')
        inst.add_port('jesd_' + fmc + '_syncinb_p',     self.expand_name('jesd_' + fmc + '_syncinb_p'),     parent_port=True, dir='out')
        inst.add_port('jesd_' + fmc + '_serdes_0_p',    self.expand_name('jesd_' + fmc + '_serdes_0_p'),    parent_port=True, dir='in', width=8)
        inst.add_port('jesd_' + fmc + '_serdes_0_n',    self.expand_name('jesd_' + fmc + '_serdes_0_n'),    parent_port=True, dir='in', width=8)
        inst.add_port('jesd_' + fmc + '_serdes_1_p',    self.expand_name('jesd_' + fmc + '_serdes_1_p'),    parent_port=True, dir='in', width=8)
        inst.add_port('jesd_' + fmc + '_serdes_1_n',    self.expand_name('jesd_' + fmc + '_serdes_1_n'),    parent_port=True, dir='in', width=8)
        # Simulink Ports
        for i in range(32):
            inst.add_port('adc_' + fmc + '_dout_' + str(i), self.expand_name('adc_' + fmc + '_dout_' + str(i)), width=12, parent_port=False)
        inst.add_port('locked_' + fmc, self.expand_name('locked_' + fmc), width=3, parent_port=False)
        # Data output clock
        inst.add_port('adc_' + fmc + '_clkout', 'fmc_' + fmc + '_clk', parent_port=False)
        
    def expand_name(self, name):
        return self.fullname + '_' + name

    def modify_top(self,top):
        inst = top.get_instance(entity='htg_ad9213_quad_top', name=self.expand_name('inst'))

        # Common ports
        # 200M Clk
        inst.add_port('clk_200_p', self.expand_name('clk_200_p'), dir='in', parent_port=True)
        inst.add_port('clk_200_n', self.expand_name('clk_200_n'), dir='in', parent_port=True)

        for fmc in ['a', 'b', 'c', 'd']:
            top.add_signal('fmc_%s_clk' % fmc) # Connected to core
            top.add_signal('fmc_%s_clk90' % fmc)  # unconnected
            top.add_signal('fmc_%s_clk180' % fmc) # unconnected
            top.add_signal('fmc_%s_clk270' % fmc) # unconnected
            top.assign_signal('fmc_%s_clk90' % fmc, "1'b0")
            top.assign_signal('fmc_%s_clk180' % fmc, "1'b0")
            top.assign_signal('fmc_%s_clk270' % fmc, "1'b0")

        # Simulink reset input
        inst.add_port('reset', self.expand_name('reset'))

        # Uart pins
        if self.use_uart:
            inst.add_port('uart_txd', self.expand_name('uart_txd'), dir='in', parent_port=True)
            inst.add_port('uart_rxd', self.expand_name('uart_rxd'), dir='out', parent_port=True)
        else:
            inst.add_port('uart_txd', "1'b0")
            inst.add_port('uart_rxd', "")

        # TODO. LEDs, Lock signals, etc.

        inst.add_parameter('USE_FMC_A', "1'b1" if self.use_fmc_a else "1'b0")
        inst.add_parameter('USE_FMC_B', "1'b1" if self.use_fmc_b else "1'b0")
        inst.add_parameter('USE_FMC_C', "1'b1" if self.use_fmc_c else "1'b0")
        inst.add_parameter('USE_FMC_D', "1'b1" if self.use_fmc_d else "1'b0")

        if self.use_fmc_a:
            self._add_one_fmc_interface(inst, 'a')
        if self.use_fmc_b:
            self._add_one_fmc_interface(inst, 'b')
        if self.use_fmc_c:
            self._add_one_fmc_interface(inst, 'c')
        if self.use_fmc_d:
            self._add_one_fmc_interface(inst, 'd')
        
    def gen_tcl_cmds(self):
        tcl_cmds = {}
        tcl_cmds['pre_synth'] = []
        if self.use_fmc_a:
            tcl_cmds['pre_synth'] += ['source %s' % self.bd['a']]
        if self.use_fmc_b:
            tcl_cmds['pre_synth'] += ['source %s' % self.bd['b']]
        if self.use_fmc_c:
            tcl_cmds['pre_synth'] += ['source %s' % self.bd['c']]
        if self.use_fmc_d:
            tcl_cmds['pre_synth'] += ['source %s' % self.bd['d']]
        tcl_cmds['pre_synth'] += ['set_property SCOPED_TO_CELLS { microblaze_adc_0 } [get_files adc.elf]']
        return tcl_cmds

    def _gen_constraints_one_fmc_interface(self, fmc):
        """
        Return all constraints associated with ``fmc``.

        :param fmc: FMC port. Either 'a', 'b', 'c', or 'd'
        :type fmc: str
        """

        assert fmc in ['a', 'b', 'c', 'd']

        cons = []
        cons += [PortConstraint(self.expand_name('hmc_' + fmc + '_sync'),           'fmc_' + fmc + '_la_n', iostd='LVCMOS18', iogroup_index=3)]
        cons += [PortConstraint(self.expand_name('hmc_' + fmc + '_reset'),          'fmc_' + fmc + '_la_p', iostd='LVCMOS18', iogroup_index=3)]
        cons += [PortConstraint(self.expand_name('hmc_' + fmc + '_gpio1'),          'fmc_' + fmc + '_la_p', iostd='LVCMOS18', iogroup_index=2)]
        cons += [PortConstraint(self.expand_name('hmc_' + fmc + '_gpio2'),          'fmc_' + fmc + '_la_p', iostd='LVCMOS18', iogroup_index=0)]
        cons += [PortConstraint(self.expand_name('hmc_' + fmc + '_gpio3'),          'fmc_' + fmc + '_la_n', iostd='LVCMOS18', iogroup_index=1)]
        cons += [PortConstraint(self.expand_name('hmc_' + fmc + '_gpio4'),          'fmc_' + fmc + '_la_p', iostd='LVCMOS18', iogroup_index=5)]

        cons += [PortConstraint(self.expand_name('spi_' + fmc + '_clk'),            'fmc_' + fmc + '_la_n', iostd='LVCMOS18', iogroup_index=2)]
        cons += [PortConstraint(self.expand_name('spi_' + fmc + '_data'),           'fmc_' + fmc + '_la_p', iostd='LVCMOS18', iogroup_index=1)]
        cons += [PortConstraint(self.expand_name('spi_' + fmc + '_slen_hmc7044'),   'fmc_' + fmc + '_la_n', iostd='LVCMOS18', iogroup_index=0)]
        cons += [PortConstraint(self.expand_name('spi_' + fmc + '_cs_adf4371'),     'fmc_' + fmc + '_la_n', iostd='LVCMOS18', iogroup_index=16)]
        cons += [PortConstraint(self.expand_name('spi_' + fmc + '_csb_ad9213'),     'fmc_' + fmc + '_la_p', iostd='LVCMOS18', iogroup_index=6)]

        cons += [PortConstraint(self.expand_name('adc_' + fmc + '_pdwn'),           'fmc_' + fmc + '_la_n', iostd='LVCMOS18', iogroup_index=7)]
        cons += [PortConstraint(self.expand_name('adc_' + fmc + '_rstb'),           'fmc_' + fmc + '_la_p', iostd='LVCMOS18', iogroup_index=16)]
        cons += [PortConstraint(self.expand_name('adc_' + fmc + '_gpio0'),          'fmc_' + fmc + '_la_n', iostd='LVCMOS18', iogroup_index=5)]
        cons += [PortConstraint(self.expand_name('adc_' + fmc + '_gpio1'),          'fmc_' + fmc + '_la_n', iostd='LVCMOS18', iogroup_index=4)]
        cons += [PortConstraint(self.expand_name('adc_' + fmc + '_gpio2'),          'fmc_' + fmc + '_la_n', iostd='LVCMOS18', iogroup_index=6)]
        cons += [PortConstraint(self.expand_name('adc_' + fmc + '_gpio3'),          'fmc_' + fmc + '_la_p', iostd='LVCMOS18', iogroup_index=4)]
        cons += [PortConstraint(self.expand_name('adc_' + fmc + '_gpio4'),          'fmc_' + fmc + '_la_n', iostd='LVCMOS18', iogroup_index=12)]

        cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_ref_clk0_p'),    'fmc_' + fmc + '_gbtclk_m2c_p', iogroup_index=0)]
        cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_ref_clk0_n'),    'fmc_' + fmc + '_gbtclk_m2c_n', iogroup_index=0)]
        cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_ref_clk1_p'),    'fmc_' + fmc + '_gbtclk_m2c_p', iogroup_index=1)]
        cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_ref_clk1_n'),    'fmc_' + fmc + '_gbtclk_m2c_n', iogroup_index=1)]
        cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_sysref1_clk_p'), 'fmc_' + fmc + '_clk_m2c_p', iogroup_index=0)]
        cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_sysref1_clk_n'), 'fmc_' + fmc + '_clk_m2c_n', iogroup_index=0)]
        cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_syncinb_p'),     'fmc_' + fmc + '_la_p', iostd='LVCMOS18', iogroup_index=10)]
        # Set by IP
        #cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_serdes_0_p'),    'fmc_' + fmc + 'XXXXX', iogroup_index=2)]
        #cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_serdes_0_n'),    'fmc_' + fmc + 'XXXXX', iogroup_index=2)]
        #cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_serdes_1_p'),    'fmc_' + fmc + 'XXXXX', iogroup_index=2)]
        #cons += [PortConstraint(self.expand_name('jesd_' + fmc + '_serdes_1_n'),    'fmc_' + fmc + 'XXXXX', iogroup_index=2)]
        cons += [ClockConstraint(self.expand_name('jesd_' + fmc + '_ref_clk0_p'), freq=self.sample_rate / 32)]
        cons += [ClockConstraint(self.expand_name('jesd_' + fmc + '_ref_clk1_p'), freq=self.sample_rate / 32)]
        return cons


    def gen_constraints(self):
        cons = []
        # Common constraints
        cons += [PortConstraint(self.expand_name('clk_200_p'), 'sys_clk_200_p')]
        cons += [PortConstraint(self.expand_name('clk_200_n'), 'sys_clk_200_n')]
        cons += [ClockConstraint(self.expand_name('clk_200_p'), name=self.fullname+"_refclk", freq=200.0)]
        cons += [ClockGroupConstraint('-include_generated_clocks %s_refclk' % self.fullname, '-of_objects -include_generated_clocks [get_nets sys_clk]', 'asynchronous')]


        if self.use_uart:
            cons += [PortConstraint(self.expand_name('uart_txd'), 'usb_tx', iostd='LVCMOS18')]
            cons += [PortConstraint(self.expand_name('uart_rxd'), 'usb_rx', iostd='LVCMOS18')]

        if self.use_fmc_a:
            cons += self._gen_constraints_one_fmc_interface('a')
        if self.use_fmc_b:
            cons += self._gen_constraints_one_fmc_interface('b')
        if self.use_fmc_c:
            cons += self._gen_constraints_one_fmc_interface('c')
        if self.use_fmc_d:
            cons += self._gen_constraints_one_fmc_interface('d')

        return cons

        
