% clear all;
MHz=1e6;
GHz=1e9;
km=1e3;

%%
tdelay_CD=0;
NFFT =128;
NOFDE =2048;
CPratio =1/8;
subband=16;  
tone=10;
syncpoint=2;
Nbpsc=4;
SampleTime =1/21/GHz *(Nbpsc/4 );
cfotype=5;

precomp_en =0;  
FiberLength=720*km;
osnrin =22;
noedfanoise = 0; en_AWGN = 0 ; nolinewidth = 0; nonoise= 0; b2b=0;
%% Simulation environment setting

defaultStream = RandStream.getGlobalStream;
savedState = defaultStream.State; 

dirdlm = [ pwd '\'];
sdirdlm = [dirdlm 'Single\'];
logfile = [dirdlm '4QAMlog.txt'];
delete(logfile);
cd(dirdlm);

%% Simulation set
maxsim=20;
%% sim_mode=1
sim_mode =1 ;   
for jitter = [0.00:0.02:0.06] * params.SampleTime
figure1 =figure( 'FileName', ['BERvsFiberLength_112Gbps_50kHz_ISFAen_' num2str(Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
noedfanoise = 0; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=0;
extcon =1;X_coor=[0 150:150:900]; 
osnrin = snr2osnr( 20, 1/SampleTime) ;
en_OFDE = 1;

for NFFT=[ 32 64 128 256 512 1024] 
    run('../Run_files/run_BER_precomp.m')
%     plot_ber(2, sim, params,   X_coor , BER, Q , edfa, laser, log2(params.NFFT)-3, 1, 'WO OFDE ', 'N_F_F_T ', params.NFFT );
end
% ylim([1e-5 0.1])

annotation(figure1,'textbox',[0.23  0.75 0.2 0.07 ],'String',...
    { ['Jitter:' num2str(jitter/params.SampleTime), ' T_s', ' 112 Gbps SNR: 20 dB ', 'linewidth:' num2str(laser.linewidth/1e3)]}, ...
    'HorizontalAlignment','center','FitBoxToText','off')
end
legend('show') 
jitter=0;
%% BER as a function of FFT size 
sim_mode =1 ;   
figure1 =figure( 'FileName', ['BERvsFFTsize_448Gbps_50kHz_ISFAen_' num2str(Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
noedfanoise = 0; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=0;
extcon =1;X_coor=0; 
osnrin = snr2osnr( 22, 1/SampleTime) ;
en_OFDE = 1;
jidx=1;
for jitter = [0.06:0.02:0.06] *  SampleTime
    for NFFT=[ 32 64 128 256 512 1024] 
        run('../Run_files/run_BER_precomp.m')
        BER_NFFT(log2(NFFT)-4)=BER(1);
        Q_NFFT(log2(NFFT)-4)=Q(1);
    end
plot_ber(1, sim, params, [ 32 64 128 256 512 1024] , BER_NFFT, Q_NFFT, edfa, laser, jidx, 1, 'WO OFDE ', 'Jitter ', jitter/ params.SampleTime );
jidx=jidx+1;
end
annotation(figure1,'textbox',[0.23  0.75 0.2 0.07 ],'String',...
    { ['Jitter:' num2str(jitter/params.SampleTime), ' T_s', '448 Gbps SNR: 20 dB ', 'linewidth:' num2str(laser.linewidth/1e3)]}, ...
    'HorizontalAlignment','center','FitBoxToText','off')
legend('show') 
jitter=0;

%% Multi-stage FFT base NLC 

jitter=0;
maxsim= 5;
sim_mode = 3;
FiberLength = 900 *km;
figure1 =figure( 'FileName', ['BERvsLP_112Gbps_50kHz_ISFAen_' num2str(2^Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
X_coor = 18.45 + (0:1:4);
osnrin = snr2osnr( 24, 1/SampleTime) ;
for NFFT=[  32  64 128 256 512  1024] 
    run('../Run_files/run_BER_precomp.m')
    plot_ber(2, sim, params,   X_coor , BER, Q , edfa, laser, log2(params.NFFT)-3, 1, 'WO OFDE ', 'N_F_F_T ', params.NFFT );
end
annotation(figure1,'textbox',[0.23  0.75 0.2 0.07 ],'String',...
    { ['Jitter:' num2str(jitter/params.SampleTime), ' T_s', ' 112 Gbps SNR: 24 dB ', 'linewidth:' num2str(laser.linewidth/1e3)]}, ...
    'HorizontalAlignment','center','FitBoxToText','off')

%% BER as a function of FFT size 
maxsim=100;
sim_mode =1 ;   
figure1 =figure( 'FileName', ['BERvsFFTsize_112Gbps_900km_50kHz_ISFAen_' num2str(2^Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
noedfanoise = 0; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=0;
extcon =1;X_coor= 900; 
osnrin = snr2osnr( 22, 1/SampleTime) ;
en_OFDE = 1;
edfa_gain_list=18.45 + [ 4 3 2 2 1 0 ];
jidx=1;
for jitter = [0.00:0.02:0.06 ] * SampleTime
    for NFFT=[ 32 64 128 256 512 1024] 
        gain_dB = edfa_gain_list(log2(NFFT)-4);
        run('../Run_files/run_BER_precomp.m')
        BER_NFFT(log2(NFFT)-4)=BER(1);
        Q_NFFT(log2(NFFT)-4)=Q(1);
    end
    plot_ber(1, sim, params, [ 32 64 128 256 512 1024] , BER_NFFT, Q_NFFT, edfa, laser, jidx, 1, '', 'Jitter ', jitter/ params.SampleTime );
    jidx=jidx+1;
end
annotation(figure1,'textbox',[0.23  0.75 0.2 0.07 ],'String',...
    { ['Jitter: (\sigma/T_s)^2 ', '112 Gbps 900km SNR: 18 dB,  ', 'Combined linewidth:' num2str(2*laser.linewidth/1e3), ' kHz' ]}, ...
    'HorizontalAlignment','center','FitBoxToText','off')
legend('show') 
jitter=0;

%%
SampleTime = SampleTime/4;
maxsim=100;
sim_mode =1 ;   
figure1 =figure( 'FileName', ['BERvsFFTsize_448Gbps_300km_50kHz_ISFAen_' num2str(2^Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
noedfanoise = 1; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=0;
extcon =1;X_coor= 300; 
osnrin = snr2osnr( 18, 1/SampleTime) ;
en_OFDE = 1;
edfa_gain_list=18.45 + [ 4 3 2 2 1 0 ];
jidx=1;
for jitter = [0.00   0.02 ] * SampleTime
    for NFFT=[ 32 64 128 256 512 1024] 
        gain_dB = edfa_gain_list(log2(NFFT)-4);
        run('../Run_files/run_BER_precomp.m')
        BER_NFFT(log2(NFFT)-4)=BER(1);
        Q_NFFT(log2(NFFT)-4)=Q(1);
    end
    plot_ber(1, sim, params, [ 32 64 128 256 512 1024] , BER_NFFT, Q_NFFT, edfa, laser, jidx, 1, '', 'Jitter ', jitter/ params.SampleTime );
    jidx=jidx+1;
end
annotation(figure1,'textbox',[0.23  0.75 0.2 0.07 ],'String',...
    { ['Jitter: (\sigma/T_s)^2 ', ' T_s', '448 Gbps 300km SNR: 18 dB, No edfa noise ', 'Combined linewidth:' num2str(2*laser.linewidth/1e3), ' kHz' ]}, ...
    'HorizontalAlignment','center','FitBoxToText','off')
legend('show') 
jitter=0;