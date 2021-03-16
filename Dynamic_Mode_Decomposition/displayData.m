clear all; close all; clc;

v1 = VideoReader('ski_drop.mov');
v2 = VideoReader('monte_carlo.mov');

numFrames = min(v1.numFrames, v2.numFrames);

figure(1)
for i = 1:numFrames
    frame1 = readFrame(v1);
    frame2 = readFrame(v2);
    subplot(1,2,1); imshow(frame1); xlabel('ski\_drop.mov');
    subplot(1,2,2); imshow(frame2); xlabel('monte\_carlo.mov');
    drawnow;
end
