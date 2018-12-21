function [dataF]=flattend(data,direction)

switch direction
    case 1 % 0-degree 0-order flatten
        dumM=mean( data(~isnan(data)));
        dataF     =   data-diag(mean(data,2,'omitnan'))*ones(size(data))+dumM;
    case 2 % 90-degree 0-order flatten
        dumM=mean( data(~isnan(data)));
        dataF     =   data-ones(size(data))*diag(mean(data,'omitnan'))+dumM;
    otherwise
        disp('wrong command fro flatten. use "1" for zero order flatten (zero degree), or use "2" for zero order flatten (90 degree)')
        return
end