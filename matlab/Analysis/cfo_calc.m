
function [cfo_est, mean_dc, dc_freq] = cfo_calc( in )
%% Approximation, must be changed.
%     noisyreceivein(:, rxpacketlen-1000:rxpacketlen);
    freq_in = fft( in);
    cfo_freq_index = find (abs(freq_in) == max(abs(freq_in))) ;
    cfo_freq =cfo_freq_index;
    if ( cfo_freq > (length(freq_in) /2  -1))
        cfo_freq = -length(freq_in) +cfo_freq ;
    end
    cfo_freq_MHz = (cfo_freq -1)* 40e9 / ( length(in) )/1e6 ;
%     disp([ 'cfo_freq ', num2str(cfo_freq_MHz),  ' MHz']);
    cfo_est = cfo_freq_MHz;
    dc_freq= freq_in(1);
    time_dc = ifft( [dc_freq, zeros(1, length(freq_in)-1)]);
    mean_dc = time_dc(1);
    tx_dc = zeros(1,length(freq_in));
    
    tx_dc(cfo_freq_index ) = freq_in(cfo_freq_index);
    time_tx_dc = ifft( tx_dc);
    mean_tx_dc = time_tx_dc(1);
    disp2( 'DCoffset.txt', ['tx ',num2str(mean_tx_dc), ' rx ', num2str(mean_dc),' ', datestr(now,'HH:MM ')]);
%     disp2( 'DCoffset.txt', [ num2str(mean_tx_dc),   num2str(mean_dc)   ]);
%     mean_dc = mean( in) ;
end
