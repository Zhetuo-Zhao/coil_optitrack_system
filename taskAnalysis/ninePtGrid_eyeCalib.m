if ~exist('inputPath')
    addpath('..\tools\')

    direct='C:/Users/sanjana/OneDrive - University of Rochester/Documents/Sanjana/Projects/coil/fieldCalibrate/data/';
    date='06-Mar-2020';
    session='run3';

    inputPath= [direct date '/' session '/'];
    outputPath= [inputPath '/Figures/']; 
    if ~exist(outputPath)
        mkdir(outputPath); 
    end
    
    params = struct('opti2roomTransMatrix',[0 0 -1;-1 0 0 ; 0 1 0],...
    'activeChannels',[2,3,4],...
    'eyeChannel',[2],...
    'headCoilL',5,'headCoilR',1,...
    'headRestMarkers',[1 2 3 4 5],...
    'eyeProbeMarkers',[5 4 2 6],...
    'ninePtsMarkers',[9 6 4 8 1 3 7 2 5],...
    'tableGridMarkers',[7 3 4 5 6 2 1 8],...
    'tableMarkers',[5 1 2 3 4],...
    'headChannel',[3 4]);
end


if ~exist('ninePoints')
    load([params.inputPath 'processed_objects.mat'])
end
if ~exist('head')
    load([params.inputPath 'processed_head.mat'])
end
if ~exist('eye')
    load([params.inputPath 'processed_eye.mat'])
end
if ~exist('timings')
    load([params.inputPath 'processed_timings.mat'])
end

%% 9pts eye calibration
clear data2plot
data2plot{1}=eye.coil_sync{1}; data2plot{2}=head.Euler_head;
tagging_plot(coilData.t_sync,data2plot, {'eye coil reading','head orientation'}, tagData);

tim=timings.headFix9pt{2};

% eyeCalib9pts=nFixExtract2(eye,[trialTim(ninePtsTrial,1):trialTim(ninePtsTrial,2)],ninePtsPos,5E-3,1,VIEW);
eyeCalib9pts=nFixExtract3(eye,tim,ninePoints.markerPos_room,1,VIEW);
eyeCalib9pts.field=eye_calibration(eyeCalib9pts,VIEW,params.outputPath,'headFree9Pt');
save([params.inputPath 'eyeCalib9pts.mat'],'eyeCalib9pts');

ninePoints.posCell1=Grid9PtsPos(ninePoints,R_opti2room,[tim.trial(1):tim.trial(2)], [5 6 2],VIEW);
eyeIdx=1;
lineSight1=eyeCalib9pts.field.M\eye.coil_sync{eyeIdx}(:,tim.trial(1):tim.trial(2));
[pos3D1,pos2D1]=plotEyeTraceOnPlane(eye.pos{eyeIdx},[tim.trial(1):tim.trial(2)],lineSight1,ninePoints.posCell1,params.outputPath,'headFree9Pt');



