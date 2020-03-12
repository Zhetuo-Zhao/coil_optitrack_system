function XYZ=vec2frame(a,b)
    x=a/norm(a);
    y=b-(b'*x)*x;
    y=y/norm(y);
    z=cross(x,y);
    z=z/norm(z);
    XYZ=[x y z];
end