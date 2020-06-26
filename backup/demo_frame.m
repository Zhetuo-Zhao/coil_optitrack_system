function demo_frame( objs, head, eyes, tagData, R, tt, dur, frameIdx)

    %% object panel
    hAxis.objs = axes( 'position', [0.06, 0.06, 0.45, 0.95] );
    xlim([-0.8 0.6]); ylim([-2 -0.6]); zlim([0.6 1.3]);
    hold on;
    colors=get(gca,'colororder');
    for objIdx=1:length(objs)
        pivot=R*objs{objIdx}.pos(:,frameIdx);
        scatter3(pivot(1),pivot(2),pivot(3),'lineWidth',2,'MarkerEdgeColor',[0 0 0]);

        text(pivot(1),pivot(2),pivot(3),objs{objIdx}.name);

        clear markersM_opt
        for i=length(objs{objIdx}.marker):-1:1
            markersM_opt(:,i)=objs{objIdx}.marker{i}.pos(:,frameIdx);
        end
        markersM=R*markersM_opt;
        
        for i=1:size(markersM,2)
            for j=1:size(markersM,2)
                plot3([markersM(1,i) markersM(1,j)],[markersM(2,i) markersM(2,j)],[markersM(3,i) markersM(3,j)],'color',colors(objIdx,:));
            end
        end
        
        scatter3(markersM(1,:),markersM(2,:),markersM(3,:),'lineWidth',2,'MarkerEdgeColor',colors(objIdx,:));
        for i=1:size(markersM,2)
            text(markersM(1,i),markersM(2,i),markersM(3,i),sprintf('p%d',i))
        end
    end
    grid on; view(3); view([158.1 31.6]); %view([163.3 42]);
    xlabel('x(m)'); ylabel('y(m)'); zlabel('z(m)'); 

    
    %% eye
    for iEye = 1 : length(eyes.pos) 
        hAxis.eyePos(iEye,1) = plot3( hAxis.objs, eyes.pos{iEye}(1,frameIdx), eyes.pos{iEye}(2,frameIdx), eyes.pos{iEye}(3,frameIdx), 'ok', 'MarkerSize', 3, 'LineWidth', 1 );
        hAxis.eyePos(iEye,2) = plot3( hAxis.objs, eyes.pos{iEye}(1,frameIdx), eyes.pos{iEye}(2,frameIdx), eyes.pos{iEye}(3,frameIdx), 'ok', 'MarkerSize', 8, 'LineWidth', 1 );

        if( isfield( eyes, 'sightVec_sync' ) )
            sightVec = 10*eyes.sightVec_sync{iEye}(:,frameIdx-dur(1)+1);
            hAxis.eyeVec(iEye) = quiver3( hAxis.objs, eyes.pos{iEye}(1,frameIdx), eyes.pos{iEye}(2,frameIdx), eyes.pos{iEye}(3,frameIdx), sightVec(1), sightVec(2), sightVec(3), '--k', 'LineWidth', 2 );
        end
    end
    %% 1D tace
    hAxis.objs = axes( 'position', [0.55, 0.75+0.04, 0.44, 0.185] );
    h1=plot(tt(dur),(head.pos(:,dur)-mean(head.pos(:,head.refframes),2))','Marker','.','lineStyle','none');
    title('head position relative to that in head rest');
    h2=line([tt(frameIdx) tt(frameIdx)],ylim,'color','k','lineStyle','--','lineWidth',1.5);
    legend(h1,{'x','y','z'});
    xlim([tt(dur(1)) tt(dur(end))]); 
    ylabel('meter');
    
    hAxis.objs = axes( 'position', [0.55, 0.5+0.04, 0.44, 0.185] );
    hold on; 
    h1=plot(tt(dur),head.Euler_head(:,dur)','Marker','.','lineStyle','none');
    h2=line([tt(frameIdx) tt(frameIdx)],ylim,'color','k','lineStyle','--','lineWidth',1.5);
    legend(h1,{'Yaw (z)','Pitch (y)','Roll (x)'})
    title('head Euler angle relative to head orientation in head rest')
    xlim([tt(dur(1)) tt(dur(end))]); 
    ylabel('degree');

    hAxis.objs = axes( 'position', [0.55, 0.25+0.04, 0.44, 0.185] );
    lineSight2=vec2ang(eyes.sightVec_sync{1}); 
    lineSight2(1,find(lineSight2(1,:)<-50))=180+lineSight2(1,find(lineSight2(1,:)<-50));
    h1=plot(tt(dur),lineSight2','Marker','.','lineStyle','none');
    h2=line([tt(frameIdx) tt(frameIdx)],ylim,'color','k','lineStyle','--','lineWidth',1.5);
    title('line of sight in room');
    ylabel('degree'); 
    xlim([tt(dur(1)) tt(dur(end))]);
    legend(h1,{'azimuth','altitude'});

    hAxis.objs = axes( 'position', [0.55, 0+0.04, 0.44, 0.185] );
    h1=plot(tt(dur),eyes.ang2head_sync{1}','Marker','.','lineStyle','none');
    h2=line([tt(frameIdx) tt(frameIdx)],ylim,'color','k','lineStyle','--','lineWidth',1.5);
    title('eye angles in head');
    ylabel('degree'); xlabel('time (sec)');
    xlim([tt(dur(1)) tt(dur(end))]);
    legend(h1,{'azimuth','altitude'});
end
