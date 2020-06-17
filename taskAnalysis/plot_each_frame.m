function plot_each_frame(obj,t, R) %R: room 2 optitrack

    figure;
    pivot=R*obj.pos(:,t);
    scatter3(pivot(1),pivot(2),pivot(3),'lineWidth',2,'MarkerEdgeColor',[0.85 0.33 0.1]);
    hold on; 
    text(pivot(1),pivot(2),pivot(3),'pivot');
    
    
    for i=length(obj.marker):-1:1
        markersM_opt(:,i)=obj.marker{i}.pos(:,t);
    end
    markersM=R*markersM_opt;
    
    scatter3(markersM(1,:),markersM(2,:),markersM(3,:),'lineWidth',2,'MarkerEdgeColor',[0 0.45 0.74]);
    for i=1:size(markersM,2)
        text(markersM(1,i),markersM(2,i),markersM(3,i),sprintf('p%d',i))
    end
    
    hold off; 
    grid on; view(3)
    xlabel('x(m)'); ylabel('y(m)'); zlabel('z(m)'); 
    title(sprintf('marker offsets of object %s, frame %d', obj.name,t));
end
