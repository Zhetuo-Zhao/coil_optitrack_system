LOADFILE=0;  PlotFigure=0;
addpath('..\tools\');
if LOADFILE
    session='06-Mar-2020';
    direct=['../../data/' session '/'];
    folder='run3';

    load([direct folder '\processed_head.mat'])
    load([direct folder '\processed_eye.mat'])
    load([direct folder '\rawData_tag.mat'])
    load([direct folder '\processed_objects.mat'])
    load([direct folder '\processed_timings.mat'])
    load([direct folder '\processed_hand.mat'])
end



eyeIdx=1;


%% test head free table
fileName='headFreeTableFix';
for trialI=1%:length(timings.headFreeTable)
    trialTim=timings.headFreeTable{trialI}.trial;
    fixTim=timings.headFreeTable{trialI}.fix;
    durSync=trialTim(1):trialTim(2);
    dur1k=timeSwitch(tagData.t_1k,tagData.t_sync,trialTim(1)):timeSwitch(tagData.t_1k,tagData.t_sync,trialTim(2));

    lineSight1=eyeCalibTable.field.M\eye.coil_1k{eyeIdx}(:,dur1k);

    data{trialI}.t{1}=durSync; data{trialI}.t{2}=dur1k;

    data{trialI}.head.Euler_room=head.Euler_room(:,durSync);
    data{trialI}.head.Euler_head=head.Euler_head(:,durSync);
    data{trialI}.head.pos=head.pos(:,durSync);
    data{trialI}.head.Euler_room_coil=head.Euler_room_coil(:,dur1k);
    data{trialI}.head.Euler_head_coil=head.Euler_head_coil(:,dur1k);

    data{trialI}.eye.pos{eyeIdx}=eye.pos{eyeIdx}(:,durSync);
    data{trialI}.eye.pos1K{eyeIdx}=eye.pos1K{eyeIdx}(:,dur1k);

    data{trialI}.eye.sightVec_sync{eyeIdx}=eyeCalibTable.field.M\eye.coil_sync{eyeIdx}(:,durSync);
    data{trialI}.eye.ang2head_sync{eyeIdx}=eye2head(data{trialI}.eye.sightVec_sync{eyeIdx},head,durSync,0);

    data{trialI}.eye.sightVec_1k{eyeIdx}=eyeCalibTable.field.M\eye.coil_1k{eyeIdx}(:,dur1k);
    data{trialI}.eye.ang2head_1k{eyeIdx}=eye2head(data{trialI}.eye.sightVec_1k{eyeIdx},head,dur1k,1);

    objs{1}=tableGrid; objs{2}=table; 
    for objIdx=1:length(objs)
        data{trialI}.obj{objIdx}=object_trial(objs{objIdx},R_opti2room,durSync); 
    end 
    tableCell=Grid9PtsPos(objs,R_opti2room,durSync, [6 5 7],1);
    data{trialI}.tableCell=tableCell;
    gazePosOnPlane=linePlaneInter(eye.pos1K{eyeIdx}(:,dur1k), data{trialI}.eye.sightVec_1k{eyeIdx}, tableCell.plane.param);
    gaze2D=pts3to2(gazePosOnPlane, tableCell.plane.xAxis, tableCell.plane.yAxis, tableCell.plane.origin);
    data{trialI}.eye.gaze2D{eyeIdx}=gaze2D;
end

%% save data
save([direct folder '\' fileName '_processed.mat'],'data')

%% plot figures
if PlotFigure
    [pos3D1,pos2D1]=plotEyeTraceOnPlane(eye.pos1K{eyeIdx},dur1k,lineSight1,tableGrid.posCell1,[direct folder '\Figures\'],fileName);
    %%  plot 2D trace
    clear true_nc true_nc2 tmp
    true_nc=[];
    for i=1:7
    tmp=R_opti2room*tableGrid.marker{tableGrid.markerIdx(i)}.pos(:,durSync)-eye.pos{1}(:,durSync);
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
    xlim([-5 40]);
    saveFigure([fileName '_2D'],[direct folder '\Figures\']);

    %% plot 1D trace at each fixation 
    figure; 
    fixIdx=[1 2 3 6 9 7 4];
    for ptIdx=7:-1:1
        fixDur_sync=fixTim(ptIdx,1)+50: fixTim(ptIdx,2)-20;
        fixDur_1k=timeSwitch(coilData.t_1k,coilData.t_sync,fixTim(ptIdx,1)+50):timeSwitch(coilData.t_1k,coilData.t_sync,fixTim(ptIdx,2)-20);
        eyeVec=eyeCalibTable.field.M\eye.coil_1k{eyeIdx}(:,fixDur_1k);
        tmp=tableGrid.markerPos_room{ptIdx}(:,fixDur_sync)-eye.pos{1}(:,fixDur_sync);
        trueVec=normc(tmp);
        subplot(3,3,fixIdx(ptIdx)); hold on;

        eyeVec2=vec2ang(eyeVec); trueVec2=vec2ang(trueVec); 
        plot(coilData.t_1k(fixDur_1k),eyeVec2(1,:)*60,'Marker','.','lineStyle','none')
        plot(coilData.t_sync(fixDur_sync),trueVec2(1,:)*60,'Marker','.','lineStyle','none')
    end
    saveFigure([fileName '_X'],outputFolder);


    figure;
    for ptIdx=7:-1:1
        fixDur_sync=fixTim(ptIdx,1)+50: fixTim(ptIdx,2)-20;
        fixDur_1k=timeSwitch(coilData.t_1k,coilData.t_sync,fixTim(ptIdx,1)+50):timeSwitch(coilData.t_1k,coilData.t_sync,fixTim(ptIdx,2)-20);
        eyeVec=eyeCalibTable.field.M\eye.coil_1k{eyeIdx}(:,fixDur_1k);
        tmp=tableGrid.markerPos_room{ptIdx}(:,fixDur_sync)-eye.pos{1}(:,fixDur_sync);
        trueVec=normc(tmp);
        subplot(3,3,fixIdx(ptIdx)); hold on;

        eyeVec2=vec2ang(eyeVec); trueVec2=vec2ang(trueVec); 
        plot(coilData.t_1k(fixDur_1k),eyeVec2(2,:)*60,'Marker','.','lineStyle','none')
        plot(coilData.t_sync(fixDur_sync),trueVec2(2,:)*60,'Marker','.','lineStyle','none')
    end
    saveFigure([fileName 'Y'],outputFolder);

    %% plot 1D data: head euler, eye angle, eye in the head
    figure;  color3=get(gca,'colororder');
    ax(1)=subplot(3,1,1); hold on; 
    for i=1:3
        tmp=head.Euler_head_coil(i,dur1k)-mean(head.Euler_head_coil(i,dur1k))+mean(head.Euler_head(i,durSync));
        h(i)=plot(coilData.t_1k(dur1k),tmp,'Marker','.','color',color3(i,:),'lineStyle','none');
        plot(coilData.t_sync(durSync),head.Euler_head(i,durSync),'Marker','o','color',color3(i,:),'lineStyle','none');
    end
    legend(h(1:3),{'Yaw (z)','Pitch (y)','Roll (x)'})
    title('head Euler angle relative to head fix orientation')
    xlim([coilData.t_1k(dur1k(1)) coilData.t_1k(dur1k(end))]); %ylim([-1 10]);
    ylabel('degree');

    ax(2)=subplot(3,1,2); lineSight2=vec2ang(lineSight1);
    plot(coilData.t_1k(dur1k),lineSight2','Marker','.','lineStyle','none');
    title('line of sight in room');
    ylabel('degree'); 
    xlim([coilData.t_1k(dur1k(1)) coilData.t_1k(dur1k(end))]); 
    legend({'azimuth','altitude'});


    ax(3)=subplot(3,1,3); eye2head2=eye2head(lineSight1,head,dur1k,1);
    plot(coilData.t_1k(dur1k),eye2head2','Marker','.','lineStyle','none');
    title('eye angles in head');
    ylabel('degree'); xlabel('time (sec)');
    xlim([coilData.t_1k(dur1k(1)) coilData.t_1k(dur1k(end))]); 
    legend({'azimuth','altitude'});

    linkaxes([ax(1) ax(2) ax(3)],'x')
    saveFigure([fileName '_1D'],[direct folder '\Figures\'])

    objs{1}=helmet; objs{2}=table; objs{3}=tableGrid; 
    plot3Dobjects2(objs, durSync(1), R_opti2room);
    myScatter3(eye.pos{1}(:,durSync(1)));
    text(eye.pos{1}(1,durSync(1)),eye.pos{1}(2,durSync(1)),eye.pos{1}(3,durSync(1)),'eyePos')
    saveFigure([fileName '_3D'],[direct folder '\Figures\'])
end