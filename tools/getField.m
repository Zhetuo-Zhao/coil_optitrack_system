function F3=getField(estField,IN,estField0)
    
    if size(estField,1)>1
        if exist('estField0','var')
            outField=field_interpolation(estField,2,estField0);
        else
            outField=field_interpolation(estField,2);
        end
    else
        outField=estField;
    end
    [~,xt]=min(abs(IN(1)-outField.x_out));
    [~,yt]=min(abs(IN(2)-outField.y_out));
    
    for Bidx=1:3
        F3{Bidx}=outField.B_out{Bidx}(yt,xt)*[outField.nf_out{Bidx,1}(yt,xt); outField.nf_out{Bidx,2}(yt,xt); outField.nf_out{Bidx,3}(yt,xt)];
    end
end
