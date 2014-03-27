
%% Clear
% clc; clear all; close all;


%% Parameter Setting 

MPSK = 6 ;
nSymbol = 1000 ;
nBitMin = 26*MPSK;
nStep = 1;
nBitMax= 26*MPSK; % 50;


sim.enScramble = 0  ;
sim.enClipping = 0; 
sim.enSelectiveMapping = 0 ; 

sim.ipModPlot = 0 ; 
sim.enWavePlot = 1 ; 
sim.histPlot = 1 ; 
sim.cdfPlot = 0;
%% Constant parameter define 
% BPSK =1 ;
% QPSK =2;
% 8QAM = 3;
% 16QAM = 4;
% 32QAM = 5;
% 64QAM = 6;

%% Call paprofdm

%paprofdm( MPSK, numOne, nSymbol, reductionMethod, ipModPlot, enWavePlot,
%histPlot 
% reduction method :(enSelectiveMapping, enClipping, enScramble)

for i=nBitMin:nStep:nBitMax
    [averagepapr(i), VarPAPR(i), PAPR] = paprofdm_for_long_sim(MPSK, i, nSymbol, sim ); 
%     [n x] = hist(PAPR,[0:0.5:40]);
%     plot(x,cumsum(n)/nSymbol,'LineWidth',2, 'DisplayName', sprintf('%0.5d', i));

end
