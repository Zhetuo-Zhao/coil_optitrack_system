LOADDATA=1;

if LOADDATA
    session='05-Feb-2020';
    direct=['Z:/fieldCalibrate/data/' session '/'];
    folder='session2';

    load([direct folder '\processed_objects.mat'])
    load([direct folder '\rawData_tag.mat'])
    load([direct folder '\rawData_coil.mat'])
end


for coilIdx=1:2
    if ~isempty(coilData.sig_syncR{coilIdx})... 
    && sum(coilData.sig_syncR{coilIdx}(1,:)<0)/length(coilData.sig_syncR{coilIdx}(1,:))<0.4 ...
    && sum(coilData.sig_syncR{coilIdx}(2,:)<0)/length(coilData.sig_syncR{coilIdx}(2,:))<0.4
        eyeCoil_sync{coilIdx}=-coilData.sig_syncR{coilIdx};
        eyeCoil_1k{coilIdx}=-coilData.sig_1kR{coilIdx}; 
    else
        eyeCoil_sync{coilIdx}=coilData.sig_syncR{coilIdx};
        eyeCoil_1k{coilIdx}=coilData.sig_1kR{coilIdx}; 
    end
    
    headCoil_sync{coilIdx}=coilData.sig_syncR{2+coilIdx}; 
    headCoil_1k{coilIdx}=coilData.sig_1kR{2+coilIdx}; 
end

disp('calculate head related parameters')
head.coil_sync=headCoil_sync; head.coil_1k=headCoil_1k;
tcell{1}=coilData.t_sync; tcell{2}=coilData.t_1k; 
head=head_process(helmet,headRest.vector{1},R_opti2room,headRest.Frames,headCoil_1k,tcell,1);

data2plot{1}=head.pos-mean(head.pos(:,headRest.Frames),2); data2plot{2}=head.Euler_head; 
tagging_plot(coilData.t_sync,data2plot, {'head position in room coordinate(m)', 'head Euler angles relative to head-fix calibration (degree)'}, tagData, {'x','y','z','yaw (z)','pitch (y)','roll (x)'});
disp('Done!');

figure; 
for hi=1:3
   subplot(3,1,hi); hold on;
   plot(tcell{1}, head.Euler_head(hi,:))
   plot(tcell{2}, head.Euler_head_coil(hi,:))
   
   errV{hi}=head.Euler_head_coil(hi,1:5:length(tcell{2}))-head.Euler_head(hi,:);
end

figure; 
for hi=1:3
    subplot(1,3,hi); histogram(errV{hi});
    xlim([-2 2]);
end

disp('calculate eye related parameters')
%% calculate eye related parameters:
eyeChannel=2;
eye.coil_sync{1}=eyeCoil_sync{eyeChannel};
eye.coil_1k{1}=eyeCoil_1k{eyeChannel};
eye.pos=eye_position(head,eyeProbe,R_opti2room,eyeProbe.Frames,1);
eye.pos1K{1}=[interp1(coilData.t_sync,eye.pos{1}(1,:),coilData.t_1k,'spline'); interp1(coilData.t_sync,eye.pos{1}(2,:),coilData.t_1k,'spline'); interp1(coilData.t_sync,eye.pos{1}(3,:),coilData.t_1k,'spline')];
eye.coil_vel{1}=vel3D(eye.coil_sync{1});

% check eye position
objs{1}=eyeProbe; objs{2}=helmet; objs{3}=ninePoints; objs{4}=headRest;
plot3Dobjects(objs, eyeProbeFrames{1}(1), R_opti2room);
myScatter3(eye.pos{1}(:,eyeProbeFrames{1}(1)));
disp('Done!');

disp('saving data');
save([direct folder '\processed_head.mat'],'head');
save([direct folder '\processed_eye.mat'],'eye');
disp('Done!')