function createfigure1( handles)
Y1 = handles.maxoffset.EVM_dB_sc;
Y2 = handles.maxoffset.EVM_dB_sym;
Y3 = handles.maxoffset.commonphase;
Y4 = handles.maxoffset.fftout(1,:);
Y5 = handles.maxoffset.idealout(1,:);
Y6 = 1./ handles.maxoffset.H ;

if ( handles.params.Nstream == 2 )
    Y6 = zeros(size(handles.maxoffset.H));
    for ii=1:(length(handles.params.LTFindex))
        idx=handles.params.LTFindex(ii);
        Y6(:,:,handles.params.LTFindex(ii)) = inv(handles.maxoffset.H(:,:,handles.params.LTFindex(ii)));
    end
end

in = handles.maxoffset.noisyreceivein(1,:);
params = handles.params;
frame = handles.maxoffset.frame ;
sim=handles.sim;
instr='';
Rb = 1/params.SampleTime;

[snr, OSNR, mean_pwr, mean_noise_power] = get_snrt(in, Rb);

% Create plot
% plot(handles.axes_EVM_sym,  Y1);

handles.EVM_avg = handles.EVM_avg /handles.TotFrame ;
% plot(handles.axes_EVM_sym,  10*log10(handles.EVM_avg), 'r');
plot(handles.axes_EVM_sym,1:size(Y1,1), Y1,'b',1:size(Y1,1), 10*log10(handles.EVM_avg),'r')
xlim(handles.axes_EVM_sym,[0 length(Y1)]); 
ylim(handles.axes_EVM_sym,[ -23 -8]);
% Create xlabel
xlabel(handles.axes_EVM_sym,'subcarrier');
ylabel(handles.axes_EVM_sym,'EVM');
if ( size(Y3,1)==1)
    plot (handles.axes_EVM_sc,   1:length(Y2), Y3(1,1:length(Y2)));
else
plot (handles.axes_EVM_sc,   1:length(Y3), Y3(1,1:length(Y3)),   1:length(Y3), Y3(2,1:length(Y3)) );
end
    xlabel('symbol');
    ylim(handles.axes_EVM_sc,[-1.5 1.5]); 
 

% Create plot
if ( size(Y6,1)==1)
    plot(handles.axes_channel, 1:params.NFFT, abs(Y6),'g',  1:params.NFFT, real(Y6),'r',   1:params.NFFT, imag(Y6),'b'); 
else
    H11(1:size(Y6,3))=Y6(1,1,1:size(Y6,3));
   Y6 = H11;
    plot(handles.axes_channel, 1:params.NFFT, abs(Y6),'g',  1:params.NFFT, real(Y6),'r',   1:params.NFFT, imag(Y6),'b'); 
    ylim(handles.axes_channel, [-2 2]);
end

xlabel(handles.axes_channel,'Estimated channel')
hold off;
% xlim(axes3,[0 size(Y6,3)+2]); 


% Create plot
plot(handles.axes_const,real(Y4), imag(Y4),'b*',real(Y5), imag(Y5),'r*','MarkerSize', 2)

xlim(handles.axes_const,[-1.5 1.5]);
ylim(handles.axes_const,[-1.5 1.5]); 

% hist(handles.err_num, mod(frame.diff_rtx, params.Nsd), params.Nsd)
hist(handles.err_num, mod(handles.list2, params.Nsd), params.Nsd)
xlabel(handles.err_num,'Subcarrier vs Number of error')
xlim(handles.err_num,[1 handles.params.Nsd]);

plot(handles.axes7,handles.Qlist)
xlabel(handles.axes7,'Frame vs Number of error ')

plot (handles.axes19,   Y2 );
 
