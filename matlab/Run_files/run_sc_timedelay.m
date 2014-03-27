
of=0.15;

figure;hold on;
% NFFT=128;
% [NFFT-7:4:NFFT 1:4:8] %
for ii= params.SubcarrierIndex %[NFFT/2+1:4:NFFT  1:4:NFFT/2] %params.SubcarrierIndex
    sim.tone=ii;
    tone = ii;
run_BER_precomp;
%  of=of+0.6; plot(real(ofdmout(1,1:1000))+of,'Display',[num2str(sim.tone)])
 of=of+0.05;
 plot(real(noisyreceivein(1,1000:3000))+of,'b','Display',[num2str(sim.tone)])
 
sim.tone=sim.tone+1;
end 

% Q

%%
% 
% for zerohead=0:2:512
%     
% run_BER_precomp;
% Q_list(zerohead+1)= Q;
% end
%% 
% % sim.tone=1;
% of=0;
% 
% figure;hold on;
% for ii=1:7
% run_BER_precomp;
%  of=of+0.03; plot(real(sum(preambleout(1:128,:),1))+of,'Display',[num2str(sim.tone)])
%  
% tone = ii;
% end

% 
% %%
% ii=0;
% for phs=0:0.01:0.5
%     ii=ii+1;
%     sim.phase(25:29) = phs*(24:28)/24;
%     bb(ii)=bit_err(SNRsim);
%     qq(ii)=Q(SNRsim);
%     run_BER_precomp;
% end