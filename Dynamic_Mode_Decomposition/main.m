%% clean and load data
clear variables; close all; clc;

% v = VideoReader('monte_carlo.mov');
v = VideoReader('ski_drop.mov');

rank = 5;

dt = 1/v.Framerate;
t = 1:dt:v.Duration;

x = v.Height;
y = v.Width;
if (strcmp(v.name,'ski_drop.mov'))
    frames = zeros(x*y,length(t) - 15);
    t = t(16:end);
else
    frames = zeros(x*y,length(t));
end

index = 1;
for i = 1:length(t)
    frame = readFrame(v);
    if (strcmp(v.name,'ski_drop.mov') && i <= 15) % clean data
        continue
    end
    frame = rgb2gray(frame);
    frame = im2double(frame);
    
    frame = reshape(frame,x*y,1);
    frames(:,index) = frame;
    index = index + 1;
end

%% Dynamic Mode Decomposition
X1 = frames(:,1:end-1);
X2 = frames(:,2:end);
[U, Sigma, V] = svd(X1,'econ');
U = U(:,1:rank);
Sigma = Sigma(1:rank,1:rank);
V = V(:,1:rank);

S = U'*X2*V*diag(1./diag(Sigma));
[eV, D] = eig(S);  % compute eigenvalues + eigenvectors
mu = diag(D);      % extract eigenvalues
omega = log(mu)/dt;
Phi = U*eV;

y0 = Phi\X1(:,1);  % pseudoinverse to get initial conditions
u_modes = zeros(length(y0),length(t));
for iter = 1:length(t)
    u_modes(:,iter) = y0.*exp(omega*t(iter));
end
u_dmd = Phi*u_modes;

%% optimize DMD spectrum of frequencies and display data
X = reshape(frames,x,y,size(frames,2));
X_lowrank = reshape(u_dmd,x,y,size(u_dmd,2));
X_sparse = X - abs(X_lowrank);
R = X_sparse;
R(R>0) = 0;

X_lowrank_residual = R + abs(X_lowrank);
X_sparse = X_sparse - R;
figure(1)
for i = 1:size(X_lowrank,3)
    subplot(2,2,1)
    imshow(X(:,:,i));
    xlabel('Original')
    
    subplot(2,2,2)
    imshow(X_lowrank_residual(:,:,i));
    xlabel('Background video + residual')
    
    subplot(2,2,3)
    imshow(abs(X_lowrank(:,:,i)));
    xlabel('Background video')
    
    subplot(2,2,4)
    imshow(X_sparse(:,:,i));
    xlabel('Foreground video')
    
    sgtitle(['Frame at t = ', num2str(i)]);
    drawnow
    
end


