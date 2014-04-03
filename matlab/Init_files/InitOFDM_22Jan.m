function [sim, params, MZmod,fiber,laser, lolaser, txedfa, edfa, rxedfa, PD]=  InitOFDM_11Sept( NFFT, ovsampling, sampletime )
%%  Clear

% clc; clear all; close all;
Nbpsc =4;
% NFFT =128;
noedfanoise = 0 ;
NUM =  300;%320*128/NFFT -2 ;
% NUM =   320*128/NFFT -2 ;
phi =  0*54 * 64/(64^2) ;
CD  = 17;
TXLP  =  1e-3; 
RXLP  = 1e-3;
%%  Define constants, unit 
fs = 10^-15 ;
ps = 10^-12;
nm = 10^-9 ;
THz = 10 ^ 12 ;
MHz = 1e6;
GHz = 1e9;
kHz = 1e3;
km = 10^3;
mW = 1e-3;
um = 1e-6;
W = 1;
mV =1e-3;
ppm = 1e-6;
c = 2.99e8;  % Speed of light 
h =6.6e-34;  % Plank constant, J.s
Z0 = 377 ;                                       % ohm

j=sqrt(-1);

%% Simulation
sim.MAXSIM = 1 ; % Number of simulation 
sim.backtoback = 0; % Direct connection between transmitter and receiver
sim.oversample =2; 
sim.nonoise = 0 ; % Remove additive gaussion noise  
sim.useolddata = 0;
sim.usefilter = 0;
sim.SNR = 25 ;
sim.initcpe= 0;


sim.txfreqoff =  0*5*ppm; % -5 *ppm; % Sampling clock frequency offset.
sim.txtimeoff = 0* 0.5  ; % Sampling clock timing offset due to sampling clock freq offset.
sim.enSCFOcomp = 0 ; % Coarse Carrier frequency offset estimation ( using Short preamble)
sim.enCFOcomp = 0 ; % Fine Carrier frequency offset using LTF
sim.enSFOcomp = 0;  % Sampling frequency offset
sim.enCPEcomp = 1; % Common phase compensation
sim.enRCFOcomp= 0;
sim.CFOcomp_en =0;
sim.nlcompen  = 1 ;
    
% sim.estimatedgain = 9.1074;
% SNR = sim.SNR ; 
sim.subband=0;
sim.exp_cfo =0 ;
sim.en_ISFA =0;
sim.ISFASize=5;
sim.ISFASize1=2;

%% OFDM parameter setting 
params.Nbpsc =Nbpsc;

params.NSymbol= NUM;
params.NFFT = NFFT;

params.OVERSAMPLE = 1.0;
params.RxOVERSAMPLE = 1.0  ;
params.RxOVERSAMPLE = ovsampling  ; 
params.CPratio = 1/8; 
params.phi = phi/params.NFFT/2;
params.NSTF = 2;
params.NLTF = 1;          % Number of repetitive LTF for pol.(?)
% params.SampleTime =  Ts1*(params.Nbpsc ) * ( 1 +1/8)/( 1 +params.CPratio ) ;% 100*ps;
params.SampleTime =sampletime  ;
params.SampleperSymbol =  params.OVERSAMPLE * params.NFFT * ( 1 +params.CPratio);
params.RxSampleperSymbol =  params.RxOVERSAMPLE * params.NFFT * ( 1 +params.CPratio);

params.preamblefactor = 1;                      % Preamble amplitude factor 
params.Nstream = 1 ;
params.RXstream = 1;
params.LTF = zeros(1, params.NFFT);


