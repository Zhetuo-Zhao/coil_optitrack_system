LOADFILE=1;

if LOADFILE
    session='05-Feb-2020';
    direct=['Z:/fieldCalibrate/data/' session '/'];
    folder='session2';

    load([direct folder '\processed_head.mat'])
    load([direct folder '\processed_eye.mat'])
    load([direct folder '\rawData_tag.mat'])
    load([direct folder '\processed_objects.mat'])
    load([direct folder '\processed_timings.mat'])
end


fileName='headFree9Pt';
load([direct folder '\eyeCalib9pts.mat']);
eyeIdx=1;
trialTim=timings.headFree9pt{1}.trial;
fixTim=timings.headFree9pt{1}.fix;
tim2=trialTim(2)-200;
durSync=trialTim(1):tim2;
dur1k=timeSwitch(tagData.t_1k,tagData.t_sync,trialTim(1)):timeSwitch(tagData.t_1k,tagData.t_sync,tim2);

lineSight1=eyeCalib9pts.field.M\eye.coil_1k{eyeIdx}(:,dur1k);
lineSight2 = vec2ang(lineSight1);
[pos3D1,pos2D1]=plotEyeTraceOnPlane(eye.pos1K{eyeIdx},dur1k,lineSight1,ninePoints.posCell1,[direct folder '\Figures\'],'headFree9Pt1K');
%%  plot 2D trace
clear true_nc true_nc2 tmp
true_nc=[];
for i=1:9
tmp=R_opti2room*ninePoints.marker{ninePoints.markerIdx(i)}.pos(:,durSync)-eye.pos{1}(:,durSync);
true_nc=[true_nc normc(tmp)];
end

true_nc2=vec2ang(true_nc);
figure('position',[100 100 800 300]); %suptitle(sprintf('session %d',i));

subplot(1,2,1); hold on;
scatter(-true_nc2(1,:),true_nc2(2,:),'MarkerEdgeColor',[0.5 0.5 0.5]);
scatter(-lineSight2(1,:),lineSight2(2,:),20,[1:size(lineSight2,2)]);
xlabel('azimuth (degree)'); ylabel('altitude (degree)'); title('gaze angle');

subplot(1,2,2); hold on;
plot(100*pos2D1(1,:), 100*pos2D1(2,:),'Marker','+','color','r')
scatter(100*ninePoints.posCell1.pts2D(1,:),100*ninePoints.posCell1.pts2D(2,:),'lineWidth',3,'MarkerEdgeColor','k');
xlabel('cm'); ylabel('cm'); title('gaze projection on 9-point grid');
saveFigure([fileName '_2D'],[direct folder '\Figures\']);


figure; hold on;
plot(100*pos2D1(1,:), 100*pos2D1(2,:),'Marker','+','color','r')
scatter(100*ninePoints.posCell1.pts2D(1,:),100*ninePoints.posCell1.pts2D(2,:),'lineWidth',3,'MarkerEdgeColor','k');
xlabel('cm'); ylabel('cm');
saveFigure([fileName '_2D'],[direct folder '\Figures\']);
%% plot 1D trace at each fixation 
figure;
for ptIdx=9:-1:1
    fixDur_sync=fixTim(ptIdx,1)+50: fixTim(ptIdx,2)-20;
    fixDur_1k=timeSwitch(tagData.t_1k,tagData.t_sync,fixTim(ptIdx,1)+50):timeSwitch(tagData.t_1k,tagData.t_sync,fixTim(ptIdx,2)-20);
    eyeVec=eyeCalib9pts.field.M\eye.coil_1k{eyeIdx}(:,fixDur_1k);
    tmp=ninePoints.markerPos_room{ptIdx}(:,fixDur_sync)-eye.pos{1}(:,fixDur_sync);
    trueVec=normc(tmp);
    subplot(3,3,ptIdx); hold on;
    
    eyeVec2=vec2ang(eyeVec); trueVec2=vec2ang(trueVec); 
    plot(tagData.t_1k(fixDur_1k)-tagData.t_1k(fixDur_1k(1)),(eyeVec2(1,:)-trueVec2(1,1))*60,'Marker','.','lineStyle','none')
    plot(tagData.t_sync(fixDur_sync)-tagData.t_sync(fixDur_sync(1)),(trueVec2(1,:)-trueVec2(1,1))*60,'Marker','.','lineStyle','none')
end
saveFigure([fileName '_X'],[direct folder '\Figures\']);


figure;
for ptIdx=9:-1:1
    fixDur_sync=fixTim(ptIdx,1)+50: fixTim(ptIdx,2)-20;
    fixDur_1k=timeSwitch(tagData.t_1k,tagData.t_sync,fixTim(ptIdx,1)+50):timeSwitch(tagData.t_1k,tagData.t_sync,fixTim(ptIdx,2)-20);
    eyeVec=eyeCalib9pts.field.M\eye.coil_1k{eyeIdx}(:,fixDur_1k);
    tmp=ninePoints.markerPos_room{ptIdx}(:,fixDur_sync)-eye.pos{1}(:,fixDur_sync);
    trueVec=normc(tmp);
    subplot(3,3,ptIdx); hold on;
    
    eyeVec2=vec2ang(eyeVec); trueVec2=vec2ang(trueVec); 
    plot(tagData.t_1k(fixDur_1k)-tagData.t_1k(fixDur_1k(1)),(eyeVec2(2,:)-trueVec2(2,1))*60,'Marker','.','lineStyle','none')
    plot(tagData.t_sync(fixDur_sync)-tagData.t_sync(fixDur_sync(1)),(trueVec2(2,:)-trueVec2(2,1))*60,'Marker','.','lineStyle','none')
end
saveFigure([fileName 'Y'],[direct folder '\Figures\']);

%%
figure;
for ptIdx=9:-1:1
    fixDur_sync=fixTim(ptIdx,1)+50: fixTim(ptIdx,2)-20;
    fixDur_1k=timeSwitch(tagData.t_1k,tagData.t_sync,fixTim(ptIdx,1)+50):timeSwitch(tagData.t_1k,tagData.t_sync,fixTim(ptIdx,2)-20);
    eyeVec=eyeCalib9pts.field.M\eye.coil_1k{eyeIdx}(:,fixDur_1k);
    tmp=ninePoints.markerPos_room{ptIdx}(:,fixDur_sync)-eye.pos{1}(:,fixDur_sync);
    trueVec=normc(tmp);
    subplot(3,3,ptIdx); hold on;
    
    eyeVec2=vec2ang(eyeVec); trueVec2=vec2ang(trueVec); 
    ref=[interp1(tagData.t_sync(fixDur_sync),trueVec2(1,:),tagData.t_1k(fixDur_1k),'spline');...
         interp1(tagData.t_sync(fixDur_sync),trueVec2(2,:),tagData.t_1k(fixDur_1k),'spline')];
    plot(tagData.t_1k(fixDur_1k)-tagData.t_1k(fixDur_1k(1)),(-eyeVec2(1,:)+ref(1,:))*60,'Marker','.','lineStyle','none');
end
saveFigure([fileName '_X2'],[direct folder '\Figures\']);

figure;
for ptIdx=9:-1:1
    fixDur_sync=fixTim(ptIdx,1)+50: fixTim(ptIdx,2)-20;
    fixDur_1k=timeSwitch(tagData.t_1k,tagData.t_sync,fixTim(ptIdx,1)+50):timeSwitch(tagData.t_1k,tagData.t_sync,fixTim(ptIdx,2)-20);
    eyeVec=eyeCalib9pts.field.M\eye.coil_1k{eyeIdx}(:,fixDur_1k);
    tmp=ninePoints.markerPos_room{ptIdx}(:,fixDur_sync)-eye.pos{1}(:,fixDur_sync);
    trueVec=normc(tmp);
    subplot(3,3,ptIdx); hold on;
    
    eyeVec2=vec2ang(eyeVec); trueVec2=vec2ang(trueVec); 
    ref=[interp1(tagData.t_sync(fixDur_sync),trueVec2(1,:),tagData.t_1k(fixDur_1k),'spline');...
         interp1(tagData.t_sync(fixDur_sync),trueVec2(2,:),tagData.t_1k(fixDur_1k),'spline')];
    plot(tagData.t_1k(fixDur_1k)-tagData.t_1k(fixDur_1k(1)),(-eyeVec2(2,:)+ref(2,:))*60,'Marker','.','lineStyle','none');
end
saveFigure([fileName 'Y2'],[direct folder '\Figures\']);

%% plot 1D data: head euler, eye angle, eye in the head
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
    plot(tagData.t_sync(durSync)-tagData.t_sync(durSync(1)),head.Euler_head(i,durSync),'Marker','o','color',color3(i,:),'lineStyle','none');
end
legend(h(1:3),{'Yaw (z)','Pitch (y)','Roll (x)'})
title('head rotation')
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
ylabel('degree');
set(ax(2),'FontSize',12);

ax(4)=subplot(4,1,4); 
plot(tagData.t_1k(dur1k)-tagData.t_1k(dur1k(1)),lineSight2','Marker','.','lineStyle','none');
title('gaze direction (in room)');
ylabel('degree'); xlabel('time (s)');
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
legend({'horizontal','vertical'});
set(ax(4),'FontSize',12);

ax(3)=subplot(4,1,3); ang2head=eye2head(lineSight1,head,dur1k,1);
plot(tagData.t_1k(dur1k)-tagData.t_1k(dur1k(1)),ang2head','Marker','.','lineStyle','none');
title('eye movements (angle in head)');
ylabel('degree'); 
xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
legend({'horizontal','vertical'});
set(ax(3),'FontSize',12);


linkaxes([ax(1) ax(2) ax(3) ax(4)],'x')
saveFigure([fileName '_1D'],[direct folder '\Figures\'])

objs{1}=helmet; objs{2}=table; objs{3}=ninePoints; 
plot3Dobjects2(objs, durSync(1), R_opti2room);
myScatter3(eye.pos{1}(:,durSync(1)));
text(eye.pos{1}(1,durSync(1)),eye.pos{1}(2,durSync(1)),eye.pos{1}(3,durSync(1)),'eyePos')
saveFigure([fileName '_3D'],[direct folder '\Figures\'])