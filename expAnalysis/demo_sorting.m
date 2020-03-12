function demo_sorting( objs, head, eyes, R, tt,dur, frameIdx,Img,tableCell)

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
    grid on; view(3); view([169.3 40.4]); %view([163.3 42]);
    xlabel('x(m)'); ylabel('y(m)'); zlabel('z(m)'); 

    
    %% eye
    for iEye = 1 : length(eyes.pos) 
        hAxis.eyePos(iEye,1) = plot3( hAxis.objs, eyes.pos{iEye}(1,frameIdx), eyes.pos{iEye}(2,frameIdx), eyes.pos{iEye}(3,frameIdx), 'ok', 'MarkerSize', 3, 'LineWidth', 1 );
        hAxis.eyePos(iEye,2) = plot3( hAxis.objs, eyes.pos{iEye}(1,frameIdx), eyes.pos{iEye}(2,frameIdx), eyes.pos{iEye}(3,frameIdx), 'ok', 'MarkerSize', 8, 'LineWidth', 1 );

        if( isfield( eyes, 'sightVec_sync' ) )
            sightVec = 10*eyes.sightVec_sync{iEye}(:,frameIdx-dur{1}(1)+1);
            hAxis.eyeVec(iEye) = quiver3( hAxis.objs, eyes.pos{iEye}(1,frameIdx), eyes.pos{iEye}(2,frameIdx), eyes.pos{iEye}(3,frameIdx), sightVec(1), sightVec(2), sightVec(3), '--k', 'LineWidth', 2 );
        end
    end
    
    %% table mapping
    t=timeSwitch(tt{2},tt{1},frameIdx)-dur{2}(1)+1;
    hAxis.objs = axes( 'position', [0.55, 0.06, 0.45, 0.95] );
    hold on;
    for i=1:length(tableCell.pts2D)
        scatter(100*tableCell.pts2D{i}(1,:),100*tableCell.pts2D{i}(2,:),'lineWidth',3);
    end
    if t>50
    scatter(100*eyes.gaze2D(1,t-50:t), 100*eyes.gaze2D(2,t-50:t),50,[0:50]/100,'filled');
    else
        scatter(100*eyes.gaze2D(1,1:t), 100*eyes.gaze2D(2,1:t),50,[1:t]/2/t,'filled');
    end
    colormap('hot');
    xlabel('cm'); ylabel('cm');

    h = image([-29.7 56.5],-[-41.5 20],Img); 
    uistack(h,'bottom')
    xlim([-8 38]); ylim([-12 32]);
end
