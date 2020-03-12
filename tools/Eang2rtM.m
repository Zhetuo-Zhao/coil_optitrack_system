function rtM=Eang2rtM(AngZ, AngY, AngX)
    
    Rz=[cos(AngZ) -sin(AngZ) 0; sin(AngZ) cos(AngZ) 0; 0 0 1];
    Ry=[cos(AngY) 0 sin(AngY); 0 1 0; -sin(AngY) 0 cos(AngY)];
    Rx=[1 0 0; 0 cos(AngX) -sin(AngX); 0 sin(AngX) cos(AngX)];
    
    rtM=Rx*Ry*Rz;
%     rtM=Rz*Ry*Rx;
end