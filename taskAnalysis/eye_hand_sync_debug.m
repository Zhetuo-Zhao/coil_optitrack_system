figure; 
h1=subplot(3,1,1); plot(eye.coil_sync{eyeIdx}(:,[1:2E5])');

h2=subplot(3,1,2); plot(hand{2}.wristP')
h3=subplot(3,1,3); plot(hand{2}.JointAngles')

linkaxes([h1 h2 h3],'x');


%%
fingerTip=zeros(2,size(hand2D{2}.out,2));
for t=1:size(hand2D{2}.out,2)
    fingerTip(:,t)=hand2D{2}.out{2,t}(:,6);
end
figure; 
h1=subplot(2,1,1); plot(dur1k,eye.gaze2D'); 
h2=subplot(2,1,2); plot(durSync,fingerTip'); 