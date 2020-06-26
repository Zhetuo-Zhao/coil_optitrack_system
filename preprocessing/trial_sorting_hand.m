LOADFILE=1; DemoVideo=0; PlotFigure=0;
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

fileName='sorting_color';
eyeIdx=1;
R_opti2room=[0 0 -1;-1 0 0 ; 0 1 0];
trialTim=timings.sorting{1}.trial;
tim1=trialTim(1);
tim2=trialTim(2);
durSync=tim1:tim2;
dur1k=timeSwitch(tagData.t_1k,tagData.t_sync,trialTim(1)):timeSwitch(tagData.t_1k,tagData.t_sync,tim2);
data.t{1}=durSync;
data.t{2}=dur1k;

data.head.Euler_room=head.Euler_room(:,durSync);
data.head.Euler_head=head.Euler_head(:,durSync);
data.head.pos=head.pos(:,durSync);
data.head.Euler_room_coil=head.Euler_room_coil(:,dur1k);
data.head.Euler_head_coil=head.Euler_head_coil(:,dur1k);

data.eye.pos{eyeIdx}=eye.pos{eyeIdx}(:,durSync);
data.eye.pos1K{eyeIdx}=eye.pos1K{eyeIdx}(:,dur1k);

%%
folders={'high','middle','low'};
for i=length(folders):-1:1
    load(['..\..\calibration\field\BinCoil\200205\' folders{i} '\estFieldR13_syncDebug']);
    estField3D{i}=estField;
end

load([direct folder '\eyeCalibTable.mat']);
data.eye.sightVec_1k{eyeIdx}=field_compensate_3D(estField3D, eye.coil_1k{eyeIdx}(:,dur1k), eye.pos1K{eyeIdx}(:,dur1k), eyeCalibTable.field);     
data.eye.ang2head_1k{eyeIdx}=eye2head(data.eye.sightVec_1k{eyeIdx},head,dur1k,1);

data.eye.sightVec_sync{eyeIdx}=field_compensate_3D(estField3D, eye.coil_sync{eyeIdx}(:,durSync), eye.pos{eyeIdx}(:,durSync), eyeCalibTable.field);     
data.eye.ang2head_sync{eyeIdx}=eye2head(data.eye.sightVec_sync{eyeIdx},head,durSync,0);

objs{1}=tableGrid; objs{2}=table; objs{3}=iceTray;
for objIdx=1:length(objs)
    data.obj{objIdx}=object_trial(objs{objIdx},R_opti2room,durSync); 
end
tableCell=Grid9PtsPos(objs,R_opti2room,durSync, [6 5 7],1);
data.tableCell=tableCell;
gazePosOnPlane=linePlaneInter(eye.pos1K{eyeIdx}(:,dur1k), data.eye.sightVec_1k{eyeIdx}, tableCell.plane.param);
gaze2D=pts3to2(gazePosOnPlane, tableCell.plane.xAxis, tableCell.plane.yAxis, tableCell.plane.origin);
data.eye.gaze2D{eyeIdx}=gaze2D;


%% hand projection on the table
for t=durSync
    t
    for hi=1:2
        for fi=1:5
            tmp=R_opti2room*hand{hi}.out{fi,t}/1000;
            for ji=1:6
                PtonTable=linePlaneInter(tmp(:,ji), tableCell.plane.param(1:3)', tableCell.plane.param);
                hand2D{hi}.out{fi,t-durSync(1)+1}(:,ji)=pts3to2(PtonTable, tableCell.plane.xAxis, tableCell.plane.yAxis, tableCell.plane.origin);
            end
        end
    end
end
for hi=1:2
    data.hand{hi}.jointPos=hand{hi}.out(:,durSync);
    data.hand{hi}.jointPos2D=hand2D{hi}.out;
end

%% save data
save([direct folder '\' fileName '_processed.mat'],'data')


%% save video
if DemoVideo
    Img=imread([direct folder '/report/tableTilted.png']);
    tt{1}=tagData.t_sync; tt{2}=tagData.t_1k;
    dur{1}=durSync; dur{2}=dur1k;

    myVideo = VideoWriter(fileName); %open video file
    myVideo.FrameRate = 24;  %can adjust this, 5 - 10 works well for me
    open(myVideo)
    figure('position',[10 50 1900 800]); cols=get(gca,'colorOrder');
    for t=durSync(1):4:durSync(end)
        t
        demo_sorting_hand( data, tt,dur, t,Img,cols);
        pause(0.01) %Pause and grab frame
        frame = getframe(gcf); %get frame
        writeVideo(myVideo, frame);
        clf;
    end
    close(myVideo)
end

%% plot 1D trace
if PlotFigure
    figure;  color3=get(gca,'colororder');
    ax(1)=subplot(4,1,1);
    h1=plot(tagData.t_sync(durSync)-tagData.t_sync(durSync(1)),(head.pos(:,durSync)-mean(head.pos(:,head.refframes),2))','Marker','.','lineStyle','none');
    title('head translation');
    legend(h1,{'x','y','z'});
    xlim([tagData.t_sync(durSync(1)) tagData.t_sync(durSync(end))]-tagData.t_sync(durSync(1)));  
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

    ax(4)=subplot(4,1,4); lineSight2=vec2ang(data.eye.sightVec_1k{eyeIdx});
    lineSight2(1,find(lineSight2(1,:)<-50))=180+lineSight2(1,find(lineSight2(1,:)<-50));
    plot(tagData.t_1k(dur1k)-tagData.t_1k(dur1k(1)),lineSight2','Marker','.','lineStyle','none');
    title('gaze direction (in room)');
    ylabel('degree'); xlabel('time (s)');
    xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
    legend({'horizontal','vertical'});
    set(ax(4),'FontSize',12);

    ax(3)=subplot(4,1,3); 
    plot(tagData.t_1k(dur1k)-tagData.t_1k(dur1k(1)),data.eye.ang2head_1k{eyeIdx}','Marker','.','lineStyle','none');
    title('eye movements (angle in head)');
    ylabel('degree'); xlabel('time (s)');
    xlim([tagData.t_1k(dur1k(1)) tagData.t_1k(dur1k(end))]-tagData.t_1k(dur1k(1))); 
    legend({'horizontal','vertical'});
    set(ax(3),'FontSize',12);


    linkaxes([ax(1) ax(2) ax(3) ax(4)],'x')
    saveFigure(['sorting1_zoomIn' '_1D'],[direct folder '\Figures\'])
end