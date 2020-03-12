if ~exist('session')
    session='05-Feb-2020';
    direct=['Z:/fieldCalibrate/data/' session '/'];
    folder='session2';
end


if ~exist('ninePoints')
    load([direct folder '\processed_objects.mat'])
end
if ~exist('head')
    load([direct folder '\processed_head.mat'])
end
if ~exist('eye')
    load([direct folder '\processed_eye.mat'])
end
if ~exist('timings')
    load([direct folder '\processed_timings.mat'])
end

%% 9pts eye calibration
clear data2plot
data2plot{1}=eye.coil_sync{1}; data2plot{2}=head.Euler_head;
tagging_plot(coilData.t_sync,data2plot, {'eye coil reading','head orientation'}, tagData);

tim=timings.headFix9pt{2};

% eyeCalib9pts=nFixExtract2(eye,[trialTim(ninePtsTrial,1):trialTim(ninePtsTrial,2)],ninePtsPos,5E-3,1,VIEW);
eyeCalib9pts=nFixExtract3(eye,tim,ninePoints.markerPos_room,1,VIEW);
eyeCalib9pts.field=eye_calibration(eyeCalib9pts,VIEW,[direct folder '\Figures\'],'headFree9Pt');
save([direct folder '\eyeCalib9pts.mat'],'eyeCalib9pts');

ninePoints.posCell1=Grid9PtsPos(ninePoints,R_opti2room,[tim.trial(1):tim.trial(2)], [5 6 2],VIEW);
eyeIdx=1;
lineSight1=eyeCalib9pts.field.M\eye.coil_sync{eyeIdx}(:,tim.trial(1):tim.trial(2));
[pos3D1,pos2D1]=plotEyeTraceOnPlane(eye.pos{eyeIdx},[tim.trial(1):tim.trial(2)],lineSight1,ninePoints.posCell1,[direct folder '\Figures\'],'headFree9Pt');



