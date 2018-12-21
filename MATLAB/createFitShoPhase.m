function [fitresult, gof] = createFitShoPhase(freq, phase)
%CREATEFIT(FREQ,PHASE)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : freq
%      Y Output: phase
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 17-Aug-2016 16:57:30


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( freq, phase );

% Set up fittype and options.
ft = fittype( '(atan2(freq.*freq0./Q,freq0^2-freq.^2)+offset)', 'independent', 'freq', 'dependent', 'phase' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 min(freq) -2*pi];
opts.upper = [2000 max(freq)   2*pi];
opts.MaxIter = 1000;
opts.Robust = 'LAR';
opts.StartPoint = [100 200e3 0.186872604554379];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
yyaxis right
h = plot( fitresult );
% legend( h, 'phase vs. freq', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel freq
ylabel phase
grid on

