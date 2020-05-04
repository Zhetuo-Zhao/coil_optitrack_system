
disp('calculate head related parameters');
tcell{1}=coilData.t_sync; tcell{2}=coilData.t_1k; 
headCoilFlag=1;
head = headProcess(helmet,headRest.vector{1},params.opti2roomTransMatrix,headRest.Frames,headCoil_1k,tcell,headCoilFlag);

data2plot{1}=head.pos-mean(head.pos(:,headRest.Frames),2); data2plot{2}=head.Euler_head; 
taggingPlot(coilData.t_sync,data2plot, {'head position in room coordinate(m)', 'head Euler angles relative to head-fix calibration (degree)'}, tagData, {'x','y','z','yaw (z)','pitch (y)','roll (x)'});
disp('Done!');

if headCoilFlag
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
end


%% calculate eye related parameters:
disp('calculate eye related parameters')
for eyeIdx=1:length(params.eyeChannel)
    eye.pos = eyePosition(head,eyeProbe,params.opti2roomTransMatrix,eyeProbe.Frames,eyeIdx);
    eye.pos1K{eyeIdx}=[interp1(coilData.t_sync,eye.pos{eyeIdx}(1,:),coilData.t_1k,'spline'); interp1(coilData.t_sync,eye.pos{eyeIdx}(2,:),coilData.t_1k,'spline'); interp1(coilData.t_sync,eye.pos{eyeIdx}(3,:),coilData.t_1k,'spline')];
    eye.coil_vel{eyeIdx}=vel3D(eye.coil_sync{eyeIdx});
end


% check eye position
objs{1}=eyeProbe; objs{2}=helmet; objs{3}=ninePoints; objs{4}=headRest;
for eyeIdx=1:length(params.eyeChannel)
    plot3Dobjects(objs, eyeProbe.Frames{eyeIdx}(1), params.opti2roomTransMatrix);
    myScatter3(eye.pos{eyeIdx}(:,eyeProbe.Frames{eyeIdx}(1)));
end
disp('Done!');

disp('saving data');
save([params.inputPath 'processed_head.mat'],'head');
save([params.inputPath 'processed_eye.mat'],'eye');
disp('Done!')
