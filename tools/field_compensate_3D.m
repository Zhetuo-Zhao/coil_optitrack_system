function [ncV_estField, debug]=field_compensate_3D(estField, coilV, posV, estField0)
    if exist('estField0','var')
        outField=field_interpolation_3D(estField,2,estField0);
    else
        outField=field_interpolation_3D(estField,2);
    end
    

    ncV_estField=[];
    
   
    for t=size(coilV,2):-1:1
        % field amplitude and orientation at currrent sample
        [~,xt]=min(abs(posV(1,t)-outField.x));
        [~,yt]=min(abs(posV(2,t)-outField.y));
        [~,zt]=min(abs(posV(3,t)-outField.z));
        
        posBin(1,t)=xt; posBin(2,t)=yt; posBin(3,t)=zt;
        for Bidx=1:3
            B{Bidx}=outField.B{Bidx}(yt,xt,zt);
            nf{Bidx}=[outField.nf{Bidx,1}(yt,xt,zt); outField.nf{Bidx,2}(yt,xt,zt); outField.nf{Bidx,3}(yt,xt,zt)];
        end

        tmp=[B{1}*nf{1}'; B{2}*nf{2}'; B{3}*nf{3}']\coilV(:,t);
        
        nfV{1}(:,t)=B{1}*nf{1};
        nfV{2}(:,t)=B{2}*nf{2};
        nfV{3}(:,t)=B{3}*nf{3};
        
        ncV_estField(:,t)=tmp/norm(tmp);
 
    end
    debug.posBin=posBin;   
    debug.nfV=nfV;  
    debug.field=outField;
    % calculate the average field amplitude across space
    for Bidx=3:-1:1
        B_mean(Bidx)=mean(outField.B{Bidx}(:));
    end
    tmp2=coilV./(B_mean'*ones(1,size(coilV,2)));
    debug.ncV_idealField=tmp2./vecnorm(tmp2);  
end