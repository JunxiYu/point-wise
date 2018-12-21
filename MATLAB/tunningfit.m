% Code written by Ehsan Nasr Esfahani, 2016-08-26

%this code takes one tuning from ZI lock in amplifier, fit SHO model and
%finds the Q, f0, and A0.

%options:
%-sample1 : the device name, usually dev981
%-demods: which demod is used for saving the tune?
%-AmpInvOLS: this is the option for converting voltage to deflection.%Should be the same value as AR value unit [m/V].
%-Npoints: number of points around the peak. Only these points are used from
%making the tune
%-title1: this the title of your tune


% example:
% tunningfit(dev981,1,1e-7,150,'Title')

function [fitresultAmp]=tunningfit(sample1,demods,AmpInvOLS,NPoint,title1)

sample=sample1.demods(demods).sample;
phase=sample{1, 1}.phase;
freq=sample{1, 1}.frequency;
amp=sample{1, 1}.r;

[~,locs]=findpeaks(amp,'NPeaks',1,'SortStr','descend');

%conventions of AR (mechanical engineers) and electrical engineers is
%different for phase lag!
     phase=-phase;
phase=wrapTo2Pi(phase-phase(locs)+pi/2);


if  NPoint==0
    amp2=amp;
    freq2=freq;
    phas2=phase;
else
    amp2=amp(locs-NPoint:locs+NPoint);
    freq2=freq(locs-NPoint:locs+NPoint);
    phas2=phase(locs-NPoint:locs+NPoint);
end
%data in V
figure
yyaxis left
scatter(freq2,amp2)
xlabel('Freq. [Hz]')
ylabel('Amp [V]')
yyaxis right
scatter(freq2,phas2)




h=figure;hold all
%experimental amp data
yyaxis left
hh1(1,1)=scatter(1e-3*freq2,1e12*amp2.*AmpInvOLS,'o') ;


[~, ~]=createFitShoPhase(freq, phase);
[fitresultAmp,~]=createFitSHOAmp(freq2, amp2);
yyaxis left
% fited amp data
hh1(2,1)=plot(1e-3*freq2,1e12*fitresultAmp.A0.*AmpInvOLS.*fitresultAmp.freq0.^2./sqrt((fitresultAmp.freq0.^2-freq2.^2).^2+(freq2.*fitresultAmp.freq0./fitresultAmp.Q).^2),'-');
xlabel('Freq. [kHz]')
ylabel('Amplitude [pm]')
% set(h3,'Color',[0,0.447,0.741])
set(hh1(2,1),'LineWidth',2)

%fited phase data
yyaxis right
hh1(3,1)=plot(1e-3*freq2,atan2(freq2.*fitresultAmp.freq0./fitresultAmp.Q,fitresultAmp.freq0^2-freq2.^2)*180./pi);
ylabel(['Phase',char(176)])
ylim([0 180])
set(hh1(3,1),'LineWidth',2)
% legend(h3,['Q=',num2str(fitresultAmp.Q),char(10),'A_0=',num2str(fitresultAmp.A0.*AmpInvOLS),'[m]',char(10),'f_0=',num2str(fitresultAmp.freq0),'Hz'],'Location', 'NorthWest');legend('boxoff')
xlim([min(freq2) max(freq2)]*1e-3)
set(gca,'FontSize',14)
% title(title1)


% fitresultAmp.freq0
% 
dum2=min(abs(freq2-fitresultAmp.freq0));
indc=find((abs(freq2-fitresultAmp.freq0)==dum2));
phas2=wrapTo2Pi(phas2-mean(phas2(indc-1:indc+1))+pi/2);

%experiemtal phase 
yyaxis right
hh1(4,1)=scatter(1e-3*freq2,phas2*180./pi,'*')
yticks([0 90 180])
c={'Amp. data' 'Fitted amp.' 'Fitted phase' 'Phase data'}; % legend list
order=[1 2 4 3];
legend(hh1(order),c{order},'Location','northwest')
legend boxoff  

export_fig tuning.png -m4 -transparent
% saveas(h, title1, 'png')
% savefig([title1,'.fig'])