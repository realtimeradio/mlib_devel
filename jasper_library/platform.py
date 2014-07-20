class Platform(object):
    '''
    A class encapsulating information about an FPGA platform.
    '''
    @staticmethod
    def get_loader(name):
        if name.startswith('SNAP'):
            return SnapPlatform()
        if name.startswith('KC705'):
            return KC705Platform()
        else:
            raise Exception('Unsupported hardware platform!')

    def __init__(self):
        #: A dictionary of pin names associated with the platform.
        self._pins = {}
        #: A list of resources present on a platform to facilitate
        #: simple drc checking. Eg. ['qdr0', 'sysclk2x']
        self.provides = []
        #: A list of source files/directories required to compile
        #: the template top.v (does NOT include top.v itself)
        self.sources = []
        #: A list of constraint files/directories required to compile
        #: the template top.v 
        self.consts = []
        #: FPGA manufacturer
        self.manufacturer = 'xilinx'
        #: Platform name. Eg, ROACH, SNAP, etc.
        self.name = 'generic'
        #: FPGA model. Should be the full version ready to pass to the
        #: vendor tools. Eg., xc7k325tffg900-2
        self.fpga = 'xc7k325tffg900-2'

    def add_pins(self, name, iostd, loc):
        '''
        Add a pin to the platform. Generally for use in constructors
        of Platform subclasses.

        :param name: Abstract pin name. Eg., 'zdok0'
        :type name: str
        :param iostd: IO Standard of the pin. Eg., 'LVDS'. Assumes all pins added have the same iostd.
        :type iostd: str
        :param locs: Physical location of the pin. Eg., 'AC12'. Can be a string or a list, if the name refers to a bank of pins
        :type locs: str, list of str
        '''
        if not self._pins.has_key('name'):
            self._pins[name] = []

        if not isinstance(loc,list):
            loc = [loc]
        
        self._pins[name] += [Pin(iostd, l) for l in loc]

    def get_pins(self, name, index=[0]):
        '''
        Return a list of pin objects based on index input.
        If index is integer, return single element

        :param name: Abstract pin name, eg. zdok0
        :type name: str
        :param index: Index of the pin, if the name refers to a bank. Can be None (single pin), integer, or list of pin indices.
        :type index: int,list
        '''

        if type(index) is not list: index = [index]
        try:
            return [self._pins[name][i] for i in index]
        except KeyError:
            raise KeyError("No pin named %s"%name)
        except IndexError:
            raise IndexError("Pin named %s does not have indices %s"%(name, index))


class Pin(object):
    '''
    A simple class to hold the IO standard and LOCs
    of FPGA pins.
    '''
    def __init__(self, iostd, loc):
        '''
        iostd should be a string e.g. 'LVDS'
        locs should be string indicating a pin number.
        e.g. 'A21'.
        '''
        self.iostd = iostd
        self.loc = loc

