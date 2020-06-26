function out=object_trial(obj,R_opti2room,tim)
    
    out.name=obj.name;
    out.pos=R_opti2room*obj.pos(:,tim);
    if isfield(obj,'markerIdx')
        out.markerIdx=obj.markerIdx;
    end
    for i=1:length(obj.marker)
        out.markerPos{i}=R_opti2room*obj.marker{i}.pos(:,tim);
    end
end