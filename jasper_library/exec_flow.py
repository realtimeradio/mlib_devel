#! /usr/bin/env python

import os
import logging
import toolflow
import time

# A straight lift from StackOverflow...
def shell_source(script):
    """Sometime you want to emulate the action of "source" in bash,
    settings some environment variables. Here is a way to do it."""
    import subprocess, os
    pipe = subprocess.Popen(". %s > /dev/null; env" % script, stdout=subprocess.PIPE, shell=True)
    output = pipe.communicate()[0]
    env = dict((line.split("=", 1) for line in output.splitlines()))
    os.environ.update(env)

os.environ['USE_VIVADO_RUNTIME_FOR_MATLAB'] = '1' #see Xilinx answer record 59236
os.environ['MATLAB_PATH'] = '/tools/MATLAB/R2013a'
#os.environ['XILINX_PATH'] = '/media/overflow/Xilinx/Vivado/2014.2'
os.environ['XILINX_PATH'] = '/tools/ISE/14.6/ISE_DS'
os.environ['MLIB_DEVEL_PATH'] = '/tools/mlib_devel'
os.environ['SYSGEN_SCRIPT'] = os.environ['MLIB_DEVEL_PATH']+'/startsg'
os.environ['MATLAB'] = os.environ['MATLAB_PATH']
os.environ['CASPER_BASE_PATH'] = '/tools/mlib_devel'
os.environ['HDL_ROOT'] = os.environ['CASPER_BASE_PATH']+'/jasper_library/hdl_sources'
shell_source(os.environ['XILINX_PATH']+'/settings64.sh')

from optparse import OptionParser
parser = OptionParser()
parser.add_option("--skipyb", dest="skipyb", action='store_false', default='True',
                  help="skip yellow block peripheral file generation")
parser.add_option("--skipfe", dest="skipfe", action='store_false', default='True',
                  help="skip frontend compilation")
parser.add_option("--skipbe", dest="skipbe", action='store_false', default='True',
                  help="skip backend compilation")
parser.add_option("--be", dest="be", type='string', default='vivado',
                  help="Backend to use. Default: vivado")
parser.add_option("-m", "--model", dest="model", type='string',
                  default='/tools/mlib_devel/jasper_library/test_models/test.slx',
                  help="model to compile")
parser.add_option("-c", "--builddir", dest="builddir", type='string',
                  default='',
                  help="build directory. Default: Use directory with same name as model")

(opts, args) = parser.parse_args()

# get build directory
# use user defined directory else use a directory with same name as model
builddir = opts.builddir or opts.model[:-4]

# logging stuff...
os.system('mkdir -p %s'%builddir)
logger = logging.getLogger('jasper')
logger.setLevel(logging.DEBUG)

handler = logging.FileHandler('%s/jasper.log'%builddir, mode='w')
handler.setLevel(logging.DEBUG)
format = logging.Formatter('%(levelname)s - %(asctime)s - %(name)s - %(message)s')
handler.setFormatter(format)

logger.addHandler(handler)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
logger.addHandler(ch)

logger.info('Starting compile')

if opts.be == 'vivado':
    os.environ['SYSGEN_SCRIPT'] = os.environ['MLIB_DEVEL_PATH']+'/startsg'
if opts.be == 'ise':
    os.environ['SYSGEN_SCRIPT'] = os.environ['MLIB_DEVEL_PATH']+'/startsg_ise'

# initialise the toolflow
toolflow = toolflow.Toolflow(frontend='simulink', backend=opts.be, compile_dir=builddir, frontend_target=opts.model)

toolflow.exec_flow(gen_per=opts.skipyb, frontend_compile=opts.skipfe, backend_compile=opts.skipbe)
