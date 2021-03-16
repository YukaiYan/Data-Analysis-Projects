%% Clean workspace and initialization
clear variables; close all; clc

load subdata.mat % Imports the data as the 262144x49 (space by time) matrix called subdata

L = 10; % spatial domain
n = 64; % Fourier modes
x2 = linspace(-L,L,n+1); x = x2(1:n); y = x; z = x;
k = (2*pi/(2*L))*[0:(n/2 - 1) -n/2:-1]; ks = fftshift(k);

[X,Y,Z]=meshgrid(x,y,z);
[Kx,Ky,Kz]=meshgrid(ks,ks,ks);

% plot unfiltered subdata
for j=1:49
    Un(:,:,:)=reshape(subdata(:,j),n,n,n);
    M = max(abs(Un),[],'all');
    density = abs(Un)/M;
    
    isosurface(X,Y,Z,density,0.7);
    axis([-10 10 -10 10 -10 10]), 
    xlabel('x'), ylabel('y'),zlabel('z'),
    title('Subdata in spatial domain');
    hold on, grid on, drawnow
    pause(0.2)
end

%% averaging the signal
avg = zeros(n,n,n);
for j = 1:49
    Un(:,:,:)=reshape(subdata(:,j),n,n,n);
    avg = avg + fftn(Un); 
end
avg = abs(fftshift(avg))/j;
M = max(avg,[],'all');

% plot the average graph
close all, isosurface(Kx,Ky,Kz, avg/M,0.7)
axis([-10 10 -10 10 -10 10]), grid on, drawnow
title('Averaging the spectrum in the frequency space')
xlabel('Kx'),ylabel('Ky'),zlabel('Kz')

% locate the center frequency
pos = find(avg == M);           % the peak
[r,c,h] = ind2sub(size(avg), pos);
xfreq = Kx(r,c,h);
yfreq = Ky(r,c,h);
zfreq = Kz(r,c,h);

%% define the Gaussian filter
tau = 0.2;
filter = exp(-tau*((Kx-xfreq).^2 + (Ky-yfreq).^2 + (Kz-zfreq).^2));

% find the submarine
xpos = zeros(49,1); ypos = xpos; zpos = xpos;
for j = 1:49
    Un(:,:,:) = reshape(subdata(:,j),n,n,n);
    Untf = fftshift(fftn(Un)).* filter;
    Unf = ifftn(fftshift(Untf));
    M = max(Unf, [], 'all');
    
    pos = find(Unf == M);
    [r, c, h] = ind2sub(size(Unf), pos);
    xpos(j) = X(r,c,h); ypos(j) = Y(r,c,h); zpos(j) = Z(r,c,h);
    
    % plot the data
    plot3(xpos(j),ypos(j),zpos(j), '-o');
    xlabel('x'), ylabel('y'),zlabel('z'),
    xlim([-10,10]),ylim([-10,10]),zlim([-10,10])
    % title(['(',num2str(xpos),', ',num2str(ypos),', ',num2str(zpos),') when t = ', num2str(j)]);
    title('The path of the submarine');
    hold on, grid on, drawnow
    pause(0.2) 
end

%% output the chart
clc;
time = (1:49)';
t = table(time,xpos, ypos, zpos);
writetable(t,'data.csv');