if ( params.NFFT == 2048 )
    
    sim.ISFASize=7;
     MaxIdx =   820 ;% 112Gbps(Nominal)
    if ( MaxIdx > 960 )        
        SubcarrierIndex1 = [12:127 129:255  257:447 449:639 641:767  769:959 961:MaxIdx] ;         
        PilotIndex1 = [  128   256   448   640   768   960 ] ;   
        params.Pilot = [ -1 -1 1 1 1 -1 1 1 -1 -1 -1 1 ];
    else
        if (  MaxIdx > 769 )
        SubcarrierIndex1 = [12:127 129:255  257:447 449:639 641:767  769:MaxIdx] ;         
        PilotIndex1 = [  128   256   448   640   768    ] ;      
        params.Pilot = [  -1 1 1 1 -1 1 -1 -1 -1 1 ];
        else
        SubcarrierIndex1 = [12:63 65:127 129:191 193:255  257:319 321:447 448:MaxIdx] ;         
        PilotIndex1 = [  64 128  192  256   320       ] ;      
        params.Pilot = [  -1 1 1 1 -1 1 -1 -1 -1 1 ];
        end
    end
  
    
    PilotIndex2 = sort(-PilotIndex1); 
    LTF_2048 = [	 ...
          1,-1, 1,-1,-1, 1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1, 1, 1,-1, 1, 1, 1, 1, 1,-1,-1, 1,-1, 1,-1, 1, 1 ,...
        1,-1, 1, 1,-1,-1, 1, 1,-1, 1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1, 1, 1, 1,-1,-1,-1,-1,-1,-1,-1, 1,-1 ,...
        1,-1,-1,-1, 1,-1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1,-1,-1, 1, 1, 1, 1,-1, 1, 1,-1,-1,-1,-1, 1,-1,-1 ,...
        1, 1, 1, 1,-1, 1, 1, 1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1,-1,-1,-1, 1,-1, 1, 1, 1,-1,-1, 1, 1 ,...
        -1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1, 1,-1, 1,-1,-1,-1,-1,-1, 1, 1, 1, 1, 1, 1,-1, 1,-1 ,...
        -1,-1, 1, 1, 1,-1,-1, 1,-1,-1,-1,-1, 1, 1,-1, 1, 1, 1,-1,-1, 1,-1,-1, 1,-1,-1, 1, 1,-1, 1, 1,-1 ,...
        -1,-1, 1, 1, 1, 1,-1, 1, 1, 1, 1, 1, 1, 1, 1,-1, 1,-1, 1,-1, 1, 1,-1, 1, 1, 1, 1, 1,-1,-1,-1,-1 ,...
        1,-1,-1, 1, 1, 1, 1, 1, 1, 1,-1, 1, 1, 1, 1,-1,-1, 1, 1,-1,-1, 1,-1,-1,-1, 1,-1, 1, 1, 1, 1,-1 ,...
        1, 1, 1, 1, 1,-1,-1,-1,-1, 1,-1,-1,-1,-1, 1,-1,-1,-1,-1,-1,-1, 1,-1,-1, 1,-1,-1, 1,-1,-1, 1,-1 ,...
        -1, 1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1, 1, 1,-1, 1,-1,-1,-1,-1,-1,-1, 1, 1,-1,-1,-1,-1, 1, 1 ,...
        -1,-1, 1, 1,-1, 1,-1,-1, 1,-1,-1, 1,-1, 1,-1,-1, 1,-1,-1,-1,-1, 1, 1, 1, 1, 1, 1, 1, 1,-1,-1,-1 ,...
        1,-1,-1,-1,-1, 1, 1, 1, 1, 1,-1,-1, 1, 1, 1, 1, 1,-1,-1, 1,-1, 1,-1,-1,-1,-1, 1, 1, 1, 1,-1,-1 ,...
        -1, 1, 1,-1,-1,-1,-1, 1, 1, 1,-1,-1, 1, 1,-1, 1, 1,-1,-1,-1, 1,-1, 1, 1,-1, 1, 1,-1,-1, 1,-1,-1 ,...
        -1, 1,-1, 1,-1,-1,-1,-1, 1, 1,-1,-1,-1,-1,-1, 1, 1,-1, 1, 1,-1, 1,-1, 1, 1,-1,-1,-1,-1,-1, 1,-1 ,...
        -1,-1,-1,-1,-1,-1, 1,-1,-1,-1, 1, 1, 1, 1,-1, 1,-1,-1,-1,-1, 1, 1,-1,-1,-1,-1,-1,-1, 1,-1,-1,-1 ,...
        1,-1, 1, 1, 1, 1,-1, 1,-1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1, 1, 1,-1, 1,-1,-1,-1,-1, 1,-1,-1,-1, 1 ,...
        1,-1, 1, 1, 1, 1,-1,-1, 1, 1,-1, 1, 1,-1,-1,-1, 1,-1, 1,-1,-1, 1, 1, 1,-1,-1,-1, 1,-1, 1, 1, 1 ,...
        -1, 1,-1, 1,-1, 1, 1, 1, 1,-1, 1, 1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1, 1, 1, 1, 1,-1, 1,-1, 1 ,...
        -1, 1, 1, 1,-1, 1, 1, 1,-1,-1,-1,-1, 1, 1, 1,-1, 1,-1, 1,-1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1 ,...
        -1, 1, 1, 1, 1, 1,-1, 1, 1, 1, 1,-1,-1,-1, 1, 1, 1,-1,-1,-1, 1,-1, 1, 1, 1,-1, 1,-1, 1, 1,-1, 1 ,...
        -1, 1, 1, 1, 1, 1, 1, 1,-1,-1, 1, 1,-1, 1,-1, 1, 1, 1, 1, 1, 1,-1,-1,-1, 1, 1,-1,-1, 1,-1, 1,-1 ,...
        -1,-1, 1,-1,-1, 1,-1,-1,-1, 1,-1, 1, 1, 1, 1, 1, 1, 1, 1, 1,-1,-1,-1, 1,-1, 1,-1,-1, 1,-1,-1, 1 ,...
        1,-1, 1,-1,-1, 1,-1, 1,-1, 1,-1,-1,-1, 1, 1,-1, 1, 1,-1,-1, 1,-1, 1, 1, 1, 1, 1, 1,-1, 1, 1, 1 ,...
        -1,-1,-1,-1,-1,-1, 1,-1, 1, 1,-1, 1,-1,-1,-1, 1,-1,-1,-1, 1, 1, 1, 1, 1,-1, 1,-1,-1,-1, 1, 1, 1 ,...
        1, 1,-1, 1,-1,-1,-1, 1,-1,-1,-1,-1, 1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1,-1 ,...
        -1, 1, 1, 1, 1,-1,-1,-1, 1, 1, 1, 1, 1,-1, 1,-1, 1, 1, 1, 1, 1,-1, 1,-1,-1,-1, 1,-1, 1, 1, 1,-1 ,...
        1, 1, 1, 1, 1,-1,-1, 1, 1, 1,-1, 1, 1, 1,-1, 1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1,-1,-1 ,...
        -1, 1,-1, 1, 1,-1, 1,-1,-1,-1, 1,-1,-1, 1,-1,-1,-1,-1, 1, 1,-1,-1,-1, 1, 1, 1, 1, 1,-1,-1,-1, 1 ,...
        -1,-1, 1, 1,-1,-1, 1,-1, 1, 1, 1, 1,-1, 1,-1,-1, 1, 1, 1,-1,-1, 1, 1, 1,-1, 1, 1,-1,-1, 1,-1,-1 ,...
        1,-1,-1,-1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1,-1,-1,-1,-1,-1, 1, 1,-1,-1, 1,-1,-1,-1, 1,-1, 1,-1, 1 ,...
        1,-1,-1,-1,-1,-1, 1, 1,-1, 1,-1,-1,-1, 1, 1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1,-1,-1, 1, 1,-1, 1 ,...
        -1, 1,-1, 1, 1,-1,-1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1, 1, 1, 1,-1, 1, 1, 1, 1, 1, 1,-1,-1,-1,-1, 1 ,...
        1, 1,-1, 1, 1,-1, 1, 1, 1,-1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1,-1,-1, 1,-1, 1,-1,-1,-1, 1, 1, 1,-1 ,...
        -1, 1, 1, 1, 1, 1,-1, 1, 1, 1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1,-1,-1, 1,-1,-1,-1, 1, 1,-1 ,...
        -1,-1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,-1, 1,-1, 1, 1, 1,-1,-1,-1, 1,-1, 1,-1,-1,-1,-1,-1,-1,-1, 1 ,...
        -1, 1, 1,-1, 1, 1,-1,-1, 1, 1, 1, 1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1,-1,-1,-1, 1, 1,-1 ,...
        1, 1,-1,-1, 1, 1,-1,-1,-1,-1,-1, 1, 1, 1, 1,-1,-1, 1, 1, 1, 1, 1,-1, 1, 1,-1, 1, 1, 1,-1,-1,-1 ,...
        1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1, 1, 1, 1,-1, 1,-1, 1, 1, 1,-1, 1,-1,-1,-1 ,...
        -1, 1,-1,-1,-1,-1,-1,-1,-1, 1,-1, 1, 1,-1,-1,-1,-1, 1, 1, 1, 1,-1,-1,-1,-1,-1, 1, 1,-1,-1,-1, 1 ,...
        1, 1,-1,-1,-1, 1,-1,-1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1, 1,-1, 1, 1,-1,-1,-1,-1,-1, 1,-1,-1,-1,-1 ,...
        -1,-1, 1,-1,-1, 1, 1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,-1,-1, 1,-1,-1,-1,-1, 1, 1, 1,-1, 1, 1 ,...
        1,-1, 1,-1,-1, 1, 1,-1,-1,-1,-1,-1,-1,-1,-1, 1,-1, 1, 1, 1,-1, 1,-1, 1, 1, 1,-1,-1, 1, 1,-1, 1 ,...
        1, 1, 1, 1, 1, 1,-1,-1, 1, 1, 1,-1,-1, 1,-1,-1, 1,-1,-1,-1,-1, 1,-1,-1, 1,-1, 1, 1, 1,-1,-1, 1 ,...
        1,-1,-1, 1, 1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1,-1 ,...
        -1, 1, 1,-1, 1, 1,-1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1,-1, 1,-1, 1, 1 ,...
        1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1, 1, 1,-1, 1, 1, 1,-1,-1,-1,-1, 1, 1, 1, 1,-1,-1,-1,-1,-1,-1, 1 ,...
        1, 1,-1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1, 1, 1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1, 1 ,...
        -1,-1,-1,-1,-1,-1, 1,-1,-1,-1, 1,-1,-1,-1, 1, 1, 1,-1, 1,-1,-1, 1, 1, 1, 1,-1, 1, 1, 1,-1, 1,-1 ,...
        1,-1,-1, 1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1, 1, 1, 1, 1, 1,-1, 1, 1, 1,-1,-1,-1,-1,-1,-1,-1 ,...
        -1, 1, 1, 1,-1,-1,-1,-1,-1,-1, 1, 1, 1, 1, 1,-1,-1, 1, 1, 1,-1,-1, 1,-1,-1, 1,-1,-1,-1, 1, 1, 1 ,...
        1,-1, 1,-1,-1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1, 1, 1, 1, 1, 1 ,...
        1,-1, 1,-1, 1,-1, 1,-1, 1,-1,-1,-1,-1, 1, 1, 1,-1,-1, 1, 1, 1, 1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1 ,...
        1, 1, 1, 1,-1,-1, 1, 1,-1, 1, 1, 1, 1, 1,-1, 1,-1,-1,-1, 1,-1,-1,-1,-1, 1, 1,-1, 1, 1, 1, 1, 1 ,...
        -1, 1, 1,-1, 1,-1, 1, 1,-1, 1, 1,-1,-1, 1, 1, 1,-1, 1, 1,-1, 1, 1, 1,-1,-1, 1, 1,-1, 1, 1,-1, 1 ,...
        1, 1,-1, 1,-1,-1,-1,-1, 1, 1,-1, 1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1, 1,-1, 1,-1,-1, 1,-1,-1,-1,-1 ,...
        -1, 1, 1,-1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1,-1,-1,-1, 1,-1 ,...
        1, 1,-1,-1,-1, 1, 1, 1,-1,-1,-1, 1, 1,-1,-1,-1,-1,-1,-1, 1,-1, 1, 1, 1,-1,-1,-1, 1,-1,-1,-1,-1 ,...
        1, 1, 1,-1, 1, 1, 1, 1,-1,-1,-1,-1, 1,-1,-1, 1,-1,-1,-1,-1,-1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1, 1 ,...
        1, 1, 1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1,-1,-1, 1,-1,-1, 1, 1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1,-1, 1 ,...
        -1,-1, 1, 1,-1,-1,-1, 1, 1,-1,-1, 1,-1, 1, 1, 1, 1, 1, 1, 1, 1, 1,-1, 1, 1, 1,-1, 1, 1, 1, 1,-1 ,...
        1, 1,-1,-1, 1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 1, 1, 1,-1, 1, 1,-1, 1, 1, 1, 1, 1, 1,-1,-1, 1,-1, 1 ,...
        -1, 1, 1, 1,-1, 1, 1,-1,-1,-1, 1, 1, 1,-1,-1, 1,-1,-1,-1, 1,-1,-1,-1,-1,-1, 1, 1, 1, 1,-1, 1, 1 ,...
        -1, 1,-1, 1,-1,-1,-1,-1, 1,-1,-1,-1,-1,-1, 1,-1,-1,-1,-1,-1,-1,-1,-1,-1, 1,-1, 1, 1, 1,-1, 1,-1 ,...
        -1,-1, 1, 1, 1, 1, 1, 1, 1,-1, 1, 1, 1, 1,-1, 1, 1, 1,-1, 1, 1, 1, 1,-1, 1,-1, 1, 1, 1, 1, 1, 1 ...
 ];


    STF_128 = [ 0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
                1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0,	0, 0, 0, 0, ...	//0 -
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
                1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                ];

    params.STF = [ STF_128 STF_128 STF_128 STF_128 STF_128 STF_128 STF_128 STF_128];
    params.STF = [  params.STF   params.STF ];
    LTF  =  [ LTF_2048 ];
