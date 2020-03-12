function dis=pt2planeDis(pt,planeParam)

    out=linePlaneInter(pt, planeParam(1:3)', planeParam);
    dis=norm(out-pt);

end