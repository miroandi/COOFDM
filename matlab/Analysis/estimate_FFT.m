% clear all;
%% Initialize
MHz =1e6;
GHz =1e9;
km = 1e3;
ps  =1e-12;
ns  =1e-9;
nm = 1e-9;
params.NPol =2 ;
params.Nbpsc = 2 ; % modulation 
params.NFFT = 128 ;
params.Nsd = params.NFFT /1.28 ;
params.Ncbps =  params.Nsd  * params.Nbpsc ;
params.CPratio = 1/8;

%%
Nband=1;
Nsubband = 8;
Rb=112*GHz/Nband;
Rov =1.28;
Ts = params.NPol * params.Nbpsc/(1+params.CPratio)/Rb/Rov;
Ts1 = Ts *1  ;   % 4QAM
Ts2 = Ts *2 ;     % 16QAM
Ts3 = Ts *1.5 ;   % 8QAM
1/Ts1/GHz

lambda = 1550 *nm;
c = 299792 *km;
D = 17 *ps/nm/km ;
tDGD=1*120*ps;
fiber.Dp = 1 *2* 1*ps/sqrt(km); 
fiber.DGD = 0.1*ps/km;
stepidx=(1:1:200);

%% Minimum FFT size

for L =stepidx
    tDGD =   estimate_pmd( fiber, L*10*km );
    tCP =  D * lambda^2/c * 1/Ts1/Rov *(params.Nsd/params.NFFT) * L*10*km;
    min_FFT1(L) = (log2( (tDGD +tCP)/params.CPratio/Ts1));
    tCP =  D * lambda^2/c * 1/Ts2/Rov *(params.Nsd/params.NFFT) * L*10*km;
    min_FFT2(L) =   (log2( (tDGD +tCP)/params.CPratio/Ts2));
    tCP =  D * lambda^2/c * 1/Ts3/Rov *(params.Nsd/params.NFFT) * L*10*km ;
    min_FFT5(L) =   (log2( (tDGD +tCP)/params.CPratio/Ts3));
end 

%% Minimum FFT size of subbandding 


for L =stepidx
    tDGD =   estimate_pmd( fiber, L*10*km );
    tCP =  D * lambda^2/c * 1/Ts1/Nsubband   * L*10*km + Ts1; 
    min_FFT3(L) = (log2( (tDGD +tCP)/params.CPratio/Ts1));
    
    tCP =  D * lambda^2/c * 1/Ts2/Nsubband   * L*10*km + Ts2; 
    min_FFT4(L) =   (log2( (tDGD +tCP)/params.CPratio/Ts2));
    
    tCP =  D * lambda^2/c * 1/Ts3/Nsubband   * L*10*km + Ts3; 
    min_FFT6(L) =   (log2( (tDGD +tCP)/params.CPratio/Ts3));
end 

%% Plot
figure( 'FileName', 'Fig1_FFTsize.fig'); hold;

% plot(10*(stepidx),  min_FFT1, 'r',  'Display', '4 QAM')
% plot(10*(stepidx),  min_FFT2, 'b',  'Display', '16 QAM')
% plot(10*(stepidx),  min_FFT5, 'g',  'Display', '32 QAM')
legend('show')
plot(10*(stepidx), ceil(min_FFT1), 'r--',  'Display', 'Conventional 4 QAM-PDM')
plot(10*(stepidx), ceil(min_FFT2), 'b-',  'Display', 'Conventional 16 QAM-PDM')
plot(10*(stepidx), ceil(min_FFT5), 'g--',  'Display', 'Conventional 8 QAM-PDM')
legend('show')
ylim([3 12.5])
xlabel('Fiber length(km)');
ylabel('log_2 (Minimum FFT size )');
title(['FFT size as a function of Fiber length at a given CP ratio = ', num2str(params.CPratio)]);
grid on
%% Plot
figure( 'FileName', 'Fig2_FFTsize.fig'); hold;
plot(10*(stepidx), ceil(min_FFT3), 'r--',  'Display','Proposed 4 QAM-PDM')
plot(10*(stepidx), ceil(min_FFT4), 'b-',  'Display', 'Proposed 16 QAM-PDM')
plot(10*(stepidx), ceil(min_FFT6), 'g--',  'Display', 'Proposed 8 QAM-PDM')
legend('show')
ylim([3 12.5]);
xlabel('Fiber length(km)');
ylabel('log_2 (Minimum FFT size )');
title(['FFT size as a function of Fiber length N_s_u_b_b_a_n_d = ', num2str(Nsubband)]); 
grid on
%% Plot
figure( 'FileName', 'Fig3_FFTsize1.fig'); hold;
plot(10*(stepidx), ceil(min_FFT3), 'r--',  'Display','Proposed 4 QAM-PDM')
% plot(10*(stepidx), ceil(min_FFT4), 'b-',  'Display', 'Proposed 16 QAM-PDM')
% plot(10*(stepidx), ceil(min_FFT6), 'g-',  'Display', 'Proposed 8 QAM-PDM')
plot(10*(stepidx), ceil(min_FFT1), 'r-',  'Display', 'Conventional 4 QAM-PDM')
legend('show')
ylim([3 12.5]);
xlabel('Fiber length(km)');
ylabel('log_2 (Minimum FFT size )');



