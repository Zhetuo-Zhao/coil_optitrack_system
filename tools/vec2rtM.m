function rtM=vec2rtM(a,b)
    a=a/norm(a);
    b=b/norm(b);
    
    w=cross(a,b);
    x=w(1); y=w(2); z=w(3);
    ang=acos(a'*b);
    
    c=cos(ang/2); s=sin(ang/2);
    
    m11=2*(x^2-1)*s^2+1;
    m12=2*x*y*s^2-2*z*c*s;
    m13=2*x*z*s^2+2*y*c*s;
    
    m21=2*x*y*s^2+2*z*c*s;
    m22=2*(y^2-1)*s^2+1;
    m23=2*y*z*s^2-2*x*c*s;
    
    m31=2*x*z*s^2-2*y*c*s;
    m32=2*y*z*s^2+2*x*c*s;
    m33=2*(z^2-1)*s^2+1;
    
    rtM=[m11 m12 m13; m21 m22 m23; m31 m32 m33];
end