function demo_headEyeSacc2( helmet,pts, head, eyes, tagData, R, tt, dur, frameIdx)

    %% object panel
    hAxis.objs = axes( 'position', [0.06, 0.06, 0.45, 0.95] );
    xlim([-0.8 0.6]); ylim([-2 -0.6]); zlim([0.6 1.3]);
    hold on;
    colors=get(gca,'colororder'); colors=[colors; 0.3*ones(1,3)]; 

    pivot=R*helmet.pos(:,frameIdx);
    scatter3(pivot(1),pivot(2),pivot(3),'lineWidth',2,'MarkerEdgeColor',[0 0 0]);
    text(pivot(1)-0.02,pivot(2),pivot(3),helmet.name,'fontsize',12);

    clear markersM_opt
    for i=length(helmet.marker):-1:1
        markersM_opt(:,i)=helmet.marker{i}.pos(:,frameIdx);
    end
    markersM=R*markersM_opt;

    for i=1:size(markersM,2)
        for j=1:size(markersM,2)
            plot3([markersM(1,i) markersM(1,j)],[markersM(2,i) markersM(2,j)],[markersM(3,i) markersM(3,j)],'color',colors(1,:));
        end
    end
    scatter3(markersM(1,:),markersM(2,:),markersM(3,:),'lineWidth',2,'MarkerEdgeColor',colors(1,:));
%     for i=1:size(markersM,2)
%         text(markersM(1,i),markersM(2,i),markersM(3,i),sprintf('p%d',i))
%     end
 
    
    %% fixation points
    for ptsIdx=1:size(pts,2)
        scatter3(pts{ptsIdx}(1,frameIdx),pts{ptsIdx}(2,frameIdx),pts{ptsIdx}(3,frameIdx),'lineWidth',3,'MarkerEdgeColor',colors(ptsIdx,:));
        text(pts{ptsIdx}(1,frameIdx)-0.02,pts{ptsIdx}(2,frameIdx),pts{ptsIdx}(3,frameIdx),sprintf('p%d',ptsIdx));
        plot3([pts{ptsIdx}(1,frameIdx) pts{ptsIdx}(1,frameIdx)],[pts{ptsIdx}(2,frameIdx) pts{ptsIdx}(2,frameIdx)],[pts{ptsIdx}(3,frameIdx) 0.4],'k--');
    end
    
    grid on; view(3); view([158.1 31.6]); %view([163.3 42]);
    xlabel('x(m)'); ylabel('y(m)'); zlabel('z(m)'); 
   
    %% eye
    for iEye = 1 : length(eyes.pos) 
        hAxis.eyePos(iEye,1) = plot3( hAxis.objs, eyes.pos{iEye}(1,frameIdx), eyes.pos{iEye}(2,frameIdx), eyes.pos{iEye}(3,frameIdx), 'ok', 'MarkerSize', 12, 'LineWidth', 1 ,'MarkerFaceColor', [1 0.84 0]);
        hAxis.eyePos(iEye,2) = plot3( hAxis.objs, eyes.pos{iEye}(1,frameIdx), eyes.pos{iEye}(2,frameIdx), eyes.pos{iEye}(3,frameIdx), 'ok', 'MarkerSize', 3, 'LineWidth', 1 ,'MarkerFaceColor', [0 0 0]);
        
        text(eyes.pos{iEye}(1,frameIdx)-0.02,eyes.pos{iEye}(2,frameIdx),eyes.pos{iEye}(3,frameIdx),'eye','fontsize',12);
        
        if( isfield( eyes, 'sightVec_sync' ) )
            sightVec = 10*eyes.sightVec_sync{iEye}(:,frameIdx-dur{1}(1)+1);
            hAxis.eyeVec(iEye) = quiver3( hAxis.objs, eyes.pos{iEye}(1,frameIdx), eyes.pos{iEye}(2,frameIdx), eyes.pos{iEye}(3,frameIdx), sightVec(1), sightVec(2), sightVec(3), '--k', 'LineWidth', 2 );
        end
        %plot3([eyes.pos{iEye}(1,frameIdx) eyes.pos{iEye}(1,frameIdx)],[eyes.pos{iEye}(2,frameIdx) eyes.pos{iEye}(2,frameIdx)],[eyes.pos{iEye}(3,frameIdx) 0.4],'k--');
    end
    
%     [xi,yi]=meshgrid(-0.8:0.05:0.6,-2:0.05:-0.6);
%     scatter3(xi(:),yi(:),0.6*ones(1,length(xi(:))),5,0.5*ones(1,3),'filled');
%     for xi=-0.8:0.05:0.6
%         for yi=-2:0.05:-0.6
%             scatter3(xi,yi,0.6,5,0.7*ones(1,3),'filled');
%         end
%     end
    for xi=-0.8:0.05:0.6
        yi=-2:0.05:-0.6;
        scatter3(xi*ones(1,length(yi)),yi,0.6*ones(1,length(yi)),5,0.7*ones(1,3),'filled');
    end
    
    %% 1D tace
    hAxis.objs = axes( 'position', [0.55, 0.75+0.03, 0.44, 0.185] );
    h1=plot(tt{1}(dur{1})-tt{1}(dur{1}(1)),(head.pos(:,dur{1})-mean(head.pos(:,head.refframes),2))','Marker','.','lineStyle','none');
    title('head translation');
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    legend(h1,{'x','y','z'});
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1))); 
    ylabel('m');
    set(hAxis.objs,'FontSize',12);
    
    hAxis.objs = axes( 'position', [0.55, 0.5+0.04, 0.44, 0.185] );
    hold on; 
    h1=plot(tt{2}(dur{2})-tt{2}(dur{2}(1)),head.Euler_head_coil(:,dur{2})','Marker','.','lineStyle','none');
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    legend(h1,{'Yaw (z)','Pitch (y)','Roll (x)'})
    title('head rotation')
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1))); 
    ylabel('degree');
    set(hAxis.objs,'FontSize',12);
    
    hAxis.objs = axes( 'position', [0.55, 0.25+0.05, 0.44, 0.185] );
    h1=plot(tt{2}(dur{2})-tt{2}(dur{2}(1)),eyes.ang2head_1k{1}','Marker','.','lineStyle','none');
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    title('eye movements (angle in head)');
    ylabel('degree'); 
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1)));
    legend(h1,{'horizontal','vertical'});
    set(hAxis.objs,'FontSize',12);
    
    hAxis.objs = axes( 'position', [0.55, 0+0.06, 0.44, 0.185] );
    lineSight2=vec2ang(eyes.sightVec_1k{1}); 
    lineSight2(1,find(lineSight2(1,:)<-50))=180+lineSight2(1,find(lineSight2(1,:)<-50));
    h1=plot(tt{2}(dur{2})-tt{2}(dur{2}(1)),lineSight2','Marker','.','lineStyle','none');
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    title('gaze direction (in room)');
    ylabel('degree');  xlabel('time (s)');
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1)));
    legend(h1,{'horizontal','vertical'});
    set(hAxis.objs,'FontSize',12);
    
end
