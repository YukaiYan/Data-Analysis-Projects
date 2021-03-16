clear variables; close all; clc;

load('cam1_1.mat')
load('cam2_1.mat')
load('cam3_1.mat')

% display video
% implay(vidFrames1_1)

t = 1;
frame1 = vidFrames1_1(:,:,:,t);
frame2 = vidFrames2_1(:,:,:,t);
frame3 = vidFrames3_1(:,:,:,t);

figure(1)
subplot(1,3,1),imshow(frame1); title(['Camera 1 at t = ', num2str(t)]);
subplot(1,3,2),imshow(frame2); title(['Camera 2 at t = ', num2str(t)]);
subplot(1,3,3),imshow(frame3); title(['Camera 3 at t = ', num2str(t)]);




