clear all; close all; % clear all variables and figures
L=2*pi*100; % define the computational domain [-L/2,L/2]
n=1024; % define the number of Fourier modes 2^n
x2=linspace(-L/2,L/2,n+1); % define the domain discretization
x=x2(1:n); % consider only the first n points: periodicity
y=x;
[X,Y]=meshgrid(x,y);
u=2.5*cos(X)+1.3*cos(3*Y); % function to take a derivative of
figure;surf(X,Y,u)
ut=fftshift(fft2(u)); % FFT the function
% k=(2*pi/L)*[0:(n/2-1) (-n/2):-1]; % k rescaled to 2pi domain
kx=(2*pi/L)*[(-n/2):(n/2-1) ]; % k rescaled to 2pi domain
ky=kx;
[Kx,Ky]=meshgrid(kx,ky);

figure;surf(Kx,ky,abs(ut)./(length(x)^2));shading interp