class SnapPlatform(Platform):
    def __init__(self):
        Platform.__init__(self)
        self.manufacturer = 'Xilinx'
        self.fpga= 'xc7k160tffg676-2'
        self.name = 'snap'
        self.provides = ['sys_clk', 'sys_clk90', 'sys_clk180', 'sys_clk270', 'wb_clk', 'zdok0']
        self.consts   = ['snap.xdc', 'snap.ucf']
        self.sources  = ['infrastructure', 'spi_wb_bridge',
                        'wbs_arbiter', 'sys_block']
        # pin constraints
        # You only need to include things here
        # which aren't defined by the base package
        self.add_pins('miso', 'LVCMOS25', 'AA27')
        self.add_pins('mosi', 'LVCMOS25', 'AB28')
        self.add_pins('sclk', 'LVCMOS25', 'AA25')
        self.add_pins('cs_n', 'LVCMOS25', 'AB25')
        self.add_pins('gpio_led4', 'LVCMOS25', 'F13')
        self.add_pins('led0', 'LVCMOS25', 'D13')
        zdok_pins = [
        'AA23',
        'AB24',
        'Y25',
        'Y26',
        'U24',
        'U25',
        'U19',
        'U20',
        'T24',
        'T25',
        'M21',
        'M22',
        'M24',
        'L24',
        'L22',
        'K22',
        'J24',
        'J25',
        'G25',
        'G26',
        'Y22',
        'AA22',
        'Y23',
        'AA24',
        'V23',
        'V24',
        'R22',
        'R23',
        'R21',
        'P21',
        'P23',
        'N23',
        'K25',
        'K26',
        'K23',
        'J23',
        'H21',
        'G21',
        'G22',
        'F23',
        'AE23',
        'AF23',
        'AC23',
        'AC24',
        'W23',
        'W24',
        'T22',
        'T23',
        'R18',
        'P18',
        'N18',
        'M19',
        'N19',
        'M20',
        'J21',
        'H22',
        'G24',
        'F24',
        'D23',
        'D24',
        'AE22',
        'AF22',
        'AB26',
        'AC26',
        'V21',
        'W21',
        'U17',
        'T17',
        'R16',
        'R17',
        'P19',
        'P20',
        'P16',
        'N17',
        'J26',
        'H26',
        'E25',
        'D25',
        'F22',
        'E23',
        ]
 
        self.add_pins('zdok0', 'LVCMOS25', zdok_pins)
 
        zdok_pins_p = [
        'AA23',
        'Y25',
        'U24',
        'U19',
        'T24',
        'M21',
        'M24',
        'L22',
        'J24',
        'G25',
        'Y22',
        'Y23',
        'V23',
        'R22',
        'R21',
        'P23',
        'K25',
        'K23',
        'H21',
        'G22',
        'E23',
        'AC23',
        'W23',
        'T22',
        'R18',
        'N18',
        'N19',
        'J21',
        'G24',
        'D23',
        'AE22',
        'AB26',
        'V21',
        'U17',
        'R16',
        'P19',
        'P16',
        'J26',
        'E25',
        'F22',
        ]
 
        zdok_pins_n = [
        'AB24',
        'Y26',
        'U25',
        'U20',
        'T25',
        'M22',
        'L24',
        'K22',
        'J25',
        'G26',
        'AA22',
        'AA24',
        'V24',
        'R23',
        'P21',
        'N23',
        'K26',
        'J23',
        'G21',
        'F23',
        'AF23',
        'AC24',
        'W24',
        'T23',
        'P18',
        'M19',
        'M20',
        'H22',
        'F24',
        'D24',
        'AF22',
        'AC26',
        'W21',
        'T17',
        'R17',
        'P20',
        'N17',
        'H26',
        'D25',
        'E23',
        ]
 
        self.add_pins('zdok0_p', 'LVDS_25', zdok_pins_p)
        self.add_pins('zdok0_n', 'LVDS_25', zdok_pins_n)
        self.add_pins('eth_clk_p', None, 'K6')
        self.add_pins('eth_clk_n', None, 'K5')
        self.add_pins('mgt_tx_p0', None, 'P2')
        self.add_pins('mgt_tx_n0', None, 'P1')
        self.add_pins('mgt_rx_p0', None, 'R4')
        self.add_pins('mgt_rx_n0', None, 'R3')

       
class KC705Platform(Platform):
    def __init__(self):
        Platform.__init__(self)
        self.manufacturer = 'xilinx'
        self.fpga= 'xc7k325tffg900-2'
        self.name = 'kc705'
        self.provides = ['sys_clk', 'sys_clk90', 'sys_clk180', 'sys_clk270', 'wb_clk']
        self.consts   = ['kc705.xdc', 'kc705.ucf']
        self.sources  = ['infrastructure', 'spi_wb_bridge',
                        'wbs_arbiter', 'sys_block']
        # pin constraints
        # You only need to include things here
        # which aren't defined by the base package
        self.add_pins('miso', 'LVCMOS25', 'AA27')
        self.add_pins('mosi', 'LVCMOS25', 'AB28')
        self.add_pins('sclk', 'LVCMOS25', 'AA25')
        self.add_pins('cs_n', 'LVCMOS25', 'AB25')
        self.add_pins('gpio_led4', 'LVCMOS25', 'AE26')
        self.add_pins('led', 'LVCMOS25', 'E18')
