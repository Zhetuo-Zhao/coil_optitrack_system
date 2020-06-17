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
% clear data2plot
% data2plot{1}=eye.coil_sync{1}; data2plot{2}=head.Euler_head;
% tagging_plot(coilData.t_sync,data2plot, {'eye coil reading','head orientation'}, tagData);
tim=timings.headFreeTable{1};
% eyeCalib9pts=nFixExtract2(eye,[trialTim(ninePtsTrial,1):trialTim(ninePtsTrial,2)],ninePtsPos,5E-3,1,VIEW);
nPts=[tableGrid.markerPos_room(1) tableGrid.markerPos_room(3:7)];
eyeCalibTable=nFixExtract3(eye,tim,nPts,1,VIEW);
eyeCalibTable.field=eye_calibration(eyeCalibTable,VIEW,params.outputPath,'headFreeTable');
save([params.inputPath 'eyeCalibTable.mat'],'eyeCalibTable');

tableGrid.posCell1=Grid9PtsPos(tableGrid,R_opti2room,[tim.trial(1):tim.trial(2)], [6 5 7],VIEW);
eyeIdx=1;
lineSight1=eyeCalibTable.field.M\eye.coil_sync{eyeIdx}(:,tim.trial(1):tim.trial(2));
[pos3D1,pos2D1]=plotEyeTraceOnPlane(eye.pos{eyeIdx},[tim.trial(1):tim.trial(2)],lineSight1,tableGrid.posCell1,params.outputPath,'headFreeTable');

%%
clear true_nc true_nc2 tmp
true_nc=[];
for i=1:7
tmp=R_opti2room*tableGrid.marker{tableGrid.markerIdx(i)}.pos(:,[tim.trial(1):tim.trial(2)])-eye.pos{1}(:,[tim.trial(1):tim.trial(2)]);
true_nc=[true_nc normc(tmp)];
end

true_nc2=vec2ang(true_nc);
figure('position',[100 100 800 300]); %suptitle(sprintf('session %d',i));
lineSight2 = vec2ang(lineSight1);
subplot(1,2,1); hold on;
scatter(-true_nc2(1,:),true_nc2(2,:),'MarkerEdgeColor',[0.5 0.5 0.5]);  
scatter(-lineSight2(1,:),lineSight2(2,:),20,[1:size(lineSight2,2)]);
xlabel('azimuth (degree)'); ylabel('altitude (degree)'); title('gaze angle');

subplot(1,2,2); hold on;
plot(100*pos2D1(1,:), 100*pos2D1(2,:),'Marker','+','color','r')
scatter(100*tableGrid.posCell1.pts2D(1,:),100*tableGrid.posCell1.pts2D(2,:),'lineWidth',3,'MarkerEdgeColor','k');
xlabel('cm'); ylabel('cm'); title('gaze projection on 9-point grid');
xlim([-5 40])
saveFigure('headFreeTable_test',params.outputPath);

