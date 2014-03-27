function outPapr = getPapr1(outputiFFT, meanSquareValue)
   % computing the peak to average power ratio for each symbol
    peakValue = max(outputiFFT.*conj(outputiFFT));
    outPapr = peakValue/meanSquareValue; 
end