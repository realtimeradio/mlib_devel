function adi_jesd_init()
blk = gcb;
check_mask_type(blk, 'xsg_adi_jesd');
% relabel the gateway ins...
gateway_ins = find_system(gcb,'searchdepth',1,'FollowLinks', 'on', 'lookundermasks','all','masktype','Xilinx Gateway In Block');
for n = 1:length(gateway_ins)
    gw = gateway_ins{n};
    if regexp(get_param(gw,'Name'),'(dout)$')
        toks = regexp(get_param(gw,'Name'),'(dout)$','tokens');
        set_param(gw,'Name',clear_name([blk,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(dout_vld)$')
        toks = regexp(get_param(gw,'Name'),'(dout_vld)$','tokens');
        set_param(gw,'Name',clear_name([blk,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(dout_sync)$')
        toks = regexp(get_param(gw,'Name'),'(dout_sync)$','tokens');
        set_param(gw,'Name',clear_name([blk,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(dout_overflow)$')
        toks = regexp(get_param(gw,'Name'),'(dout_overflow)$','tokens');
        set_param(gw,'Name',clear_name([blk,'_',toks{1}{1}]));
    else
        error(['Unknown gateway name: ',gw]);
    end
end
end

