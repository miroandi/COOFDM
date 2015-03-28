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
CD_residual=1;
%% Simulation environment setting

defaultStream = RandStream.getGlobalStream;
% savedState = defaultStream.State; 

dirdlm = [ pwd '\'];
sdirdlm = [dirdlm 'Single\'];
logfile = [dirdlm '4QAMlog1.txt'];
delete(logfile);
cd(dirdlm);
%%
% save ( 'savedState.mat', 'savedState');
%%
load 'savedState.mat';
%% Simulation set
maxsim=100;
%% sim_mode=1
sim_mode =1 ;   

subband=128;  
figure1 =figure( 'FileName', ['BERvsFiberLength_112Gbps_' num2str(2^Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
noedfanoise = 0; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=0;
% noedfanoise = 1; en_AWGN = 0 ; nolinewidth = 1; nonoise= 1; b2b=0;
extcon =1;X_coor=[ 1500:300:2400]; 
osnrin = snr2osnr( 26, 1/SampleTime) ; 
precomp_en =0; en_OFDE =1;
% syncpoint=NFFT * CPratio /2;
run('../Run_files/run_BER_precomp.m')
precomp_en =1;
syncpoint=1;
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

extcon =1;X_coor=[ 150:150:1600]; 
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
maxsim=100;
%% sim_mode=1
% Fiber Length를 변화시키면서 필요한 OSNR을 구하기 위한 simulation.
% 
sim_mode =2 ;   
syncpoint=NFFT * CPratio /2;
subband=128;  
figure1 =figure( 'FileName', ['BERvsFiberLength_112Gbps_' num2str(2^Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
noedfanoise = 1; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=0;
extcon =1;X_coor=[30:-2:14]; 
osnrin = snr2osnr( 28, 1/SampleTime) ; 
X_coor=[14.6:0.2:15.8];
precomp_en =0; en_OFDE =1;    
for FiberLength=[150 300:150:1100]  * km
    
    run('../Run_files/run_BER_precomp.m')    
end
FiberLength= 1500 * km ;  X_coor=[15.2:0.2:17];run('../Run_files/run_BER_precomp.m')  


precomp_en =1;  X_coor=[14.4:0.2:16.8];
for FiberLength=[150 300:150:900]  * km     
    run('../Run_files/run_BER_precomp.m')   
    X_coor = X_coor + 0.3;
end
FiberLength= 150 * km ;  X_coor=[14.6:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[14.8:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[15.0:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 600 * km ;  X_coor=[15.2:0.2:20]; run('../Run_files/run_BER_precomp.m')
FiberLength= 750 * km ;  X_coor=[15.5:0.2:20]; run('../Run_files/run_BER_precomp.m')
FiberLength= 900 * km ;  X_coor=[15.7:0.2:20]; run('../Run_files/run_BER_precomp.m') 
FiberLength= 1050 * km ;  X_coor=[16.0:0.2:17];run('../Run_files/run_BER_precomp.m');  
FiberLength= 1200 * km ;  X_coor=[16.4:0.2:17.4]; run('../Run_files/run_BER_precomp.m');
FiberLength= 1350 * km ;  X_coor=[16.8:0.2:17.6]; run('../Run_files/run_BER_precomp.m');
FiberLength= 1500 * km ;  X_coor=[17.2:0.2:18]; run('../Run_files/run_BER_precomp.m');
FiberLength= 1650 * km ;  X_coor=[17.6:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1800 * km ;  X_coor=[18.0:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1950 * km ;  X_coor=[18.6:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 2100 * km ;  X_coor=[19.8:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
% FiberLength= 2250 * km ;  X_coor=[20.2:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
% FiberLength= 2400 * km ;  X_coor=[18.8:0.2:25.2]; run('../Run_files/run_BER_precomp.m')

%% Pulse shaped  (Raised cosine) precomp_en

FiberLength= 150 * km ;  X_coor=[14.2:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[14.2:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[14.6:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 600 * km ;  X_coor=[14.8:0.2:20]; run('../Run_files/run_BER_precomp.m')
FiberLength= 750 * km ;  X_coor=[14.8:0.2:20]; run('../Run_files/run_BER_precomp.m')
FiberLength= 900 * km ;  X_coor=[15.0:0.2:20]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1050 * km ;  X_coor=[15.0:0.2:22]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1200 * km ;  X_coor=[15.2:0.2:24]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1350 * km ;  X_coor=[15.6:0.2:24]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1500 * km ;  X_coor=[15.8:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1650 * km ;  X_coor=[16.2:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1800 * km ;  X_coor=[16.4:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1950 * km ;  X_coor=[16.8:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 2100 * km ;  X_coor=[17.0:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 2250 * km ;  X_coor=[17.2:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 2400 * km ;  X_coor=[17.8:0.2:25.2]; run('../Run_files/run_BER_precomp.m')

%% rectangular window  precomp_en 0

FiberLength= 1200 * km ;  X_coor=[14.8:0.2:24]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1350 * km ;  X_coor=[14.8:0.2:24]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1500 * km ;  X_coor=[14.8:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1650 * km ;  X_coor=[15.2:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1800 * km ;  X_coor=[15.4:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1950 * km ;  X_coor=[15.8:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 2100 * km ;  X_coor=[16.0:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
FiberLength= 2175 * km ;  X_coor=[19.0:0.2:25.2]; run('../Run_files/run_BER_precomp.m')


%% Pulse shaping of precomp_en
precomp_en =1; 
X_coor=[14.6:0.2:18.8]; 
for FiberLength=[150:150:2400]  * km    
    run('../Run_files/run_BER_precomp.m')    
end
% FiberLength= 1500 * km ;  X_coor=[15.2:0.2:17];
% run('../Run_files/run_BER_precomp.m') 
% FiberLength= 1500 * km ;  X_coor=[15.2:0.2:17];
% run('../Run_files/run_BER_precomp.m')  

%%
 
extcon =1;
precomp_en =0; en_OFDE =0;
FiberLength= 75 * km ;  X_coor=[14.6:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 150 * km ;  X_coor=[14.8:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 225 * km ;  X_coor=[16.8:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 255 * km ;  X_coor=[23.0:0.4:25]; run('../Run_files/run_BER_precomp.m')
 
%%
 
FiberLength= 150 * km ;  X_coor=[17:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[17.2:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[17.8:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 600 * km ;  X_coor=[18:0.2:20]; run('../Run_files/run_BER_precomp.m')
FiberLength= 750 * km ;  X_coor=[18.4:0.2:20]; run('../Run_files/run_BER_precomp.m')
FiberLength= 900 * km ;  X_coor=[18.8:0.2:20]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1050 * km ;  X_coor=[20.6:0.2:22]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1200 * km ;  X_coor=[21.2:0.2:24]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1350 * km ;  X_coor=[23.4:0.2:24]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1500 * km ;  X_coor=[24.2:0.2:25.2]; run('../Run_files/run_BER_precomp.m')
%%
 
plot(X_coor, 3.8e-3 * ones(size(X_coor)), 'r-' )
annotation(figure1,'textbox',[0.23  0.75 0.2 0.07 ],'String',...
    { [' 112 Gbps SNR: 28 dB ', 'Combined linewidth:' num2str(2* laser.linewidth/1e3), ' kHz']}, ...
    'HorizontalAlignment','center','FitBoxToText','off')
 
legend('show') 
 
cd(dirdlm);


%%  생성된 file로부터 읽어 graph 그리기 
figure1 =figure( 'FileName', ['OSNRvsFiberLength_112Gbps_' num2str(2^Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
sim.mode=1;
sim.laser =laser;
sim.OSNR_offset = 14.59 ;
spanidx=[1 2 3   3.4];sim.precomp_en =0; sim.en_OFDE =0;
plot_osnr_penalty( 'Precomp0_Rect/matlab_sb0_16QAM_0prec_5cfo_2mode_', spanidx, sim, params  )

spanidx=[1 2:2:14];sim.precomp_en =1; sim.en_OFDE =0;
plot_osnr_penalty( 'Precomp1_NoPhaseComp/matlab_sb128_16QAM_1prec_0ISFA_1RCD_2mode_', spanidx, sim, params  )


spanidx=[4:2:28 29];sim.precomp_en =0; sim.en_OFDE =1;
plot_osnr_penalty( 'RGI_CO_OFDM_Rect/matlab_sb0_16QAM_0prec_5cfo_2mode_', spanidx, sim, params  )

spanidx=[ 2:2:28 29];sim.precomp_en =0; sim.en_OFDE =1;
plot_osnr_penalty( 'Precomp0_RC/matlab_sb0_16QAM_0prec_5cfo_2mode_', spanidx, sim, params  )


spanidx=[1 2:2:28];
sim.precomp_en =1; sim.en_OFDE =0;
plot_osnr_penalty( 'Precomp_Rect/matlab_sb128_16QAM_1prec_5cfo_2mode_', spanidx, sim, params  )


spanidx=[2:2:32];sim.precomp_en =1; sim.en_OFDE =0;
plot_osnr_penalty( 'Precomp_PhaseComp_PulseShape/matlab_sb128_16QAM_1prec_5cfo_2mode_', spanidx, sim, params  )
 
ylim([-1 12] )
ylabel('OSNR penalty (dB)');
box on;
grid on;
legend show;

%% OFDE를 수행하지 않았을 때, 성능확인할 것.
% extcon =1;X_coor=[ 75:75:300]; 
% precomp_en =0; en_OFDE =0;
% run('../Run_files/run_BER_precomp.m')

%% OFDE를 사용하지 않고 FFT 를 키웠을 때, 
extcon =1;X_coor=[ 75:75:1600]; 
precomp_en =0; en_OFDE =0; NFFT=512;
syncpoint=NFFT * CPratio /2;
run('../Run_files/run_BER_precomp.m')

%% phase compensation을 하지 않았을 때 성능확인할 것. 
% sim.nophase 
extcon =1;X_coor=[ 150:150:1600]; 
precomp_en =1; NFFT=128;
syncpoint=NFFT * CPratio /2;
 precomp_en =1;  X_coor=[16.8:0.2:18.2];
 for FiberLength=[150 300:150:900]  * km     
    run('../Run_files/run_BER_precomp.m')   
    X_coor = X_coor + 0.4;
 end
FiberLength = FiberLength + 150 *km;
X_coor = X_coor + 0.8;
FiberLength = FiberLength + 150 *km;
X_coor = X_coor + 0.8;
FiberLength = FiberLength + 150 *km;
X_coor = X_coor + 0.4;
FiberLength = FiberLength + 150 *km;
X_coor = X_coor + 0.4;

%% 
figure1 =figure( 'FileName', ['SubbandvsFiberLength_112Gbps_' num2str(2^Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
noedfanoise = 1; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=0;
sim_mode = 2 ;   
syncpoint=NFFT * CPratio /2;
precomp_en =1; en_OFDE =0; 
extcon =1;  X_coor=[14 :2:30]; 
 
for subband = 2 .^[1:7]
    for FiberLength = [2:2:20] * km * 75
        run('../Run_files/run_BER_precomp.m');
        if (BER(SNRsim) > 0.7e-2  )
            break;
        end
    end
end
%% Raised cosine window 
subband=2;
FiberLength= 150 * km ;  X_coor=[14.2:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[14.8:0.2:19]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[15.6:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 525 * km ;  X_coor=[17.6:0.2:28]; run('../Run_files/run_BER_precomp.m') 
 
subband=4;
FiberLength= 150 * km ;  X_coor=[14.4:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[14.4:0.2:19]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[14.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 600 * km ;  X_coor=[15.6:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 750 * km ;  X_coor=[16.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 900 * km ;  X_coor=[18.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 975 * km ;  X_coor=[19.0:0.2:28]; run('../Run_files/run_BER_precomp.m')

%%
subband=8;
FiberLength= 150 * km ;  X_coor=[14.4:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[14.4:0.2:19]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[14.6:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 600 * km ;  X_coor=[14.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 750 * km ;  X_coor=[15.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 900 * km ;  X_coor=[15.2:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1050 * km ;  X_coor=[15.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1200 * km ;  X_coor=[16.2:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1350 * km ;  X_coor=[16.7:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1500 * km ;  X_coor=[17.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1650 * km ;  X_coor=[18.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1800 * km ;  X_coor=[21.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1875 * km ;  X_coor=[23.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
%%
subband=16;
FiberLength= 1350 * km ;  X_coor=[15.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1500 * km ;  X_coor=[16.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1650 * km ;  X_coor=[16.5:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1800 * km ;  X_coor=[16.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1950 * km ;  X_coor=[17.2:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 2100 * km ;  X_coor=[17.4:0.2:28]; run('../Run_files/run_BER_precomp.m')

FiberLength= 150 * km ;  X_coor=[14.6:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[14.6:0.2:19]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[15.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 600 * km ;  X_coor=[15.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 750 * km ;  X_coor=[15.6:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 900 * km ;  X_coor=[15.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1050 * km ;  X_coor=[16.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1200 * km ;  X_coor=[16.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1350 * km ;  X_coor=[17.2:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1500 * km ;  X_coor=[17.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
% subband=128;
% FiberLength= 750 * km ;  X_coor=[15.8:0.2:30]; run('../Run_files/run_BER_precomp.m')
% FiberLength= 900 * km ;  X_coor=[15.8:0.2:30]; run('../Run_files/run_BER_precomp.m')
% FiberLength= 1050 * km ;  X_coor=[16.2:0.2:17];run('../Run_files/run_BER_precomp.m');  
% FiberLength= 1200 * km ;  X_coor=[16.4:0.2:17.4];run('../Run_files/run_BER_precomp.m');
% FiberLength= 1350 * km ;  X_coor=[17:0.2:17.6];run('../Run_files/run_BER_precomp.m');
% FiberLength= 1500 * km ;  X_coor=[17.2:0.2:18];run('../Run_files/run_BER_precomp.m');

%% Rectangular window 
subband=2;
FiberLength= 150 * km ;  X_coor=[14.6:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[14.8:0.2:19]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[15.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 600 * km ;  X_coor=[16.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 750 * km ;  X_coor=[20.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
 
subband=4;
FiberLength= 150 * km ;  X_coor=[14.6:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[14.6:0.2:19]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[15.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 600 * km ;  X_coor=[15.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 750 * km ;  X_coor=[16.2:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 900 * km ;  X_coor=[17.2:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1050 * km ;  X_coor=[19.6:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1125 * km ;  X_coor=[22.2:0.2:23.8]; run('../Run_files/run_BER_precomp.m')
subband=8;
FiberLength= 150 * km ;  X_coor=[14.6:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[14.6:0.2:19]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[14.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 600 * km ;  X_coor=[14.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 750 * km ;  X_coor=[15.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 900 * km ;  X_coor=[15.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1050 * km ;  X_coor=[16.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1200 * km ;  X_coor=[16.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1350 * km ;  X_coor=[17.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1500 * km ;  X_coor=[19.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
subband=16; 
FiberLength= 1350 * km ;  X_coor=[15.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1500 * km ;  X_coor=[16.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1650 * km ;  X_coor=[16.5:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1800 * km ;  X_coor=[16.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1950 * km ;  X_coor=[17.2:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 2100 * km ;  X_coor=[17.7:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 2250 * km ;  X_coor=[18.6:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 2400 * km ;  X_coor=[19.2:0.2:28]; run('../Run_files/run_BER_precomp.m')
 
subband=32;
FiberLength= 150 * km ;  X_coor=[14.6:0.2:18]; run('../Run_files/run_BER_precomp.m')
FiberLength= 300 * km ;  X_coor=[14.6:0.2:19]; run('../Run_files/run_BER_precomp.m')
FiberLength= 450 * km ;  X_coor=[15.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 600 * km ;  X_coor=[15.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 750 * km ;  X_coor=[15.6:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 900 * km ;  X_coor=[15.8:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1050 * km ;  X_coor=[16.0:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1200 * km ;  X_coor=[16.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1350 * km ;  X_coor=[17.2:0.2:28]; run('../Run_files/run_BER_precomp.m')
FiberLength= 1500 * km ;  X_coor=[17.4:0.2:28]; run('../Run_files/run_BER_precomp.m')
% subband=128;
% FiberLength= 750 * km ;  X_coor=[15.8:0.2:30]; run('../Run_files/run_BER_precomp.m')
% FiberLength= 900 * km ;  X_coor=[15.8:0.2:30]; run('../Run_files/run_BER_precomp.m')
% FiberLength= 1050 * km ;  X_coor=[16.2:0.2:17];run('../Run_files/run_BER_precomp.m');  
% FiberLength= 1200 * km ;  X_coor=[16.4:0.2:17.4];run('../Run_files/run_BER_precomp.m');
% FiberLength= 1350 * km ;  X_coor=[17:0.2:17.6];run('../Run_files/run_BER_precomp.m');
% FiberLength= 1500 * km ;  X_coor=[17.2:0.2:18];run('../Run_files/run_BER_precomp.m');
%%
figure1 =figure( 'FileName', ['SubbandvsFiberLength_112Gbps_' num2str(2^Nbpsc) 'QAM_'  num2str(maxsim) 's.fig']);  hold on;    
  
subband =16;   spanidx =[18:2:32];
stack = cell( 128,1);
stack{2}.spanidx = [2:2:6 7];
stack{4}.spanidx = [2:2:12 13];
stack{8}.spanidx = [2:2:24 25];
stack{16}.spanidx = [18:2:32];
for subband=[2 4 8 16]
    plot_osnr_penalty( ['Subbands_RC/matlab_sb', num2str(subband), '_16QAM_1prec_5cfo_2mode_'], stack{subband}.spanidx, sim, params  )
end
    

spanidx=[2:2:32];sim.precomp_en =1; sim.en_OFDE =0;
plot_osnr_penalty( 'Precomp_PhaseComp_PulseShape/matlab_sb128_16QAM_1prec_5cfo_2mode_', spanidx, sim, params  )
 

ylim([-1 12] )
ylabel('OSNR penalty (dB)');
box on;
grid on;
legend show;
%%

