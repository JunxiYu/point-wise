clear all; close all; % clear all variables and figures
L=2*pi*100; % define the computational domain [-L/2,L/2]
n=1024; % define the number of Fourier modes 2^n
x2=linspace(-L/2,L/2,n+1); % define the domain discretization
x=x2(1:n); % consider only the first n points: periodicity
dx=x(2)-x(1); % dx value needed for finite difference
u=cos(x); % function to take a derivative of
figure;plot(x,u)
ut=fftshift(fft(u)); % FFT the function
% k=(2*pi/L)*[0:(n/2-1) (-n/2):-1]; % k rescaled to 2pi domain
k=(2*pi/L)*[(-n/2):(n/2-1) ]; % k rescaled to 2pi domain

utl=abs(ut/length(x));
utl_psd = utl.^2;
figure;plot(k,abs(ut))
figure;plot(k,(utl))
