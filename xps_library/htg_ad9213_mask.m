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


function htg_ad9213_mask(blk, use_fmc_a, use_fmc_b, use_fmc_c, use_fmc_d)

try
  clog('adc16_init: pre same_state','trace');

  check_mask_type(blk, 'htg_ad9213');
  delete_lines(blk);
  %clean_blocks(blk)

  gw_name = clear_name(blk);

  fmcs = {'a', 'b', 'c', 'd'};

  x =  0;
  y = 20;
  in_port_num = 1;
  out_port_num = 1;


  inport_name  = sprintf('reset');
  gateway_name = sprintf('%s_reset', gw_name);
  outport_name = sprintf('reset_term');

  inport_pos  = [x+ 20, y,   x+ 20+30, y+14];
  gateway_pos = [x+100, y-3, x+100+70, y+17];
  outport_pos = [x+210, y,   x+210+30, y+14];

  reuse_block(blk, inport_name, 'built-in/inport', ...
  'Port', num2str(in_port_num), ...
  'Position', inport_pos);

  reuse_block(blk, gateway_name, 'xbsIndex_r4/Gateway Out', ...
     'Position', gateway_pos);

  reuse_block(blk, outport_name, 'built-in/Terminator', ...
     'Position', outport_pos);
  
  add_line(blk, [inport_name,  '/1'], [gateway_name, '/1']);
  add_line(blk, [gateway_name, '/1'], [outport_name, '/1']);
  
  in_port_num = in_port_num + 1;
  y = y + 50;
  
  for fmc_cell=fmcs
    fmc = fmc_cell{1};
    if strcmp(fmc, 'a')
      use_fmc = use_fmc_a;
    elseif strcmp(fmc, 'b')
      use_fmc = use_fmc_b;
    elseif strcmp(fmc, 'c')
      use_fmc = use_fmc_c;
    elseif strcmp(fmc, 'd')
      use_fmc = use_fmc_d;
    end
    if use_fmc == 1
      for lane=0:31
        
        inport_name  = sprintf('adc_%s_sim%d', fmc, lane);
        gateway_name = sprintf('%s_adc_%s_dout%d', gw_name, fmc, lane);
        outport_name = sprintf('adc_%s_dout%d', fmc, lane);

        inport_pos  = [x+ 20, y,   x+ 20+30, y+14];
        gateway_pos = [x+100, y-3, x+100+70, y+17];
        outport_pos = [x+210, y,   x+210+30, y+14];

        reuse_block(blk, inport_name, 'built-in/inport', ...
          'Port', num2str(in_port_num), ...
          'Position', inport_pos);

        reuse_block(blk, gateway_name, 'xbsIndex_r4/Gateway In', ...
          'arith_type', 'Signed', ...
          'n_bits', '12', ...
          'bin_pt', '11', ...
          'Position', gateway_pos);

        reuse_block(blk, outport_name, 'built-in/outport', ...
          'Port', num2str(out_port_num), ...
          'Position', outport_pos);

        add_line(blk, [inport_name,  '/1'], [gateway_name, '/1']);
        add_line(blk, [gateway_name, '/1'], [outport_name, '/1']);

        in_port_num = in_port_num + 1;
        out_port_num = out_port_num + 1;
        y = y + 50;
      end % lanes
      inport_name  = sprintf('locked_%s_sim', fmc);
      gateway_name = sprintf('%s_locked_%s', gw_name, fmc);
      outport_name = sprintf('locked_%s', fmc);

      inport_pos  = [x+ 20, y,   x+ 20+30, y+14];
      gateway_pos = [x+100, y-3, x+100+70, y+17];
      outport_pos = [x+210, y,   x+210+30, y+14];

      reuse_block(blk, inport_name, 'built-in/inport', ...
        'Port', num2str(in_port_num), ...
        'Position', inport_pos);

      reuse_block(blk, gateway_name, 'xbsIndex_r4/Gateway In', ...
        'arith_type', 'Unsigned', ...
        'n_bits', '2', ...
        'bin_pt', '0', ...
        'Position', gateway_pos);

      reuse_block(blk, outport_name, 'built-in/outport', ...
        'Port', num2str(out_port_num), ...
        'Position', outport_pos);

      add_line(blk, [inport_name,  '/1'], [gateway_name, '/1']);
      add_line(blk, [gateway_name, '/1'], [outport_name, '/1']);

      in_port_num = in_port_num + 1;
      out_port_num = out_port_num + 1;
      y = y + 50;
      % Increment column
      x = x + 210+30+50;
      y = 20 + 50;
    end % fmc enabled
  end % fmcs
  clean_blocks(blk)
catch ex
  dump_and_rethrow(ex);
end % try/catch
end % function