%% Plot
figure( 'FileName', 'Fig3_FFTsize.fig'); hold;
% plot(10*(stepidx), ceil(min_FFT3), 'r--',  'Display','Proposed 4 QAM-PDM')
% plot(10*(stepidx), ceil(min_FFT4), 'b-',  'Display', 'Proposed 16 QAM-PDM')
plot(10*(stepidx), ceil(min_FFT6), 'g-',  'Display', 'Proposed 8 QAM-PDM')
plot(10*(stepidx), ceil(min_FFT5), 'r-',  'Display', 'Conventional 8 QAM-PDM')
legend('show')
ylim([3 12.5]);
xlabel('Fiber length(km)');
ylabel('log_2 (Minimum FFT size )');

plot(10*(stepidx),  (min_FFT6), 'k--',  'Display', 'Proposed 8 QAM-PDM')
plot(10*(stepidx),  (min_FFT5), 'k--',  'Display', 'Conventional 8 QAM-PDM')
% title(['FFT size as a function of Fiber length N_s_u_b_b_a_n_d = ', num2str(Nsubband)]); 
% grid on
%%
plot(10*(stepidx), 2.^ceil(min_FFT3), 'k--')
plot(10*(stepidx), 2.^ceil(min_FFT4), 'k-')
plot(10*(stepidx), 2.^ceil(min_FFT6), 'k:')

xlabel('Fiber length(km)');
ylabel('log_2 (Minimum FFT size )');
title(['FFT size as given CP ratio = ', num2str(params.CPratio), ' subband =' num2str(Nsubband)  ' OBM=' num2str(Nband) ]); 
%% optimum subband 

SampleTime =Ts2;
figure( 'FileName', 'Fig3_subbandsize_16QAM.fig'); hold;
for Nsub=0:4
    for L =stepidx
        tDGD =   estimate_pmd( fiber, L *10*km);
        tCP =  D * lambda^2/c * 1/SampleTime/(2^Nsub)   *L *10*km +SampleTime;
        min_FFT3(L) = (log2( (tDGD +tCP)/params.CPratio/SampleTime));
    end 
    plot( 10*(stepidx), (min_FFT3), 'k:', 'Display', ['subband', num2str(2^Nsub)])
end
xlabel('Fiber length(km)');
ylabel('log_2 (Minimum FFT size )');
title(['FFT size as a function of Fiber length with 16 QAM-PDM ']);
legend show;
grid on

%%
SampleTime =Ts3;
figure( 'FileName', 'Fig3_subbandsize_8QAM.fig'); hold;

stepidx=(1:10:160);
for Nsub=0:4
    for L =stepidx
        tDGD =   estimate_pmd( fiber, L *10*km);
        tCP =  D * lambda^2/c * 1/SampleTime/(2^Nsub)  *L *10*km +SampleTime;
        min_FFT7(L) = (log2( (tDGD +tCP)/params.CPratio/SampleTime));
    end 
    plot( 10*(stepidx), (min_FFT7(stepidx)), 'k:', 'Display', ['subband', num2str(2^Nsub)])
end
xlabel('Fiber length(km)');
ylabel('log_2 (Minimum FFT size )');
title(['FFT size as a function of Fiber length with 8 QAM-PDM ']);
legend show;
grid on
%%