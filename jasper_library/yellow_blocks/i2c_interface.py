from .yellow_block import YellowBlock
from constraints import PortConstraint, RawConstraint

class i2c_interface(YellowBlock):
    def initialize(self):
        '''
        This function is called by YellowBlocks __init__ method.
        We could override __init__ here, but this seems a little
        bit more user friendly.
        '''
        self.platform_support = 'all'
        self.requirements = ['wb_clk']
        self.add_source('i2c/*.v')

        # Create a name for the external pins, which depends on the type of yellow block,
        # but not the model name (i.e., NOT self.fullname). This makes PR easier since
        # the top-level interface doesn't vary between models.
        self.sda_portname = "i2c_{sda_gpio}{sda_index}_sda_io".format(
            sda_gpio=self.sda_gpio, sda_index=self.sda_gpio_index)
        self.scl_portname = "i2c_{scl_gpio}{scl_index}_scl_io".format(
            scl_gpio=self.scl_gpio, scl_index=self.scl_gpio_index)

    def modify_top(self, top):
        module = 'i2c_master_top'
        inst = top.get_instance(entity=module, name=self.fullname)
        inst.add_wb_interface(regname=self.unique_name, mode='rw', nbytes=4*16)
        inst.add_parameter('ARST_LVL', '1\'b1')
        inst.add_port('arst_i', signal='1\'b0')

        inst.add_port('scl_pad_i', self.fullname + '_scl_pad_i')
        inst.add_port('scl_pad_o', self.fullname + '_scl_pad_o')
        inst.add_port('scl_padoen_o', self.fullname + '_scl_padoen_o')
        inst.add_port('sda_pad_i', self.fullname + '_sda_pad_i')
        inst.add_port('sda_pad_o', self.fullname + '_sda_pad_o')
        inst.add_port('sda_padoen_o', self.fullname + '_sda_padoen_o')

        # Infrastructure module, with IOBUFs

        module = 'i2c_infrastructure'
        inst = top.get_instance(entity=module, name=self.fullname + '_infra')
        inst.add_port('scl_pad_i', self.fullname + '_scl_pad_o')
        inst.add_port('scl_pad_o', self.fullname + '_scl_pad_i')
        inst.add_port('scl_padoen_i', self.fullname + '_scl_padoen_o')
        inst.add_port('sda_pad_i', self.fullname + '_sda_pad_o')
        inst.add_port('sda_pad_o', self.fullname + '_sda_pad_i')
        inst.add_port('sda_padoen_i', self.fullname + '_sda_padoen_o')
        inst.add_port('scl_io', self.scl_portname, dir='inout', parent_port = True, width = 1)
        inst.add_port('sda_io', self.sda_portname, dir='inout', parent_port = True, width = 1)

    def gen_constraints(self):
        consts = []
        consts += [PortConstraint(self.scl_portname, self.scl_gpio, port_index=[0], iogroup_index=[self.scl_gpio_index])]
        consts += [PortConstraint(self.sda_portname, self.sda_gpio, port_index=[0], iogroup_index=[self.sda_gpio_index])]
        consts += [RawConstraint('set_property SLEW SLOW [get_ports %s]' % (self.scl_portname))]
        consts += [RawConstraint('set_property SLEW SLOW [get_ports %s]' % (self.sda_portname))]
        return consts

