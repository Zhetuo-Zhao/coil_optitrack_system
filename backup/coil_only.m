data2plot{1}=head.coil_sync{1}; data2plot{2}=eye.coil_sync{1}; 
data2plot{1}=coilData.sig_syncR{3}; data2plot{2}=coilData.sig_syncR{1}; 
tagging_plot(coilData.t_sync,data2plot, {'head coil', 'eye coil'}, tagData);

%% head coil
headCoil=head.coil_1k;
for jj=1:2
    if mean(headCoil{jj}(3,:))>0
        load('Z:\fieldCalibrate\calibration\field\BinCoil\191028\191028Pos\estFieldR13_syncDebug.mat');
    else
        load('Z:\fieldCalibrate\calibration\field\BinCoil\191028\191028Neg\estFieldR13_syncDebug.mat');
    end
    headCoilPos=[0.53;-0.84;0]*ones(1,size(headCoil{jj},2));
    head.headCV{jj}=field_compensate(estField, headCoil{jj}, headCoilPos);
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

clear data2plot
data2plot{1}=head.Euler_head_coil(:,1:5:end); data2plot{1}=data2plot{1}(:,1:length(tt{1}));
tagging_plot(tagData.t_sync,data2plot, {'head coil'}, tagData);


%% sorting
fileName='sorting1';
trialTim=timings.sorting{1}.trial;
dur1k=timeSwitch(coilData.t_1k,tagData.t_sync,trialTim(1)):timeSwitch(coilData.t_1k,coilData.t_sync,trialTim(2));
lineSight1=eyeCalib9pts.field.M\eye.coil_1k{eyeIdx}(:,dur1k);
[eye2head2,eye2head3]=eye2head(lineSight1,head,dur1k,1);

figure;  color3=get(gca,'colororder');
ax(1)=subplot(3,1,1); hold on; 
for i=1:3
    h(i)=plot(tagData.t_1k(dur1k),head.Euler_head_coil(i,dur1k),'Marker','.','color',color3(i,:),'lineStyle','none');
end
legend(h(1:3),{'Yaw (z)','Pitch (y)','Roll (x)'})
title('head Euler angle relative to head fix orientation')
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]); % ylim([-1 10]);
ylabel('degree');

ax(2)=subplot(3,1,2); lineSight2=vec2ang(lineSight1);
plot(tagData.t_1k(dur1k),lineSight2','Marker','.','lineStyle','none');
title('line of sight in room');
ylabel('degree'); 
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]); 
legend({'azimuth','altitude'});

ax(3)=subplot(3,1,3); 
plot(tagData.t_1k(dur1k),eye2head2','Marker','.','lineStyle','none');
title('eye angles in head');
ylabel('degree'); xlabel('time (sec)');
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]); 
legend({'azimuth','altitude'});

linkaxes([ax(1) ax(2) ax(3)],'x') 
xlim([965 1025])
saveFigure([fileName '_1D'],[direct folder '\Figures\'])


%% head eye saccade
fileName='head_eye_sacc2';
trialTim=timings.headEyeSacc{2}.trial;
dur1k=timeSwitch(tagData.t_1k,tagData.t_sync,trialTim(1)):timeSwitch(tagData.t_1k,tagData.t_sync,trialTim(2));
lineSight1=eyeCalib9pts.field.M\eye.coil_1k{eyeIdx}(:,dur1k);
[eye2head2,eye2head3]=eye2head(lineSight1,head,dur1k,1);

figure;  color3=get(gca,'colororder');
ax(1)=subplot(3,1,1); hold on; 
for i=1:3
    h(i)=plot(tagData.t_1k(dur1k),head.Euler_head_coil(i,dur1k),'Marker','.','color',color3(i,:),'lineStyle','none');
end
legend(h(1:3),{'Yaw (z)','Pitch (y)','Roll (x)'})
title('head Euler angle relative to head fix orientation')
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]); % ylim([-1 10]);
ylabel('degree');

ax(2)=subplot(3,1,2); lineSight2=vec2ang(lineSight1); lineSight2(1,find(lineSight2(1,:)<-50))=180+lineSight2(1,find(lineSight2(1,:)<-50));
plot(tagData.t_1k(dur1k),lineSight2','Marker','.','lineStyle','none');
title('line of sight in room');
ylabel('degree'); 
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]); 
legend({'azimuth','altitude'});


ax(3)=subplot(3,1,3);
plot(tagData.t_1k(dur1k),eye2head2','Marker','.','lineStyle','none');
title('eye angles in head');
ylabel('degree'); xlabel('time (sec)');
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]); 
legend({'azimuth','altitude'});

linkaxes([ax(1) ax(2) ax(3)],'x') 
% xlim([800 860])
saveFigure([fileName '_1D'],[direct folder '\Figures\'])
