% function [x_out,y_out,z_out,B_out,nf_out]=field_interpolation(estField,k,estField0)
function outField=field_interpolation(estField,k,estField0)
    
    [m,n]=size(estField);
    
    if exist('estField0','var')
        for y=m:-1:1
            for x=n:-1:1
                xc1(x)=estField{x,y}.centerXY(1);
                yc1(y)=estField{x,y}.centerXY(2);
            end
        end

        [~,minX]=min(abs(xc1-estField0.x));
        [~,minY]=min(abs(yc1-estField0.y));


        for BI=1:3
           BR(BI)=estField0.B{BI}/estField{minX,minY}.B{BI};
           nfR{BI}=vec2rtM2(estField{minX,minY}.nf{BI},estField0.nf{BI});
        end
    end
    
    
    for y=m:-1:1
        for x=n:-1:1
            xc(y,x)=estField{x,y}.centerXY(1);
            yc(y,x)=estField{x,y}.centerXY(2);
            
            if isfield(estField{x,y},'nf')
                z(y,x)=estField{x,y}.center(3);
                for BI=1:3
                    if exist('estField0','var')
                        B{BI}(y,x)=BR(BI)*estField{x,y}.B{BI};
                        tmp=nfR{BI}*estField{x,y}.nf{BI};
                        nf{BI,1}(y,x)=tmp(1);
                        nf{BI,2}(y,x)=tmp(2);
                        nf{BI,3}(y,x)=tmp(3);
                    else
                        B{BI}(y,x)=estField{x,y}.B{BI};
                        nf{BI,1}(y,x)=estField{x,y}.nf{BI}(1);
                        nf{BI,2}(y,x)=estField{x,y}.nf{BI}(2);
                        nf{BI,3}(y,x)=estField{x,y}.nf{BI}(3);
                    end
                end
            else
                z(y,x)=NaN;
                for BI=1:3
                    B{BI}(y,x)=NaN;
                    nf{BI,1}(y,x)=NaN;
                    nf{BI,2}(y,x)=NaN;
                    nf{BI,3}(y,x)=NaN;
                    
                end
            end
        end
    end
    
    
    margCount=10;
    xRange=[find(sum(isnan(B{1}))<n-margCount,1,'first')  find(sum(isnan(B{1}))<n-margCount,1,'last')];
    yRange=[find(sum(isnan(B{1}),2)<m-margCount,1,'first')  find(sum(isnan(B{1}),2)<m-margCount,1,'last')];
    
    xc=xc([yRange(1):yRange(2)] ,[xRange(1):xRange(2)]);
    yc=yc([yRange(1):yRange(2)] ,[xRange(1):xRange(2)]);
    
    z=fillmissing(z([yRange(1):yRange(2)] ,[xRange(1):xRange(2)]),'nearest');
    for BI=1:3
        B{BI}=fillmissing(B{BI}([yRange(1):yRange(2)] ,[xRange(1):xRange(2)]),'nearest');
        nf{BI,1}=fillmissing(nf{BI,1}([yRange(1):yRange(2)] ,[xRange(1):xRange(2)]),'nearest');
        nf{BI,2}=fillmissing(nf{BI,2}([yRange(1):yRange(2)] ,[xRange(1):xRange(2)]),'nearest');
        nf{BI,3}=fillmissing(nf{BI,3}([yRange(1):yRange(2)] ,[xRange(1):xRange(2)]),'nearest');
    end
    
    x_grid=interp2(xc,k);
    y_grid=interp2(yc,k);
    
    outField.z_out=interp2(xc,yc,z,x_grid,y_grid,'cubic');
    for BI=1:3
        B_out{BI}=interp2(xc,yc,B{BI},x_grid,y_grid,'cubic');
        nf_out{BI,1}=interp2(xc,yc,nf{BI,1},x_grid,y_grid,'cubic');
        nf_out{BI,2}=interp2(xc,yc,nf{BI,2},x_grid,y_grid,'cubic');
        nf_out{BI,3}=interp2(xc,yc,nf{BI,3},x_grid,y_grid,'cubic');
    end
    
    outField.B_out=B_out;
    outField.nf_out=nf_out;
    outField.x_out=x_grid(1,:);
    outField.y_out=y_grid(:,1)';
    
    
end