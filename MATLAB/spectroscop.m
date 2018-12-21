%this code takes care of spectroscopy results
% spectroscop(dev981,4,1.4257e-7,20,'0.5 Hz')


function [dum1, dum2]=spectroscop(sample1,demod,AmpInvOLS,scannumber,title1)

% close all
switch demod
    case 3
        ii1=[1 2 3]; %demodulators that we will read, 1,2,3
    case 4
        ii1=[4 5 6]; %demodulators that we will read, 4,5,6
    otherwise
        disp('wrong demod. set, put 3 for for the first 3demods  or put 4 for demods4,5,6')
        return
end


for ii2=1:scannumber
    dum(ii2) = length(sample1.demods(ii1(1)).sample{1,ii2}.x);
end
num_points=min(dum)-2;

%% removing the first cycle 
%very bad approach
ct1=round(length(sample1.demods(ii1(1)).sample{1, 1}.x  )*.2);



for ii2=1:scannumber
    
    %% loops on 3 demods
    ct3=0; %counter on different demodulator
    for ii3=ii1
        sample=sample1.demods(ii3).sample;
        ct3=ct3+1;
        Output(ct3).Amp       =   abs(sample{1,ii2}.x(ct1:num_points) + 1i*sample{1,ii2}.y(ct1:num_points)).*AmpInvOLS; %take the amplitude in V and convert it m!
        Output(ct3).Phase     =   wrapTo180(-atan2(sample{1,ii2}.y(ct1:num_points),sample{1,ii2}.x(ct1:num_points)).*180./pi()); % I invert the phase response of ZI lock-in to be simillar to the convetion AR uses (the phase response before res=0, after res=+180)
        Output(ct3).Freq      =   sample{1,ii2}.frequency(ct1:num_points) ;
    end
    
    %% SHO parameter
    Fside=mean(Output(3).Freq(~isnan(Output(3).Freq))) ;%side band frequency range
    %let us correct the resul and save them in CorOutput
    [CorOutput.Ampd(:,ii2),CorOutput.PhaseD(:,ii2),CorOutput.QD(:,ii2),CorOutput.FreqD(:,ii2)]=SolveSHOParms(Output(3).Amp,Output(2).Amp,   Output(3).Phase,  Output(2).Phase,Output(1).Freq, Fside);
%     figure;plot(CorOutput.Ampd(:,ii2));hold all
    
end





CorOutput.Ampdav=mean(CorOutput.Ampd,2,'omitnan');hold all
 hamp1=figure(1);
scatter(sample{1, 1}.auxin0(ct1:num_points)  ,CorOutput.Ampdav,'o')
figure;hold all
% hh=plot(dum3(1,:),dum4(1,:),dum3(2,:),dum4(2,:),dum3(3,:),dum4(3,:))
hh(1,1)=scatter(dum3(1,:),dum4(1,:))
hh(2,1)=scatter(dum3(2,:),dum4(2,:))
hh(3,1)=scatter(dum3(3,:),dum4(3,:))
ylim([0 8]*1e-12)
ylabel('STIM amp. [m]')
xlabel('DC bias [V]')
% title(title1)
set(gca, 'FontSize', 14)

dum1=sample{1, 1}.auxin0(ct1:num_points);
dum2=CorOutput.Ampdav;
c={'20 Hz' '2 Hz' '0.2 Hz'}; % legend list
order=[3 2 1];
legend(hh(order),c{order})
xlim([0 1.1])
ylim([0 9e-12])
% saveas(hamp1,['Amp',title1,'.png'])
% savefig(hamp1,['Amp',title1,'.fig'])
% hamp2=figure;
% CorOutput.PhaseDav=mean(CorOutput.PhaseD,2,'omitnan');
% plot(sample{1, 1}.auxin0(ct1:num_points)  ,CorOutput.PhaseDav,'o')
% ylabel(['Phase [',sprintf( char(176)),']'])
% xlabel('Set point [V]')
% ylim([30 120])
% title(title1)
% set(gca, 'FontSize', 14)
% saveas(hamp2,['Phase',title1,'.png'])
% savefig(hamp2,['Phase',title1,'.fig'])
% hamp3=figure;
% CorOutput.FreqDav=mean(CorOutput.FreqD,2,'omitnan');
% plot(sample{1, 1}.auxin0(ct1:num_points)  ,CorOutput.FreqDav,'o')
% ylabel('Frequency [Hz]')
% xlabel('Set point [V]')
% ylim([1.155 1.195]*1e5)
% title(title1)
% set(gca, 'FontSize', 14)
% saveas(hamp3,['Freq',title1,'.png'])
% savefig(hamp3,['Freq',title1,'.fig'])