%% Initialize 
MHz = 1e6;
GHz=1e9;
km=1e3;
Ts1=1/(40*GHz);
sim.coeff =1;
% NFFT =128;
laser.freqoff   =0* 400*MHz;%87*MHz; %96
run('./Init_files/init_OFDM.m')

params.Nstream = 2 ;
params.RXstream = 2 ;
sim.oversample = 2;
sim.MAXSIM= 10;
% 1: Current design, 2: Ref[2] ,3:Idea 2 ,4:Idea 2 -1, 5:Idea 1 6: Ref[8] 
sim.cfotype = 1; 
% sim.precomp_en = 1;
sim.nlcompen  = 1 ;
% span = 34 ;

%% Simulation enviroment 
sim.FiberLength = span * 50*km  ;    
fiber.DeltaH = 50*km ;
sim.precom_CD  = 0;
sim.subband=32;
sim.mode =1;
fixed_sim=0;

run('./Init_files/reinit_OFDM.m');


%% Main body of the simulation

if (sim.cfotype ==5 || sim.cfotype == 1)
    preambleout   = Preamble_1Tone_PreComp( params, sim ) * ...
    params.preamblefactor ;
else    
    preambleout   = Preamble( params ) * params.preamblefactor ;
end

optiout =[];
optidata =[];

[sim.precom_CD, sim.delay] = NCalDelay(fiber, params, sim) ; 
   
      
    avg_cfo_phase =0 ;
%% read pbrs
% pbrs =importdata('prbs15.txt');
% tmpdata = pbrs;
% for ii=1:ceil(totalbits*sim.MAXSIM/length(tmpdata) )
%     tmpdata = [tmpdata pbrs];
%     length(tmpdata);
% end
% sim.userandom =0 ;
%% main loop 


    for numsim=1:sim.MAXSIM
        dataf = GenStim(totalbits, sim, 'prbs15.txt' ) ;
        
        %=================  Transmitter =================
        mapperout     = NMapper( dataf,  params );
        pilotout      = NPilot( mapperout, params );
        ofdmoutd      = IFFTnAddCP_PreComp( pilotout, params, sim ); 
         ofdmout       = NPrecompCD([ ofdmoutd], sim.delay, params);        
        ofdmout       = NPrecompCD([preambleout, ofdmoutd], sim.delay, params);        
        ofdmout       = SPMPreComp( ofdmout, fiber, sim.nlcompen, laser.launch_power);
        ofdmout       = Change_fixed_bit(ofdmout, sim.DACbit);
%         ofdmout       = NLowPassFilter( ofdmout, sim, sim.txLPF_en );
%         ofdmout       = NSamplingFreqOffset( sim.txfreqoff, sim.txtimeoff, ofdmout );

	    optiout =[ optiout ofdmout zeros(params.Nstream, 1000) ];
        optidata =[ optidata  dataf ];
     
    end
    
amp = 1000;
optiout_time = (1:size(optiout,2) )* params.SampleTime- params.SampleTime ;
opti1_i = [ optiout_time; real(optiout(1,:)*amp*NFFT/128)];
opti1_q = [ optiout_time; imag(optiout(1,:)*amp*NFFT/128)];

% dlmwrite('TX128_16QAM_I.tim','time voltage', 'delimiter', ' ')
 
dir_name='D:\user\haeyoung\Project\2012\COOFDM\optisystem\Data50\';
if ( params.Nstream ==2 )
    stim= [ dir_name, 'TX', num2str(NFFT), '_16QAM_2POL'];
    opti2_i = [ optiout_time; real(optiout(2,:)*amp*NFFT/128)];
    opti2_q = [ optiout_time; imag(optiout(2,:)*amp*NFFT/128)];
else    
    stim=  [ dir_name, 'TX', num2str(NFFT), '_16QAM_1POL']
end
filename =[ stim '_I_', num2str(span), '.tim'];
write_ADS( filename, opti1_i );
% dlmwrite(filename, ['BEGIN TIMEDATA'] ,'delimiter','') ;
% dlmwrite(filename, ['# T ( SEC V R 50 )'] ,'delimiter','', '-append') ;
% dlmwrite(filename, ['% t v'] ,'delimiter','', '-append') ;
% dlmwrite(filename,  opti1_i','-append', 'delimiter', '\t','newline' , 'pc','precision', 7)

filename =[ stim '_Q_', num2str(span), '.tim'];
write_ADS( filename, opti1_q );
% dlmwrite(filename, ['BEGIN TIMEDATA'] ,'delimiter','') ;
% dlmwrite(filename, ['# T ( SEC V R 50 )'] ,'delimiter','', '-append') ;
% dlmwrite(filename, ['% t v'] ,'delimiter','', '-append') ;
% dlmwrite(filename,  opti1_q', '-append', 'delimiter', '\t','newline' , 'pc','precision', 7)

filename =[ stim '_', num2str(span), '.dataf'];
dlmwrite(filename,  optidata', 'delimiter', '\t','newline' , 'pc');

if ( params.Nstream ==2 )

    filename =[ stim '_2I_', num2str(span), '.tim'];
%     dlmwrite(filename, ['BEGIN TIMEDATA'] ,'delimiter','') ;
%     dlmwrite(filename, ['# T ( SEC V R 50 )'] ,'delimiter','', '-append') ;
%     dlmwrite(filename, ['% t v'] ,'delimiter','', '-append') ;
%     dlmwrite(filename,  opti2_i','-append', 'delimiter', '\t','newline' , 'pc','precision', 8)
    write_ADS( filename, opti2_i );
    
    filename =[ stim '_2Q_', num2str(span), '.tim'];
%     dlmwrite(filename, ['BEGIN TIMEDATA'] ,'delimiter','') ;
%     dlmwrite(filename, ['# T ( SEC V R 50 )'] ,'delimiter','', '-append') ;
%     dlmwrite(filename, ['% t v'] ,'delimiter','', '-append') ;
%     dlmwrite(filename,  opti2_q', '-append', 'delimiter', '\t','newline' , 'pc','precision', 8)
    write_ADS( filename, opti2_q );

end

%%
% OSNR = Rs/2/Bref *SNR
% Rs: smbol rate
% Bref : Optical reference bandwidth, tpicall 0.1nm or 12.5GHz @1550nm 