%     params.NLTF =1;
end 
if ( params.NFFT == 1024 )
    MaxIdx =  410 ;% 112Gbps(Nominal)
    if ( MaxIdx > 480 )        
        SubcarrierIndex1 = [6:63 65:127  129:223 225:319 321:383  385:479 481:MaxIdx] ;         
        PilotIndex1 = [  64   128   224   320   384   480 ] ;   
        params.Pilot = [ -1 -1 1 1 1 -1 -1 -1 1 1 1 -1 ];
    else
        SubcarrierIndex1 = [6:63 65:127  129:223 225:319 321:383  385:MaxIdx] ;
        PilotIndex1 = [  64   128   224   320   384 ];   
        params.Pilot = [ -1  1 1 1 -1 -1 -1 1 1  -1 ];
    end
  
    
    PilotIndex2 = sort(-PilotIndex1); 
    LTF_512 = [	 ...
  1   -1   1   1   1   1  -1   1   1  -1   1  -1   1   1   1   1 ...
   1   1   1   1   1   1   1   1   1   1   1  -1   1   1   1  -1 ...
  -1  -1   1  -1  -1  -1  -1   1  -1   1   1  -1   1   1   1   1 ...
   1   1   1   1   1   1   1   1   1   1  -1   1  -1  -1  -1   1 ...
   1  -1  -1   1  -1  -1  -1   1   1   1  -1   1   1  -1   1  -1 ...
   1  -1  -1   1   1  -1   1  -1   1   1  -1   1  -1  -1   1   1 ...
   1  -1  -1   1  -1  -1  -1   1  -1   1   1  -1  -1  -1   1   1 ...
  -1  -1  -1  -1   1   1   1   1   1   1  -1  -1   1   1   1  -1 ...
  -1   1  -1   1  -1   1  -1  -1  -1  -1   1  -1   1  -1  -1   1 ...
   1   1   1  -1   1  -1  -1   1  -1  -1   1  -1  -1  -1   1  -1 ...
  -1   1  -1   1  -1  -1  -1  -1  -1   1   1  -1  -1   1  -1   1 ...
  -1  -1  -1  -1   1   1  -1  -1  -1  -1  -1  -1  -1  -1  -1  -1 ...
  -1   1  -1   1  -1  -1   1  -1   1  -1   1   1  -1   1  -1  -1 ...
  -1  -1  -1   1  -1  -1   1   1   1   1   1   1   1   1  -1  -1 ...
   1  -1   1   1  -1  -1  -1   1  -1  -1  -1   1  -1   1  -1  -1 ...
   1   1   1   1  -1   1  -1  -1  -1  -1  -1   1  -1   1   1  -1 ...
  -1  -1   1   1  -1   1   1  -1   1  -1   1   1   1   1   1   1 ...
   1  -1  -1   1  -1   1  -1  -1  -1   1   1  -1  -1   1   1  -1 ...
  -1   1   1  -1   1  -1   1   1   1  -1  -1   1   1  -1  -1   1 ...
   1   1  -1  -1   1   1   1   1   1   1   1  -1  -1   1  -1  -1 ...
   1  -1   1  -1   1  -1   1  -1  -1   1   1  -1  -1   1  -1   1 ...
   1   1   1   1   1   1   1   1  -1   1   1   1  -1   1   1   1 ...
   1  -1   1  -1  -1  -1  -1   1   1   1   1  -1   1  -1  -1   1 ...
  -1  -1   1   1  -1   1   1  -1  -1  -1   1  -1   1   1  -1   1 ...
   1   1   1  -1   1   1   1  -1   1   1  -1  -1  -1  -1  -1  -1 ...
  -1  -1  -1  -1  -1  -1  -1   1   1   1   1   1   1   1  -1   1 ...
   1  -1  -1   1  -1   1  -1  -1   1   1  -1  -1   1  -1  -1   1 ...
  -1  -1  -1  -1  -1   1  -1  -1  -1   1   1   1   1   1  -1   1 ...
   1   1  -1  -1  -1  -1  -1  -1  -1  -1   1  -1  -1   1  -1   1 ...
   1   1   1   1  -1   1  -1  -1   1  -1  -1   1   1   1  -1   1 ...
   1   1   1   1  -1   1  -1  -1   1  -1   1  -1  -1   1   1   1 ...
  -1   1   1   1  -1   1   1   1  -1   1  -1  -1   1   1   1  -1 ...
   1  -1   1  -1   1   1   1   1  -1  -1   1  -1   1  -1  -1  -1 ...
   1   1  -1  -1   1   1  -1   1  -1  -1  -1  -1  -1  -1   1  -1 ...
   1  -1   1  -1  -1   1   1  -1  -1  -1  -1   1  -1  -1   1  -1 ...
   1   1  -1   1  -1  -1   1   1   1  -1  -1  -1   1  -1  -1  -1 ...
   1  -1  -1  -1   1   1   1  -1   1  -1  -1  -1   1   1  -1   1 ...
  -1   1   1  -1   1  -1   1  -1  -1  -1  -1   1  -1   1   1  -1 ...
   1   1   1  -1  -1  -1  -1  -1   1   1  -1  -1   1   1   1   1 ...
  -1  -1   1   1   1   1   1  -1  -1   1   1  -1   1  -1  -1   1 ...
   1   1   1  -1  -1   1   1  -1  -1  -1  -1  -1  -1   1   1  -1 ...
   1   1   1   1   1  -1  -1   1  -1  -1   1  -1   1   1   1   1 ...
   1   1  -1  -1  -1  -1  -1  -1  -1   1   1   1   1   1   1  -1 ...
  -1  -1  -1   1   1   1  -1   1   1  -1   1   1   1   1   1   1 ...
   1  -1   1  -1  -1   1  -1   1  -1  -1   1   1   1   1   1  -1 ...
  -1  -1  -1   1  -1   1  -1  -1   1   1  -1  -1   1   1   1   1 ...
   1   1   1   1   1  -1   1  -1  -1  -1  -1  -1  -1   1   1   1 ...
   1  -1  -1   1  -1   1  -1  -1  -1  -1   1  -1   1  -1   1  -1 ...
   1  -1  -1   1  -1   1   1   1   1  -1  -1  -1  -1   1  -1  -1 ...
   1  -1   1  -1   1  -1  -1   1   1  -1   1  -1   1   1   1  -1 ...
   1  -1  -1   1  -1   1   1   1   1   1  -1   1  -1  -1   1   1 ...
  -1   1  -1  -1   1   1  -1   1  -1   1  -1  -1   1  -1   1  -1 ...
   1   1   1  -1  -1  -1  -1  -1   1   1  -1   1   1   1   1   1 ...
   1  -1   1  -1  -1   1   1  -1   1  -1  -1   1  -1  -1  -1   1 ...
   1  -1  -1  -1   1  -1  -1   1  -1  -1   1   1   1  -1   1   1 ...
   1   1   1   1   1   1  -1   1  -1  -1   1   1  -1  -1  -1   1 ...
  -1  -1  -1  -1   1  -1   1   1   1  -1   1   1   1  -1   1   1 ...
  -1   1  -1   1   1  -1   1  -1  -1   1   1   1   1  -1  -1  -1 ...
   1  -1  -1  -1   1  -1   1  -1   1  -1   1   1   1  -1  -1   1 ...
  -1  -1  -1  -1   1  -1   1   1  -1   1  -1   1  -1  -1   1  -1 ...
  -1   1  -1   1  -1  -1  -1   1  -1   1  -1  -1  -1  -1   1  -1 ...
   1  -1   1   1  -1  -1   1   1   1   1   1   1  -1  -1   1  -1 ...
   1   1  -1   1  -1  -1  -1  -1  -1  -1   1   1  -1  -1  -1   1 ...
  -1  -1  -1   1  -1  -1   1   1   1   1   1   1  -1   1  1 -1  ...
 ];


    STF_128 = [ 0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
                1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0,	0, 0, 0, 0, ...	//0 -
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
                1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                ];

    params.STF = [ STF_128 STF_128 STF_128 STF_128 STF_128 STF_128 STF_128 STF_128];
    LTF  =  [ LTF_512 LTF_512];
