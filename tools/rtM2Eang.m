function [yawAng, pitchAng, rollAng]=rtM2Eang(rtM)
    
%     yawAng=atan2(rtM(2,1),rtM(1,1));
%     pitchAng=atan2(-rtM(3,1),sqrt(rtM(3,2)^2+rtM(3,3)^2));
%     rollAng=atan2(rtM(3,2),rtM(3,3));
    
    yawAng=atan(-rtM(1,2)/rtM(1,1));
    pitchAng=atan(rtM(1,3)/sqrt(rtM(1,2)^2+rtM(1,1)^2));
    rollAng=atan(-rtM(2,3)/rtM(3,3));

    
%     yawAng=atan2_boundShift(yawAng);
%     pitchAng=atan2_boundShift(pitchAng);
%     rollAng=atan2_boundShift(rollAng);
    
end