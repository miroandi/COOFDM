
of=0.15;
tone_sav = tone;
figure;hold on;
% NFFT=128;
 
% for ii= params.SubcarrierIndex  
% for ii= [NFFT/2+1:4:NFFT  1:4:NFFT/2]  
for ii= [1:5] 
    sim.tone=ii;
    tone = ii;
run_BER_precomp;
%  of=of+1.0; plot(real(ofdmout(1,1000:3000))+of,'Display',[num2str(sim.tone)])
 of=of+0.25; plot(real(noisyreceivein(1,1000:3000))+of,'b','Display',[num2str(sim.tone)])
 
sim.tone=sim.tone+1;
end 
plot([1000 1000], [0 of], 'r-' )
% Q
tone =  tone_sav;
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