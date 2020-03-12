function idx_1k=timeSwitch(t_1k, t_sync, idx_sync)
    
    tt=t_sync(idx_sync);
    for ti=length(tt):-1:1
        
        [~,idx_1k(ti)]=min(abs(t_1k-tt(ti)));
    end
end