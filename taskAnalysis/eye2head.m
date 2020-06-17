function [eye2head2,eye2head3]=eye2head(lineSight,head,dur,t1k)

    if t1k
        for t=size(lineSight,2):-1:1
            headFrame=[head.XYZ_room_coil{1}(:,dur(t)) head.XYZ_room_coil{2}(:,dur(t)) head.XYZ_room_coil{3}(:,dur(t))];
            eye2head3(:,t)=headFrame'*lineSight(:,t);
        end
        eye2head2=vec2ang(eye2head3);
    else
        for t=size(lineSight,2):-1:1
            headFrame=[head.XYZ_room{1}(:,dur(t)) head.XYZ_room{2}(:,dur(t)) head.XYZ_room{3}(:,dur(t))];
            eye2head3(:,t)=headFrame'*lineSight(:,t);
        end
        eye2head2=vec2ang(eye2head3);
    end

end