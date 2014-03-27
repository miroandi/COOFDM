function createfigure2( handles)
Y1 = handles.maxoffset.EVM_dB_sc;
Y2 = handles.maxoffset.EVM_dB_sym;
Y3 = handles.maxoffset.commonphase;
Y4 = handles.maxoffset.fftout(1,:);
Y5 = handles.maxoffset.idealout(1,:);
if ( handles.params.Nstream == 2 )
    Y6 = zeros(size(handles.maxoffset.H));
    for ii=1:(length(handles.params.LTFindex))
        idx=handles.params.LTFindex(ii);

        Y6(:,:,handles.params.LTFindex(ii)) = inv(handles.maxoffset.H(:,:,handles.params.LTFindex(ii)));

    end
else
    Y6 = 1./ handles.maxoffset.H ;
end
% Y6 = 1./ handles.maxoffset.H ;
in = handles.maxoffset.noisyreceivein(1,:);
params = handles.params;
frame = handles.maxoffset.frame ;
sim=handles.sim;
instr='';
Rb = 1/params.SampleTime;


plot(handles.axes_EVM_sc1,1:size(Y1,1), Y1(:,1),'b' );
xlim(handles.axes_EVM_sc1,[0 length(Y1)]); 
ylim(handles.axes_EVM_sc1,[ -23 -13]);
xlabel(handles.axes_EVM_sc1,'subcarrier (X pol)','fontsize',8);
ylabel(handles.axes_EVM_sc1,'EVM','fontsize',8);

if ( handles.params.Nstream == 2 )
    plot(handles.axes_EVM_sc2,1:size(Y1,1), Y1(:,2),'b')
    xlim(handles.axes_EVM_sc2,[0 length(Y1)]); 
    ylim(handles.axes_EVM_sc2,[ -23 -13]);
    xlabel(handles.axes_EVM_sc2,'subcarrier(Y pol)','fontsize',8);
%     ylabel(handles.axes_EVM_sc2,'EVM','fontsize',8);
    
    plot (handles.axes_EVM_sc,   1:length(Y3), Y3(1,1:length(Y3)),'b', 1:length(Y3), Y3(2,1:length(Y3)),'r' );
    xlabel(handles.axes_EVM_sc,'CPE vs Symbol','fontsize',8)
    ylim(handles.axes_EVM_sc,[-pi pi]);
%     ylim(handles.axes_EVM_sc,[-1.0 1.0]);
else
    plot (handles.axes_EVM_sc,   1:length(Y3), Y3(1,1:length(Y3)));
    xlabel(handles.axes_EVM_sc,'CPE vs Symbol','fontsize',8)
    ylim(handles.axes_EVM_sc,[-1.0 1.0]);
end 


Z4 = handles.maxoffset.fftout(1,:);
Z5 = handles.maxoffset.idealout(1,:);
plot(handles.axes_const1,real(Z4), imag(Z4),'b*',real(Z5), imag(Z5),'r*','MarkerSize', 2)
xlim(handles.axes_const1,[-1.5 1.5]);
ylim(handles.axes_const1,[-1.5 1.5]); 
xlabel(handles.axes_const1, 'X pol','fontsize',8)

if ( handles.params.Nstream == 2 )
    Z4 = handles.maxoffset.fftout(2,:);
    Z5 = handles.maxoffset.idealout(2,:);
    plot(handles.axes_const2,real(Z4), imag(Z4),'b*',real(Z5), imag(Z5),'r*','MarkerSize', 2)
    xlim(handles.axes_const2,[-1.5 1.5]);
    ylim(handles.axes_const2,[-1.5 1.5]); 
    xlabel(handles.axes_const2,'Y pol','fontsize',8)
end
% Create plot

if ( handles.sim.fixed_sim == 1)
    LIM= 1024;
else
    LIM =1.5;
end
if ( handles.params.Nstream == 2 )
H11(1:size(Y6,3))=Y6(1,1,1:size(Y6,3));   
plot(handles.axes_H11, 1:params.NFFT, abs(H11),'g',  1:params.NFFT, real(H11),'r',   1:params.NFFT, imag(H11),'b'); 
ylim(handles.axes_H11, [-LIM LIM]);
H12(1:size(Y6,3))=Y6(1,2,1:size(Y6,3));   
plot(handles.axes_H12, 1:params.NFFT, abs(H12),'g',  1:params.NFFT, real(H12),'r',   1:params.NFFT, imag(H12),'b'); 
ylim(handles.axes_H12, [-LIM LIM]);
H21(1:size(Y6,3))=Y6(2,1,1:size(Y6,3));   
plot(handles.axes_H21, 1:params.NFFT, abs(H21),'g',  1:params.NFFT, real(H21),'r',   1:params.NFFT, imag(H21),'b'); 
ylim(handles.axes_H21, [-LIM LIM]);
H22(1:size(Y6,3))=Y6(2,2,1:size(Y6,3));   
plot(handles.axes_H22, 1:params.NFFT, abs(H22),'g',  1:params.NFFT, real(H22),'r',   1:params.NFFT, imag(H22),'b'); 
ylim(handles.axes_H22, [-LIM LIM]);
xlabel(handles.axes_H11,'Channel H11','fontsize',8);
xlabel(handles.axes_H12,'Channel H12','fontsize',8);
xlabel(handles.axes_H21,'Channel H21','fontsize',8);
xlabel(handles.axes_H22,'Channel H22','fontsize',8);
else
    plot(handles.axes_H11, 1:params.NFFT, abs(Y6),'g',  1:params.NFFT, real(Y6),'r',   1:params.NFFT, imag(Y6),'b'); 
end

hist(handles.err_num, mod(handles.list2, params.Nsd), params.Nsd)
xlabel(handles.err_num,'Subcarrier vs Acc. error(X)','fontsize',8)
xlim(handles.err_num,[1 handles.params.Nsd]);

hist(handles.err_num2, mod(handles.list3, params.Nsd), params.Nsd)
xlabel(handles.err_num2,'Subcarrier vs Acc. error(Y)','fontsize',8)
xlim(handles.err_num2,[1 handles.params.Nsd]);

plot(handles.axes7,handles.Qlist)
xlabel(handles.axes7,'Frame vs # of errors ')

plot (handles.axes19,   Y2 );
xlabel(handles.axes19,'EVM vs symbol','fontsize',8);
