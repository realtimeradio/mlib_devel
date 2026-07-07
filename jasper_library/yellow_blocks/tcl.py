import os
from .yellow_block import YellowBlock

class tcl(YellowBlock):
    def initialize(self):
        if not os.path.isfile(self.tcl_file):
            raise RuntimeError('tcl file %s does not exist!' % self.tcl_file)

    def gen_tcl_cmds(self):
        cmds = [] 
        with open(self.tcl_file, 'r') as fh:
            for line in fh.readlines():
                cmds += [line]
        return {self.stage:cmds}
