function out=vel3D(in)  % in:3xT, out: 1xT
    if isempty(in)
        out=[];
    else
        out=sqrt(diff(in(1,:)).^2+diff(in(2,:)).^2+diff(in(3,:)).^2);
        out=[out(1) out];
    end
end