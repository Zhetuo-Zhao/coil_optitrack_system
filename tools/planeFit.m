function [planeParam, pts3]=planeFit(points)
    N=20;
    fun=@(param)norm(param(1)*points(1,:)+param(2)*points(2,:)+param(3)*points(3,:)+param(4));
    
    for i=N:-1:1
%         [param(i,:), resNorm(i)]=lsqnonlin(fun,rand(1,4),-100*ones(1,4),100*ones(1,4),optimoptions('lsqnonlin','Display','off'));
        [param(i,:), costV(i)] = fmincon(fun,rand(1,4),[],[],[],[],[],[],@planeCon,optimoptions('fmincon','Display','off'));
    end
    [~,minIdx]=min(costV);
    planeParam=param(minIdx,:);
    
    for j=size(points,2):-1:1
        pts3(:,j)=linePlaneInter(points(:,j), planeParam(1:3)', planeParam);
    end
    
end