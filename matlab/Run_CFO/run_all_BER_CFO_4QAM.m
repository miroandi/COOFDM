% clear all;
MHz=1e6;
GHz=1e9;
km=1e3;

b2b = 0;
tdelay_CD=0;
Ts1= 4.9603e-011 / 4/1.3158; 
Ts=Ts1;
NFFT =128;
osnrin =22;
precomp_en =0;  
FiberLength=720*km;
subband=16;   
noedfanoise = 0;
nonoise=0;
nolinewidth=0;
noedfanoise = 0;
en_AWGN = 0 ;

tone=10;
syncpoint=2;
Nbpsc=4;
SampleTime =1/26/GHz *(Nbpsc/4 );
NOFDE =1024;
NFFT=128; precomp_en =0;  CPratio =1/8;
jitter =0;
en_OFDE=0;
%%
defaultStream = RandStream.getDefaultStream;
% defaultStream = RandStream.getGlobalStream;
savedState = defaultStream.State;
sim_mode =4;
sim_mode1 = 0 ;
maxsim=50;
dirdlm = [ pwd '\'];;
sdirdlm = [dirdlm 'Single\'];
logfile = [dirdlm '4QAMlog.txt'];
delete(logfile);
cd(dirdlm);

%% sim_mode=1
if (sim_mode == 1 || sim_mode1 == 100 ) 
    sim_mode =1 ;   
    figure( 'FileName', ['MSEEvsFiberLength_4QAM'  num2str(maxsim) 's.fig']);  hold on;    
%     noedfanoise = 0; en_AWGN = 0; nolinewidth = 0; nonoise= 0; b2b=0;
%     noedfanoise = 1; en_AWGN = 1 ; nolinewidth = 1; nonoise= 0; b2b=0;
    noedfanoise = 0; en_AWGN = 0 ; nolinewidth = 0; nonoise= 0; b2b=0;
    extcon =1;X_coor=160:160:1000; 
    osnrin = snr2osnr( 22, 1/SampleTime) ;
    for cfotype= [  2, 4, 5, 7 ]%, 4, 5, 7, 9 ]
        run('../Run_files/run_BER_precomp.m')
    end
    
    legend('show')
    ylim([ 1e-6 1 ])
    extcon =0;
    
end

%% sim_mode= 2
if (sim_mode == 4 || sim_mode1 == 100 )
    sim_mode = 2;  
    noedfanoise = 1; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=1;
    extcon =1;X_coor=14:2:20; %X_coor =X_coor -0.2;
    figure( 'FileName', ['MSEEvsSNR_16QAM_OB2B'  num2str(maxsim) 's_100kHz.fig']);  hold on; 
    
    
    
    for cfotype=[ 2,4 ,5, 7, 8] %2, 4,  5, 7]
        run('../Run_files/run_BER_precomp.m')
    end
    
    
    noedfanoise = 1; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=1;  
    
    for cfotype=[  2 ,5,4,7, 8] %2, 4,  5, 7]
        run('../Run_files/run_BER_precomp.m')
    end
    
    
%     cfo_phase : one sample´ç phase error (¥Õsample)
%     ¥Õsample* NFFT/ (2 ¥ð)
%     SNR = 10.^(X_coor/10);
%     CRB =1/1/pi/pi/(72)./SNR;
%     plot(X_coor,CRB(1:length(X_coor)), 'k-','Display', 'CRB');
%     CRB =1/1/pi/pi/(144)./SNR;
%     CRB_sample = CRB/144/144/4;
% CRB_sample = CRB  /(144*2)^2
%     plot(X_coor,CRB_sample(1:length(X_coor)), 'k-','Display', 'CRB');

    legend('show')
%     noedfanoise = 0; en_AWGN = 0; nolinewidth = 0; nonoise= 0; b2b=0;
    ylabel(['MSEE( \phi_s_a_m_p_l_e ]']);
    xlabel('OSNR');
    cd ..\Run_CFO;
end
%%

if (sim_mode == 6 || sim_mode1 == 100 )
    sim_mode = 6; 
    MaxVal=1/SampleTime/2 /MHz;
    InitVal=-MaxVal;
    extcon =1;  X_coor =InitVal:4*(MaxVal-InitVal)/2/144 :(MaxVal -1);
    
    
    noedfanoise = 1; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=1;
    figure2=figure( 'FileName', ['MSEEvsCFO_4QAM_OB2B_20GHz_'  num2str(maxsim) 's.fig']);  hold on; 
    figure1=figure( 'FileName', ['BERvsCFO_4QAM_OB2B_20GHz_'  num2str(maxsim) 's.fig']);  hold on; 
    
     
    for cfotype=[ 2,  4, 5 ]
        run('../Run_files/run_BER_precomp.m')
    end
    
    MaxVal=5*MaxVal/128;
    InitVal=-5*MaxVal/128;
    extcon =1;  X_coor =InitVal:(MaxVal-InitVal)/8 :MaxVal;
     for cfotype=[ 7]
        run('../Run_files/run_BER_precomp.m')
     end
    
    legend('show')
    cd ..\Run_CFO;
end

%%

    sim_mode = 2;  
    noedfanoise = 1; en_AWGN = 1 ; nolinewidth = 0; nonoise= 0; b2b=1;
    extcon =1;X_coor=12:4:24; %X_coor =X_coor -0.2;
    figure( 'FileName', ['MSEEvsSNR_16QAM_OB2B'  num2str(maxsim) 's_100kHz.fig']);  hold on; 
    cfotype =8; 
    run('../Run_files/run_BER_precomp.m') ; % SISO 
    run('../Run_files/run_BER_precomp.m') ; % MIMO emul
    run('../Run_files/run_BER_precomp.m') ; % MIMO LTF [ 1 1 1 -1] 
    run('../Run_files/run_BER_precomp.m') ; % MIMO LTF [ 10 0 1 ]

