function rtM=vec2rtM2(a,b)
    a=a/norm(a);
    b=b/norm(b);
    
    v=cross(a,b);
    s=norm(v);
    c=a'*b;
    
    V=[0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
    
    if (s==0)
        rtM=eye(3);
    else
        rtM=eye(3)+V+(1-c)/s^2*V*V;
    end
end