%     params.NLTF =1;
end 
if ( params.NFFT == 512 )
    MaxIdx =  210 ;% 112Gbps(Nominal)
    if ( MaxIdx > 240 )        
        SubcarrierIndex1 = [6:31 33:63  65:111 113:159 161:191 193:239 241:MaxIdx] ;
        PilotIndex1 = [  32   64  112   160   192   240 ];   
        params.Pilot = [ -1 -1 1 1 1 -1 -1 -1 1 1 1 -1 ];
    else
        SubcarrierIndex1 = [6:31 33:63  65:111 113:159 161:191 193:MaxIdx] ;
        PilotIndex1 = [  32   64  112   160   192    ];   
        params.Pilot = [ -1  1 1 1 -1 -1 -1 1 1  -1 ];
    end
  
    
    PilotIndex2 = sort(-PilotIndex1); 
    LTF_512 = [	 ...
          0  0  0 -1  1 -1 -1 -1  1 -1 -1  1  1 -1  1 -1 ...
         -1  1 -1  1  1  1  1  1  1  1  1 -1 -1  1  1  1 ...
         -1  1  1  1  1 -1  1 -1 -1 -1 -1  1  1 -1 -1 -1 ...
          1 -1 -1  1 -1 -1  1 -1  1 -1 -1 -1  1  1  1  1 ...
          1 -1 -1  1  1 -1 -1  1 -1  1 -1 -1  1  1  1  1 ...
         -1  1 -1  1  1  1 -1  1  1  1 -1 -1 -1 -1 -1 -1 ...
          1  1  1  1  1  1 -1 -1  1 -1  1  1 -1 -1  1 -1 ...
         -1  1  1 -1 -1 -1 -1 -1  1  1  1 -1  1 -1 -1  1 ...
         -1  1 -1  1 -1  1  1 -1 -1 -1  1  1  1  1  1  1 ...
          1  1  1  1  1 -1  1 -1 -1 -1 -1 -1 -1 -1 -1 -1 ...
          1 -1 -1  1 -1  1  1  1 -1 -1 -1  1 -1 -1  1 -1 ...
          1  1 -1 -1  1 -1 -1  1  1  1  1 -1 -1 -1 -1 -1 ...
         -1  1 -1 -1 -1  1  1  1  1  1 -1  1  1  1  1  1 ...
          1  1  1  1  1  1 -1  1  1 -1  1 -1  1 -1  1 -1 ...
          1  1 -1 -1  1  1  1 -1  1  1 -1  1 -1 -1  1  1 ...
         -1 -1 -1  1 -1 -1  1 -1  1  1 -1  0  0  0  0  0 ...
          0  0  0  0  0 0 -1 -1 -1 -1 -1 -1  1  1  1  1 ...
          1 -1  1  1 -1 -1  1  1  1 -1  1 -1  1 -1 -1 -1 ...
         -1 -1  1 -1 -1 -1 -1  1  1  1  1  1 -1 -1  1 -1 ...
          1 -1 -1 -1 -1  1  1 -1 -1  1 -1 -1 -1 -1 -1  1 ...
          1 -1 -1 -1  1 -1 -1  1 -1  1  1 -1  1  1 -1 -1 ...
         -1 -1  1 -1 -1  1  1  1 -1 -1  1 -1 -1  1 -1 -1 ...
         -1  1 -1  1  1 -1  1  1 -1  1 -1  1  1  1 -1 -1 ...
         -1  1 -1  1  1 -1 -1  1 -1 -1  1  1 -1 -1  1  1 ...
         -1  1 -1  1  1  1  1  1  1  1 -1  1  1 -1 -1  1 ...
          1  1  1  1  1 -1  1  1 -1 -1 -1 -1  1  1 -1 -1 ...
          1 -1 -1  1  1 -1 -1  1  1  1 -1  1 -1 -1 -1 -1 ...
         -1 -1  1 -1 -1  1  1 -1 -1 -1  1  1  1  1  1  1 ...
         -1 -1 -1  1 -1  1 -1 -1  1  1 -1 -1 -1  1  1 -1 ...
          1 -1  1  1 -1 -1  1  1 -1 -1  1 -1 -1  1  1 -1 ...
         -1 -1 -1  1  1 -1 -1  1  1  1 -1 -1 -1 -1  1  1 ...
         -1  1 -1  1  1  1 -1  1  1  1 -1  1  1 -1  0  0 ...
 ];


    STF_128 = [ 0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
                1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0,	0, 0, 0, 0, ...	//0 -
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
                1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                ];

    params.STF = [ STF_128 STF_128 STF_128 STF_128 ];
    LTF  =  LTF_512;
