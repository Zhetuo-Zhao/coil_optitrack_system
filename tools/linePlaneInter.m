function [out,t]=linePlaneInter(pt, vec, planeParam)
    
    t=-(planeParam(1:3)*pt+planeParam(4))./(planeParam(1:3)*vec);
    
    out=pt+t.*vec;
end