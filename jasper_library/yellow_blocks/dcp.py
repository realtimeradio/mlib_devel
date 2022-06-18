import os
from .yellow_block import YellowBlock

class dcp(YellowBlock):
    def initialize(self):
        self.add_source(self.dcp_file)

    def gen_tcl_cmds(self):
       tcl_cmds = {}
       cmd = 'read_checkpoint [get_files %s]' % os.path.basename(self.dcp_file)
       tcl_cmds['post_synth'] = [cmd] # After opening main synthesized design
       return tcl_cmds
        
