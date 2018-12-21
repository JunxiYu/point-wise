function [Ampd,Phsd,Qfac,Freq0]=SolveSHOParms(Amp1, Amp2, Phs1, Phs2, Freq, Sideband)


Freq1=Freq-Sideband;
Freq2=Freq+Sideband;


Freq1(Freq1 <= 0) = NaN; % eliminate invalid data  ! there should be no negative anymore
Freq2(Freq2 <= 0) = NaN; % eliminate invalid data


Phs1 = Phs1.*pi()./180;
Phs2 =Phs2.* pi()./180;

% 	Phs1 =- Phs1.*pi()./180;
%     Phs2 =-Phs2.* pi()./180;	% convert to radians
    Phs1 = wrapToPi(Phs1);
	Phs2 = wrapToPi(Phs2);

    

dPhs = Phs2 - Phs1;

dPhs = wrapToPi(dPhs);


Phs2(dPhs < 0) = NaN; % eliminate invalid data
Phs1(dPhs < 0) = NaN; % eliminate invalid data

% figure;imagesc(Phs2);colorbar;title dPhs

a = (Amp1.*Freq1)./(Amp2.*Freq2) ;
b = tan(Phs2-Phs1);


X1 = (-1 + sign(b).*sqrt(1 + b.^2)./a)./b;
X2 = ( 1 - sign(b).*sqrt(1 + b.^2).*a)./b;

X1(imag(X1)~=0)=NaN;
X2(imag(X2)~=0)=NaN;


Qfac  = sqrt(Freq1.*Freq2).*sqrt(Freq2.*X1 - Freq1.*X2).*(sqrt(Freq1.*X1 - Freq2.*X2))./(Freq2.^2 - Freq1.^2);
Freq0 = sqrt(Freq1.*Freq2).*sqrt(Freq2.*X1 - Freq1.*X2)./(sqrt(Freq1.*X1 - Freq2.*X2)); 
Qfac(imag(Qfac)~=0)=NaN;
%     Qfac(Qfac<0)=NaN;    %Qfac(Qfac==inf)=NaN;
Freq0(imag(Freq0)~=0)=NaN;
Phsd = Phs1 - atan2(Freq0.*Freq1./Qfac, Freq0.^2 - Freq1.^2);

Ampd = Amp1.*sqrt((Freq0.^2 - Freq1.^2).^2 + (Freq0.*Freq1./Qfac).^2)./Freq0.^2;
% Ampd(imag(Ampd)>0)=NaN;



Phsd = wrapToPi(Phsd);
Phsd=   Phsd.*180./pi();
end