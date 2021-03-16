%% load and plot data
clear variables; close all; clc;

showgraph = true; % plot the 'animation' in for loop

figure(1)
[y_gnr, Fs1] = audioread('GNR.m4a');
t_gnr = (1:length(y_gnr))/Fs1; % record time in seconds
subplot(2,1,1)
plot(t_gnr,y_gnr);
xlabel('Time [sec]'); ylabel('Amplitude');
title('GNR');

[y_floy, Fs2] = audioread('Floyd.m4a');
t_floy = (1:length(y_floy))/Fs2;
subplot(2,1,2)
plot(t_floy,y_floy);
xlabel('Time [sec]'); ylabel('Amplitude');
title('Floyd');
%p8 = audioplayer(y,Fs); playblocking(p8);

%% GNR Gabor Transform
L = t_gnr(end);    % spatial domain
n = length(t_gnr); % Fourier modes
k = (1/L)*[0:(n/2 - 1) -n/2:-1]; ks = fftshift(k); % even

figure(2)
diff = 0.1;      % step size
tau = 0:diff:L;  % centre of window
a = 100;         % window size;
gnr_spec = [];
for j = 1:length(tau)
    g = exp(-a *(t_gnr - tau(j)).^ 2); %Gaussian
    yf_floy = g'.*y_gnr;
    yft_gnr = fft(yf_floy);
    
    % clean data for better spectrogram
    yft_spec = fftshift(abs(yft_gnr))/max(abs(yft_gnr));
    gnr_spec(:,j) = yft_spec;
    
    % plot the graph
    if (showgraph)
        subplot(3,1,1)
        plot(t_gnr, y_gnr, 'k', t_gnr, g, 'm', 'Linewidth',2);
        set(gca,'Fontsize',16)
        xlabel('Time [sec]'), ylabel('Amplitude')
        title('Audio data and the current window');
        drawnow
        
        subplot(3,1,2),
        plot(t_gnr,yf_floy, 'k', 'Linewidth',2)
        set(gca,'Fontsize',16,'ylim',[-0.05, 0.05])
        xlabel('Time [sec]'), ylabel('Amplitude * g(t-\tau)');
        title('Audio data times the filter');
        drawnow
        
        subplot(3,1,3),
        plot(ks,yft_spec, 'r', 'Linewidth',2)
        set(gca,'Fontsize',16)
        xlabel('frequency'); ylabel('fft(Amplitude * g(t-\tau))');
        title('Audio data in the frequency space');
        drawnow
        
        pause(0.1)
    end
    
end
    
%% plot the spectrogram for GNR
figure(3)
pcolor(tau,ks,log(gnr_spec + 1))
shading interp
set(gca,'ylim',[0,1000],'Fontsize',16)
colormap(hot)
xlabel('time (Sec)'), ylabel('frequency (Hz)')


%% Floyd Gabor Transform for bass
% optional cutoff(first half)
% only evaluate part of data due to the limitation of computing power
% cutoff = (length(t_floy)+1)/4 + 1;
% t_floy = t_floy(1:cutoff);
% y_floy = y_floy(1:cutoff);

% setup
L = t_floy(end);    % spatial domain
n = length(t_floy); % Fourier modes
k = (1/L)*[0:(n/2) (-n/2):-1]; ks = fftshift(k); %odd

% data of interest to reduce run-time complexity
filter = abs(ks) <= 250 & abs(ks) >= 50;  % frequency range for bass
yft_floy = fftshift(fft(y_floy)).*filter';
yf_floy = ifft(fftshift(yft_floy));

