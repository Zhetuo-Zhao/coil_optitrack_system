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
% clear data2plot
% data2plot{1}=eye.coil_sync{1}; data2plot{2}=head.Euler_head;
% tagging_plot(coilData.t_sync,data2plot, {'eye coil reading','head orientation'}, tagData);
tim=timings.headFreeTable{1};
% eyeCalib9pts=nFixExtract2(eye,[trialTim(ninePtsTrial,1):trialTim(ninePtsTrial,2)],ninePtsPos,5E-3,1,VIEW);
nPts=[tableGrid.markerPos_room(1) tableGrid.markerPos_room(3:7)];
eyeCalibTable=nFixExtract3(eye,tim,nPts,1,VIEW);
eyeCalibTable.field=eye_calibration(eyeCalibTable,VIEW,[direct folder '\Figures\'],'headFreeTable');
save([direct folder '\eyeCalibTable.mat'],'eyeCalibTable');

tableGrid.posCell1=Grid9PtsPos(tableGrid,R_opti2room,[tim.trial(1):tim.trial(2)], [6 5 7],VIEW);
eyeIdx=1;
lineSight1=eyeCalibTable.field.M\eye.coil_sync{eyeIdx}(:,tim.trial(1):tim.trial(2));
[pos3D1,pos2D1]=plotEyeTraceOnPlane(eye.pos{eyeIdx},[tim.trial(1):tim.trial(2)],lineSight1,tableGrid.posCell1,[direct folder '\Figures\'],'headFreeTable');

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
saveFigure('headFreeTable_test',[direct folder '\Figures\']);

