function XYZ=vec2frameXZ(x0,z0)
    x=x0/norm(x0);
    z=z0-(z0'*x)*x;
    z=z/norm(z);
    y=cross(z,x);
    y=y/norm(y);
    XYZ=[x y z];
end