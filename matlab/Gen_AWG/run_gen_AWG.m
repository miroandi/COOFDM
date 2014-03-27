sim.en_optisyschannel =0;
sim.en_read_ADS =0;
sim.en_gen_ADS =1;

sim_mode=1;
dirdlm = 'D:\user\haeyoung\Project\2014\matlab_23Dec\Gen_AWG\CFO5_SPM\';
sdirdlm = [dirdlm 'Single\'];
logfile = [dirdlm '4QAMlog.txt'];
MHz = 1e6;
GHz=1e9;
kHz=1e3;
km=1e3;

NFFT=128;
[sim, params, MZmod,fiber,laser, iolaser, txedfa, edfa, rxedfa, PD]= InitOFDM_22Jan(NFFT, 1, 1/( 10*GHz ));
sim.enSCFOcomp= 1 ;
sim.cfotype = 4; % 
sim.cetype= 7;
sim.nophase =1 ;
sim.useprbsdata =1;
sim.txgain = 0.7;
sim.Clipping_dB = 16;  % Clipping level 
sim.noClip = 0;
sim.zerohead2=0;
sim.syncpoint=2;
linewidth  = 500*kHz;
SNR = 18;
noise_en = 0 ;
sim.preemphasis_H_en = 1;  % 수신 channel matrix를 이용한 equalization 
preemphasis_filter_en = 0; % filte를 이용한 equalization 
params.ignore_edge_sb = 1;
%% NL compensation
sim.nlcompen = 0; % Nonlinear compensation 
sim.nlc_coef = 0.5  ; 
sim.multi_level =0;
sim.ofde = 0.4;
sim.en_OFDE=0;
% txedfa.gain_dB =12-0.4314-4.5;
sim.FiberLength=1200*km;
%%
[sim, params ]=  ...
    ReInitOFDM('Test.txt', sim, params, MZmod,fiber,laser, iolaser, txedfa, edfa, rxedfa, PD );
% sim.MAXSIM=1;
%% initialization for the simuation
optiout =[];
dataf_t =[];
[sim.precom_CD, sim.delay, sim.phase ] = NCalDelay_ver2(fiber, params, sim) ;   
optiout=[];
snr1=0;
% Hpre = dlmread('H10G.txt');
% params.Hpre = ones(1, params.NFFT);
% params.Hpre(params.LTFindex) = 1 ./ Hpre(params.LTFindex);
%% Running simulation
preambleout   = Preamble_PreComp( params, sim ) * params.preamblefactor ;


for numsim=1:sim.MAXSIM
    dataf = GenStim(params.totalbits , sim, 'prbs15.txt', dataf_t, mod((numsim-1)*params.totalbits , 2^15-1) ) ; 
%     dataf = GenStim(params.totalbits , sim, 'prbs15.txt', dataf_t, mod((numsim )*params.totalbits , 2^15-1) ) ; 
    ofdmout=  TxMain( dataf,preambleout, sim, params, txedfa, edfa, laser, fiber,MZmod );
    eofdmout      = [ ofdmout * sim.txgain  ]; 
    if ( params.MIMO_emul == 0 )
        optiout       = [ optiout eofdmout(1,:) ...
                      0*ones(1, sim.zeropad) ...
                      0.4*ones(1, sim.zeropad1) ...                    
                      ]; %% Export data to optisys
    else
        optiout       = [ optiout eofdmout(1,:) ...
                          0*ones(1, sim.zeropad) ...
                          0.25*ones(1, sim.zeropad1) ...
                          eofdmout(1, (size(eofdmout, 2)-sim.zeropad2+1):size(eofdmout, 2)) ...
                          zeros(1, 144), ...
                          ]; %% Export data to optisys 
    end
end

% optiout1 = (1:size(optiout,2)) * 2 /(size(optiout,2)) - 1 ;
% optiout2 = sin(2*pi*(1:size(optiout,2))/(size(optiout,2)) ) ;

if ( preemphasis_filter_en == 1)
    bpre=[1 -0.5];
    apre=[1];
    optiout=filter(bpre,apre,optiout);
end


mean_amp1 = (mean(abs(real(optiout))) + mean(abs(imag(optiout))))/2;
% max_amp = mean_amp * 10^( sim.Clipping_dB/20);


%% Clip
if ( sim.noClip == 0 )
    max_amp = 0.6;
    mean_amp = max_amp / 10^( sim.Clipping_dB/20);
    optiout = optiout * mean_amp/mean_amp1 ;
    optiout =  max(-max_amp, min( max_amp, real(optiout))) ...
            + 1j * max(-max_amp, min( max_amp, imag(optiout)));

% No clip 
else
    max_amp= 1;
    optiout = optiout * max_amp / max(max(abs(real(optiout))), max(abs(imag(optiout))));
end


if ( params.MIMO_emul == 0 )
    optiout_wr = optiout(1,:);
else
    optiout2 =  circshift(optiout(1,:), [0, 144]);
    optiout_wr =  [optiout(1,:); optiout2;]  ;
end
    %% CFO 
% noisyreceivein = NCarrierFreqOffset( noisyreceivein, laser.freqoff );
% optiout = 1 *ones(size(optiout));


if ( noise_en == 1 )
    noise=AddAWGN(optiout_wr, SNR, sim );
    phasenoise = AddPhaseNoise( optiout_wr, params.SampleTime, linewidth );   
else
    noise = zeros( size(optiout_wr));
    phasenoise = zeros( 1, size(optiout_wr, 2));
end


%% Generate
sim.SNR =SNR ;
% 
% optiout_wr(1,:)= optiout(1,:) *1 + optiout2*1*  1/3;
% optiout_wr(2,:)= optiout(1,:) * 1/3 + optiout2 * 1;
% optiout_wr=optiout_wr .* (ones(size(optiout_wr, 1),1) *exp( 1j * phasenoise ));
% optiout_wr=optiout_wr+noise;% 
% optiout_wr =1/2*[optiout_wr optiout_wr];
% optiout_wr=[optiout_wr(:,size(optiout_wr,2)-220:size(optiout_wr,2)) optiout_wr];
gennerate_AWG( 1, optiout_wr     , dataf_t, dirdlm, params, sim, edfa );
