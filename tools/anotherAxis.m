function axis2=anotherAxis(plane,axis1,axis2b)

    syms x y z
    eqn1= plane(1)*x+plane(2)*y+plane(3)*z==0;
    eqn2= axis1(1)*x+axis1(2)*y+axis1(3)*z==0;
    eqn3= x^2+y^2+z^2==1;
    sol = solve([eqn1, eqn2, eqn3], [x, y, z]);
    
    tmp(3,:)=double(sol.z)';
    tmp(2,:)=double(sol.y)';
    tmp(1,:)=double(sol.x)';
    
    axis2b=axis2b/norm(axis2b);
    if tmp(:,1)'*axis2b > tmp(:,2)'*axis2b
        axis2=tmp(:,1);
    else
        axis2=tmp(:,2);
    end
end