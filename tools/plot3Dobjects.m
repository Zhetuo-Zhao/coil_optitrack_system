function plot3Dobjects(objs, t,R) %R: room 2 optitrack

    figure; hold on; 
    colors=get(gca,'colororder');
    for objIdx=1:length(objs)
        pivot=R*objs{objIdx}.pos(:,t);
        scatter3(pivot(1),pivot(2),pivot(3),'lineWidth',2,'MarkerEdgeColor',[0 0 0]);

        text(pivot(1),pivot(2),pivot(3),objs{objIdx}.name);

        clear markersM_opt
        for i=length(objs{objIdx}.marker):-1:1
            markersM_opt(:,i)=objs{objIdx}.marker{i}.pos(:,t);
        end
        markersM=R*markersM_opt;

        scatter3(markersM(1,:),markersM(2,:),markersM(3,:),'lineWidth',2,'MarkerEdgeColor',colors(objIdx,:));
        for i=1:size(markersM,2)
            text(markersM(1,i),markersM(2,i),markersM(3,i),sprintf('p%d',i))
        end
    end
    grid on; view(3)
    xlabel('x(m)'); ylabel('y(m)'); zlabel('z(m)'); 

end