%     params.NLTF =1;
end 
if (params.NFFT == 256 ) 
    MaxIdx =109 ;
    if ( MaxIdx > 96 )        
        SubcarrierIndex1 = [5:15 17:31  33:47 49:63 65:95 97:MaxIdx] ;
    else
        SubcarrierIndex1 = [5:15 17:31  33:47 49:63 65:MaxIdx] ;
    end
    PilotIndex1 = [ 16 32 48 64 96 ];   
    params.Pilot = [ 1 -1 -1  1 1 -1 1 -1 -1 -1];
%     PilotIndex1 = [ 16   48   96 ];  
%     params.Pilot = [ -1 -1 1 1 1 -1 ];
      LTF_256 = [ ...
          0,  0, -1, -1, -1, -1,  1,  1, -1,  1, -1,  1, -1,  1,  1, -1, ...
          1, -1, -1, -1,  1,  1, -1, -1,  1, -1, -1,  1,  1, -1, -1,  1, ...
         -1, -1,  1,  1, -1,  1,  1, -1,  1,  1, -1, -1,  1,  1,  1, -1, ...
          1, -1, -1, -1,  1, -1,  1, -1,  1, -1, -1, -1,  1, -1,  1, -1, ...
         -1,  1, -1, -1, -1,  1, -1, -1,  1, -1,  1, -1,  1, -1,  1,  1, ...
          1,  1, -1, -1, -1, -1, -1,  1, -1,  1, -1, -1,  1,  1, -1,  1, ...
          1,  1,  1,  1,  1,  1, -1, -1,  1, -1, -1,  1, -1, -1,  1,  1, ...
         -1,  1, -1,  1, -1, -1, -1,  1,  1,  1, -1,  1,  1,  0,  0,  0,  ...
          0,  0, -1,  1, -1,  1, -1, -1,  1, -1, -1,  1, -1,  1,  1,  1,  ...
         -1,  1,  1,  1, -1,  1,  1,  1, -1, -1, -1, -1, -1,  1, -1, -1, ...
         -1,  1,  1, -1,  1, -1, -1, -1,  1,  1,  1, -1,  1,  1, -1, -1, ...
          1, -1,  1,  1,  1, -1, -1,  1, -1, -1,  1,  1, -1,  1, -1, -1, ...
         -1,  1,  1,  1, -1, -1,  1, -1, -1, -1,  1, -1, -1,  1,  1,  1, ...
          1,  1, -1, -1,  1, -1,  1, -1, -1,  1,  1,  1,  1, -1, -1,  1, ...
          1,  1, -1, -1, -1, -1, -1, -1,  1,  1,  1, -1, -1,  1,  1, -1, ...
         -1,  1, -1,  1, -1,  1, -1, -1,  1, -1,  1, -1, -1,  0,  0,  0 ...
       ];
   
    LTF  =  LTF_256;
    STF_128 = [ 0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
                1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0,	0, 0, 0, 0, ...	//0 -
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
                1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                ];

    params.STF = [ STF_128 STF_128  ];
