function caxiscorrection(dataa)
dumM=mean(dataa(~isnan(dataa)));
dumS=std(dataa(~isnan(dataa)));
caxis([max(dumM-1.*dumS,0) dumM+1*dumS])
