function [dataf] =  GenStim( totalbits, sim, filename , datain, shift )
if ( sim.useolddata == 1 )
    dataf =datain;
    return ;
end
if ( sim.useprbsdata == 1 )
    %% read pbrs
    pbrs =importdata(filename);%, 'prbs15.txt');
    tmpdata = pbrs;
    for ii=1:(ceil(totalbits/length(tmpdata) )+shift/length(tmpdata))
        tmpdata = [tmpdata pbrs];
%         length(tmpdata);
    end
    dataf = tmpdata(shift+1:shift+totalbits);
else
    dataf = rand(1,totalbits) > 0.5;
end

end