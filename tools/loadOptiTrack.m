function result = loadOptiTrack(filepath,intepolate)
    % read header  
    fID = fopen(filepath,'r');
    for i=1:3
        fgetl(fID);
    end
    header = split(fgetl(fID), ',');
    header = header(3:end);
    
    % read data
    data = csvread(filepath, 7, 1)';
    
    %%
    result.data = {};
    
    % time stamp
    result.time = data(1, :);
    
    nRigidBody = 0;
    nMarkers = 0;
    idx = 1;
    while idx < length(header)
        label = header{idx};
        switch label(1)
            case 'U'
                % Unlabel marker
                if (nMarkers > 0)
                    nRigidBody = nRigidBody + 1;
                    result.data{nRigidBody} = rigid;
                end
                break;
            case '"'
                % new marker
                nMarkers = nMarkers + 1;
                marker.name = label;                % name
                marker.pos = data(idx+1:idx+3, :);  if intepolate marker.pos=drop_frame(marker.pos,intepolate); end 
                marker.err = data(idx+4, :);        if intepolate marker.err=drop_frame(marker.err,intepolate); end 
                
                % add to rigid
                rigid.markers{nMarkers} = marker;
                
                % next item
                idx = idx + 4;
            otherwise
                % new rigid body
                % save last rigidbody
                if (nMarkers > 0)
                    nRigidBody = nRigidBody + 1;
                    result.data{nRigidBody} = rigid;
                    nMarkers = 0;
                end

                %create new rigid body
                rigid.name = label;              % name
                rigid.q = data([idx+4 idx+1:idx+3], :);   if intepolate rigid.q=drop_frame(rigid.q,intepolate); end 
                rigid.pos = data(idx+5:idx+7, :);    if intepolate rigid.pos=drop_frame(rigid.pos,intepolate); end 
                rigid.error = data(idx+8, :);       if intepolate rigid.error=drop_frame(rigid.error,intepolate); end 
                rigid.markers = {};
                
                % next item
                idx = idx + 8;
        end

    end
    if idx>=length(header)
        if (nMarkers > 0)
            nRigidBody = nRigidBody + 1;
            result.data{nRigidBody} = rigid;
        end
    end
    
    function out=drop_frame(in,intepolate)
        
        for tryI=1:intepolate
            skipFrame=find(sum(in==0)==size(in,1)); 
            in(:,skipFrame(2:end))=in(:,skipFrame(2:end)-1);
        end
	
        out=in;
    end
end


