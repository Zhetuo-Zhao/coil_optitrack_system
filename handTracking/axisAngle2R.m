function R=axisAngle2R(w,theta)
    
    s=sin(theta); c=cos(theta); v=1-c;
    w1=w(1); w2=w(2); w3=w(3);
    
    R11=w1^2*v+c;
    R12=w1*w2*v-w3*s;
    R13=w1*w3*v+w2*s;
    
    R21=w1*w2*v+w3*s;
    R22=w2^2*v+c;
    R23=w2*w3*v-w1*s;
    
    R31=w1*w3*v-w2*s;
    R32=w2*w3*v+w1*s;
    R33=w3^2*v+c;
    
    R=[R11 R12 R13; R21 R22 R23; R31 R32 R33];
end