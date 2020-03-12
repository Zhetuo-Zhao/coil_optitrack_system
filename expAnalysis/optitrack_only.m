head_eye_tim=133939;
objs{1}=helmet; objs{2}=eyeProbe;  objs{3}=ninePoints; objs{4}=head_eye; objs{5}=table;
plot3Dobjects2(objs, head_eye_tim, R_opti2room);
myScatter3(eye.pos{1}(:,head_eye_tim));
text(eye.pos{1}(1,head_eye_tim),eye.pos{1}(2,head_eye_tim),eye.pos{1}(3,head_eye_tim),'eye')
saveFigure(['headEyeSacc' '_3D'],[direct folder '\Figures\'])

sorting_tim=186788;
clear objs
objs{1}=helmet; objs{2}=iceTray; objs{3}=table;
plot3Dobjects2(objs, sorting_tim, R_opti2room);
myScatter3(eye.pos{1}(:,sorting_tim));
text(eye.pos{1}(1,sorting_tim),eye.pos{1}(2,sorting_tim),eye.pos{1}(3,sorting_tim),'eye')
saveFigure(['sorting' '_3D'],[direct folder '\Figures\'])