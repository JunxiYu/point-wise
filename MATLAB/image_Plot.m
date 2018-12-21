%Ehsan Nasr Esfahani, 8/21/2016
%This code generate and visualize the data from Zurich instrument lock-in
%amplifier in "SW Trig - Grid mode".
%Options of this code:
%-sample1: the name of the ZI lock-in amplifier. for the current device,
%eneter dev981
%-size1: can take the size of image in meters (should be equal to AR scan size)
%-direction:  upward or downward image? (for "framdown" use -1, for "framsup" use 1)
%demod: Take data from modulators 1-3 (USE 3) or 4-6  (USE 4) (when the MOD is used, it could be
%input 1 VS input2 (demod option).
%-lines: Take the trace (USE 6) or the rectrace (USE 5)
%-AmpInvOLS: this is the option for converting voltage to deflection.%Should be the same value as AR value unit [m/V].
%-Flatten: This flattens the data: USE 0: flatten off - USE 1: flatten on, 0 degree 0-order, USE 2:flatten on, 90 degree, 0-order
%- phaseoffset: manually shifts the phase in degrees. only do when necessary, otherwise put zero.
%-figureSave : USE 9 to save all images, USE 0 no figure is saved
%-fonts : font size used for export of images
%-medfilt:  Median filter, use 0 for no median filter or 15 for median
%filrter. you will be prompt to enter the neighborhood pixels

%example
% first load the ZI saved data like following:
% load('C:\Users\Asylum User\Documents\Zurich Instruments\LabOne\WebServer\session_20160727_160237_01\LytV2S1_STIM_0001_000\LytV2S1_STIM_0001_00000.mat')
% change the matlab current directory to where this code is saved, then run this command
% image_Plot(dev981,1e-6,-1,4,5,8.145e-6,1,0,9,12,15)
function [CorOutput]=image_Plot(sample1,size1,direction,demod,lines,AmpInvOLS,flatten,phaseoffset,figureSave,fonts,medfilt)



%scann number saved in ZI labOne
scannumber=1;

%scan direction diefined here
switch direction
    case -1
        str1='reverse';
    case 1
        str1='normal';
    otherwise
        disp('wrong direction, put -1 for downward, 1 for upward')
        return
end

% which demods?
switch demod
    case 3
        ii1=[1 2 3]; %demodulators that we will read, 1,2,3
        string2='Vertical';
    case 4
        ii1=[4 5 6]; %demodulators that we will read, 4,5,6
        string2='Lateral';
        string2='';
        
    otherwise
        disp('wrong demod. set, put 3 for for the first 3demods  or put 4 for demods4,5,6')
        return
end





%finding size of stored matrices
[num_raws,num_points] = size(sample1.demods(ii1(1)).sample{1,scannumber}.x);
num_raws=num_raws-1;


%make free matrices
value1={NaN(num_raws/2, num_points);NaN(num_raws/2, num_points);NaN(num_raws/2, num_points)};
Output=struct('Amp',value1,'Phase',value1,'Freq',value1);



switch lines %% trace or retrace?
    case 5 %retrace
        LineIndex=2:2:num_raws;
        str3='reverse';
        str4='Retrace';
    case 6    %trace
        LineIndex=1:2:num_raws;
        str3='normal';
        str4='Trace';
    otherwise
        disp('wrong command. Use "5" for retrace or use "6" for trace')
        return
end


%% loops on 3 demods
ct3=0; %counter on different demodulator
for ii3=ii1
    sample=sample1.demods(ii3).sample;
    ct3=ct3+1;
    Output(ct3).Amp       =   abs(sample{1,scannumber}.x(LineIndex,:) + 1i*sample{1,scannumber}.y(LineIndex,:)).*AmpInvOLS; %take the amplitude in V and convert it m!
    Output(ct3).Phase     =   wrapTo180(-atan2(sample{1,scannumber}.y(LineIndex,:),sample{1,scannumber}.x(LineIndex,:)).*180./pi()+phaseoffset); % I invert the phase response of ZI lock-in to be simillar to the convetion AR uses (the phase response before res=0, after res=+180)
    Output(ct3).Freq      =   sample{1,scannumber}.frequency(LineIndex,:) ;
end

%% SHO parameter
Fside=mean(Output(3).Freq(~isnan(Output(3).Freq))) ;%side band frequency range
%let us correct the resul and save them in CorOutput
[CorOutput.Ampd,CorOutput.PhaseD,CorOutput.QD,CorOutput.FreqD]=SolveSHOParms(Output(3).Amp,Output(2).Amp,   Output(3).Phase,  Output(2).Phase,Output(1).Freq, Fside);

CorOutput.ampdU=CorOutput.QD.*CorOutput.Ampd; % A_{max}

%% check if our SHO fit makes sense on random points!
nn1=1;
for ii4=1:nn1 %randomly plots nn1 points from the image
    figure;hold all
    dum1=round(rand(1)*num_raws/2);
    dum2=round(rand(1)*num_points);
    omega0=CorOutput.FreqD(dum1,dum2)*2*pi();
    omega=omega0-.7e5:1e3:omega0+.7e5;
    A=CorOutput.Ampd(dum1,dum2)*omega0^2./sqrt((omega0^2-omega.^2).^2+(omega.*omega0./CorOutput.QD(dum1,dum2)).^2);
    theta=atan2(omega.*omega0./CorOutput.QD(dum1,dum2),omega0^2-omega.^2);
    yyaxis left
    plot(omega./(2*pi),A)
    scatter([Output(1).Freq(dum1,dum2)-Fside CorOutput.FreqD(dum1,dum2) Output(1).Freq(dum1,dum2)+Fside],[Output(3).Amp(dum1,dum2)  CorOutput.ampdU(dum1,dum2) Output(2).Amp(dum1,dum2)],'o')
    legend(['Q=',num2str(CorOutput.QD(dum1,dum2))])
    yyaxis right
    plot(omega./(2*pi),theta*180./pi)
    scatter([Output(1).Freq(dum1,dum2)-Fside   Output(1).Freq(dum1,dum2)+Fside],wrapTo180([Output(3).Phase(dum1,dum2)-CorOutput.PhaseD(dum1,dum2) Output(2).Phase(dum1,dum2)-CorOutput.PhaseD(dum1,dum2)]),'o')
end
% return
%% flatten

switch flatten %flattens the data
    case 0 %no flatten, do nothing
    case {1,2} %faltten 0-order
        CorOutput.Ampd= flattend(CorOutput.Ampd,flatten);
        CorOutput.FreqD= flattend(CorOutput.FreqD,flatten);
        CorOutput.QD= flattend(CorOutput.QD,flatten);
    otherwise
        disp('wrong command fro flatten. Use "0" for no-flatten or use "1" for zero order flatten (zero degree), or use "2" for zero order flatten (90 degree)')
        return
end


%% 2-D median filtering
switch medfilt
    case 15
        
        prompt = 'enter the value of neighborhood around the corresponding pixel for average filter? ';
        x11 = input(prompt);
        imageFilter=fspecial('disk',x11);
        CorOutput.Ampd = nanconv(CorOutput.Ampd,imageFilter, 'edge');
        CorOutput.FreqD = nanconv(CorOutput.FreqD,imageFilter, 'nanout');
        CorOutput.QD = nanconv(CorOutput.QD,imageFilter, 'nanout');
        
        %         CorOutput.Ampd= medfilt2(CorOutput.Ampd,[x11 x11]);
        %         CorOutput.FreqD= medfilt2(CorOutput.FreqD,[x11 x11]);
        %         CorOutput.QD= medfilt2(CorOutput.QD,[x11 x11]);
    case 0
        
    otherwise
        disp('wrong command fro flatten. Use "0" for no-flatten or use "15" for median filter')
        return
end
%% graphing

%Amp1
hamp1=figure;imagesc([0 size1],[0 size1],Output(3).Amp);hcb=colorbar; title(['Amp1-Demod',num2str(ii3)]) ;%caxis([max(mean(Output(3).AmpFRet(~isnan(Output(3).AmpFRet)))-1.5*std(Output(3).AmpFRet(~isnan(Output(3).AmpFRet))),0) mean(Output(3).AmpFRet(~isnan(Output(3).AmpFRet)))+2*std(Output(3).AmpFRet(~isnan(Output.AmpFRet)))])
set(gca,'XDir',str3);set(gca,'YDir',str1);axis square;colormap(othercolor('BuOrR_14'));title(hcb,'m')
caxiscorrection(Output(3).Amp) %this function adjusts caxis

%Phase1
hphs1=figure;imagesc([0 size1],[0 size1],Output(3).Phase);hcb=colorbar; title(['Phase1-Demod',num2str(ii3)]);%caxis([mean(Output(3).Phase(~isnan(Output(3).Phase)))-2*std(Output(3).Phase(~isnan(Output(3).Phase))) mean(Output(3).Phase(~isnan(Output(3).Phase)))+2*std(Output(3).Phase(~isnan(Output(3).Phase)))])
set(gca,'XDir',str3);set(gca,'YDir',str1);colormap(pmkmp(256,'LinLhot'));axis square;title(hcb,sprintf('%c', char(176)))
caxiscorrPhase(Output(3).Phase) %this function adjusts caxis

%Amp2
hamp2=figure;imagesc([0 size1],[0 size1],Output(2).Amp);hcb=colorbar; title(['Amp2-Demod',num2str(ii3-1)]) ;%caxis([max(mean(Output(2).AmpFRet(~isnan(Output(2).AmpFRet)))-1.5*std(Output(2).AmpFRet(~isnan(Output(2).AmpFRet))),0) mean(Output(2).AmpFRet(~isnan(Output(2).AmpFRet)))+2*std(Output(2).AmpFRet(~isnan(Output.AmpFRet)))])
set(gca,'XDir',str3);set(gca,'YDir',str1);axis square;colormap(othercolor('BuOrR_14'));title(hcb,'m')
caxiscorrection(Output(2).Amp) %this function adjusts caxis

%phase2
hphs2=figure;imagesc([0 size1],[0 size1],Output(2).Phase);hcb=colorbar; title(['Phase2-Demod',num2str(ii3-1)])%;caxis([mean(Output(2).Phase(~isnan(Output(2).Phase)))-2*std(Output(2).Phase(~isnan(Output(2).Phase))) mean(Output(2).Phase(~isnan(Output(2).Phase)))+2*std(Output(2).Phase(~isnan(Output(2).Phase)))])
set(gca,'XDir',str3);set(gca,'YDir',str1);colormap(pmkmp(256,'LinLhot'));axis square;title(hcb,sprintf('%c', char(176)))
caxiscorrPhase(Output(2).Phase) %this function adjusts caxis

%Carrier freq
%freq
hfre3=figure;imagesc([0 size1],[0 size1],Output(1).Freq);hcb=colorbar; title(['Freq-Demod',num2str(ii3-2)]);set(gca,'XDir',str3);set(gca,'YDir',str1);
colormap(pmkmp(256,'CubicL'));axis square;title(hcb,'Hz')
caxiscorrection(Output(1).Freq) %this function adjusts caxis
axis off

%amp
hamp3=figure;imagesc([0 size1],[0 size1],Output(1).Amp);hcb=colorbar; title(['Amp-Demod',num2str(ii3-2)]);set(gca,'XDir',str3);set(gca,'YDir',str1);
colormap(othercolor('BuOrR_14'));axis square;title(hcb,'m')
caxiscorrection(Output(1).Amp) %this function adjusts caxis
axis off

%phase
hphs3=figure;imagesc([0 size1],[0 size1],Output(1).Phase);hcb=colorbar; title(['Phase-Demod',num2str(ii3-2)]);set(gca,'XDir',str3);set(gca,'YDir',str1);
set(gca,'XDir',str3);set(gca,'YDir',str1);colormap(pmkmp(256,'LinLhot'));axis square;title(hcb,sprintf('%c', char(176)))
caxiscorrPhase(Output(1).Phase) %this function adjusts caxis


%% amp un-corrected

dumM=mean(CorOutput.ampdU(~isnan(CorOutput.ampdU)));
dumS=std(CorOutput.ampdU(~isnan(CorOutput.ampdU)));
figure;datahist1=histogram(CorOutput.ampdU,'BinLimits',[max(dumM-min(4*dumS,dumM),0) dumM+min(4*dumS,dumM)],'BinWidth',1e-12);
x1=datahist1.BinEdges(1:end-1);y1=datahist1.Values;
f=fit(x1.',y1.','gauss2');title([string2,' Uncorrected Amp - ', str4]) %;hold all;plot(f)
hamu=figure;imagesc([0 size1],[0 size1],CorOutput.ampdU);hcb=colorbar; title([string2,'Uncorrected Amp - ', str4]) ;
set(gca,'XDir',str3);set(gca,'YDir',str1);colormap(othercolor('BuOrR_14'));axis square;title(hcb,'m')
caxis([f.b1-1*f.c1 f.b1+1.*f.c1])

%% corrected

%amp
dumM=mean(CorOutput.Ampd(~isnan(CorOutput.Ampd)));
dumS=std(CorOutput.Ampd(~isnan(CorOutput.Ampd)));
figure;datahist1=histogram(CorOutput.Ampd,'BinLimits',[max(dumM-min(4*dumS,dumM),0) dumM+min(4*dumS,dumM)],'BinWidth',1e-14);
x1=datahist1.BinEdges(1:end-1);y1=datahist1.Values;
f=fit(x1.',y1.','gauss2');title([string2,' Amp - ', str4]) %;hold all;plot(f)
ham=figure;bb1=imagesc([0 size1],[0 size1],CorOutput.Ampd.*1e12);hcb=colorbar; %title([string2,' Corrected Amp - ', str4]) ;
caxiscorrection(CorOutput.Ampd.*1e12) %this function adjusts caxis
% caxis([3 9])
set(gca,'XDir',str3);set(gca,'YDir',str1);colormap(othercolor('BuOrR_14'));axis square;title(hcb,'pm')
set(gca,'FontSize',fonts)
axis off

%  set(bb1,'AlphaData',~isnan(CorOutput.Ampd))

% phase
% dumM=mean(CorOutput.PhaseD(~isnan(CorOutput.PhaseD)));
% dumS=std(CorOutput.PhaseD(~isnan(CorOutput.PhaseD)));
figure;datahist=histogram(CorOutput.PhaseD,'BinWidth',2);
x1=datahist.BinEdges(1:end-1);y1=datahist.Values;
f=fit(x1.',y1.','gauss2');title([string2,' Phase - ', str4]);%hold all;plot(f);
hph=figure;bb1=imagesc([0 size1],[0 size1],CorOutput.PhaseD);hcb=colorbar; %title([string2,' Phase - ', str4]);
caxiscorrPhase(CorOutput.PhaseD) %this function adjusts caxis
set(gca,'XDir',str3);set(gca,'YDir',str1);colormap(pmkmp(256,'LinLhot'));axis square;title(hcb,sprintf('%c', char(176)))
set(gca,'FontSize',fonts)
%  set(bb1,'AlphaData',~isnan(CorOutput.PhaseD))
axis off

%Q
dumM=mean(CorOutput.QD(~isnan(CorOutput.QD)));
dumS=std(CorOutput.QD(~isnan(CorOutput.QD)));
figure;datahist=histogram(CorOutput.QD,'BinLimits',[max(dumM-min(4*dumS,dumM),0) dumM+min(4*dumS,dumM)]);
x1=datahist.BinEdges(1:end-1);y1=datahist.Values;
f=fit(x1.',y1.','gauss2');hold all;plot(f);%title([string2,'Corrected Quality - ', str4])
hq=figure;bb1=imagesc([0 size1],[0 size1],(CorOutput.QD));hcb=colorbar; %title([string2,' Quality - ', str4]);
caxis([f.b1-1*f.c1 f.b1+1.5*f.c1])
% caxis([max(dumM-1*min(dumS,dumM),0) dumM+1*min(dumS,dumM)])
set(gca,'XDir',str3);set(gca,'YDir',str1);colormap(pmkmp(256,'CubicYF'));axis square;
colormap(othercolor('BrBG10'))
set(gca,'FontSize',fonts)
%  set(bb1,'AlphaData',~isnan(CorOutput.QD))
% caxis([40 90])
axis off

%Freq
dumM=mean(CorOutput.FreqD(~isnan(CorOutput.FreqD)));
dumS=std(CorOutput.FreqD(~isnan(CorOutput.FreqD)));
figure;datahist=histogram(CorOutput.FreqD,'BinLimits',[max(dumM-min(4*dumS,dumM),0) dumM+min(4*dumS,dumM)]);
x1=datahist.BinEdges(1:end-1);y1=datahist.Values;
f=fit(x1.',y1.','gauss2');hold all;plot(f);title([string2,' Corrected Freq - ', str4])
hf=figure;bb1=imagesc([0 size1],[0 size1],CorOutput.FreqD.*1e-3);hcb=colorbar;% title([string2,' Freq - ', str4]);
caxis([f.b1-2*f.c1 f.b1+2.*f.c1].*1e-3) 
% caxis([117.5 120])
set(gca,'XDir',str3);set(gca,'YDir',str1);colormap(pmkmp(256,'CubicL'));axis square;title(hcb,'kHz')
% figure;histogram(CorOutput.FreqD);
set(gca,'FontSize',fonts)
%  set(bb1,'AlphaData',~isnan(CorOutput.FreqD))
 
%plot failing ploints
dumm=isnan(CorOutput.Ampd);
axis off

%failed
hfail=figure;imagesc([0 size1],[0 size1],dumm);colormap gray
title('Failed points in white');set(gca,'XDir',str3);set(gca,'YDir',str1);

%% save image?
switch figureSave
    case 9
        saveas(hf,[string2,' Corrected Freq - ', str4,'.png'])
        savefig(hf,[string2,' Corrected Freq - ', str4,'.fig'])
        saveas(hq,[string2,' Corrected Quality - ', str4,'.png'])
        savefig(hq,[string2,' Corrected Quality - ', str4,'.fig'])
        saveas(hph,[string2,' Corrected Phase - ', str4,'.png'])
        savefig(hph,[string2,' Corrected Phase - ', str4,'.fig'])
        saveas(ham,[string2,' Corrected Amp - ', str4,'.png'])
        savefig(ham,[string2,' Corrected Amp - ', str4,'.fig'])
        saveas(hamu,[string2,'Uncorrected Amp - ', str4,'.png'])
        savefig(hamu,[string2,'Uncorrected Amp - ', str4,'.fig'])
        saveas(hphs3,['Phase-Demod',num2str(ii3-2),'.png'])
        savefig(hphs3,['Phase-Demod',num2str(ii3-2),'.fig'])
        saveas(hamp3,['Amp-Demod',num2str(ii3-2),'.png'])
        savefig(hamp3,['Amp-Demod',num2str(ii3-2),'.fig'])
        saveas(hfre3,['Freq-Demod',num2str(ii3-2),'.png'])
        savefig(hfre3,['Freq-Demod',num2str(ii3-2),'.fig'])
        saveas(hphs2,['Phase2-Demod',num2str(ii3-1),'.png'])
        savefig(hphs2,['Phase2-Demod',num2str(ii3-1),'.fig'])
        saveas(hamp2,['Amp2-Demod',num2str(ii3-1),'.png'])
        savefig(hamp2,['Amp2-Demod',num2str(ii3-1),'.fig'])
        saveas(hphs1,['Phase1-Demod',num2str(ii3),'.png'])
        savefig(hphs1,['Phase1-Demod',num2str(ii3),'.fig'])
        saveas(hamp1,['Amp1-Demod',num2str(ii3),'.png'])
        savefig(hamp1,['Amp1-Demod',num2str(ii3),'.fig'])
    case 0
    otherwise
        disp('wrong save image option, put 9 to save, or  10 to do nothing')
        return
end