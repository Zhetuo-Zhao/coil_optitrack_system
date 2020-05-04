function eyePos=eyePosition(head,eyeProbe,R_opti2room,eyeProbeFrames,eyeIdx)
    
    for ii=eyeIdx
        eye_pos_c_room=R_opti2room*eyeProbe.offsetLoc{ii}; 
        headXYZc_room=[mean(head.XYZ_room{1}(:,eyeProbeFrames{ii}),2) mean(head.XYZ_room{2}(:,eyeProbeFrames{ii}),2) mean(head.XYZ_room{3}(:,eyeProbeFrames{ii}),2)];
        headPosc_room=mean(head.pos(:,eyeProbeFrames{ii}),2);
        EyeInHead_vector=headXYZc_room'*(eye_pos_c_room-headPosc_room);

        for t=length(head.qh_room):-1:1
            eyePos{ii}(:,t)=head.pos(:,t)+[head.XYZ_room{1}(:,t) head.XYZ_room{2}(:,t) head.XYZ_room{3}(:,t)]*EyeInHead_vector;  % room coordinate
        end
        
    end

end
