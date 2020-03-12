function [ncV_estField, debug]=field_compensate(estField, coilV, posV, estField0)
    if exist('estField0','var')
        outField=field_interpolation(estField,2,estField0);
    else
        outField=field_interpolation(estField,2);
    end
    

    ncV_estField=[];
    
   
    for t=size(coilV,2):-1:1
        % field amplitude and orientation at currrent sample
        [~,xt]=min(abs(posV(1,t)-outField.x_out));
        [~,yt]=min(abs(posV(2,t)-outField.y_out));
        
         debug.xV(t)=xt; debug.yV(t)=yt;
        for Bidx=1:3
            B{Bidx}=outField.B_out{Bidx}(yt,xt);
            nf{Bidx}=[outField.nf_out{Bidx,1}(yt,xt); outField.nf_out{Bidx,2}(yt,xt); outField.nf_out{Bidx,3}(yt,xt)];
            
            debug.heightV(t)=outField.z_out(yt,xt);
        end

        tmp=[B{1}*nf{1}'; B{2}*nf{2}'; B{3}*nf{3}']\coilV(:,t);
        
        debug.nfV{1}(:,t)=B{1}*nf{1};
        debug.nfV{2}(:,t)=B{2}*nf{2};
        debug.nfV{3}(:,t)=B{3}*nf{3};
        
        ncV_estField(:,t)=tmp/norm(tmp);
 
    end
        %figure; plot([xV;yV]')

       
    % calculate the average field amplitude across space
    for Bidx=3:-1:1
        B_mean(Bidx)=mean(outField.B_out{Bidx}(:));
    end
    tmp2=coilV./(B_mean'*ones(1,size(coilV,2)));
    debug.ncV_idealField=tmp2./vecnorm(tmp2);  
end