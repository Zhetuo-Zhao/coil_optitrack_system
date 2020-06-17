clear; close all; 
direct='.\200306_run3\';
for i=1:4
    i
    load([direct sprintf('processed_hand%d.mat',i)]);
    for hi=1:2
        if i==1
            hand{hi}.wristQ=handT{hi}.wristQ;
            hand{hi}.wristP=handT{hi}.wristP;
            hand{hi}.JointAngles=handT{hi}.JointAngles;
            hand{hi}.out=handT{hi}.out;
        else
            hand{hi}.wristQ=[hand{hi}.wristQ handT{hi}.wristQ];
            hand{hi}.wristP=[hand{hi}.wristP handT{hi}.wristP];
            hand{hi}.JointAngles=[hand{hi}.JointAngles handT{hi}.JointAngles];
            hand{hi}.out=[hand{hi}.out handT{hi}.out];
        end
    end
end
save([direct 'processed_hand.mat'],'hand');