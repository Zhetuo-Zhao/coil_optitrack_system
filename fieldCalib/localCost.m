function cost=localCost(Bn,center,coil,pos,ori)
    %% Bn:      [Bx, By, Bz]
    
    % cost=0; %costV=[];
    % wV=[];
    % for i=1:length(coil) 
    %     w=1/(sqrt(norm(pos(1:2,i)-center'))+0.00001);
    %     wV=[wV w];
    %     cost=cost+w*(coil(i)-sum(Bn'.*ori(:,i)))^2;
    %     %costV=[costV (coil(i)-B*sum(nf.*ori(:,i)))^2];
    % end
    % cost=cost/sum(wV);

    w = 1 ./ ( ( ( pos(1,:) - center(1) ).^2 + ( pos(2,:) - center(2) ).^2 ).^0.25 + 0.00001 );
    cost = w * ( coil - Bn * ori )'.^2 / sum(w);
    
    
%     figure; 
%     subplot(3,1,1); plot(costV); title('cost')
%     subplot(3,1,2); plot(coil); title('coil reading')
%     subplot(3,1,3); plot(ori'); title('coil orientation')
end