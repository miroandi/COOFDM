
function [padnum, totlength] = CalcPadNum( datalength, overlap, blocksize)
    totlength = blocksize * ( ceil( datalength/blocksize) + (overlap - 1));
    padnum = totlength - datalength ;
end