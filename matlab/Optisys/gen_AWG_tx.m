%% Rha, Haeyoung 10, October!!

%% Initial

laser.freqoff   =  0;
MHz=1e6;GHz=1e9;

osc_sampling = 20*GHz;
tx_sample =10*GHz; % 1250*MHz;
Freq= 20*GHz;
run('./init_OFDM.m')
params.Nbpsc =2;

params.NSymbol= 300;

%% preamble from the realtime transmitter 
params.NSTF = 7;
params.NLTF = 5; 
idx= params.NLTF*144+params.NSTF*128;
Ctx =importdata('Ctx.txt');
in1 = (Ctx(71:length(Ctx(:,1)), 161:192));
in1=reshape(in1', 2,  length(in1)*16);
in1= mod ( in1, 256)-128;
preambleout = complex(in1(1,1:idx), in1(2,1:idx));

% preambleout= Preamble( params );
%% read pbrs
pbrs =importdata('prbs_pattern/prbs15.txt');
totalbits = params.Nbpsc * params.Nsd * params.NSymbol*params.Npol;
tmpdata = pbrs;
%%
for ii=1:ceil(totalbits/length(tmpdata) )
    tmpdata = [tmpdata pbrs];
    length(tmpdata);
end

dataf = tmpdata(1:totalbits);

%% Main body of pattern generate
mapperout     = NMapper( dataf,  params );
pilotout      = NPilot( mapperout, params );
ofdmoutd      = IFFTnAddCP( pilotout, params );  
% ofdmoutd      = 1* 128/max(real(ofdmoutd))*ofdmoutd;
ofdmoutd       = 1/1.026 *ofdmoutd ;
ofdmout       = [preambleout, ofdmoutd];

in_625MHz=ofdmout;
%%



outi = Change_fixed_bit_lim( ofdmout, 8, 0.0228 );

in_625MHz=outi;

dlmwrite('AWG_OFDM_I_digital.txt', real(in_625MHz)', 'newline' , 'pc')
dlmwrite('AWG_OFDM_Q_digital.txt', imag(in_625MHz)', 'newline' , 'pc')