end

if ( params.NFFT == 128 )
    MaxIdx =  42;% 48;
    if ( MaxIdx > 40 )        
        SubcarrierIndex1 = [5:7 9:23 25:39  41:MaxIdx] ;
    else
        SubcarrierIndex1 = [5:7 9:23 25:MaxIdx] ;
    end    
    PilotIndex1 = [ 8 24 40  ];%48 ];   
%     params.Pilot = [ 1 -1 -1 1 -1 1 1 -1 ];
    params.Pilot = [ -1 -1 1 1 1 -1 ];
    params.AddEdgeSc =[MaxIdx+ 1];%,   MaxIdx+ 2  MaxIdx+ 3 ] ;
% 
%     SubcarrierIndex1 = [5:5 7:11 13:17 19:23 25:29 31:35 37:MaxIdx] ;
%     PilotIndex1 = 6:6:36;
%     params.Pilot = [ -1 -1 1 1 1 -1 -1 -1 1 1 1 -1 ];
    
    
    
%    
%     SubcarrierIndex1 = [3:7 9:11 13:15 17:MaxIdx] ;
%      MaxIdx = 23;
%     SubcarrierIndex1 = [ 1:13 ] +7 +8;%
%     PilotIndex1 = [ 14 15 16  ]+7 +8;
%     
%     SubcarrierIndex1 = [ 1:8 ] +7 +8+4;%
%     PilotIndex1 = [ 9:11  ]+7 +8+4;
%     params.Pilot = [ -1 -1 1  ];
        
     LTF_128 = [	0, 0, 0, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	//1 @1
                1, 1, 1, 1, 1,-1,-1,1, 1,-1, 1,-1, 1, 1, 1,1, ...
                1, 1,-1,-1, 1, 1,-1,1,-1, 1,-1,-1,-1,-1,-1,1, ...
                1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1, 0,0, ...	//-1 @59
                0, 0, 0, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	//-1 @-59
                1, 1, 1, 1, 1,-1,-1,1, 1,-1, 1,-1, 1, 1, 1,1, ...
                1, 1,-1,-1, 1, 1,-1,1,-1, 1,-1,-1,-1,-1,-1,1, ...
                1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1, 0,0 ];

    % 16 repetition
    STF_128 = [ 0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
                1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0,	0, 0, 0, 0, ...	//0 -
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
                1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                ];

    params.STF = STF_128;
    LTF  =  LTF_128;   
end 


% if ( params.NFFT == 128 )
%     MaxIdx =  45;
%     if ( MaxIdx > 40 )        
%         SubcarrierIndex1 = [  9:23 25:39  41:MaxIdx] ;
%     else
%         SubcarrierIndex1 = [  9:23 25:MaxIdx] ;
%     end    
%     PilotIndex1 = [   24 40 46  ];%48 ];   
%     params.Pilot = [ -1 -1 1 1 1 -1 ];
% 
%      LTF_128 = [	0, 0, 0, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	//1 @1
%                 1, 1, 1, 1, 1,-1,-1,1, 1,-1, 1,-1, 1, 1, 1,1, ...
%                 1, 1,-1,-1, 1, 1,-1,1,-1, 1,-1,-1,-1,-1,-1,1, ...
%                 1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1, 0,0, ...	//-1 @59
%                 0, 0, 0, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	//-1 @-59
%                 1, 1, 1, 1, 1,-1,-1,1, 1,-1, 1,-1, 1, 1, 1,1, ...
%                 1, 1,-1,-1, 1, 1,-1,1,-1, 1,-1,-1,-1,-1,-1,1, ...
%                 1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1, 0,0 ];
% 
%     % 16 repetition
%     STF_128 = [ 0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
%                 -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
%                 -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
%                 1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
%                 0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0,	0, 0, 0, 0, ...	//0 -
%                 -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
%                 -1-j, 0, 0, 0,	0, 0, 0, 0, -1-j, 0, 0, 0, 0, 0, 0, 0, ...
%                 1+j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
%                 ];
% 
%     params.STF = STF_128;
%     LTF  =  LTF_128;   
% end

