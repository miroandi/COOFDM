
function   OFD( in , Rs)

figure;hold
Hs=spectrum.periodogram;
psd(Hs,in(1,:), 'Fs',Rs, 'CenterDC', 1)
% 
% figure1 = figure;
% 
% plot(abs(fftshift(fft(in))) .^2,'r', 'Display',str)
% 
% mean_power=mean(((abs(in) .^2))/1e-3);
% str3 =[ 'mean power ', num2str(10*log10(mean_power)),' dBm'];
% annotation(figure1,'textbox',...
%     [0.277785714285714 0.935714285714286 0.481142857142857 0.0476190476190487],...
%     'String',{ str3},...
%     'FitBoxToText','off',...
%     'EdgeColor','none');
% ylim([-140 -100]);
end 
