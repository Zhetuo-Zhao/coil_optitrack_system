function eye=eye_process(R_opti2room,eyeCoil,head,eyeProbe,eyeProbeFrames,ninePtsFrames)
    for ii=1:length(eyeProbeFrames)
        eye_pos_c_room=R_opti2room*eyeProbe.offsetLoc{ii}; 
        headXYZc_room=[mean(head.XYZ_room{1}(:,eyeProbeFrames{ii}),2) mean(head.XYZ_room{2}(:,eyeProbeFrames{ii}),2) mean(head.XYZ_room{3}(:,eyeProbeFrames{ii}),2)];
        headPosc_room=mean(head.pos(:,eyeProbeFrames{ii}),2);
        EyeInHead_vector=headXYZc_room'*(eye_pos_c_room-headPosc_room);

        for t=length(head.qh_room):-1:1
            eye.pos{ii}(:,t)=head.pos(:,t)+[head.XYZ_room{1}(:,t) head.XYZ_room{2}(:,t) head.XYZ_room{3}(:,t)]*EyeInHead_vector;  % room coordinate
        end

        if ~isempty(eyeCoil{ii})
            eye.coilraw=eyeCoil{ii}; 
            eye.coilVt=field_compensate(estField, eye.coilraw, eye.pos);


            eye.coilVc=mean(eye.coilVt(:,ninePtsFrames),2);

            for t=size(eye.pos,2):-1:1
                Re_r=vec2rtM2(eye.coilVc,eye.coilVt(:,t));
                eye.qe_room(t)=quaternion.rotationmatrix(Re_r);
            end


            tmp=EulerAngles(eye.qe_room,'zyx');  tmp=reshape(tmp,[3 size(eye.pos,2)]);
            eye.Euler_room=tmp/pi*180; % in degree

            tmp=R_opti2room*mean(ninePoints.markerPos{5}(:,ninePtsFrames),2)-mean(eye.pos(:,ninePtsFrames),2);
            eye.EVc_room=tmp/norm(tmp);

            eye.EVt_room=RotateVector(eye.qe_room, eye.EVc*ones(1,size(eye.pos,2)));

            eye.EVt_head=[sum(head.XYZ_room{1}.*eye.EVt_room); sum(head.XYZ_room{2}.*eye.EVt_room); sum(head.XYZ_room{3}.*eye.EVt_room)];

            tmpX=eye.EVt_head(1,:); tmpY=eye.EVt_head(2,:); tmpZ=eye.EVt_head(3,:);
            eye.Euler_head=[atand(tmpY./tmpX); atand(tmpZ./sqrt(tmpX.^2+tmpY.^2))];
        end
    end
end