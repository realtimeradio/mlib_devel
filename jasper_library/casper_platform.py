import yaml
import os


class Platform(object):
    """
    A class encapsulating information about an FPGA platform.
    """

    def __init__(self, name):
        """
        Constructor. This method will build the platform called <name>,
        scraping details from a yaml configuration file called
        <MLIB_DEVEL_PATH>/jasper_library/platforms/name.yaml
        """
        platdir = os.environ['MLIB_DEVEL_PATH'] + '/jasper_library/platforms'
        conffile = platdir + '/%s.yaml' % name.lower()
        print(conffile)
        if not os.path.isfile(conffile):
            raise RuntimeError('Couldn\'t find platform configuration file '
                               '%s' % conffile)

        with open(conffile, 'r') as fh:
            self.conf = yaml.load(fh.read(), Loader=yaml.Loader)

        print(self.conf)
        #: A dictionary of pin names associated with the platform.
        self._pins = {}
        for pinname, val in self.conf['pins'].items():
            self.add_pins(pinname, val.get('iostd', None), val.get('loc', None), val.get('drive_strength', None), val.get('diff_term', None))
        #: A list of resources present on a platform to facilitate
        #: simple drc checking. Eg. ['qdr0', 'sysclk2x']
        self.provides = self.conf.get('provides', [])
        #: A version number for the underlying hardware
        #: defaults to 1 if none is specified in the yaml configuration
        self.version = self.conf.get('version', 1)
        #: A list of source files/directories required to compile
        #: the template top.v (does NOT include top.v itself)
        self.sources = self.conf.get('sources', [])
        #: A list of constraint files/directories required to compile
        #: the template top.v 
        self.consts = self.conf.get('constraints', [])
        #: FPGA manufacturer
        self.manufacturer = self.conf.get('manufacturer', [])
        #: Platform name. Eg, ROACH, SNAP, etc.
        self.name = self.conf['name']
        #: FPGA model. Should be the full version ready to pass to the
        #: vendor tools. Eg., xc7k325tffg900-2
        self.fpga = self.conf['fpga']
        #: FPGA board (needed along with FPGA model for accelerator cards)
        #: eg. xilinx.com:au50:part0:1.2 for Alveo U50
        if 'board' in self.conf:
            self.board = self.conf['board']
        #: backend target -- used to decide what compiler to use
        self.backend_target = self.conf['backend_target']
        #: boot image --used to determine whether a toolflow, multiboot or golden image

        try:
            self.boot_image = self.conf['boot_image']
        except KeyError:
            self.boot_image = 'toolflow'
        self.user_clk_rate = 100
        self.user_clk = 'user_clk'
        #: project mode -- used to decide what Vivado compiler project
        # mode to use
        #: Default set to true, so project mode is enabled by default (not
        # read from YAML file, As it is up to the user to select which
        # mode must be used)
        self.project_mode = True
        #: This represents the DSP wishbone base address - useful if certain
        # base addresses are important
        try:
            self.dsp_wb_base_address = self.conf['dsp_wb_base_address']
        except KeyError:
            self.dsp_wb_base_address = 0x00010000
        #: This represents the DSP wishbone base address alignment
        try:
            self.dsp_wb_base_address_alignment = \
                self.conf['dsp_wb_base_address_alignment']
        except KeyError:
            self.dsp_wb_base_address_alignment = 4
        # Add respective memory map bus architecture attributes to support AXI4-lite
        try:
            self.mmbus_architecture = self.conf['mmbus_architecture']
            if not isinstance(self.mmbus_architecture, list):
                self.mmbus_architecture = [self.mmbus_architecture]
        except KeyError:
            self.mmbus_architecture = ['wishbone']
        
        # mmbus_base_address is the address the client should use for an AXI transaction
        self.mmbus_base_address = self.conf.get('mmbus_base_address', 0x40000000)
        # axi_ic_base_address is the address the AXI devices consider themselves to have.
        # This may or may not be the same as mmbus_base_address. It will be different
        # if an upstream arbiter is removing the mmbus_base_address before passing
        # on an AXI command
        self.axi_ic_base_address = self.conf.get('axi_ic_base_address', self.mmbus_base_address)
        try:
            self.mmbus_address_alignment = self.conf['mmbus_address_alignment']
        except KeyError:
            self.mmbus_address_alignment = 4
        try:
            self.mmbus_rfdc_base_address = self.conf['mmbus_rfdc_base_address']
        except KeyError:
            self.mmbus_rfdc_base_address = 0xA0800000
        try:
            self.mmbus_xil_base_address = self.conf['mmbus_xil_base_address']
        except KeyError:
            self.mmbus_xil_base_address = []

    def add_pins(self, name, iostd, loc, drive_strength=None, diff_term=None):
        """
        Add a pin to the platform. Generally for use in constructors
        of Platform subclasses.

        :param name: Abstract pin name. Eg., 'zdok0'
        :type name: str
        :param iostd: IO Standard of the pin. Eg., 'LVDS'. Assumes all pins 
            added have the same iostd.
        :type iostd: str
        :param loc: Physical location of the pin. Eg., 'AC12'. Can be a 
            string or a list, if the name
        refers to a bank of pins
        :type loc: str, list of str
        :param drive_strength: Drive strength, if applicable, of pin in mA
        :type drive_strength: int. Assumes all pins added have the same drive strength
        :param diff_term: Use of internal 100 ohm termination for lvds pins
        :type diff_term: str, list of str
        """
        if 'name' not in self._pins:
            self._pins[name] = []

        if not isinstance(loc, list):
            loc = [loc]
        
        self._pins[name] += [Pin(iostd, l, drive_strength=drive_strength, diff_term=diff_term) for l in loc]

    def get_pins(self, name, index=None):
        """
        Return a list of pin objects based on index input.
        If index is integer, return single element

        :param name: Abstract pin name, eg. zdok0
        :type name: str
        :param index: Index of the pin, if the name refers to a bank. 
            Can be None (single pin), integer, or list of pin indices.
        :type index: int,list
        """
        if index is None:
            index = [0]
        if type(index) is not list:
            index = [index]
        try:
            return [self._pins[name][i] for i in index]
        except KeyError:
            raise KeyError('No pin named %s' % name)
        except IndexError:
            raise IndexError('Pin named %s does not have indices '
                             '%s' % (name, index))


class Pin(object):
    """
    A simple class to hold the IO standard and LOCs
    of FPGA pins.
    """
    def __init__(self, iostd, loc, drive_strength=None, diff_term=None):
        """
        iostd should be a string e.g. 'LVDS'
        loc should be string indicating a pin number.
        e.g. 'A21'.
        """
        self.iostd = iostd
        self.loc = loc
        self.drive_strength = drive_strength
        self.diff_term = diff_term

# end
