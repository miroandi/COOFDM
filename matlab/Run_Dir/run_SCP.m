% clear all;
MHz=1e6;
GHz=1e9;
km=1e3;

%%
tdelay_CD=0;
NFFT =128;
NOFDE =256;

subband=16;  
tone=10;

Nbpsc=4;
SampleTime =1/26/GHz *(Nbpsc/4 );CPratio =1/8;
% SampleTime =1/24.5/GHz *(Nbpsc/4 );CPratio =1/16; % Nominal Datarate
% SampleTime =1/23.7/GHz *(Nbpsc/4 );CPratio =1/32; % Nominal Datarate
% SampleTime =1/21/GHz *(Nbpsc/4 );CPratio =1/8;
% SampleTime =1/19.8/GHz *(Nbpsc/4 );CPratio =1/16; % Nominal Datarate
% SampleTime =1/19.14/GHz *(Nbpsc/4 );CPratio =1/32; % Nominal Datarate
syncpoint=NFFT * CPratio /2  ;
cfotype=5;

precomp_en =0;  
FiberLength=720*km;
osnrin =22;
noedfanoise = 0; en_AWGN = 0 ; nolinewidth = 0; nonoise= 0; b2b=0;
jitter =0; 
%% Simulation environment setting

defaultStream = RandStream.getGlobalStream;
savedState = defaultStream.State; 

dirdlm = [ pwd '\'];
sdirdlm = [dirdlm 'Single\'];
logfile = [dirdlm '4QAMlog.txt'];
delete(logfile);
cd(dirdlm);

%% Simulation set
maxsim=100;
%% sim_mode=1
sim_mode =1 ;   
syncpoint=NFFT * CPratio /2;
subband=128;  
figure1 =figure( 'FileName', ['BERvsFiberLength_112Gbps_' num2str(2^Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
noedfanoise = 0; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=0;
% noedfanoise = 1; en_AWGN = 0 ; nolinewidth = 1; nonoise= 1; b2b=0;
extcon =1;X_coor=[ 75:75:1600]; 
osnrin = snr2osnr( 28, 1/SampleTime) ; 
precomp_en =0; en_OFDE =1;
% run('../Run_files/run_BER_precomp.m')
precomp_en =1;
% run('../Run_files/run_BER_precomp.m')

% ylim([1e-5 0.1])
plot(X_coor, 3.8e-3 * ones(size(X_coor)), 'r-' )
annotation(figure1,'textbox',[0.23  0.75 0.2 0.07 ],'String',...
    { [' 112 Gbps SNR: 28 dB ', 'Combined linewidth:' num2str(2* laser.linewidth/1e3), ' kHz']}, ...
    'HorizontalAlignment','center','FitBoxToText','off')
 
legend('show') 
 
cd(dirdlm);
%% OFDE를 수행하지 않았을 때, 성능확인할 것.
extcon =1;X_coor=[ 75:75:300]; 
precomp_en =0; en_OFDE =0;
run('../Run_files/run_BER_precomp.m')

%% OFDE를 사용하지 않고 FFT 를 키웠을 때, 
extcon =1;X_coor=[ 75:75:1600]; 
precomp_en =0; en_OFDE =0; NFFT=512;
syncpoint=NFFT * CPratio /2;
run('../Run_files/run_BER_precomp.m')

%% phase compensation을 하지 않았을 때 성능확인할 것. 
% sim.nophase 
extcon =1;X_coor=[ 75 150:150:1800]; 
precomp_en =1; NFFT=128;
syncpoint=NFFT * CPratio /2;
run('../Run_files/run_BER_precomp.m')

%%  Square root raised cosine 사용했을 때 

% extcon =1;X_coor=[ 75 150:150:1800]; 
% precomp_en =1;
% run('../Run_files/run_BER_precomp.m')

%% Residual CD에 의한 성능 열화. 
figure1 =figure( 'FileName', ['ResidualCD_BERvsLength_112Gbps_' num2str(2^Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    

extcon =1;X_coor=[  150:150:1800]; 
precomp_en =1; NFFT=128;
syncpoint=NFFT * CPratio /2;
for CD_residual=0.85:0.05:1.15
run('../Run_files/run_BER_precomp.m')
end

%%
