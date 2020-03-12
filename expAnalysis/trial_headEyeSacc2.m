LOADFILE=1;

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

addpath('../tools/')
fileName='headEyeSacc_test';
eyeIdx=1;
R_opti2room=[0 0 -1;-1 0 0 ; 0 1 0];
trialTim=timings.headEyeSacc{1}.trial;
durSync=trialTim(1):trialTim(2);
dur1k=timeSwitch(tagData.t_1k,tagData.t_sync,trialTim(1)):timeSwitch(tagData.t_1k,tagData.t_sync,trialTim(2));


folders={'high','middle','low'};
for i=length(folders):-1:1
    load(['Z:\fieldCalibrate\calibration\field\BinCoil\200205\' folders{i} '\estFieldR13_syncDebug']);
    estField3D{i}=estField;
end
load([direct folder '\eyeCalib9pts.mat']);

eye.sightVec_1k{eyeIdx}=field_compensate_3D(estField3D, eye.coil_1k{eyeIdx}(:,dur1k), eye.pos1K{eyeIdx}(:,dur1k), eyeCalib9pts.field);     
eye.ang2head_1k{eyeIdx}=eye2head(eye.sightVec_1k{eyeIdx},head,dur1k,1);

eye.sightVec_sync{eyeIdx}=field_compensate_3D(estField3D, eye.coil_sync{eyeIdx}(:,durSync), eye.pos{eyeIdx}(:,durSync), eyeCalib9pts.field);     
eye.ang2head_sync{eyeIdx}=eye2head(eye.sightVec_sync{eyeIdx},head,durSync,0);


%% save as a movie

fixPts{1}=ninePoints.markerPos_room{5};
fixPts{2}=R_opti2room*head_eye.marker{4}.pos;
fixPts{3}=R_opti2room*head_eye.marker{1}.pos;
fixPts{4}=R_opti2room*head_eye.marker{3}.pos;
fixPts{5}=R_opti2room*head_eye.marker{2}.pos;
fixPts{6}=ninePoints.markerPos_room{9};
fixPts{7}=ninePoints.markerPos_room{7};
fixPts{8}=R_opti2room*eyeProbe.marker{6}.pos;

tt{1}=tagData.t_sync; tt{2}=tagData.t_1k;
dur{1}=durSync; dur{2}=dur1k;

myVideo = VideoWriter('headEyeSacc_demo'); %open video file
myVideo.FrameRate = 24;  %can adjust this, 5 - 10 works well for me
open(myVideo)
figure('position',[10 50 1900 950]);
for t=durSync(1):5:durSync(end)
    t
    demo_headEyeSacc2(helmet,fixPts, head, eye, tagData, R_opti2room, tt,dur,t);
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
xlim([tagData.t_sync(durSync(1)) tagData.t_sync(durSync(end))]-tagData.t_sync(durSync(1)));  
ylabel('m');
set(ax(1),'FontSize',10);

ax(2)=subplot(4,1,2); hold on; 
for i=1:3
    tmp=head.Euler_head_coil(i,dur1k)-mean(head.Euler_head_coil(i,dur1k))+mean(head.Euler_head(i,durSync));
    h(i)=plot(tagData.t_1k(dur1k)-tagData.t_1k(dur1k(1)),tmp,'Marker','.','color',color3(i,:),'lineStyle','none');
    plot(tagData.t_sync(durSync)-tagData.t_sync(durSync(1)),head.Euler_head(i,durSync),'Marker','o','color',color3(i,:),'lineStyle','none');
end
legend(h(1:3),{'Yaw','Pitch','Roll'})
title('head rotation')
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
ylabel('degree');
set(ax(2),'FontSize',10);

ax(3)=subplot(4,1,3); 
plot(tagData.t_1k(dur1k)-tagData.t_1k(dur1k(1)),eye.ang2head_1k{eyeIdx}','Marker','.','lineStyle','none');
title('eye movements (angle in head)');
ylabel('degree'); 
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
legend({'horizontal','vertical'});
set(ax(3),'FontSize',10);

ax(4)=subplot(4,1,4); lineSight2=vec2ang(eye.sightVec_1k{eyeIdx});
lineSight2(1,find(lineSight2(1,:)<-50))=180+lineSight2(1,find(lineSight2(1,:)<-50));
plot(tagData.t_1k(dur1k)-tagData.t_1k(dur1k(1)),lineSight2','Marker','.','lineStyle','none');
title('gaze direction');
ylabel('degree'); 
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
legend({'horizontal','vertical'}); xlabel('time (s)');
set(ax(4),'FontSize',10);
linkaxes([ax(1) ax(2) ax(3) ax(4)],'x')
saveFigure([fileName '_1D'],[direct folder '\Figures\'])

save([direct folder '\' fileName '.mat'])