function [fitresult,gof] = createFitSHOAmp(freq,amp)

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( freq, amp );


[pks,locs]=findpeaks(amp,'NPeaks',1,'SortStr','descend');

Qinit=100; %let's assume Q initaial=100;
Ampp0=pks/Qinit;




% Set up fittype and options.
ft = fittype( 'A0*freq0^2/sqrt((freq0^2-freq^2)^2+(freq*freq0/Q)^2)', 'independent', 'freq', 'dependent', 'amp' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 min(freq)];
opts.Robust = 'LAR';
opts.Upper = [10 3000 max(freq)];
opts.StartPoint = [Ampp0 Qinit freq(locs)];
% opts.StartPoint = [0.489764395788231 0.445586200710899 0.646313010111265];

% opts.DiffMinChange = 1e-15;
% opts.TolFun = 1e-12;
% opts.TolX = 1e-12;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );


