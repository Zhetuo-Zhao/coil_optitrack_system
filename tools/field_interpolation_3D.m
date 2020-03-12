function out=field_interpolation_3D(estField3D,k,estField0)

    
    if exist('estField0','var')
        for i=length(estField3D):-1:1
            hV(i)=estField3D{i}{26,26}.center(3);
        end
        [~,hi]=min(abs(hV-estField0.z));
        
        [m,n]=size(estField3D{hi});
        for y=m:-1:1
            for x=n:-1:1
                xc1(x)=estField3D{hi}{x,y}.centerXY(1);
                yc1(y)=estField3D{hi}{x,y}.centerXY(2);
            end
        end

        [~,minX]=min(abs(xc1-estField0.x));
        [~,minY]=min(abs(yc1-estField0.y));


        for BI=1:3
           BR(BI)=estField0.B{BI}/estField3D{hi}{minX,minY}.B{BI};
           nfR{BI}=vec2rtM2(estField3D{hi}{minX,minY}.nf{BI},estField0.nf{BI});
        end
    end

for i=length(estField3D):-1:1
    [m,n]=size(estField3D{i});
    
    for y=m:-1:1
        for x=n:-1:1
            xc(y,x)=estField3D{i}{x,y}.centerXY(1);
            yc(y,x)=estField3D{i}{x,y}.centerXY(2);
            
            if isfield(estField3D{i}{x,y},'nf')
                z(y,x)=estField3D{i}{x,y}.center(3);
                for BI=1:3
                    if exist('estField0','var')
                        B{BI}(y,x)=BR(BI)*estField3D{i}{x,y}.B{BI};
                        tmp=nfR{BI}*estField3D{i}{x,y}.nf{BI};
                        nf{BI,1}(y,x)=tmp(1);
                        nf{BI,2}(y,x)=tmp(2);
                        nf{BI,3}(y,x)=tmp(3);
                    else
                        B{BI}(y,x)=estField3D{i}{x,y}.B{BI};
                        nf{BI,1}(y,x)=estField3D{i}{x,y}.nf{BI}(1);
                        nf{BI,2}(y,x)=estField3D{i}{x,y}.nf{BI}(2);
                        nf{BI,3}(y,x)=estField3D{i}{x,y}.nf{BI}(3);
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
    
    outField{i}.z_out=interp2(xc,yc,z,x_grid,y_grid,'cubic');
    for BI=1:3
        B_out{BI}=interp2(xc,yc,B{BI},x_grid,y_grid,'cubic');
        nf_out{BI,1}=interp2(xc,yc,nf{BI,1},x_grid,y_grid,'cubic');
        nf_out{BI,2}=interp2(xc,yc,nf{BI,2},x_grid,y_grid,'cubic');
        nf_out{BI,3}=interp2(xc,yc,nf{BI,3},x_grid,y_grid,'cubic');
    end
    
    outField{i}.B_out=B_out;
    outField{i}.nf_out=nf_out;
    outField{i}.x_out=x_grid(1,:);
    outField{i}.y_out=y_grid(:,1)';
end


x_step=mean(diff(outField{1}.x_out));
y_step=mean(diff(outField{1}.y_out));
for i=length(outField):-1:1
    x_minV(i)=min(outField{i}.x_out);
    x_maxV(i)=max(outField{i}.x_out);
    
    y_minV(i)=min(outField{i}.y_out);
    y_maxV(i)=max(outField{i}.y_out);
    
    z_out(i)=mean(outField{i}.z_out(:));
end
x_out=max(x_minV):x_step:min(x_maxV);
y_out=max(y_minV):y_step:min(y_maxV); 
out.x=x_out;
out.y=y_out;

for i=1:3
    [~,startIdx]=min(abs(outField{i}.x_out-x_out(1)));
    [~,endIdx]=min(abs(outField{i}.x_out-x_out(end)));
    outField{i}.xRange=startIdx:endIdx;
    
    [~,startIdx]=min(abs(outField{i}.y_out-y_out(1)));
    [~,endIdx]=min(abs(outField{i}.y_out-y_out(end)));
    outField{i}.yRange=startIdx:endIdx;
end

HinterpRate=0.2;

out.z=interp1([1:length(outField)],z_out,[1:HinterpRate:length(outField)],'pchip');
%%
for yi=length(y_out):-1:1
    for xi=length(x_out):-1:1
        for Bi=3:-1:1
            for hi=length(outField):-1:1
                BV{Bi}(hi)=outField{hi}.B_out{Bi}(outField{hi}.yRange(yi),outField{hi}.xRange(xi));
                nfV{Bi,1}(hi)=outField{hi}.nf_out{Bi,1}(outField{hi}.yRange(yi),outField{hi}.xRange(xi));
                nfV{Bi,2}(hi)=outField{hi}.nf_out{Bi,2}(outField{hi}.yRange(yi),outField{hi}.xRange(xi));
                nfV{Bi,3}(hi)=outField{hi}.nf_out{Bi,3}(outField{hi}.yRange(yi),outField{hi}.xRange(xi));
            end
            
            out.B{Bi}(yi,xi,:)=interp1([1:length(outField)],BV{Bi},[1:HinterpRate:length(outField)],'pchip');
            out.nf{Bi,1}(yi,xi,:)=interp1([1:length(outField)],nfV{Bi,1},[1:HinterpRate:length(outField)],'pchip');
            out.nf{Bi,2}(yi,xi,:)=interp1([1:length(outField)],nfV{Bi,2},[1:HinterpRate:length(outField)],'pchip');
            out.nf{Bi,3}(yi,xi,:)=interp1([1:length(outField)],nfV{Bi,3},[1:HinterpRate:length(outField)],'pchip');
        end
    end
end

end