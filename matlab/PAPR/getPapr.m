function outPapr = getPapr(outputiFFT)

   
    % computing the peak to average power ratio for each symbol
    meanSquareValue = outputiFFT*outputiFFT'/length(outputiFFT);
    peakValue = max(outputiFFT.*conj(outputiFFT));
    outPapr = peakValue/meanSquareValue; 
end