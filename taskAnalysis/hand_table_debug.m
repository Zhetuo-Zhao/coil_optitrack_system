function hand_table_debug( hand,tableCell,cols)

    hold on;
    
    for i=1:length(tableCell.pts2D)
        scatter(100*tableCell.pts2D{i}(1,:),100*tableCell.pts2D{i}(2,:),'lineWidth',3);
    end
    for hi=1:2
        for fi=1:5
            tmp=100*hand{hi}.out{fi,1};
            scatter(tmp(1,:),tmp(2,:),'MarkerEdgeColor','k','MarkerFaceColor',cols(fi,:));

            for ji=2:6
               plot([tmp(1,ji-1) tmp(1,ji)],[tmp(2,ji-1) tmp(2,ji)],'color',cols(fi,:)) 
            end
        end
    end
    xlabel('cm'); ylabel('cm');
end