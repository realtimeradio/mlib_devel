function ospfb_fir_init()
blk = gcb;
check_mask_type(blk, 'xsg_ospfb_fir');
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
    elseif regexp(get_param(gw,'Name'),'(din_ready)$')
        toks = regexp(get_param(gw,'Name'),'(din_ready)$','tokens');
        set_param(gw,'Name',clear_name([blk,'_',toks{1}{1}]));
    else
        error(['Unknown gateway name: ',gw]);
    end
end

% relabel the gateway outs...
gateway_outs = find_system(gcb,'searchdepth',1,'FollowLinks', 'on', 'lookundermasks','all','masktype','Xilinx Gateway Out Block');
for n = 1:length(gateway_outs)
    gw = gateway_outs{n};
    if regexp(get_param(gw,'Name'),'(din)$')
        toks = regexp(get_param(gw,'Name'),'(din)$','tokens');
        set_param(gw,'Name',clear_name([blk,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(din_vld)$')
        toks = regexp(get_param(gw,'Name'),'(din_vld)$','tokens');
        set_param(gw,'Name',clear_name([blk,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(din_sync)$')
        toks = regexp(get_param(gw,'Name'),'(din_sync)$','tokens');
        set_param(gw,'Name',clear_name([blk,'_',toks{1}{1}]));
    elseif regexp(get_param(gw,'Name'),'(dout_ready)$')
        toks = regexp(get_param(gw,'Name'),'(dout_ready)$','tokens');
        set_param(gw,'Name',clear_name([blk,'_',toks{1}{1}]));
    else
        error(['Unknown gateway name: ',gw]);
    end
end
end

