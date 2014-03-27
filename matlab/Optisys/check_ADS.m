%% Initialize 


MHz = 1e6;
GHz=1e9;
km=1e3;
Ts1=1/(40*GHz);
sim.coeff = 1;
% NFFT =128;
laser.freqoff   =0* 400*MHz;%87*MHz; %96
run('./Init_files/init_OFDM.m')
sim.oversample = 2;
params.Nstream = 2 ;
params.RXstream = 2 ;
sim.MAXSIM= 10;
% 1: Current design, 2: Ref[2] ,3:Idea 2 ,4:Idea 2 -1, 5:Idea 1 6: Ref[8] 
sim.cfotype = 1; 
sim.precomp_en = precomp_en;
sim.nlcompen  = 0 ;
sim.nlpostcompen  = 1 ;
sim.showinteger =0;
params.Nstream = 2 ;
params.RXstream = 2 ;
sim.enSCFOcomp= 0; % Coarse ( using Short preamble)
sim.enCFOcomp = 0; % Fine, not exact!! dont use.
sim.enSFOcomp = 0;
sim.enCPEcomp = 0; % Common phase  
%% Simulation enviroment 
% sim.FiberLength = span * 50*km  ;    
fiber.DeltaH = 50*km ;
sim.subband=32;
sim.en_fsync_plot =0;
sim.en_cs_plot =0 ;
sim.en_constellation_plot =1;
sim.en_H_plot =0;
% sim.en_ISFA =1 ;
sim.mode =1;
fixed_sim=0;
fiber.FiberLength = 50*km ;
MaxIdx = 55;


run('./Init_files/reinit_OFDM.m');

sim.syncpoint = syncpoint -1 ;

%% Main body of the simulation

% dir_name='D:\user\haeyoung\Project\2012\COOFDM\optisystem\Data\';
filename='128_16QAM';

file = ['RX', filename];

if ( params.Nstream == 1 )
    exp_file = ['TX', filename, '_1POL.dataf'];
    data1 = importdata([dir_name, file, '_I.tim']);
    RX128_16QAM_I= data1.data(:,2);
    data1 = importdata([dir_name, file, '_Q.tim']);
    RX128_16QAM_Q= data1.data(:,2);
    RX128= complex(RX128_16QAM_I', RX128_16QAM_Q');
else
%     exp_file = ['TX', filename, '_2POL.dataf'];
%     data1 = importdata([dir_name, file, '_1I.tim']);
%     data2 = importdata([dir_name, file, '_1Q.tim']);
%     data3 = importdata([dir_name, file, '_2I.tim']);
%     data4 = importdata([dir_name, file, '_2Q.tim']);
    
    data1 = importdata(filename6);
    data2 = importdata(filename7);
    data3 = importdata(filename8);
    data4 = importdata(filename9);
    RX128_16QAM_1I= data1.data(:,2);
    RX128_16QAM_1Q= data2.data(:,2);
    RX128_16QAM_2I= data3.data(:,2);
    RX128_16QAM_2Q= data4.data(:,2);
    RX128= [complex(RX128_16QAM_1I', RX128_16QAM_1Q'); complex(RX128_16QAM_2I', RX128_16QAM_2Q');];
end

%% Delay
[sim.precom_CD, sim.delay] = NCalDelay(fiber, params, sim) ; 
%% Expected data
% exp_data = importdata([dir_name, exp_file]);

pbrs =importdata('prbs15.txt');
tmpdata = pbrs';
for ii=1:ceil(totalbits*sim.MAXSIM/length(pbrs) )
    tmpdata = [tmpdata pbrs'];
    length(tmpdata);
end
exp_data = tmpdata;

%%
demapperout=[];

    len=144*4 + 30 *144+2+1000; 
    len=params.NSample+params.NSTF*params.lenSTF+max(sim.delay)+1000+2;
    idx =0 ;
    amp = 1000;
    params.cs_thres = 1.5e-3 * amp/1000*128/params.NFFT;
% for ii=1:floor(size(RX128,2)/len)
nframe=0;
theta = 0*2*-pi/2*1/40* span/60 ;
amp = exp( 1i*theta);
while ((idx + len) < size(RX128,2))
%     idx = idx +NRxFindCS( RX128(:, idx+1:idx+len), params,params.cs_thres, sim.en_cs_plot);
    idx=idx+1;
    RX =RX128(:,idx+1:idx+len);
%     RX =  SPMPostComp( RX, fiber, sim.nlpostcompen, span, 1  );
    agcout = NRxAGC (RX , params, sim);
    [H, channelout,cfo_phase, cfo_phase_8,cfo_phase_17 ] = NRxChannelEst( agcout, params, sim);
    [fftout, commonphase,timingoffset]   = FFTnRemoveCP( channelout, H, params, sim);
    fftout(1,:) = amp * fftout(1,:);
    fftout(2,:) = amp * fftout(2,:);
    demapperout = [demapperout NRxDemapper( fftout,1, params )];
    evmout = NMapper_EVM ( demapperout,  params );
    if ( sim.en_constellation_plot == 1 )  
%         subplot(2,1,1);
        plot(fftout(1,:), '*'); hold;
        plot(evmout(1,:), 'r*'); hold;
        ylim([-1.5 1.5]);xlim([-1.5 1.5]); 
%         subplot(2,1,2);
        plot(fftout(2,:), '*'); hold;
        plot(evmout(2,:), 'r*'); hold;
        ylim([-1.5 1.5]);xlim([-1.5 1.5]);
%         evmout_sc = reshape( evmout(1,:), params.Nsd , length(fftout(1,:))/params.Nsd );
%         fftout_sc = reshape( fftout(1,:), params.Nsd , length(fftout(1,:))/params.Nsd );
%         error = abs(fftout_sc-evmout_sc);
%         signal = abs(evmout_sc);
%         EVM_dB_sc = 10*log10(sum(error .^2, 2 )./sum(signal .^2,2 ));
    end
    idx=idx+len-1;
    nframe=nframe+1;
   
end        
   
%  fftout_sc = reshape( fftout, params.Nsd , length(fftout)/params.Nsd );
%  fftout_sym = reshape( fftout',  length(fftout)/params.Nsd, params.Nsd );
%  
%   evmout = NMapper_EVM ( demapperout,  params );
%% BER

bitnum = min( size(demapperout,2),size(exp_data,2));
err=length(find(demapperout(1:bitnum)~=exp_data(1:bitnum)));
ber= err/bitnum;
disp(['BER :', num2str( ber), '. Number of bit',num2str( bitnum) ]);
disp(['Number of frame',num2str( nframe) ]);
%%
% OSNR = Rs/2/Bref *SNR
% Rs: smbol rate
% Bref : Optical reference bandwidth, tpicall 0.1nm or 12.5GHz @1550nm 
