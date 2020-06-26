% build 2D coordinate system based on 3D points on a plane of objects like
% 9 point grid, table, tableGrid.

% Input: 
% obj: rigid body involved. obj{1} is the object that the coordinate
% system will be based on.
% R_opti2room: rotation matrix for coordinate transformation from optitrack
% coordinate to room coordinate
% tim: fixation timings: order must match the order of obj{1}.markers
% oxy: the index of 3 markers. First one will be the original of the 2D
% coordinate. First-second vector will be the x axis. First-third vector
% will indicate the direction of y axis.

% Output: posCell
% posCell.plane: 2D coordinate system
% posCell.pts2D: 2D coordinate of all markers of objects.

function posCell=Grid9PtsPos(obj,R_opti2room,tim, oxy,VIEW)

    if length(obj)>1
        obj0=obj{1};
    else
        obj0=obj;
    end
    for ptIdx=length(obj0.marker):-1:1
        posCell.pos(:,ptIdx)=R_opti2room*mean(obj0.marker{obj0.markerIdx(ptIdx)}.pos(:,tim),2);
    end
    [posCell.plane.param,posCell.PosOnPlane]=planeFit(posCell.pos);
    
    if VIEW
        figure; hold on;
        scatter3(posCell.pos(1,:),posCell.pos(2,:),posCell.pos(3,:))
        scatter3(posCell.PosOnPlane(1,:),posCell.PosOnPlane(2,:),posCell.PosOnPlane(3,:))
    end
    % define a 2D coordinate system on the plane and transform the line of
    % sight in 3D to 2D gaze points on the plane of 9pts grid. 
    posCell.plane.origin=posCell.PosOnPlane(:,oxy(1));
    xAxis=posCell.PosOnPlane(:,oxy(2))-posCell.PosOnPlane(:,oxy(1));
    posCell.plane.xAxis=xAxis/norm(xAxis);
    yAxis=posCell.PosOnPlane(:,oxy(3))-posCell.PosOnPlane(:,oxy(1));
    posCell.plane.yAxis=anotherAxis(posCell.plane.param,posCell.plane.xAxis,yAxis);
    posCell.pts2D{1}=pts3to2(posCell.PosOnPlane, posCell.plane.xAxis, posCell.plane.yAxis, posCell.plane.origin);

    if length(obj)>1
        for i=2:length(obj)
            clear objMarker
            for ptIdx=length(obj{i}.marker):-1:1
                objMarker(:,ptIdx)=R_opti2room*mean(obj{i}.marker{ptIdx}.pos(:,tim),2);
            end
    
            posCell.pts2D{i}= pts3to2b(objMarker,posCell.plane.param, posCell.plane.xAxis, posCell.plane.yAxis, posCell.plane.origin);
        end
    end
    
    if VIEW
        figure; hold on;
        for i=1:length(posCell.pts2D)
        scatter(posCell.pts2D{i}(1,:),posCell.pts2D{i}(2,:));
        end
    end
end