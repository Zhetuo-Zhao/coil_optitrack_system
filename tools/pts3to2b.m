function pts2=pts3to2b(points,planeParam, xAxis, yAxis, o)
  
    for j=size(points,2):-1:1
        pts3OnPlane(:,j)=linePlaneInter(points(:,j), planeParam(1:3)', planeParam);
    end
    
    vec=pts3OnPlane-o;
    pts2(2,:)=yAxis'*vec;
    pts2(1,:)=xAxis'*vec;
end

