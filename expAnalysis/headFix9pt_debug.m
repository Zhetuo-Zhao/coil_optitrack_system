clear; close all;
addpath('..\tools\')

session='05-Feb-2020';
direct=['Z:/fieldCalibrate/data/' session '/'];
% direct=['\\opus.cvs.rochester.edu\aplab\fieldCalibrate/data/' session '/'];
folder='session2';
VIEW=1;
outputFolder=[direct folder '/Figures/'];

load([direct folder '/headFix9pt_data.mat']);



eyeCalib9pts=nFixExtract2(eye,[trialTim(testTrials(1),1):trialTim(testTrials(1),2)],ninePtsPos,5E-3,1,VIEW);
eyeCalib9pts.field=eye_calibration(eyeCalib9pts,VIEW,[direct folder '\Figures\']);


