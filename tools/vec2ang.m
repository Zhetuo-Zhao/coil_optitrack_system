function ang=vec2ang(vec)
    
    ang(1,:)=atand((vec(2,:)./vec(1,:)));
    ang(2,:)=atand(vec(3,:)./(sqrt(vec(1,:).^2+vec(2,:).^2)));

end