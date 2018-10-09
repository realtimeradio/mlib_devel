from yellow_block import YellowBlock
from yellow_block_typecodes import *

class pmbus_controller(YellowBlock):
    def initialize(self):
        '''
        This function is called by YellowBlocks __init__ method.
        We could override __init__ here, but this seems a little
        bit more user friendly.
        '''
        self.typecode = TYPECODE_SWREG
        self.platform_support = 'all'
        self.requirements = ['wb_clk']
        self.add_source('wb_pmbus_controller')

    def gen_children(self):
        children = YellowBlock.make_block({'tag':'xps:i2c', 'fullpath':'%s/pmbus_controller' % self.name, 'name'='pmbus_controller', 'scl_gpio':'pmbus_clk', 'sda_gpio':'pmbus_data'}, self.platform)
        return children

    def modify_top(self,top):
        module = 'wb_pmbus_controller'
        inst = top.get_instance(entity=module, name=module+'_inst', comment='Power Management Bus Alert->SW-reg')
        inst.add_wb_interface(regname='pmbus_alert', mode='rw', nbytes=4, typecode=self.typecode)
        inst.add_port('pmbus_alert', signal='pmbus_alert', dir='in', parent_sig=True)
        #inst.add_port('pmbus_data', signal='pmbus_data', dir='in', parent_sig=True)
        #inst.add_port('pmbus_clk', signal='pmbus_clk', dir='in', parent_sig=True)

    def gen_contraints(self):
        return [PortConstraint('pmbus_alert', 'pmbus_alert')]