if ( params.NFFT == 64 )
    MaxIdx =28;
    if ( MaxIdx > 24 ) 
%         SubcarrierIndex1 = [2:7 9:15  17:23 25:MaxIdx] ; 
        SubcarrierIndex1 = [2:7 9:15  17:MaxIdx] ;   
    else
        SubcarrierIndex1 = [2:7 9:15  17:MaxIdx] ;   
    end
    PilotIndex1 = [ 8 16 ];% 24];
    params.Pilot = [ -1 -1 1 1 1 -1 ];
    params.Pilot = [ -1   1 1   -1 ];
    LTF_64 = [	0, -1, -1, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	 
                1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1,-1,0, ...	 
                0, -1, -1, 1, 1,-1, 1,1,-1,-1, 1, 1,-1, 1,-1,1, ...	 
                1,-1,-1, 1,-1, 1,-1,1, 1, 1, 1,-1,-1,-1,-1,0 ];

%    LTF_64 = [ ...         
%       0,  1,  1, -1,  1,  1,  1,  1, -1, -1, -1, -1, -1, -1, -1, -1, ...
%      -1,  1,  1, -1, -1,  1, -1, -1,  1,  1,  1,  1,  1, -1, -1,  0, ...
%       0, -1, -1,  1,  1, -1,  1, -1, -1,  1, -1,  1,  1,  1, -1,  1, ...
%       1, -1,  1,  1,  1, -1, -1, -1, -1,  1, -1, -1, -1,  1,  1,  0 ];
    % 16 repetition
    STF_64 = [ 0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...               
                0, 0, 0, 0, 0, 0, 0, 0, 1+j, 0, 0, 0,	0, 0, 0, 0, ...	//0 -
                -1-j, 0, 0, 0,	0, 0, 0, 0, 1+j, 0, 0, 0, 0, 0, 0, 0, ...
                ];

    params.STF = STF_64;
    LTF =  LTF_64 ;
    params.NSTF = 4;
end 
params.LTF = LTF;
params.SubcarrierIndex1 = SubcarrierIndex1;
params.PilotIndex1 =PilotIndex1;
params.en_bitalloc =0 ;
params.LTFtype = [1 1 ; 1 -1 ;];
% params.LTFtype = [1 0 ; 0 1 ;];
%  params.NSTF = 1;
params.cs_thres =5;
params.PilotIndex1 =PilotIndex1 ;
% params.NLTF =1;
%% Filter Coefficient
% f = [0 0.55 0.55 1]; m = [1 1 0 0];
% b = fir2(160,f,m);
% params.LPF =b;
% [h, w]=freqz(b,1,128);
% plot(f,m,w/pi, abs(h))
[b,a] = butter(31,0.6,'low');
%  h1=dfilt.df2(b,a);
% fvtool(h1)


%% MZM
MZmod.Vpi_DC =  4 ; 
MZmod.Vpi_RF = 4 ; 
MZmod.Vbias1 = 2 ; 
MZmod.Vbias2 = -2 ; 
% MZmod.Extinctio

%% Fiber parameter Setting 
lambda0 = 1550*nm; %m
AlphadB = 1*0.2 /km;        
GDD= CD   ;                                        % ps/nm/km
% fiber.DeltaT = params.SampleTime / sim.oversample ;  %
fiber.DeltaH = 2*km  ;                              % m 
fiber.DeltaH = 5*km ;
fiber.FiberLength = 75  *km ;                      % Fiber length 
fiber.FFTSize = params.SampleperSymbol * sim.oversample *2 ;
fiber.Overlap =2 ;
fiber.FFTSize=0;
fiber.Beta2 = (1)*lambda0^2/(2*pi*c)*GDD*1e-6 ;  % 2nd order dispersion
fiber.Beta  = 0 ;                                 % 1st order dispersion
fiber.Alpha = AlphadB/(log10(exp(1))*10) ;        % Loss(dB/m)/10/Log10(e)
fiber.Gamma = -1*1.2/W/km ;                      % /W/m 0.6~2.4 ���� 
fiber.Aeff =  80*um^2;                            % Effective area.
fiber.n2 = 26e-21 ;                               % n2.
fiber.n = 1.5 ;                                   % Not used.
% fiber.Gamma = -1*2*pi*fiber.n2 /lambda0/fiber.Aeff;  % Gamma 
fiber.centered = 1;                               % Carrier frequency is center of bandwidth 
                                                  % PMD related parameters
fiber.Dp = 1 *2* 1*ps/sqrt(km);                   % First order PMD coefficient Dp  
fiber.power_split1= 1;                            % Power splitting ratio of polarization (Transmit side)
fiber.power_split2= 0.7;                            % Power splitting ratio of polarization (Receiver)
fiber.DGD = 1*0.1*ps/km;                          % average DGD value /km, 0.1 ps/km

fiber.Npol =params.RXstream ;                     % Polarization diversity
fiber.tolerance = 1e-5; 
fiber.maxiter = 1;

%% Laser 

launch_power = TXLP; % W 
laser.launch_power = launch_power/4;%/params.Nstream ;  % Pol splitter 

lolaser.launch_power = RXLP/4;%/params.RXstream; % Pol splitter 

laser.linewidth = 1* 50 *kHz; 
lolaser.linewidth = 1* 100 *kHz; 
sim.nolinewidth=0;
laser.freqoff =0;
lolaser.freqoff =0;
%% EDFA parameters

% edfa.length = 80*km;                          % 80*0.2=16dB, 200*0.2 = 40dB
% EDFA_GAIN_dB = 10.0 ;

txedfa.length = 80*km; %400* km
txedfa.hv = h*c/lambda0;
if ( params.Nstream == 1)    
    txedfa.gain_dB = 10;
else    
    txedfa.gain_dB =  18.40 -0.009-0.861-0.5-1.3;%6; % For single polar 10;
%     txedfa.gain_dB = 10;
end
txedfa.NF_dB = 4; 
txedfa.nonoise =noedfanoise;

edfa.length = 75*km; %400* km
edfa.hv = h*c/lambda0;
edfa.gain_dB =AlphadB * edfa.length ;
edfa.NF_dB = 6.5 ;   
edfa.nonoise =noedfanoise;

