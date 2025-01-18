from math import sin, cos, pi

# Break out of MATLAB's environment
# Complete hack job
def run_in_system_python(code):
    """
    Executes the given Python code in the system's Python interpreter
    and returns the output as a list of values.

    Parameters:
        code (str): Python code to execute. The code must print a JSON-encoded list as output.

    Returns:
        list: The output values returned by the system Python code execution.
    """
    import subprocess
    import json
    # Command to run the system Python
    command = ["python", "-c", code]
    # Execute the code
    result = subprocess.run(command, capture_output=True, check=True)
    return json.loads(result.stdout.strip())

# These window functions duplicated from numpy, because
# importing numpy here breaks MATLAB ?!?

def hanning(M):
  if M < 1:
    return []
  if M == 1:
    return [1.0]
  nlist = range(0, M)
  return [(0.5 - 0.5*cos(2.0*pi*n/(M-1))) for n in nlist]

def blackman(M):
  if M < 1:
    return []
  if M == 1:
    return [1.0]
  nlist = range(0, M)
  return [(0.42 - 0.5*cos(2.0*pi*n/(M-1)) + 0.08*cos(4.0*pi*n/(M-1))) for n in nlist]

def hamming(M):
  if M < 1:
    return []
  if M == 1:
    return [1.0]
  nlist = range(0, M)
  return [(0.54 - 0.46*cos(2.0*pi*n/(M-1))) for n in nlist]

def dpss(M):
    # Break out of whatever MATLAB environment seems to break scipy's linear algebra
    script = "import scipy.signal; import json; v = scipy.signal.windows.dpss(%d, 2.0, None, norm='subsample'); vj = json.dumps([x for x in v]); print(vj)" % M
    return run_in_system_python(script)

def window(wintype, N):
  """
  Try to replicate MATLAB's `window` function.
  Inputs:
    wintype (string) : window type, eg. "hann", "hamming", etc
    N (int)          : Number of window points requested
  This function will try to call numpy.`wintype`(N) to generate the
  desired window.
  """
  # Remap names where we know MATLAB and numpy differ
  # map is {MATLAB name : numpy name}
  remap = {
    "hann" : "hanning",
  }
  wintype = remap.get(wintype, wintype)
  try:
    winmethod = globals()[wintype]
  except KeyError:
    raise RuntimeError("Couldn't find window method '%s'" % wintype)
    return
  #try:
  #  winmethod = getattr(numpy, wintype)
  #except AttributeError:
  #  print("Couldn't find window method numpy.%s" % wintype)
  #  return
  if callable(winmethod):
    return winmethod(N)
  else:
    raise RuntimeError("Attribute numpy.%s is not callable" % wintype)
    return

def sinc(xlist):
  if not isinstance(xlist, list):
      return sinc([xlist])[0]
  rv = []
  for x in xlist:
    try:
      rv += [sin(pi*x) / (pi*x)]
    except ZeroDivisionError:
      rv += [1.0]
  return rv
