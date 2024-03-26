%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
%   Center for Astronomy Signal Processing and Electronics Research           %
%   http://seti.ssl.berkeley.edu/casper/                                      %
%   Copyright (C) 2007 Terry Filiba, Aaron Parsons                            %
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

function first_tap_init(blk, varargin)
% Initialize and configure the first tap of the Polyphase Filter Bank.
%
% first_tap_init(blk, varargin)
%
% blk = The block to configure.
% varargin = {'varname', 'value', ...} pairs
% 
% Valid varnames for this block are:
% PFBSize = The size of the PFB
% CoeffBitWidth = Bitwidth of Coefficients.
% TotalTaps = Total number of taps in the PFB
% BitWidthIn = Input Bitwidth
% mult_latency = Latency through each multiplier
% bram_latency = Latency through each BRAM.
% n_inputs = The number of parallel inputs
% fwidth = Scaling of the width of each PFB channel

% Declare any default values for arguments you might like.
defaults = {};
if same_state(blk, 'defaults', defaults, varargin{:}), return, end
check_mask_type(blk, 'first_tap');
munge_block(blk, varargin{:});

TotalTaps = get_var('TotalTaps', 'defaults', defaults, varargin{:});
use_hdl = get_var('use_hdl','defaults', defaults, varargin{:});
use_embedded = get_var('use_embedded','defaults', defaults, varargin{:});
use_shift_reg = get_var('use_shift_reg','defaults', defaults, varargin{:});

set_param([blk,'/Mult'],'use_embedded', use_embedded);
set_param([blk,'/Mult'],'use_behavioral_HDL', use_hdl);
set_param([blk,'/Mult1'],'use_embedded', use_embedded);
set_param([blk,'/Mult1'],'use_behavioral_HDL', use_hdl)

if use_shift_reg == 1
    reuse_block(blk, 'delay_bram', 'casper_library_delays/delay_slr', ...
        'DelayLen', '2^(PFBSize-n_inputs) * n_pol_blocks', ...
        'Position', [345,15,385,55]);
else
    reuse_block(blk, 'delay_bram', 'casper_library_delays/delay_bram', ...
        'DelayLen', '2^(PFBSize-n_inputs) * n_pol_blocks', ...
        'bram_latency', 'bram_latency', ...
        'Position', [345,15,385,55]);
end

fmtstr = sprintf('taps=%d', TotalTaps);
set_param(blk, 'AttributesFormatString', fmtstr);
save_state(blk, 'defaults', defaults, varargin{:});

