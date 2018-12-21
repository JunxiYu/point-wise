clear all;close all;clc
%read the directory
folder_name = uigetdir;
cd( folder_name)
%let's select all the ibw files from igor
% File=uigetfile('*.ibw', 'Select a MATLAB code file', 'MultiSelect', 'on')
File=uigetfile('*.ibw', 'Select main IBW file');

prompt = 'Please enter the First point ';
n1 = input(prompt)+1; %igor starts the indeces from 0, matlab starts from 1

prompt = 'Please enter the last point ';
n2 = input(prompt)+1;

%read the main file
dum=IBWread(File);
main=dum.y; %take the matrix data

%the indeces stracture of  Freq and Amp matrices are as follows:
% [data of tune, volt increments, points, [V1, V2,L1, L2]]

%read the Amplitude data
dum=IBWread( strcat(File(1:end-4),'Amp.ibw'));
Amp=dum.y(:,:,n1:n2,:); %take the matrix data

%read the Frequency data
dum=IBWread( strcat(File(1:end-4),'Freq.ibw'));
Freq=dum.y(:,:,n1:n2,:); %take the matrix data



for ii1=1:size(Freq,4) %loop over (Vertical 1, Vertical 2, Lateral 1, lateral2)
    for ii2=1:size(Freq,3) %loop over points
        for ii3=1:size(Freq,2) %loop over volt increments
            %makes sure the data is not nan
            if ~isnan(Freq(:,ii3,ii2,ii1))==0
                FD.Freq(ii3,ii2,ii1)=NaN;
                FD.Amp(ii3,ii2,ii1)=NaN;
                FD.Q(ii3,ii2,ii1)=NaN;
            else %this fits the SHO model and saves freq0, A0 and Q
                [fitresultAmp,~]=createFitSHOAmp(Freq(:,ii3,ii2,ii1), Amp(:,ii3,ii2,ii1));
                FD.Freq(ii3,ii2,ii1)=fitresultAmp.freq0;
                FD.Amp(ii3,ii2,ii1)=fitresultAmp.A0*main(2,1); %convert to Pm through multiplying by inverse optical lever sentivity (main(2,1))
                FD.Q(ii3,ii2,ii1)=fitresultAmp.Q;
            end
        end
    end
end


%now let's average over points
FDA.Freq=mean(FD.Freq,2,'omitnan'); %we should neglect nan values
FDA.Amp=mean(FD.Amp,2,'omitnan');
FDA.Q=mean(FD.Q,2,'omitnan');

%now let's find STD over points
FDS.Freq=std(FD.Freq,0,2,'omitnan');
FDS.Amp=std(FD.Amp,0,2,'omitnan');
FDS.Q=std(FD.Q,0,2,'omitnan');

%let's plot vertical 1st and 2nd harm as a function of drive
%% AMP
%vertical
h1=figure('units','normalized','outerposition',[0 0 1 1]);

subplot(231)
errorbar(main(1,:)./sqrt(2),FDA.Amp(:,:,1)*1e12,FDS.Amp(:,:,1)*1e12,'o','MarkerSize',10,'LineWidth',2) ;hold all
errorbar(main(1,:)./sqrt(2),FDA.Amp(:,:,2)*1e12,FDS.Amp(:,:,2)*1e12,'s','MarkerSize',10,'LineWidth',2) 
legend ('#1 Harm.','#2 Harm.');legend boxoff 
xlabel ('Drive [Vrms]')
ylabel ('Vertical Amp. [pm]')
%lateral
subplot(234)
errorbar(main(1,:)./sqrt(2),FDA.Amp(:,:,3)*1e12,FDS.Amp(:,:,3)*1e12,'x','MarkerSize',10,'LineWidth',2) ;hold all
errorbar(main(1,:)./sqrt(2),FDA.Amp(:,:,4)*1e12,FDS.Amp(:,:,4)*1e12,'d','MarkerSize',10,'LineWidth',2) 
legend ('#1 Harm.','#2 Harm.');legend boxoff 
xlabel ('Drive [Vrms]')
ylabel ('Lateral Amp. [pm]');set(gca,'FontSize',16)
%% frequency
%vertical
subplot(232)
errorbar(main(1,:)./sqrt(2),FDA.Freq(:,:,1)*1e-3,FDS.Freq(:,:,1)*1e-3,'o','MarkerSize',10 ,'LineWidth',2) ;hold all
errorbar(main(1,:)./sqrt(2),FDA.Freq(:,:,2)*1e-3,FDS.Freq(:,:,2)*1e-3,'s','MarkerSize',10,'LineWidth',2) 
legend ('#1 Harm.','#2 Harm.');legend boxoff 
xlabel ('Drive [Vrms]')
ylabel ('Vertical Frequency. [kHz]')
%lateral
subplot(235)
errorbar(main(1,:)./sqrt(2),FDA.Freq(:,:,3)*1e-3,FDS.Freq(:,:,3)*1e-3,'x','MarkerSize',10,'LineWidth',2) ;hold all
errorbar(main(1,:)./sqrt(2),FDA.Freq(:,:,4)*1e-3,FDS.Freq(:,:,4)*1e-3,'d','MarkerSize',10,'LineWidth',2) 
legend ('#1 Harm.','#2 Harm.');legend boxoff 
xlabel ('Drive [Vrms]')
ylabel ('Lateral Frequency. [kHz]');set(gca,'FontSize',16)
%% Quality
%vertical
subplot(233)
errorbar(main(1,:)./sqrt(2),FDA.Q(:,:,1),FDS.Q(:,:,1),'o','MarkerSize',10 ,'LineWidth',2) ;hold all
errorbar(main(1,:)./sqrt(2),FDA.Q(:,:,2),FDS.Q(:,:,2),'s','MarkerSize',10,'LineWidth',2) 
legend ('#1 Harm.','#2 Harm.');legend boxoff 
xlabel ('Drive [Vrms]')
ylabel ('Vertical Q')
%lateral
subplot(236)
errorbar(main(1,:)./sqrt(2),FDA.Q(:,:,3),FDS.Q(:,:,3),'x','MarkerSize',10,'LineWidth',2) ;hold all
errorbar(main(1,:)./sqrt(2),FDA.Q(:,:,4),FDS.Q(:,:,4),'d','MarkerSize',10,'LineWidth',2) 
legend ('#1 Harm.','#2 Harm.');legend boxoff 
xlabel ('Drive [Vrms]')
ylabel ('Lateral Q');set(gca,'FontSize',16)


%% saving
%saving variables
save(strcat(File(1:end-4),'.mat'),'main','FD','FDA','FDS')

%saving figure
export_fig point-wise.png -m2 -transparent
savefig(h1,strcat(File(1:end-4),'.fig'))
