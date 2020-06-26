function head = headProcess(helmet,vc_opti,R,calib_frame,headCoil,tt,coilON)
    % INPUT:
    %   helmet:
    %   headRest:
    %   R: 3x3 rotation matrix transforming from optitrack to room  
    %   calib_frame: a vector of frame index of calibration period (head on head rest)
    
    % OUTPUT:
    %   head.headEuler: 3xT matrix, yaw (Z), pitch (Y), row (Z) angles in
    %                   degree, in head cooridnate.
    %   head.XYZ_room: 1x3 structure with each 3xT matrix: x, y, z axis in
    %                  time, in room cooridnate.
    %   head.pos: 3xT matrix: head position in room coordinate
    
    
    %% based on optitrack data 
    % R_ro: transform from optitrack to room  
    head.R_opti2room=R; 
    head.q_opti2room=quaternion.rotationmatrix(head.R_opti2room);
    
    % head orientation at calibration in room coordinate
    head.vc_room=head.R_opti2room*vc_opti;
    head.XYZc_room=vec2frameXZ(head.vc_room, [0 0 1]'); % 3 axes; transform from head coordinate to room 
    
    % R_rh: transform from head coordinate to room 
    head.q_head2room=quaternion.rotationmatrix(head.XYZc_room);

    head.qc_helmet_opti=quaternion(mean(helmet.q(:,calib_frame),2));
    head.qt_helmet_opti=quaternion(helmet.q);
    %Rh_o=Rt_o*inv(Rc_o)
    head.qh_opti=rdivide(head.qt_helmet_opti,head.qc_helmet_opti*ones(1,length(head.qc_helmet_opti)));
    % %Rh_r=R_ro*Rh_o
    % head.qh_room=times(head.q_opti2room*ones(1,length(helmet.frame)),head.qh_opti);
    %Rh_r=R_ro*Rh_o*inv(R_ro)
    head.qh_room=times(ldivide(conj(head.q_opti2room)*ones(1,length(head.qh_opti)),head.qh_opti),conj(head.q_opti2room)*ones(1,length(head.qh_opti)));


    % Rh_h=inv(R_rh)*Rh_r*R_rh
    head.qh_head=times(ldivide(head.q_head2room*ones(1,length(head.qh_room)),head.qh_room),head.q_head2room*ones(1,length(head.qh_room)));

    tmp=EulerAngles(head.qh_room,'zyx'); tmp=reshape(tmp,[3 length(head.qh_room)]);
    head.Euler_room=tmp/pi*180; % in degree

    tmp=EulerAngles(head.qh_head,'zyx'); tmp=reshape(tmp,[3 length(head.qh_room)]);
    head.Euler_head=tmp/pi*180; % in degree
    

    for i=1:3
        head.XYZ_room{i}=RotateVector(head.qh_room,head.XYZc_room(:,i)*ones(1,length(head.qh_room)));
    end
    
    
    head.pos=head.R_opti2room*helmet.pos;

    head.relativePos=head.R_opti2room*(helmet.pos-mean(helmet.pos(:,calib_frame),2)*ones(1,size(helmet.pos,2)));
    
    
    %% based on coil data
    if coilON
        headCoilMarker=[helmet.coilMarkerL helmet.coilMarkerR];
        for jj=1:2
            if mean(headCoil{jj}(3,:))>0
                load('Z:\fieldCalibrate\calibration\field\BinCoil\191028\191028Pos\estFieldR13_syncDebug.mat');
            else
                load('Z:\fieldCalibrate\calibration\field\BinCoil\191028\191028Neg\estFieldR13_syncDebug.mat');
            end
            coilPos=R*helmet.marker{headCoilMarker(jj)}.pos(:,1:length(tt{1}));
            interPos=[interp1(tt{1},coilPos(1,:),tt{2},'spline'); interp1(tt{1},coilPos(2,:),tt{2},'spline'); interp1(tt{1},coilPos(3,:),tt{2},'spline')];
            head.headCV{jj}=field_compensate(estField, headCoil{jj}, interPos);
        end
        for t=size(head.headCV{1},2):-1:1
            a1=head.headCV{1}(:,t);
            b1=head.headCV{2}(:,t);
            angV1(t)=acosd(a1'*b1/(norm(a1)*norm(b1)));
            
            a2=headCoil{1}(:,t);
            b2=headCoil{2}(:,t);
            angV2(t)=acosd(a2'*b2/(norm(a2)*norm(b2)));
        end
        figure; hold on;
        plot(angV1); plot(angV2);
        
        % coil orientation at calibration in room coordinate
        head.coilXYZc_room=vec2frame(mean(head.headCV{2}(:,calib_frame*5),2),mean(head.headCV{1}(:,calib_frame*5),2));

        for t=length(tt{2}):-1:1
            coilXYZt_room=vec2frame(head.headCV{2}(:,t),head.headCV{1}(:,t));
            head.qh_room_coil(t)=quaternion.rotationmatrix(coilXYZt_room/head.coilXYZc_room);
        end


        head.qh_head_coil=times(ldivide(head.q_head2room*ones(1,length(tt{2})),head.qh_room_coil),head.q_head2room*ones(1,length(tt{2})));

        tmp=EulerAngles(head.qh_room_coil,'zyx');  tmp=reshape(tmp,[3 length(tt{2})]);
        head.Euler_room_coil=tmp/pi*180; % in degree

        tmp=EulerAngles(head.qh_head_coil,'zyx');  tmp=reshape(tmp,[3 length(tt{2})]);
        head.Euler_head_coil=tmp/pi*180; % in degree

        for i=1:3
            head.XYZ_room_coil{i}=RotateVector(head.qh_room_coil,head.XYZc_room(:,i)*ones(1,length(tt{2})));
        end
    end
end
