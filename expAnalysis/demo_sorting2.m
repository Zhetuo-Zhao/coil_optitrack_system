function demo_sorting2( head, eyes,tt,dur, frameIdx,Img,tableCell)

    %% 1D tace
    hAxis.objs = axes( 'position', [0.55, 0.75+0.03, 0.44, 0.18] );
    h1=plot(tt{1}(dur{1})-tt{1}(dur{1}(1)),(head.pos(:,dur{1})-mean(head.pos(:,head.refframes),2))','Marker','.','lineStyle','none');
    title('head translation'); ylim([-0.04 0.04]);
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    legend(h1,{'x','y','z'});
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1))); 
    ylabel('m');
    set(hAxis.objs,'FontSize',12);
    
    hAxis.objs = axes( 'position', [0.55, 0.5+0.04, 0.44, 0.18] );
    hold on; 
    h1=plot(tt{2}(dur{2})-tt{2}(dur{2}(1)),head.Euler_head_coil(:,dur{2})','Marker','.','lineStyle','none');
    ylim([-10 40]);
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    legend(h1,{'Yaw (z)','Pitch (y)','Roll (x)'})
    title('head rotation')
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1))); 
    ylabel('degree');
    set(hAxis.objs,'FontSize',12);
    
    hAxis.objs = axes( 'position', [0.55, 0.25+0.05, 0.44, 0.18] );
    h1=plot(tt{2}(dur{2})-tt{2}(dur{2}(1)),eyes.ang2head_1k{1}','Marker','.','lineStyle','none');
    ylim([-40 20]);
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    title('eye movements (angle in head)');
    ylabel('degree'); 
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1)));
    legend(h1,{'horizontal','vertical'});
    set(hAxis.objs,'FontSize',12);
    
    hAxis.objs = axes( 'position', [0.55, 0+0.06, 0.44, 0.18] );
    lineSight2=vec2ang(eyes.sightVec_1k{1}); 
    h1=plot(tt{2}(dur{2})-tt{2}(dur{2}(1)),lineSight2','Marker','.','lineStyle','none'); 
    ylim([-70 70]);
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    title('gaze direction (in room)');
    ylabel('degree');  xlabel('time (s)');
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1)));
    legend(h1,{'horizontal','vertical'},'Location','best');
    set(hAxis.objs,'FontSize',12);
    
    %% table mapping
    t=timeSwitch(tt{2},tt{1},frameIdx)-dur{2}(1)+1;
    hAxis.objs = axes( 'position', [0.04, 0.06, 0.45, 0.95] );
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
