% clear all;

GHz=1e9;
km=1e3;

b2b = 0;
tdelay_CD=0;
Ts1=  5.3325e-012  ;%4.9603e-011 / 4/1.3158 * 1.134; 
Ts=Ts1; 
osnrin =22; 
FiberLength=800*km;
subband=2;    
nonoise=0;
nolinewidth=0;
noedfanoise = 0;
en_AWGN = 0 ;

tone=10; 
Nbpsc=4;
% SampleTime =1/26/GHz *(Nbpsc/4 );
NOFDE =1024;
NFFT=128; precomp_en =0; 
CPratio =1/8;
cfotype=7;
SampleTime =1/10/GHz ;
%%

defaultStream = RandStream.getDefaultStream;
savedState = defaultStream.State;
sim_mode =3;
sim_mode1 = 0;
maxsim=2;
dirdlm = [ pwd '\'];
sdirdlm = [dirdlm 'Single\'];
logfile = [dirdlm '16QAMlog.txt'];

% currentFolder = [ pwd, '\'] ;
% addpath( [ currentFolder  ] );
% system (['rm ', logfile]);
delete(logfile);syncpoint=2;


%%
if (sim_mode == 3 || sim_mode1 == 100 )
    sim_mode = 3 ;  
    osnrin =  22;
   
    figure1 = figure( 'FileName', ['BERvsTXEDFA_16QAM'  num2str(maxsim) 's.fig']);  hold on;    
    nolinewidth =0; nonoise= 0; b2b=0; en_AWGN =0; noedfanoise=0;  
    cfotype =5; 
    extcon =1;X_coor=14:2:26;
    FiberLength=600*km;
    run('../Run_files/run_BER_precomp.m')   
    legend('show')
end
%%
sim_mode = 1;
osnrin= 30;

nolinewidth =0; nonoise= 0; b2b=0; en_AWGN =1; noedfanoise=0;  
cfotype =5; 
extcon =1;X_coor=1200;
run('../Run_files/run_BER_precomp.m')   
