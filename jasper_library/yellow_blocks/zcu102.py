from .yellow_block import YellowBlock
from clk_factors import clk_factors
from constraints import ClockConstraint, GenClockConstraint, ClockGroupConstraint, PortConstraint, RawConstraint

import os
from os import environ as env

class zcu102(YellowBlock):
    def initialize(self):
        self.ips = [{'path':'%s/axi_wb_bridge/ip_repo' % env['HDL_ROOT'],'name':'axi_slave_wishbone_classic_master','vendor':'peralex.com','library':'user','version':'1.0'}]
        self.add_source('infrastructure/zcu102_clk_adc_infrastructure.sv')
        self.add_source('infrastructure/zcu102_clk_125_infrastructure.sv')
        self.add_source('utils/cdc_synchroniser.vhd')
        self.add_source('axi_wb_bridge/ip_repo/peralex.com_user_axi_slave_wishbone_classic_master_1.0/axi_slave_wishbone_classic_master.vhd')
        self.add_source('wbs_arbiter')

        # create reference to block design name
        self.blkdesign = '{:s}_bd'.format(self.platform.conf['name'])

        if self.clk_src == "clk_125":
          self.pl_clk_mhz = 125.00
        elif self.clk_src == "adc0_clk":
          self.pl_clk_mhz = 200.00
          #self.platform.user_clk_rate = 200
        elif self.clk_src == "adc1_clk":
          self.pl_clk_mhz = 200.00
          #self.platform.user_clk_rate = 200
        elif self.clk_src == "qsfp_gtrefclk_0":
          self.pl_clk_mhz = 156.25
          #self.platform.user_clk_rate = 200
        else:
          self.throw_error("clk rate not specified")

        self.T_pl_clk_ns = 1.0/self.pl_clk_mhz*1000

        self.provides.append(self.clk_src)
        self.provides.append(self.clk_src+'90')
        self.provides.append(self.clk_src+'180')
        self.provides.append(self.clk_src+'270')
        self.provides.append(self.clk_src+'_rst')

        self.provides.append('sys_clk')
        self.provides.append('sys_rst')

        # TODO: is a bug that `axi4lite_interconnect` does not make a `requires` on `axil_clk`.
        # Looking into this more: the `_drc` check on YB requires/provides is done in `gen_periph_objs` but the `axi4lite_interconnect`
        # is not done until later within `generate_hdl > _instantiate_periphs` there fore by-passing any checks done
        self.provides.append('axil_clk')    # from block design
        self.provides.append('axil_rst_n')  # from block desgin

        self.requires.append('M_AXI') # axi4lite interface from block design

    def modify_top(self, top):
        top.assign_signal('axil_clk', 'pl_sys_clk')
        #top.assign_signal('axil_rst', 'axil_rst')
        top.assign_signal('axil_rst_n', 'axil_arst_n') # TODO RENAME the board design one `axil_arst_n`
        top.assign_signal('sys_clk', 'pl_sys_clk')
        top.assign_signal('sys_rst', '~axil_arst_n')
        
        top.add_signal(self.clk_src+'90')
        top.add_signal(self.clk_src+'180')
        top.add_signal(self.clk_src+'270')

        # generate clock parameters to use pl_clk to drive as the user IP clock
        # TODO: will need to make changes when other user ip clk source options provided
        clkparams = clk_factors(self.pl_clk_mhz, self.platform.user_clk_rate, vco_min=800.0, vco_max=1600.0)

        if self.clk_src == "clk_125":
          inst_infr = top.get_instance('zcu102_clk_125_infrastructure', 'zcu102_clk_infr_inst')
          inst_infr.add_parameter('PERIOD', "{:0.3f}".format(self.T_pl_clk_ns))
          inst_infr.add_parameter('MULTIPLY', clkparams[0])
          inst_infr.add_parameter('DIVIDE',   clkparams[1])
          inst_infr.add_parameter('DIVCLK',   clkparams[2])
          inst_infr.add_port('pl_clk_p',      "{:s}_p".format(self.clk_src), dir='in',  parent_port=True)
          inst_infr.add_port('pl_clk_n',      "{:s}_n".format(self.clk_src), dir='in',  parent_port=True)
          #inst_infr.add_port('pl_clk',      "{:s}".format(self.clk_src), dir='in',  parent_port=True)
          inst_infr.add_port('adc_clk', '{:s}'.format(self.clk_src))
          inst_infr.add_port('adc_clk90', '{:s}90'.format(self.clk_src))
          inst_infr.add_port('adc_clk180', '{:s}180'.format(self.clk_src))
          inst_infr.add_port('adc_clk270', '{:s}270'.format(self.clk_src))
          inst_infr.add_port('mmcm_locked', 'mmcm_locked', dir='out', parent_port=True)
        #elif self.clk_src == "qsfp_gtrefclk_0":
          #top.create_net('{:s}90'.format(self.clk_src))
          #top.create_net('{:s}180'.format(self.clk_src))
          #top.create_net('{:s}270'.format(self.clk_src))
        #else:
          #inst_infr = top.get_instance('zcu102_clk_adc_infrastructure', 'zcu102_clk_infr_inst')
          #inst_infr.add_parameter('PERIOD', "{:0.3f}".format(self.T_pl_clk_ns))
          #inst_infr.add_parameter('MULTIPLY', clkparams[0])
          #inst_infr.add_parameter('DIVIDE',   clkparams[1])
          #inst_infr.add_parameter('DIVCLK',   clkparams[2])
          #inst_infr.add_port('pl_clk',      "{:s}".format(self.clk_src))
          ##inst_infr.add_port('pl_clk',      'temp_clk')
          #inst_infr.add_port('adc_clk', '{:s}'.format(self.clk_src))
          #inst_infr.add_port('adc_clk90', '{:s}90'.format(self.clk_src))
          #inst_infr.add_port('adc_clk180', '{:s}180'.format(self.clk_src))
          #inst_infr.add_port('adc_clk270', '{:s}270'.format(self.clk_src))
          #inst_infr.add_port('mmcm_locked', 'mmcm_locked', dir='out', parent_port=True)

        #bd_inst = top.get_instance(self.blkdesign, '{:s}_inst'.format(self.blkdesign))
        #bd_inst.add_wb_interface(self.name, mode='rw', nbytes=2**40)
        #bd_inst.assign_address('mpsoc/Data', 'axi_slave_wishbone_c_0/S_AXI/reg0', '0xA0000000', '0x00200000')
        #bd_inst.assign_address('mpsoc/Data', 'M_AXI/Reg', '0xB0000000', '0x00200000')

    def gen_children(self):
        children = []
        #children.append(YellowBlock.make_block({'tag': 'xps:sys_block', 'board_id': '163', 'rev_maj': '2', 'rev_min': '0', 'rev_rcs': '1'}, self.platform))
        children.append(YellowBlock.make_block({'fullpath': self.fullpath, 'tag': 'xps:sys_block', 'board_id': '163', 'rev_maj': '2', 'rev_min': '0', 'rev_rcs': '1'}, self.platform))
        #bd_inst = top.get_instance(self.blkdesign, '{:s}_inst'.format(self.blkdesign))

        # instance block design containing mpsoc, and axi protocol converter for casper
        # mermory map (HPM0)
        zynq_blk = {
            'tag'     : 'xps:zynq_usplus',
            'name'    : 'mpsoc',
            'presets' : 'zcu102_mpsoc',
            'maxi_0'  : {'conf': {'enable': 1, 'data_width': 32}, 'intf': {'dest': 'axi_slave_wishbone_c_0/S_AXI'}},
            'maxi_1'  : {'conf': {'enable': 1, 'data_width': 32},  'intf': {'dest': 'axi_proto_conv/S_AXI'}},
            #'maxi_1'  : {'conf': {'enable': 0, 'data_width': 32}, 'intf': {}},
            'maxi_2'  : {'conf': {'enable': 0, 'data_width': 32}, 'intf': {}}
        }
        children.append(YellowBlock.make_block(zynq_blk, self.platform))

        proto_conv_blk = {
            'tag'             : 'xps:axi_protocol_converter',
            'name'            : 'axi_proto_conv',
            'saxi_intf'       : {'dest': 'mpsoc/M_AXI_HPM1_FPD'},
            'maxi_intf'       : {'dest': 'M_AXI'},
            'aruser_wid'      : 0,
            'awuser_wid'      : 0,
            'buser_wid'       : 0,
            'data_wid'        : 32,
            'id_wid'          : 16,
            'mi_protocol'     : 'AXI4LITE',
            'rw_mode'         : 'READ_WRITE',
            'ruser_wid'       : 0,
            'si_protocol'     : 'AXI4',
            'translation_mode': 2,
            'wuser_wid'       : 0
        }
        children.append(YellowBlock.make_block(proto_conv_blk, self.platform))

        axi_wishbone_bridge = {
            'tag'             : 'xps:axi_wb_bridge',
            'name'            : 'axi_slave_wishbone_c_0',
            'saxi_intf'       : {'dest': 'mpsoc/M_AXI_HPM0_FPD'},
            'id_wid'          : 16,
            'data_wid'        : 32,
            'addr_wid'        : 32,
            'awuser_wid'      : 0,
            'aruser_wid'      : 0,
            'wuser_wid'       : 0,
            'ruser_wid'       : 0,
            'buser_wid'       : 0
        }
        children.append(YellowBlock.make_block(axi_wishbone_bridge, self.platform))

        return children

    def gen_constraints(self):
        cons = []
        #cons.append(ClockConstraint('pl_sys_clk', name='pl_sys_clk', freq=100))
        #cons.append(RawConstraint('create_clock -period 10.000 -name pl_sys_clk -waveform {0.000 5.000} [get_nets zcu102_bd_inst/pl_sys_clk]'))
        #cons.append(ClockConstraint('{:s}_inst/pl_sys_clk'.format(self.blkdesign), name='pl_sys_clk', freq=100))
        if self.clk_src == "clk_125":
          cons.append(ClockConstraint('{:s}_p'.format(self.clk_src), '{:s}_p'.format(self.clk_src), period=self.T_pl_clk_ns, port_en=True, virtual_en=False))
          cons.append(PortConstraint('{:s}_p'.format(self.clk_src), '{:s}_p'.format(self.clk_src)))
        #cons.append(GenClockConstraint(signal='{:s}'.format(self.clk_src), name='{:s}'.format(self.clk_src), clock_source='zcu216_clk_infr_inst/pl_clk_p', divide_by=1))
          #cons.append(GenClockConstraint(signal='{:s}'.format(self.clk_src), name='{:s}'.format(self.clk_src), clock_source='{:s}_inst/pl_sys_clk'.format(self.blkdesign), divide_by=1))

        # TODO: tweak this until we have the right reference clocks
        #cons.append(ClockGroupConstraint('clk_pl_0', 'pl_clk_mmcm', 'asynchronous'))
        #cons.append(ClockGroupConstraint('{:s}_p'.format(self.clk_src), 'zcu216_clk_infr_inst/pl_clk_p', 'asynchronous'))
        if self.clk_src == "clk_125":
          cons.append(RawConstraint('set_clock_groups -name %s_p -asynchronous -group [get_clocks -include_generated_clocks %s_p] -group [get_clocks -include_generated_clocks zcu102_clk_125_infrastructure/pl_clk_p]' % (self.clk_src, self.clk_src)))
          cons.append(RawConstraint('set_property -dict { PACKAGE_PIN AL12 IOSTANDARD LVCMOS33} [get_ports { mmcm_locked }]'))

        return cons


    def gen_tcl_cmds(self):
        tcl_cmds = {}
        tcl_cmds['init'] = []
        tcl_cmds['pre_synth'] = []
        # Force user_const.xdc to be processed at LATE stage.
        # This line will get dropped into the final “gogogo.tcl” after the user_const.xdc is imported.
        #tcl_cmds['pre_synth'] += ['set_property PROCESSING_ORDER LATE [get_files [get_property directory [current_project]]/myproj.srcs/constrs_1/imports/zcu102_twoboards/user_const.xdc]']
        #tcl_cmds['pre_synth'] += ['set_property PROCESSING_ORDER LATE [get_files [get_property directory [current_project]]/myproj.srcs/constrs_1/imports/zcu102_f_200msps_64i_4096c/user_const.xdc]']
        
        tcl_cmds['post_synth'] = []
        # export hardware design xsa for software
        tcl_cmds['post_bitgen'] = []
        # TODO: $xsa_file comes from the backends class. Could re-write the path here but $xsa_file exists, use it instead.
        # This then begs the question as to if there should be some sort of known tcl variables to check against
        tcl_cmds['post_bitgen'] += ['write_hw_platform -fixed -include_bit -force -file $xsa_file']

        return tcl_cmds


