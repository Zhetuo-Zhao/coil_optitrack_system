clear; close all;
addpath('..\tools\')
%% set directory
session='05-Feb-2020';
direct=['Z:/fieldCalibrate/data/' session '/'];
% direct=['\\opus.cvs.rochester.edu\aplab\fieldCalibrate/data/' session '/'];
folder='session2';

VIEW=1; 

outputFolder=[direct folder '/Figures/'];
if ~exist(outputFolder)
   mkdir(outputFolder); 
end

R_opti2room=[0 0 -1;-1 0 0 ; 0 1 0];

%% load files
coil_fileName=[folder '_coil.csv'];
optitrack_fileName=[folder '.csv'];

disp('loading coil data');
active_channels=[1 2 3 4]; % channels that have coils plugged in. 
[coilData,tagData]=coilData_process(direct,folder,active_channels,VIEW, outputFolder); 
save([direct folder '\processed_coilData_backup.mat'],'coilData','tagData');
disp('Done!');
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

disp('loading optitrack data');
optiData = loadOptiTrack([direct folder '/' optitrack_fileName],20);
disp('Done!')

% check data
data2plot{1}=eyeCoil_sync{2};
tagging_plot(coilData.t_sync,data2plot, {'eye coil reading'}, tagData);


% sync between coil and optitrack
for i=length(coilData.t_sync):-1:1
    [~,idx]=min(abs(coilData.t_sync(i)-optiData.time));
    optSyncIdx(i)=idx;
end
objects=optSync(optiData,optSyncIdx);

%% trial timing
trialTim=trial_timing(tagData,0);
trialTim=[trialTim [1:size(trialTim,1)]']; 

for i=1:length(objects)
   {i, objects{i}.name}
end



%% calculate head related parameters: 
disp('calculate head related parameters')
helmet=objects{3};
data2plot{1}=helmet.pos; data2plot{2}=helmet.q;
tagging_plot(coilData.t_sync,data2plot, {'helmet position (m)', 'helmet quanternion'}, tagData);

headRest=objects{4};
headRestFrame=[trialTim(2,1):trialTim(2,2)];

plot_each_frame(headRest,1E4, R_opti2room)
headRest=optitrack_headRest(headRest,headRestFrame,[1 3 4 2]);

tcell{1}=coilData.t_sync; tcell{2}=coilData.t_1k; 
head=head_process(helmet,headRest.vector{1},R_opti2room,headRestFrame,headCoil_1k,tcell,0);

data2plot{1}=head.pos-mean(head.pos(:,headRestFrame),2); data2plot{2}=head.Euler_head; 
tagging_plot(coilData.t_sync,data2plot, {'head position in room coordinate(m)', 'head Euler angles relative to head-fix calibration (degree)'}, tagData, {'x','y','z','yaw (z)','pitch (y)','roll (x)'});
% saveFigure('headData9pts', [direct folder '\Figures\'])
disp('Done!');

%% eyeProbe
eyeProbe=objects{5};
plot_each_frame(eyeProbe,1E4, R_opti2room)
data2plot{1}=eyeProbe.pos; data2plot{2}=eyeProbe.q;
tagging_plot(coilData.t_sync,data2plot, {'eyeProbe position (m)', 'eyeProbe quanternion'}, tagData);

eyeProbeFrames{1}=[tagData.eyeProbe(5):tagData.eyeProbe(6)];
eyeProbe=optitrack_eyeProbe(eyeProbe,eyeProbeFrames,0.012,[5 7 6 1]); % the last index is the end og the probe


%% 9-point grid
ninePoints=objects{6};
plot_each_frame(ninePoints,1E4, R_opti2room)
% ninePoints.markerIdx=[8 6 4 7 2 5 1 9 3];
ninePoints.markerIdx=[7 9 2 5 3 1 8 6 4];



save([direct folder '\processData_backup.mat'],'coilData','tagData','optiData',...
                                      'headCoil_sync','eyeCoil_sync','headCoil_1k','eyeCoil_1k',...
                                      'objects',...
                                      'head',...
                                      'trialTim',...
                                      'R_opti2room',...
                                      'eyeProbeFrames', 'headRestFrame',...
                                      'helmet','ninePoints','eyeProbe','headRest','tableGrid');


                                
%% calculate eye related parameters:
eye.coil_sync{1}=eyeCoil_sync{2};
eye.coil_1k{1}=eyeCoil_1k{2};
eye.pos=eye_position(head,eyeProbe,R_opti2room,eyeProbeFrames,1);
eye.coil_vel{1}=vel3D(eye.coil_sync{1});

% check eye position
objs{1}=eyeProbe; objs{2}=helmet; objs{3}=ninePoints; objs{4}=headRest;
plot3Dobjects(objs, eyeProbeFrames{1}(1), R_opti2room);
myScatter3(eye.pos{1}(:,eyeProbeFrames{1}(1)));

%% 9pts eye calibration
clear data2plot
data2plot{1}=eye.coil_sync{1}; data2plot{2}=head.Euler_head;
tagging_plot(coilData.t_sync,data2plot, {'eye coil reading','head orientation'}, tagData);


ninePtsTrial=2;
ninePtsTim=tagData.calib(tagData.calib>trialTim(ninePtsTrial,1) & tagData.calib<trialTim(ninePtsTrial,2) );
ninePtsTim=[ninePtsTim trialTim(ninePtsTrial,2)];


for ptIdx=1:9
    ninePtsPos{ptIdx}=R_opti2room*ninePoints.marker{ninePoints.markerIdx(ptIdx)}.pos;
end

% eyeCalib9pts=nFixExtract(eye,ninePtsTim,ninePtsPos,0.2E3,1,VIEW);
eyeCalib9pts=nFixExtract2(eye,[trialTim(ninePtsTrial,1):trialTim(ninePtsTrial,2)],ninePtsPos,5E-3,1,VIEW);
eyeCalib9pts.field=eye_calibration(eyeCalib9pts,VIEW,[direct folder '\Figures\']);

ninePoints.posCell1=Grid9PtsPos(ninePoints,R_opti2room,[trialTim(ninePtsTrial,1):trialTim(ninePtsTrial,2)], [5 6 2],VIEW);
eyeIdx=1;
lineSight1=eyeCalib9pts.field.M\eye.coil_sync{eyeIdx}(:,trialTim(ninePtsTrial,1):trialTim(ninePtsTrial,2));
[pos3D1,pos2D1]=plotEyeTraceOnPlane(eye.pos{eyeIdx},[trialTim(ninePtsTrial,1):trialTim(ninePtsTrial,2)],lineSight1,ninePoints.posCell1,[direct folder '\Figures\'],'9ptsCalib_projection');


%% test other head-fix sessions
disp('test on other head-fix sessions')
testTrials=[2 3 4 12 13 14];
clear true_nc true_nc2
for i=9:-1:1
    true_nc(:,i)=mean(eyeCalib9pts.trueVector{i},2);
end
true_nc2=vec2ang(true_nc);
for i=1:length(testTrials)
    coilV=eye.coil_sync{1}(:,[trialTim(testTrials(i),1):trialTim(testTrials(i),2)]);
    lineSight=eyeCalib9pts.field.M\coilV;
   
    gazePosOnPlane=linePlaneInter(eye.pos{1}(:,trialTim(testTrials(i),1):trialTim(testTrials(i),2)), lineSight, ninePoints.posCell1.plane.param);
    gaze2D=pts3to2(gazePosOnPlane, ninePoints.posCell1.plane.xAxis, ninePoints.posCell1.plane.yAxis, ninePoints.posCell1.plane.origin);
    
    figure('position',[100 100 800 300]); suptitle(sprintf('session %d',i));
    lineSight2 = vec2ang(lineSight);
    subplot(1,2,1); hold on;
    scatter(-lineSight2(1,:),lineSight2(2,:));
    scatter(-true_nc2(1,:),true_nc2(2,:),'lineWidth',2);  
    xlabel('azimuth (degree)'); ylabel('altitude (degree)'); title('gaze angle');
    
    subplot(1,2,2); hold on;
    plot(100*gaze2D(1,:), 100*gaze2D(2,:),'Marker','+','color','r')
    scatter(100*ninePoints.posCell1.pts2D(1,:),100*ninePoints.posCell1.pts2D(2,:),'lineWidth',3,'MarkerEdgeColor','k');
    xlabel('cm'); ylabel('cm'); title('gaze projection on 9-point grid');
    
    saveFigure(sprintf('headFix_test_s%d',i),[direct folder '\Figures\']);
end
disp('Done!');


%% the another method: use calibrated field and fit the rotation offset
load('Z:\fieldCalibrate\calibration\field\BinCoil\191220\estFieldR13_syncDebug.mat');
load('Z:\fieldCalibrate\calibration\coil\eyeCoil\191022\coilParam.mat');
outField=field_interpolation(estField,2,estField0);
eyeCalib9pts.field2=eye_calibration2(eyeCalib9pts,outField, VIEW,[direct folder '\Figures\']);
% show calibration performance 
ninePoints.posCell1=Grid9PtsPos(ninePoints,R_opti2room,[ninePtsTim(1):ninePtsTim(end)], VIEW);

eyeIdx=1;

lineSight1=[Bn.B{1}*Bn.nf{1}'; Bn.B{2}*Bn.nf{2}'; Bn.B{3}*Bn.nf{3}']\eye.coil_sync{eyeIdx}(:,ninePtsTim(1):ninePtsTim(end));

[pos3D1,pos2D1]=plotEyeTraceOnPlane(eye.pos{eyeIdx},[ninePtsTim(1):ninePtsTim(end)],lineSight1,ninePoints.posCell1,[direct folder '\Figures\'],'9ptsCalib');



%% head free 9pts
data2plot{1}=eye.coil_sync{1};  data2plot{2}=eye.pos{1}-eye.pos{1}(:,trialTim(ninePtsTrial,1)); data2plot{3}=head.Euler_head;
tagging_plot(coilData.t_sync,data2plot, {'eye coil', 'eye position', 'head rotation'}, tagData);

headFree9ptsTrial=[7 9 11]; 
% load('Z:\fieldCalibrate\calibration\field\BinCoil\191220\estFieldR13_syncDebug.mat');
folders={'high','middle','low'};
for i=length(folders):-1:1
    load(['Z:\fieldCalibrate\calibration\field\BinCoil\200205\' folders{i} '\estFieldR13_syncDebug']);
    estField3D{i}=estField;
end
i=1;
headFree9ptsTim=[trialTim(headFree9ptsTrial(i),1):trialTim(headFree9ptsTrial(i),2)];
[lineSight1,debugCell]=field_compensate_3D(estField3D, eye.coil_sync{eyeIdx}(:,headFree9ptsTim), eye.pos{eyeIdx}(:,headFree9ptsTim), eyeCalib9pts.field);     

lineSight2=eyeCalib9pts.field.M\eye.coil_sync{eyeIdx}(:,headFree9ptsTim);        
ninePoints.posCell2=Grid9PtsPos(ninePoints,R_opti2room,headFree9ptsTim,  [5 6 2],0);
[pos3D2,pos2D2]=plotEyeTraceOnPlane(eye.pos{eyeIdx},headFree9ptsTim,lineSight,ninePoints.posCell2,[direct folder '\Figures\'],sprintf('9ptsHeadFree_s%d',i));

headFree9pts=nFixExtract2(eye,headFree9ptsTim,ninePtsPos,5E-3,1,VIEW);
figure;
for ptIdx=length(headFree9pts.num):-1:1
    eyeVec=lineSight(:,headFree9pts.fixTim{ptIdx}-headFree9ptsTim(1));
    trueVec=headFree9pts.trueVector{ptIdx};
    subplot(3,3,ptIdx); hold on;
    plot(atand(eyeVec(2,:)./eyeVec(1,:))*60)
    plot(atand(trueVec(2,:)./trueVec(1,:))*60)
end
saveFigure(sprintf('headFree9PtsX_s%d',i),outputFolder);


figure;
for ptIdx=length(headFree9pts.num):-1:1
    eyeVec=lineSight(:,headFree9pts.fixTim{ptIdx}-headFree9ptsTim(1));
    trueVec=headFree9pts.trueVector{ptIdx};
    subplot(3,3,ptIdx); hold on;
    plot(atand(eyeVec(3,:)./sqrt(eyeVec(1,:).^2+eyeVec(2,:).^2))*60)
    plot(atand(trueVec(3,:)./sqrt(trueVec(1,:).^2+trueVec(2,:).^2))*60)
end
saveFigure(sprintf('headFree9PtsY_s%d',i),outputFolder);

figure; hold on;
plot(eye.pos{eyeIdx}(3,:));
plot(1:length(eye.pos{eyeIdx}(3,:)),estField3D{1}{26,26}.center(3)*ones(1,length(eye.pos{eyeIdx}(3,:))));
plot(1:length(eye.pos{eyeIdx}(3,:)),estField3D{2}{26,26}.center(3)*ones(1,length(eye.pos{eyeIdx}(3,:))));
plot(1:length(eye.pos{eyeIdx}(3,:)),estField3D{3}{26,26}.center(3)*ones(1,length(eye.pos{eyeIdx}(3,:))));

clear objs
objs{1}=ninePoints; objs{2}=headRest;
plot3Dobjects(objs, eyeProbeFrames{1}(1), R_opti2room);
myScatter3(eye.pos{eyeIdx}(:,trialTim(2,1):trialTim(2,2))); 
text(eye.pos{eyeIdx}(1,trialTim(2,1)),eye.pos{eyeIdx}(2,trialTim(2,1)),eye.pos{eyeIdx}(3,trialTim(2,1)),'headFix');

myScatter3(eye.pos{eyeIdx}(:,trialTim(7,1):trialTim(7,2))); 
text(eye.pos{eyeIdx}(1,trialTim(7,1)),eye.pos{eyeIdx}(2,trialTim(7,1)),eye.pos{eyeIdx}(3,trialTim(7,1)),'headFree1');

myScatter3(eye.pos{eyeIdx}(:,trialTim(9,1):trialTim(9,2))); 
text(eye.pos{eyeIdx}(1,trialTim(9,1)),eye.pos{eyeIdx}(2,trialTim(9,1)),eye.pos{eyeIdx}(3,trialTim(9,1)),'headFree2');

myScatter3(eye.pos{eyeIdx}(:,trialTim(11,1):trialTim(11,2)));
text(eye.pos{eyeIdx}(1,trialTim(11,1)),eye.pos{eyeIdx}(2,trialTim(11,1)),eye.pos{eyeIdx}(3,trialTim(11,1)),'headFree3');




%% table grid
disp('tableGrid test')
tableGrid = objects{2};
plot_each_frame( tableGrid, 1E4, R_opti2room );
tableGrid.markerIdx = [5 4 3 2 1 7 6 8];

tableGridTrial=[12 13];
for trialIdx=1:length(tableGridTrial)
tableGridTim=trialTim(tableGridTrial(trialIdx),1):trialTim(tableGridTrial(trialIdx),2);
eyeTrace3=eye.coil_sync{1}(:,tableGridTim);
eyeTrace2=vec2ang(eyeTrace3);
figure; scatter(eyeTrace2(1,:),eyeTrace2(2,:))


lineSight=field_compensate(estField, eye.coil_sync{eyeIdx}(:,tableGridTim), eye.pos{eyeIdx}(:,tableGridTim), eyeCalib9pts.field);        
tableGrid.posCell1 = Grid9PtsPos( tableGrid, R_opti2room, tableGridTim, [6 5 7],VIEW );
[~,gaze2D]=plotEyeTraceOnPlane(eye.pos{eyeIdx},tableGridTim,lineSight,tableGrid.posCell1,[direct folder '\Figures\'],sprintf('tableGrid_s%d',i));


clear true_nc true_nc2 tmp
true_nc=[];
for i=1:7
tmp=R_opti2room*tableGrid.marker{tableGrid.markerIdx(i)}.pos(:,tableGridTim)-eye.pos{1}(:,tableGridTim);
true_nc=[true_nc normc(tmp)];
end


true_nc2=vec2ang(true_nc);
figure('position',[100 100 800 300]); suptitle(sprintf('session %d',i));
lineSight2 = vec2ang(lineSight);
subplot(1,2,1); hold on;
scatter(-true_nc2(1,:),true_nc2(2,:),'MarkerEdgeColor',[0.5 0.5 0.5]);  
scatter(-lineSight2(1,:),lineSight2(2,:),20,[1:size(lineSight2,2)]);
xlabel('azimuth (degree)'); ylabel('altitude (degree)'); title('gaze angle');

subplot(1,2,2); hold on;
plot(100*gaze2D(1,:), 100*gaze2D(2,:),'Marker','+','color','r')
scatter(100*tableGrid.posCell1.pts2D(1,:),100*tableGrid.posCell1.pts2D(2,:),'lineWidth',3,'MarkerEdgeColor','k');
xlabel('cm'); ylabel('cm'); title('gaze projection on 9-point grid');
xlim([-10 40])
saveFigure(sprintf('tableGrid_test_s%d',trialIdx),[direct folder '\Figures\']);
    
end



clear objs
objs{1}=tableGrid; objs{2}=headRest;
plot3Dobjects(objs, eyeProbeFrames{1}(1), R_opti2room);
myScatter3(eye.pos{eyeIdx}(:,trialTim(2,1):trialTim(2,2))); 
text(eye.pos{eyeIdx}(1,trialTim(2,1)),eye.pos{eyeIdx}(2,trialTim(2,1)),eye.pos{eyeIdx}(3,trialTim(2,1)),'headFix');
myScatter3(eye.pos{eyeIdx}(:,trialTim(7,1):trialTim(7,2))); 
text(eye.pos{eyeIdx}(1,trialTim(tableGridTrial(1),1)),eye.pos{eyeIdx}(2,trialTim(tableGridTrial(1),1)),eye.pos{eyeIdx}(3,trialTim(7,1)),'tableGrid1');
myScatter3(eye.pos{eyeIdx}(:,trialTim(9,1):trialTim(9,2))); 
text(eye.pos{eyeIdx}(1,trialTim(tableGridTrial(),1)),eye.pos{eyeIdx}(2,trialTim(9,1)),eye.pos{eyeIdx}(3,trialTim(9,1)),'tableGrid2');
disp('Done!');



%% trace plot
load('Z:\fieldCalibrate\data\20-Dec-2019\calibrate1\results\estFieldR13_syncDebug.mat')
lineSight2=field_compensate(estField, eye.coil_sync{eyeIdx}, eye.pos{eyeIdx}, eyeCalib9pts.field);
data2plot{1}=[atand(lineSight2(2,:)./lineSight2(1,:)); atand(lineSight2(3,:)./sqrt(lineSight2(1,:).^2+lineSight2(2,:).^2))];  
data2plot{2}=eye.pos{1}-mean(eye.pos{1}(:,[ninePtsTim(1):ninePtsTim(end)]),2);
tagging_plot(coilData.t_sync,data2plot, {'eye orientation after field calibration (degree)', 'eye position relative to head-fix calibration(m)'}, tagData,{'azimuth','altitude','x','y','z'});
saveFigure('eyeData9pts', [direct folder '\Figures\'])


data2plot{1}=head.pos-mean(head.pos(:,[ninePtsTim(1):ninePtsTim(end)]),2); data2plot{2}=head.Euler_head; 
tagging_plot(coilData.t_sync,data2plot, {'head position relative to head-fix calibration (m)', 'head Euler angles relative to head-fix calibration (degree)'}, tagData, {'x','y','z','yaw (z)','pitch (y)','roll (x)'});
saveFigure('headData9pts', [direct folder '\Figures\'])




%% debug
figure; hold on;
myScatter3(eye.pos{eyeIdx}(:,[ninePtsTim(1):ninePtsTim(end)]))
myScatter3(eye.pos{eyeIdx}(:,headFree9ptsTim))
myScatter3(ninePoints.posCell1.pos)
view(3); grid on;

figure; 
for i=1:3
    subplot(3,1,i); hold on;
    plot(eye.pos{eyeIdx}(i,[ninePtsTim(1):ninePtsTim(end)]))
    plot(eye.pos{eyeIdx}(i,headFree9ptsTim))
end
figure; 
for i=1:3
    subplot(3,1,i); hold on;
    plot(eye.coil_sync{eyeIdx}(i,[ninePtsTim(1):ninePtsTim(end)])')
    plot(eye.coil_sync{eyeIdx}(i,headFree9ptsTim)')
    legend({'headFix','headFree'})
    ylabel('coil orientation z value')
    xlabel('sample')
end

figure; 
for i=1:3
    subplot(3,1,i); hold on;
    plot(lineSight1(i,:))
    plot(lineSight2(i,:))
    legend({'headFix','headFree'})
    ylabel('coil orientation z value')
    xlabel('sample')
end
%% save
save([direct folder '\processData.mat'],'coilData','tagData','optiData',...
                                      'headCoil','eyeCoil',...
                                      'objects',...
                                      'head','eye','head_plot',...
                                      'helmet','ninePoints','eyeProbe','headRest','reading','eyeChart',...
                                      'headRestFrame','eyeProbeFrame');
                                  