rxedfa.length = 80*km; %400* km
rxedfa.hv = h*c/lambda0;
rxedfa.gain_dB =4;%26.1-1.2;%26;
rxedfa.NF_dB =4;   
rxedfa.nonoise =noedfanoise;

params.ignore_edge_sb = 1;
%% Optical to electrical
PD.responsivity = 1;                              % A/W, No modelling for PD
PD.noise_power_dBm = -80;                         % Opt 2 electric part noise including electri amplifier
PD.gain_dB = 35;
PD.nonoise =1;
%% Fixed simulation 
sim.DACbit =0 ;
sim.ADCbit = 9;
sim.AGCbit = 0;
sim.CSInbit = 4;
sim.CSMulOutbit = 7 ;
sim.CSSumOutbit = 9 ;
sim.CSAppr = 0 ;
sim.CFOinbit =    5 ;
sim.CFO1inbit =  4 ;
sim.CFOMulOutbit =   sim.CFOinbit * 2  -1;
sim.CFO1MulOutbit =  sim.CFO1inbit * 2  -1;
sim.CFOSumOutbit =  sim.CFOMulOutbit  +3;
sim.CFO1SumOutbit =  sim.CFO1MulOutbit  +3;
sim.CFObit =  15;
sim.FSInbit =  4;
sim.FSMulOutbit = 7;
sim.FSSumOutbit =  10 ;
sim.FSEst = 1;
sim.MulOutbit = 0;%8;
sim.ATANINbit = 0;% 11;
sim.ATANbit = 0; 
sim.FFTOutbit = 0;
sim.DCTOutbit =0 ;
sim.ATAN1bit =0 ;
sim.ATAN2bit =0 ;
sim.lut_bit =0;
sim.lut_max =0 ;
sim.fftout =0 ;
sim.fft_max =0 ;

sim.DACClipping = 8 ;   %dB 
sim.ADCClipping = 7.5; 
sim.dacgain = 1;%8;

%%
sim.dacout = params.NFFT * sim.dacgain;
sim.txgain =-0.2;
sim.rxgain = 10^(20/20);
sim.zeropad=0;
sim.zeropad1=0;
sim.iqoffset=0;
sim.zeropad2=0;
sim.zeropad3=0;

%%
sim.en_fsync_plot =0 ;
sim.useprbsdata =1 ;
sim.useolddata =0 ;
sim.FiberLength = 600   *km ;   
%% Low pass filter 

% [b,a] = cheby2(31,30,0.5,'low');
[b,a] = cheby2(30,100,0.55,'low');

% n = 6; 
% r = 80; 
% Wn = [0.07 0.4];
% ftype = 'bandpass';
% Transfer Function design
% [b,a] = cheby2(n,r,Wn,ftype);
h1=dfilt.df2(b,a);
% fvtool(h1)
sim.txfiltera = a;
sim.txfilterb = b;
 
sim.txLPF_en =0 ;
sim.rxLPF_en =0 ;
%% Simulation setting 
sim.en_H_plot = 0;
sim.showinteger =0;
sim.noplot = 0;
sim.en_H_plot = 0;
sim.en_fsync_plot =0;
sim.en_constellation_plot = 0;
sim.en_cs_plot = 0;
sim.en_disp_env =0 ;
sim.fixed_sim = 0;

sim.en_optisyschannel =0;
sim.en_read_ADS =0;
sim.en_gen_ADS =0;
sim.extcon =0; 
sim.en_AWGN = 0 ;
sim.coeff = 1;  
sim.nophase=1;
sim.osnrin=100;
sim.en_find_sync = 0;

sim.en_find_cs = 0;
sim.filname='simulation';
sim.nlcompen =1; % Nonlinear compensation 
sim.nlpostcompen = 1;
sim.nlc_coef = 1  ;%/max(1,sim.nlcompen+sim.nlpostcompen) ;
sim.multi_level =0;
sim.ofde = 1;
sim.en_OFDE=3;
sim.nlcoef_cross =1;
%%

 

sim.enCPEcomp =1;
sim.CFOcomp_en =1;
sim.en_fsync_plot =0;

params.Nstream =2;
params.RXstream = 2;
fiber.Npol =params.RXstream ; 
sim.en_ISFA=1;
sim.preemphasis_H_en =0;
sim.wavelength =0;
params.MIMO_emul =1;
sim.enIQbal =1;
params.NOFDE =1024;
params.en_DFT_S = 0;
%%
sim.DCoffst =   -(-7.1443e-004 -0.0010j );
sim.Gain = 1+1j;%1+0.987j;
 
% sim.cetyppe=1;
%% Low pass filter -analog

% [b,a] = cheby2(31,30,0.5,'low');
[b,a] = cheby2(30,100,0.55,'low');

% n = 6; 
% r = 80; 
% Wn = [0.07 0.4];
% ftype = 'bandpass';
% Transfer Function design
% [b,a] = cheby2(n,r,Wn,ftype);
h1=dfilt.df2(b,a);
% fvtool(h1)
[b,a]= butter(3,0.5 ,'low');

sim.txfilter.a = a;
sim.txfilter.b = b;
[b,a]= butter(31,0.5 ,'low');
sim.rxfilter.a = a;
sim.rxfilter.b = b;

sim.txfiltera = a;
sim.txfilterb = b;
sim.tone = 17;%2;
sim.txLPF_en = 0  ;
sim.txLPF_en1= 0;
sim.rxLPF_en = 0 ;
sim.enIQbal =0 ;
sim.decision_feedback_cpe  =1;
sim.PMDtype = 0;
fiber.PMD = 1 * 50*ps;
 sim.cetype=1;
%% BIT ALLOC 1
% 
% params.Nbpsc_sc([1,  100]) = 2;
% params.Nbpsc_sc([49:52]) = 2;
%% BIT ALLOC 3
 
% params.Nbpsc_sc(40:60) = 2;
 
%% BIT ALLOC 4
%  
% params.Nbpsc_sc(Nsd/2-1:Nsd/2+2) = 2;
%% BIT ALLOC 5
 
% params.Nbpsc_sc([1, 50:51, 100]) = 2;
end
% 10*log10((76+6)/256 )-25