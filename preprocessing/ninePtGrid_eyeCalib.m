if ~exist('ninePoints')
    load([params.inputPath params.date '/' params.session '/processed_objects.mat'])
end
if ~exist('head')
    load([params.inputPath params.date '/' params.session '/processed_head.mat'])
end
if ~exist('eye')
    load([params.inputPath params.date '/' params.session  '/processed_eye.mat'])
end
if ~exist('timings')
    load([params.inputPath params.date '/' params.session '/processed_timings.mat'])
end

%% 9pts eye calibration
clear data2plot
data2plot{1}=eye.coil_sync{1}; data2plot{2}=head.Euler_head;
taggingPlot(coilData.t_sync,data2plot, {'eye coil reading','head orientation'}, tagData);

taskName=wordSearch(timings.taskNames,{'9pt','head','fix'},{'table'}); 
taskTime=eval(['timings.' taskName]); % selected task.
if length(taskName)>1
    trialIdx=input('which trial? ');
    tim=taskTime{trialIdx};
else
    tim=taskTime;
end


eyeCalib9pts=nFixExtract(eye,tim,ninePoints.markerPos_room,1,params.VIEW);
eyeCalib9pts.field=eye_calibration(eyeCalib9pts,params.VIEW,params.outputPath,'headFree9Pt');
save([params.inputPath 'eyeCalib9pts.mat'],'eyeCalib9pts');

ninePoints.posCell1=Grid9PtsPos(ninePoints,params.opti2roomTransMatrix,[tim.trial(1):tim.trial(2)], [5 6 2],VIEW);
for eyeIdx=1:length(params.eyeChannel)
    lineSight1=eyeCalib9pts.field.M\eye.coil_sync{eyeIdx}(:,tim.trial(1):tim.trial(2));
    [pos3D1,pos2D1]=plotEyeTraceOnPlane(eye.pos{eyeIdx},[tim.trial(1):tim.trial(2)],lineSight1,ninePoints.posCell1,params.outputPath,'headFree9Pt');
end
