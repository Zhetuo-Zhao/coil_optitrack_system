LOADFILE=1;
addpath('..\tools\');
if LOADFILE
    session='06-Mar-2020';
    direct=['Z:/fieldCalibrate/data/' session '/'];
    folder='run3';

    load([direct folder '\processed_head.mat'])
    load([direct folder '\processed_eye.mat'])
    load([direct folder '\rawData_tag.mat'])
    load([direct folder '\processed_objects.mat'])
    load([direct folder '\processed_timings.mat'])
end

fileName='sorting_color';
eyeIdx=1;
R_opti2room=[0 0 -1;-1 0 0 ; 0 1 0];
trialTim=timings.sorting{1}.trial;
tim2=trialTim(1)+240*20;
%tim2=trialTim(2);
durSync=trialTim(1):tim2;
dur1k=timeSwitch(tagData.t_1k,tagData.t_sync,trialTim(1)):timeSwitch(tagData.t_1k,tagData.t_sync,tim2);

%%
folders={'high','middle','low'};
for i=length(folders):-1:1
    load(['Z:\fieldCalibrate\calibration\field\BinCoil\200205\' folders{i} '\estFieldR13_syncDebug']);
    estField3D{i}=estField;
end

load([direct folder '\eyeCalibTable.mat']);
eye.sightVec_1k{eyeIdx}=field_compensate_3D(estField3D, eye.coil_1k{eyeIdx}(:,dur1k), eye.pos1K{eyeIdx}(:,dur1k), eyeCalibTable.field);     
eye.ang2head_1k{eyeIdx}=eye2head(eye.sightVec_1k{eyeIdx},head,dur1k,1);

eye.sightVec_sync{eyeIdx}=field_compensate_3D(estField3D, eye.coil_sync{eyeIdx}(:,durSync), eye.pos{eyeIdx}(:,durSync), eyeCalibTable.field);     
eye.ang2head_sync{eyeIdx}=eye2head(eye.sightVec_sync{eyeIdx},head,durSync,0);

tableObjs{1}=tableGrid; tableObjs{2}=table; tableObjs{3}=iceTray;
tableCell=Grid9PtsPos2(tableObjs,R_opti2room,durSync, [6 5 7],1);

gazePosOnPlane=linePlaneInter(eye.pos1K{eyeIdx}(:,dur1k), eye.sightVec_1k{eyeIdx}, tableCell.plane.param);
gaze2D=pts3to2(gazePosOnPlane, tableCell.plane.xAxis, tableCell.plane.yAxis, tableCell.plane.origin);
eye.gaze2D=gaze2D;



%% save video
Img=imread([direct folder '/report/tableTilted.png']);
tt{1}=tagData.t_sync; tt{2}=tagData.t_1k;
dur{1}=durSync; dur{2}=dur1k;

myVideo = VideoWriter('demo_sorting'); %open video file
myVideo.FrameRate = 24;  %can adjust this, 5 - 10 works well for me
open(myVideo)
figure('position',[10 50 1900 800]);
for t=durSync(1):4:durSync(end)
    t
    demo_sorting2( head, eye, tt,dur, t,Img,tableCell);
    pause(0.01) %Pause and grab frame
    frame = getframe(gcf); %get frame
    writeVideo(myVideo, frame);
    clf;
end
close(myVideo)


%% plot 1D trace

figure;  color3=get(gca,'colororder');
ax(1)=subplot(4,1,1);
h1=plot(tagData.t_sync(durSync)-tagData.t_sync(durSync(1)),(head.pos(:,durSync)-mean(head.pos(:,head.refframes),2))','Marker','.','lineStyle','none');
title('head translation');
legend(h1,{'x','y','z'});
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1)));  
ylabel('m');
set(ax(1),'FontSize',12);


ax(2)=subplot(4,1,2); hold on; 
for i=1:3
    tmp=head.Euler_head_coil(i,dur1k)-mean(head.Euler_head_coil(i,dur1k))+mean(head.Euler_head(i,durSync));
    h(i)=plot(tagData.t_1k(dur1k)-tagData.t_1k(dur1k(1)),tmp,'Marker','.','color',color3(i,:),'lineStyle','none');
    %plot(tagData.t_sync(durSync)-tagData.t_sync(durSync(1)),head.Euler_head(i,durSync),'Marker','o','color',color3(i,:),'lineStyle','none');
end
legend(h(1:3),{'Yaw (z)','Pitch (y)','Roll (x)'})
title('head rotation')
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
ylabel('degree');
set(ax(2),'FontSize',12);

ax(4)=subplot(4,1,4); lineSight2=vec2ang(eye.sightVec_1k{eyeIdx});
lineSight2(1,find(lineSight2(1,:)<-50))=180+lineSight2(1,find(lineSight2(1,:)<-50));
plot(tagData.t_1k(dur1k)-tagData.t_1k(dur1k(1)),lineSight2','Marker','.','lineStyle','none');
title('gaze direction (in room)');
ylabel('degree'); xlabel('time (s)');
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
legend({'horizontal','vertical'});
set(ax(4),'FontSize',12);

ax(3)=subplot(4,1,3); 
plot(tagData.t_1k(dur1k)-tagData.t_1k(dur1k(1)),eye.ang2head_1k{eyeIdx}','Marker','.','lineStyle','none');
title('eye movements (angle in head)');
ylabel('degree'); xlabel('time (s)');
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
legend({'horizontal','vertical'});
set(ax(3),'FontSize',12);


linkaxes([ax(1) ax(2) ax(3) ax(4)],'x')
saveFigure(['sorting1_zoomIn' '_1D'],[direct folder '\Figures\'])