figure(2)
diff = 0.1;      % step size
tau = 0:diff:L;  % centre of window
a = 100;         % window size;
floy_spec = [];
for j = 1:length(tau)
    g = exp(-a *(t_floy - tau(j)).^ 2); %Gaussian
    yf_floy = g .* y_floy';
    yft_floy = fft(yf_floy);
    
    % clean data for better spectrogram
    yft_spec = fftshift(abs(yft_floy))/max(abs(yft_floy));
    floy_spec(:,j) = yft_spec;
    
    % plot the graph
    if (showgraph)
        subplot(3,1,1)
        plot(t_floy, y_floy, 'k', t_floy, g, 'm', 'Linewidth',2);
        set(gca,'Fontsize',16),
        xlabel('Time [sec]'), ylabel('Amplitude')
        drawnow
        
        subplot(3,1,2),
        plot(t_floy,yf_floy, 'k', 'Linewidth',2)
        set(gca,'Fontsize',16,'ylim',[-0.1, 0.1])
        xlabel('Time [sec]'), ylabel('Amplitude * g(t-\tau)');
        drawnow
        
        subplot(3,1,3),
        plot(ks,yft_spec, 'r', 'Linewidth',2)
        set(gca,'Fontsize',16)
        xlabel('frequency'); ylabel('fft(Amplitude * g(t-\tau))');
        drawnow
        
        pause(0.1)
    end
    
end
    
%% plot the spectrogram for Floy
figure(4)
% spectrogram(y_floy)
pcolor(tau,ks,floy_spec)
shading interp
set(gca,'ylim',[50,300],'Fontsize',16)
colormap(hot)
xlabel('time (Sec)'), ylabel('frequency (Hz)')

%% Apply filters to clean bass in Floy
% May need to run the first section again before running this part
% optional cutoff(first 15 sec)
cutoff = (length(t_floy)+1)/4 + 1;
t_floy = t_floy(1:cutoff);
y_floy = y_floy(1:cutoff);

L = t_floy(end);    % spatial domain
n = length(t_floy); % Fourier modes
k = (1/L)*[0:(n/2) (-n/2):-1]; ks = fftshift(k); %odd

% bandPass Filter
% yf_floy = bandpass(y_floy,[250 1200],Fs2);

% Box Filter
% filter = abs(ks) <= 250 & abs(ks) >= 50;  % verify  bass
filter = abs(ks) > 250;
yft_floy = fftshift(fft(y_floy)).*filter';
yf_floy = ifft(fftshift(yft_floy));

% plot the filtered graph
if (showgraph)
    plot(ks,yft_floy, 'r', 'Linewidth',2)
    set(gca,'Fontsize',16, 'ylim', [0, 500])
    xlabel('frequency(Hz)'); ylabel('fft(Floyd) * filter');
    drawnow
end

figure(5)
diff = 0.1;      % step size
a = 200;         % window size;
tau = 0:diff:L;  % centre of window
floy_spec = [];
for j = 1:length(tau)
    g = exp(-a *(t_floy - tau(j)).^ 2); %Gaussian
    yt_floy = g .* yf_floy';
    yft_floy = fft(yt_floy);
    
    % clean data for better spectrogram
    yft_spec = fftshift(abs(yft_floy))/max(abs(yft_floy));
    for k = 1:length(yft_spec)
        if (yft_spec(k) < 0.7)
            yft_spec(k) = 0;
        end
    end
            
    floy_spec(:,j) = yft_spec;
    
    % plot the graph
    if (showgraph)
        subplot(3,1,1)
        plot(t_floy, y_floy, 'k', t_floy, g, 'm', 'Linewidth',2);
        set(gca,'Fontsize',16),
        xlabel('Time [sec]'), ylabel('Amplitude')
        drawnow
        
        subplot(3,1,2),
        plot(t_floy,real(yt_floy), 'k', 'Linewidth',2)
        set(gca,'Fontsize',16, 'ylim',[-0.1, 0.1])
        xlabel('Time [sec]'), ylabel('Amplitude * g(t-\tau)');
        drawnow
        
        subplot(3,1,3),
        plot(ks,yft_spec, 'r', 'Linewidth',2)
        set(gca,'Fontsize',16)
        xlabel('frequency'); ylabel('fft(Amplitude * g(t-\tau))');
        drawnow
        
        pause(0.01)
    end
    
end

%% plot the NEW spectrogram for Floy
figure(6)
pcolor(tau,ks, floy_spec)
shading interp
set(gca,'ylim',[0,1200],'Fontsize',16)
colormap(hot)
xlabel('time (Sec)'), ylabel('frequency (Hz)')