function demo_sorting_hand( data,tt,dur, frameIdx,Img,cols)

    %% 1D tace
    hAxis.objs = axes( 'position', [0.55, 0.75+0.03, 0.44, 0.18] );
    h1=plot(tt{1}(dur{1})-tt{1}(dur{1}(1)),data.head.pos'-mean(data.head.pos,2)','Marker','.','lineStyle','none');
    title('head translation'); ylim([-0.04 0.04]);
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    legend(h1,{'x','y','z'});
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1))); 
    ylabel('m');
    set(hAxis.objs,'FontSize',12);
    
    hAxis.objs = axes( 'position', [0.55, 0.5+0.04, 0.44, 0.18] );
    hold on; 
    h1=plot(tt{2}(dur{2})-tt{2}(dur{2}(1)),data.head.Euler_head_coil','Marker','.','lineStyle','none');
    ylim([-10 40]);
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    legend(h1,{'Yaw (z)','Pitch (y)','Roll (x)'})
    title('head rotation')
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1))); 
    ylabel('degree');
    set(hAxis.objs,'FontSize',12);
    
    hAxis.objs = axes( 'position', [0.55, 0.25+0.05, 0.44, 0.18] );
    h1=plot(tt{2}(dur{2})-tt{2}(dur{2}(1)),data.eye.ang2head_1k{1}','Marker','.','lineStyle','none');
    ylim([-40 20]);
    h2=line([tt{1}(frameIdx) tt{1}(frameIdx)]-tt{1}(dur{1}(1)),ylim,'color','k','lineStyle','--','lineWidth',1.5);
    title('eye movements (angle in head)');
    ylabel('degree'); 
    xlim([tt{1}(dur{1}(1)) tt{1}(dur{1}(end))]-tt{1}(dur{1}(1)));
    legend(h1,{'horizontal','vertical'});
    set(hAxis.objs,'FontSize',12);
    
    hAxis.objs = axes( 'position', [0.55, 0+0.06, 0.44, 0.18] );
    lineSight2=vec2ang(data.eye.sightVec_1k{1}); 
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
    % table markers
    for i=1:length(data.tableCell.pts2D)
        scatter(100*data.tableCell.pts2D{i}(1,:),100*data.tableCell.pts2D{i}(2,:),'lineWidth',3);
    end
    % gaze trace
    if t>50
        scatter(100*data.eye.gaze2D{1}(1,t-50:t), 100*data.eye.gaze2D{1}(2,t-50:t),50,[0:50]/100,'filled');
    else
        scatter(100*data.eye.gaze2D{1}(1,1:t), 100*data.eye.gaze2D{1}(2,1:t),50,[1:t]/2/t,'filled');
    end
    colormap('hot');
    
    % hand
    for hi=1:2
        for fi=1:5
            
            tmp=100*data.hand{hi}.jointPos2D{fi,frameIdx-dur{1}(1)+1};
            
            if fi==1
                scatter(tmp(1,1:6),tmp(2,1:6),'MarkerEdgeColor','k','MarkerFaceColor',cols(fi+2,:));
                col=[1 1 1];
                for ji=2:6
                   plot([tmp(1,ji-1) tmp(1,ji)],[tmp(2,ji-1) tmp(2,ji)],'color',col,'lineWidth',2) 
                end
            else
                scatter(tmp(1,:),tmp(2,:),'MarkerEdgeColor','k','MarkerFaceColor',cols(fi+2,:));
                if fi==2
                    col=[1 0 0];
                else
                    col=[0 0 0];
                end
                for ji=2:6
                   plot([tmp(1,ji-1) tmp(1,ji)],[tmp(2,ji-1) tmp(2,ji)],'color',col,'lineWidth',2) 
                end
            end
            
        end
    end
    xlabel('cm'); ylabel('cm');
    
    % attach background picture
    h = image([-29.7 56.5],-[-41.5 20],Img); 
    uistack(h,'bottom')
    xlim([-8 38]); ylim([-12 32]);
end
