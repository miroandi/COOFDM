off=0;
figure;hold on;
% for tone = 1:8:1024 ;
   freq1 = zeros(1,1024);
   freq1 = ones(1,1024);
   freq1(tone) =1;
   time1=ifft(freq1);
% ofdmout=[ zeros(1,1024) time1, time1, time1, time1, time1, time1, time1
% ];
ofdmout=[  time1, time1, time1, time1, time1, time1, time1, time1, time1, time1, time1, time1, time1, time1 ];
ofdmout = ofdmout * sim.txgain ;
                %============ Electric signal to optical ===============
                [ovoptofdmout, txphase_noise] =  ...
                    elec2opt( ofdmout, laser,  MZmod, txedfa, sim,params );
                %============ Channel ==================================
                noisychannelout =  ...
                    channel( ovoptofdmout , fiber, edfa, sim, params ); 
                %============ Optical signal to electrial ==============
                [noisyreceivein, rxphase_noise] =   ...
                    opt2elec( noisychannelout, lolaser,  PD, rxedfa, sim,params);
                noisyreceivein = NCarrierFreqOffset( noisyreceivein, laser.freqoff );
                noisyreceivein = NLowPassFilter( noisyreceivein, sim, sim.rxLPF_en );
                noisyreceivein = noisyreceivein*sqrt(2);
                
                plot( real(noisyreceivein) +off);
                off = off + 7e-5;
                
% end