function posCell=Grid9PtsPos(ninePoints,R_opti2room,tim, oxy,VIEW)

    for ptIdx=length(ninePoints.marker):-1:1
        posCell.pos(:,ptIdx)=R_opti2room*mean(ninePoints.marker{ninePoints.markerIdx(ptIdx)}.pos(:,tim),2);
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
    posCell.pts2D=pts3to2(posCell.PosOnPlane, posCell.plane.xAxis, posCell.plane.yAxis, posCell.plane.origin);

    if VIEW
        figure;
        scatter(posCell.pts2D(1,:),posCell.pts2D(2,:));
    end
end