%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%   Center for Astronomy Signal Processing and Electronics Research           %
%   http://seti.ssl.berkeley.edu/casper/                                      %
%   Copyright (C) 2013 David MacMahon
%                                                                             %
%   This program is free software; you can redistribute it and/or modify      %
%   it under the terms of the GNU General Public License as published by      %
%   the Free Software Foundation; either version 2 of the License, or         %
%   (at your option) any later version.                                       %
%                                                                             %
%   This program is distributed in the hope that it will be useful,           %
%   but WITHOUT ANY WARRANTY; without even the implied warranty of            %
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             %
%   GNU General Public License for more details.                              %
%                                                                             %
%   You should have received a copy of the GNU General Public License along   %
%   with this program; if not, write to the Free Software Foundation, Inc.,   %
%   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.               %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function adc1x12_10g_init(blk, varargin)

try
  clog('adc1x12_10g_init: pre same_state','trace');
  defaults = { ...
    'block_name', blk, ...
  };
  if same_state(blk, 'defaults', defaults, varargin{:}), return, end
  clog('adc1x12_10g_init: post same_state','trace');

  check_mask_type(blk, 'adc1x12_10g');
  munge_block(blk, varargin{:});
  delete_lines(blk);

  gw_name = clear_name(blk);

  x =  0;
  y = 80;

  outputwidth=12;
  binarypoint=11;

  for channel=1:32
    port_num = num2str(channel);
    inport_name  = sprintf('in%d_sim', channel);
    gateway_name = sprintf('in_%s%d', gw_name, channel);
    outport_name = sprintf('out%d', channel);
  
    inport_pos  = [x+ 20, y,   x+ 20+30, y+14];
    gateway_pos = [x+100, y-3, x+100+70, y+17];
    outport_pos = [x+210, y,   x+210+30, y+14];
    y = y + 50;
  
    reuse_block(blk, inport_name, 'built-in/inport', ...
      'Port', port_num, ...
      'Position', inport_pos);
    
    reuse_block(blk, gateway_name, 'xbsIndex_r4/Gateway In', ...
      'arith_type', 'Signed', ...
      'n_bits', num2str(outputwidth), ...
      'bin_pt', num2str(binarypoint), ...
      'Position', gateway_pos);
    
    reuse_block(blk, outport_name, 'built-in/outport', ...
      'Port', port_num, ...
      'Position', outport_pos);
    
    
    add_line(blk, [inport_name,  '/1'], [gateway_name, '/1']);
    h=add_line(blk, [gateway_name, '/1'], [outport_name, '/1']);
    set_param(h, 'Name', outport_name);
  end 

  clean_blocks(blk);

  save_state(blk, 'defaults', defaults, varargin{:});

  clog('adc1x12_10g_init: exiting','trace');

catch ex
  dump_and_rethrow(ex);
end % try/catch
end % function
