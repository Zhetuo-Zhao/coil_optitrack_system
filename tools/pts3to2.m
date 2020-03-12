function pts2=pts3to2(pts3OnPlane, xAxis, yAxis, o)
  
    vec=pts3OnPlane-o;
    pts2(2,:)=yAxis'*vec;
    pts2(1,:)=xAxis'*vec;
end