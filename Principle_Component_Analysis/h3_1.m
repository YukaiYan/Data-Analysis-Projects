%% load data for Test1: idea case
clear variables; close all; clc;

load('cam1_1.mat')
load('cam2_1.mat')
load('cam3_1.mat')

% display video
% implay(vidFrames1_1)

% extract the location of the bucket for test1
threshold = 220;
[xpos1, ypos1] = extractLocation(vidFrames1_1, threshold, 1, false);
[xpos2, ypos2] = extractLocation(vidFrames2_1, threshold, 2, false);
[ypos3, xpos3] = extractLocation(vidFrames3_1, threshold, 3, false);

% clean and align data for graphing
minSize = min(length(xpos1), min(length(xpos2), length(xpos3)));
xpos1 = xpos1(1:minSize); xpos1 = xpos1 - mean(xpos1);
ypos1 = ypos1(1:minSize); ypos1 = ypos1 - mean(ypos1);
xpos2 = xpos2(1:minSize); xpos2 = xpos2 - mean(xpos2);
ypos2 = ypos2(1:minSize); ypos2 = ypos2 - mean(ypos2);
xpos3 = xpos3(1:minSize); xpos3 = xpos3 - mean(xpos3);
ypos3 = ypos3(1:minSize); ypos3 = ypos3 - mean(ypos3);

%% Singular value decomposition
X = [xpos1';ypos1';xpos2';ypos2';xpos3';ypos3'];
[U,S,V] = svd(X,'econ');

% Determine energy from the full system contained in each mode
sig = diag(S);
figure(2)
subplot(1,3,1); plot(sig,'ko','Linewidth',2); 
ylabel('\sigma');xlabel('singular values')
subplot(1,3,2); plot(sig.^2/sum(sig.^2),'ko','Linewidth',2);
ylabel('Energy');xlabel('singular values')
subplot(1,3,3);plot(cumsum(sig.^2)/sum(sig.^2),'ko','Linewidth',2)
ylabel('Cumulative Energy');xlabel('singular values')

%% Principle Component Analysis
t = 1:minSize;
figure(3)
subplot(2,1,1)
plot(t,V(:,1),'b',t,V(:,2),'--r',t,V(:,3),':k','Linewidth',2)
legend('Mode 1','Mode 2','Mode 3', 'Location','best');
xlabel('t')

subplot(2,1,2)
X_proj = U' * X;
plot(t, X_proj(1,:), t, X_proj(2,:));
legend('Principle component1','Principle component2', 'Location','best');
xlabel('t')


%% plot original graph and rank-1 rank-2 rank3 approximations
% not used in the paper, used to check bucket positions
t = 1:minSize;
figure(5)
subplot(2,2,1)
plot(t,xpos1,t,ypos1,t,xpos2,t,ypos2,t,xpos3,t,ypos3);
legend('x1','y1','x2','y2','x3','y3')
ylabel('Distance from mean'); xlabel('time');title('Original');
for j=1:3
    ff = U(:,1:j)*S(1:j,1:j)*V(:,1:j)';
    subplot(2,2,j+1)
    plot(t,ff)
    legend('x1','y1','x2','y2','x3','y3')
    ylabel('Distance from mean'); xlabel('time'); title(['rank ', num2str(j)]);
end


%% helper funcitons
% extract the location of the bucket by identifying the white parts
% @Input  VidFrame: video data
%         threshold: used to identify the white color
%         camera: the camera number
%         showGraph: plot comparison graph in the process
% @Output [xpos ypos]: the coordinates of the bucket
% see in-code comments for details
function [xpos, ypos] = extractLocation(vidFrame, threshold, camera, showGraph)
numFrames = size(vidFrame,4);
xpos = [];
ypos = [];

for i = 1:numFrames
    frame = vidFrame(:,:,:,i);
    r = frame(:,:,1);
    g = frame(:,:,2);
    b = frame(:,:,3);
    
    % Find white, where each color channel is more than threshold
    binaryImage = r > threshold & g > threshold & b > threshold;
    
    % crop image, data obtained using imcrop
    if (camera == 1)
        binaryImage = imcrop(binaryImage,[292.5 81.5 112 335]);
    elseif (camera == 2)
        binaryImage = imcrop(binaryImage,[228.5 82.5 141 332]);
        % remove extra white space located on the topleft
        for x = 1:80
            for y = 1:80
                binaryImage(x,y) = 0;
            end
        end
    elseif (camera == 3)
        binaryImage = imcrop(binaryImage,[171.5 238.5 394 125]);    
    end
    
    % Get rid of blobs smaller than 50 pixels.
    binaryImage = bwareaopen(binaryImage, 50);
    
    [x,y] = ind2sub(size(binaryImage),find(binaryImage,1));
    xpos = [xpos; x];
    ypos = [ypos; y];

    % show cleaned graph
    if (showGraph)
        figure(1)
        subplot(1,2,1),imshow(frame); title('Original video');
        subplot(1,2,2),imshow(binaryImage); title('Filtered video');
        drawnow
    end
end

end
