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


function white_rabbit_init(blk, varargin)

try
  clog('white_rabbit_init: pre same_state','trace');
  defaults = { ...
    'block_name', blk, ...
  };
  if same_state(blk, 'defaults', defaults, varargin{:}), return, end
  clog('white_rabbit_init: post same_state','trace');

  check_mask_type(blk, 'white_rabbit');
  munge_block(blk, varargin{:});
  delete_lines(blk);

  gw_name = clear_name(blk);

  x =  0;
  y = 20;

  sigs  = {'pps', 'led_link', 'led_act'};
  types = {'Boolean', 'Boolean', 'Boolean'};
  widths = {'1', '1', '1'};
  bps    = {'0', '0', '0'};

  port_num = 1;
  for sig=1:3
    inport_name  = sprintf('%s_sim', sigs{sig});
    gateway_name = sprintf('%s_%s', gw_name, sigs{sig});
    outport_name = sprintf('%s', sigs{sig});

    inport_pos  = [x+ 20, y,   x+ 20+30, y+14];
    gateway_pos = [x+100, y-3, x+100+70, y+17];
    outport_pos = [x+210, y,   x+210+30, y+14];
    y = y + 50;

    reuse_block(blk, inport_name, 'built-in/inport', ...
      'Port', num2str(port_num), ...
      'Position', inport_pos);

    reuse_block(blk, gateway_name, 'xbsIndex_r4/Gateway In', ...
      'arith_type', types{sig}, ...
      'n_bits', widths{sig}, ...
      'bin_pt', bps{sig}, ...
      'Position', gateway_pos);

    reuse_block(blk, outport_name, 'built-in/outport', ...
      'Port', num2str(port_num), ...
      'Position', outport_pos);


    add_line(blk, [inport_name,  '/1'], [gateway_name, '/1']);
    h=add_line(blk, [gateway_name, '/1'], [outport_name, '/1']);
    set_param(h, 'Name', outport_name);
    port_num = port_num + 1;
  end

  clean_blocks(blk);

  save_state(blk, 'defaults', defaults, varargin{:});

  clog('white_rabbit_init: exiting','trace');

catch ex
  dump_and_rethrow(ex);
end % try/catch
end % function
