
%% Initial setting 
laser.freqoff   =  0* 500 ; 
run('./init_OFDM.m')
sim.oversample = 2;
sim.MAXSIM= 1;
% 1: Current design, 2: Ref[2] ,3:Idea 2 ,4:Idea 2 -1, 5:Idea 1 6: Ref[8] 
sim.cfotype = 1;  
params.NLTF =1;
params.NSymbol=1;
params.CPratio=0;
totalbits = params.Nbpsc * params.Nsd * params.NSymbol;

sim.lut_bit = 6; 
sim.fftout = 5;


QAM_gain =1/sqrt(length(params.SubcarrierIndex)) ;
LTF_gain = 1*sqrt(1/(sum( abs(params.LTF) .* abs(params.LTF) )));
STF_gain = 1*sqrt(1/(sum( abs(params.STF) .* abs(params.STF) )));
 
%% How to determine the bits of the LUT output and the fixed point 
% 1.  Obtain the average value of the FFT LUT output in floating point.
% 
fftsize = params.NFFT;
dataf = rand(1,totalbits) > 0.5;
mapperout     = NMapper( dataf,  params );
pilotout      = NPilot( mapperout, params ) ; 
pilotout      = pilotout  *1/sqrt(length(params.SubcarrierIndex));
luto = zeros( fftsize, fftsize);
for isize=1:fftsize
    luto( :, isize ) =  pilotout .* ...
        exp(  1i*2*pi/fftsize * (isize-1) *(0:fftsize-1))/fftsize ;
end

max_lut1 = max( max(max(abs(imag(luto)))),max(max(abs(real(luto)))));
mean_lut = 0.5*(mean(mean(abs(imag(luto)))) + mean(mean(abs(real(luto)))));

%% 2. Obtain the average value of the FFT output in floating point 
max_fft =0 ;
mean_fft = 0;
for numsim=1:100 
    dataf = rand(1,totalbits) > 0.5;
    mapperout     = NMapper( dataf,  params );
    pilotout      = NPilot( mapperout, params );
    pilotout      = pilotout  *1/sqrt(length(params.SubcarrierIndex));

    ofdmoutd      = IFFTnAddCP( pilotout, params );   
    max_fft = max( max_fft, max( max(abs(real(ofdmoutd))), max(abs(imag(ofdmoutd)))));
    mean_fft = mean_fft + ( mean(abs(real(ofdmoutd))) + mean(abs(imag(ofdmoutd))) );
end 
 mean_fft = mean_fft/2/numsim;  


sim.lut_max = max_lut1 ;
sim.fft_max = sim.lut_max * 2 ; 
% sim.lut_max = mean_fft * 2;
% sim.fft_max = mean_fft * 2 ;
%% Initial search of SQNR of ( preamble, data symbol)

%% 3. Obtain LUT bit size , FFT bit size 
% For various clipping ratio, EVM will be obtained
% for 4QAM  data symbol
params.CPratio=0;
params.Nbpsc=2;
totalbits = params.Nbpsc * params.Nsd * params.NSymbol;
sim.lut_max = max_lut1 ;
figure( 'FileName', 'SQNR_bits_32.fig');hold;
SQNR=[];
for  fft_bit= 7 :10
    for  lut_bit=5:20 
    
        sim.lut_bit = lut_bit;
        sim.fftout = fft_bit;
        sim.fft_max = 32 * max_lut1;
        QNR =0;
        for numsim=1:100
            dataf = rand(1,totalbits) > 0.5;
            mapperout     = NMapper( dataf,  params );
            pilotout      = NPilot( mapperout, params );
            ofdmoutd      = IFFTnAddCP( pilotout, params );   %Floating 
            ofdmout   = ifft_lut(  pilotout *1/sqrt(length(params.SubcarrierIndex)), sim );
            QNR = QNR + sum(abs(ofdmout-ofdmoutd))/sum(abs(ofdmoutd));            
        end
        SQNR(sim.lut_bit,fft_bit)= -20*log10( QNR/numsim );
    end
    plot( SQNR( 5:20 , fft_bit), 'g', 'Display', ['FFT output bits:', num2str(fft_bit)]);
end 
xlabel('The numbers of LUT output bits') ; 
ylabel('SQNR(dB)') ; 
title('SQNR as a function of LUT output bits at the clipping ratio = 32');

%% 4. Clipping Ratio (QAM)

sim.lut_bit = 7;
sim.fftout = 8;
max_lut = max_lut1 / 32 *36 ;
sim.lut_max= max_lut  ;

params.CPratio=0;
params.Nbpsc=2;
totalbits = params.Nbpsc * params.Nsd * params.NSymbol;
figure( 'FileName', ['EVM_clipping_', num2str(sim.lut_bit), '.fig']);hold;
inum=0;
istart = max_lut     ;
iend = max_lut * 30 ;
istep = max_lut/2  ;
SQNR=[];
EVM=[];

for ibit=7:9
    inum=0;
    for  lut_max=istart:istep:iend
        sim.fftout = ibit;
        inum = inum +1;
        sim.fft_max  = lut_max;
        QNR =0;
        EVMt = 0 ; % temporary 
        for numsim=1:200  
            dataf = rand(1,totalbits) > 0.5;
            mapperout     = NMapper( dataf,  params );
            pilotout      = NPilot( mapperout, params );
            ofdmoutd      = IFFTnAddCP( pilotout, params );   %Floating 
            ofdmout   = ifft_lut(  pilotout *1/sqrt(length(params.SubcarrierIndex)), sim );
            QNR = QNR + sum(abs(ofdmout-ofdmoutd))/sum(abs(ofdmoutd));
            ideal_rx = pilotout *1/sqrt(length(params.SubcarrierIndex));
            lut_rx = fft( ofdmout );
            EVMt = EVMt + sum(abs(ideal_rx-lut_rx))/sum(abs(ideal_rx));
        end
        SQNR(inum)= -20*log10( QNR/numsim );
        EVM(inum) = 20*log10( EVMt/numsim);
    end   
%     plot( SQNR , 'gs', 'Display', [ 'FFTbit = ', num2str(sim.fftout)]);
    plot( EVM , 'k', 'Display', [ 'FFTbit = ', num2str(sim.fftout)]);
end 
xlabel('FFT output clipping value') ; 
% ylabel('SQNR(dB)') ; 
ylabel('EVM(dB)') ; 
title(['EVM as a function of clipping at the LUT bit'  num2str(sim.lut_bit) ]);

%% Determine parameters

sim.lut_max  = max_lut1  / 32 *36   ;
sim.fft_max  = sim.lut_max *32 ;
sim.fftout   = 8;
sim.lut_bit  = 6;


%% 5. Obtain SQNR for Preamble

if (sim.cfotype ==5)
    preambleout   = Preamble_1Tone ( params )  ;
    STF_1tone = zeros(1,params.NFFT);
    STF_1tone(3) = STF_gain* 1/2*(1 +1j );
else   
    
    preambleout   = Preamble( params )  ;
end

preambleout1   = ifft_lut( STF_gain*(params.STF)/2 , sim );
ref=preambleout(1:fftsize)/2;
SQNR=-20*log10( sum(abs(preambleout1-ref))/sum(abs(ref) )); 
disp(['SQNR of STF: ' num2str(SQNR), 'dB']);

preambleout2   = ifft_lut( LTF_gain* params.LTF , sim );
ref=preambleout(length(preambleout)-fftsize+1:length(preambleout));
SQNR=-20*log10( sum(abs(preambleout2-ref))/sum(abs(ref) ));
disp(['SQNR of LTF: ' num2str(SQNR), 'dB']);
%% 6. SQNR for data symbol for 4QAM 
QNR =0;
        for numsim=1:100
            dataf = rand(1,totalbits) > 0.5;
            mapperout     = NMapper( dataf,  params );
            pilotout      = NPilot( mapperout, params );
            ofdmoutd      = IFFTnAddCP( pilotout, params );   %Floating 
            ofdmout   = ifft_lut(  pilotout *1/sqrt(length(params.SubcarrierIndex)), sim );
            QNR = QNR + sum(abs(ofdmout-ofdmoutd))/sum(abs(ofdmoutd));            
        end
        SQNR= -20*log10( QNR/numsim );
disp(['SQNR of Data: ' num2str(SQNR), 'dB']);

%% Make LUT memory
% 4 QAM 
% QAM_gain =1/sqrt(length(params.SubcarrierIndex));
% (1+1j)*1/sqrt(length(params.SubcarrierIndex))
% (-1+1j)*1/sqrt(length(params.SubcarrierIndex))
% (1-1j)*1/sqrt(length(params.SubcarrierIndex))
% (-1-1j)*1/sqrt(length(params.SubcarrierIndex))
% STF
% STF_1tone(3) = 1/2*(1 +1j );
% 0
% LTF 
% LTF_gain = 1*sqrt(1/(sum( abs(params.LTF) .* abs(params.LTF) )));
%  1*sqrt(1/(sum( abs(params.LTF) .* abs(params.LTF) )))
% -1*sqrt(1/(sum( abs(params.LTF) .* abs(params.LTF) )))
% Pilot 
 
input_sets = [  0 ...                   % DC, unused subcarrier 
                STF_gain*(1 +1j)*1/sqrt(2) ...         % short preamble (singletone)
                QAM_gain*(1+1j)*1/sqrt(2)  ...    % QAM 
                QAM_gain*(1-1j)*1/sqrt(2)  ...
                QAM_gain*(-1+1j)*1/sqrt(2)  ...
                QAM_gain*(-1-1j)*1/sqrt(2) ...
                LTF_gain ...            % LTF, Pilot  
                LTF_gain * -1 ];        % LTF, Pilot       

addr_bits = ceil( log2( length(input_sets)* fftsize ));

%% Single stream 
for lut_num= 9:10
    filename = ['./vlog\lut_rom_real_', num2str(lut_num), '.v'];
    dlmwrite(filename, ['module lut_rom_real_' num2str(lut_num) '( clk, resetn, a, z ) ;' ],'delimiter','', '-append') ;  
    dlmwrite(filename, ['    parameter ADDR_BIT = ' num2str(addr_bits) ' ;' ],'delimiter','', '-append') ;    
    dlmwrite(filename, ['    parameter LUT_OUT = ' num2str(sim.lut_bit) ' ;' ],'delimiter','', '-append') ;  
    dlmwrite(filename, '    input clk, resetn;','delimiter','', '-append') ;
    dlmwrite(filename, '    input [ADDR_BIT-1:0] a;','delimiter','', '-append') ;
    dlmwrite(filename, '    output signed [LUT_OUT-1:0] z;','delimiter','', '-append') ;
    dlmwrite(filename, '    reg signed [LUT_OUT-1:0] z_wire;','delimiter','', '-append') ;
   
    dlmwrite(filename, '    always @(addr)','delimiter','', '-append') ;
    dlmwrite(filename, '        case @(addr)','delimiter','', '-append') ;
    for iaddr=1:length(input_sets)
        in = input_sets(iaddr) ;        
        for isize=1:fftsize 
            out = in * exp(  1i*2*pi/fftsize * (lut_num-1) *(isize-1))/fftsize ;
            addr = isize + (iaddr-1) * fftsize ;
            out = Change_fixed_bit_lim( out, sim.lut_bit , sim.lut_max  );
            out = out /sim.lut_max  *2^(sim.lut_bit-1);
            dlmwrite(filename, [ '            ' num2str( addr) ': z_wire = '  num2str(real(out))  ';' ],'delimiter','', '-append') ;
            out1(isize, iaddr) =real(out);
        end 
    end
    dlmwrite(filename, '            default: z_wire = 0 ; ','delimiter','', '-append') ;
    dlmwrite(filename, '        endcase ','delimiter','', '-append') ;
    dlmwrite(filename, '	rgtr #(LUT_OUT) u0 ( clk, resetn, z_wire, z );	 ','delimiter','', '-append') ;
    dlmwrite(filename, 'endmodule','delimiter','', '-append') ;
end
       
% Imaginary LUT ROM 
for lut_num= 9:10
    filename = ['./vlog\lut_rom_imag_', num2str(lut_num), '.v'];
    dlmwrite(filename, ['module lut_rom_imag_' num2str(lut_num) '( clk, resetn, a, z ) ;' ],'delimiter','', '-append') ;  
    dlmwrite(filename, ['    parameter ADDR_BIT = ' num2str(addr_bits) ' ;' ],'delimiter','', '-append') ;    
    dlmwrite(filename, ['    parameter LUT_OUT = ' num2str(sim.lut_bit) ' ;' ],'delimiter','', '-append') ;  
    dlmwrite(filename, '    input clk, resetn;','delimiter','', '-append') ;
    dlmwrite(filename, '    input [ADDR_BIT-1:0] a;','delimiter','', '-append') ;
    dlmwrite(filename, '    output signed [LUT_OUT-1:0] z;','delimiter','', '-append') ;
    dlmwrite(filename, '    reg signed [LUT_OUT-1:0] z_wire;','delimiter','', '-append') ;
   
    dlmwrite(filename, '    always @(addr)','delimiter','', '-append') ;
    dlmwrite(filename, '        case @(addr)','delimiter','', '-append') ;
    for iaddr=1:length(input_sets)
        in = input_sets(iaddr) ;        
        for isize=1:fftsize 
            out = in * exp(  1i*2*pi/fftsize * (lut_num-1) *(isize-1))/fftsize ;
            addr = isize + (iaddr-1) * fftsize ;
            out = Change_fixed_bit_lim( out, sim.lut_bit , sim.lut_max  );
            out = out /sim.lut_max  *2^(sim.lut_bit-1);
            dlmwrite(filename, [ '            ' num2str( addr) ': z_wire = '  num2str(imag(out))  ';' ],'delimiter','', '-append') ;
            out1(isize, iaddr) =imag(out);
        end 
    end
    dlmwrite(filename, '            default: z_wire = 0 ; ','delimiter','', '-append') ;
    dlmwrite(filename, '        endcase ','delimiter','', '-append') ;
    dlmwrite(filename, '	rgtr #(LUT_OUT) u0 ( clk, resetn, z_wire, z );	 ','delimiter','', '-append') ;
    dlmwrite(filename, 'endmodule','delimiter','', '-append') ;
end
  

%% 16 parallel 
for lut_num= 1:128
    filename = ['./vlog\lut_rom_real_', num2str(lut_num), '.v'];
    dlmwrite(filename, ['module lut_rom_real_' num2str(lut_num) '( clk, resetn, en, addr, z0, z1, z2, z3, z4, z5, z6, z7, z8, z9, z10, z11, z12, z13, z14, z15 ) ;' ],'delimiter','', '-append') ;  
    dlmwrite(filename, ['    parameter ADDR_BIT = ' num2str(addr_bits-4) ' ;' ],'delimiter','', '-append') ;    
    dlmwrite(filename, ['    parameter LUT_OUT = ' num2str(sim.lut_bit) ' ;' ],'delimiter','', '-append') ;  
    dlmwrite(filename, '    input clk, resetn, en;','delimiter','', '-append') ;
    dlmwrite(filename, '    input [ADDR_BIT-1:0] addr;','delimiter','', '-append') ;
    dlmwrite(filename, '    output signed [LUT_OUT-1:0] z0, z1, z2, z3, z4, z5, z6, z7;','delimiter','', '-append') ;
    dlmwrite(filename, '    output signed [LUT_OUT-1:0] z8, z9, z10, z11, z12, z13, z14, z15;','delimiter','', '-append') ;
    dlmwrite(filename, '    reg  signed [LUT_OUT-1:0] z0, z1, z2, z3, z4, z5, z6, z7;','delimiter','', '-append') ;
    dlmwrite(filename, '    reg  signed [LUT_OUT-1:0] z8, z9, z10, z11, z12, z13, z14, z15;','delimiter','', '-append') ;
    dlmwrite(filename, ['    reg signed [' num2str(sim.lut_bit-1) ':0] rom[15:0];'],'delimiter','', '-append') ;
   
    dlmwrite(filename, '    always @(addr)','delimiter','', '-append') ;
    dlmwrite(filename, '        case (addr)','delimiter','', '-append') ;
    for iaddr=1:length(input_sets)
        in = input_sets(iaddr) ;        
        for isize=1:fftsize/16 
            
            out = in * exp(  1i*2*pi/fftsize * (lut_num-1) *((isize-1)*16+(0:15)))/fftsize ;
            addr = isize + (iaddr-1) * fftsize/16 -1;
            out = Change_fixed_bit_lim( out, sim.lut_bit , sim.lut_max  );
            out = out /sim.lut_max  *(2^(sim.lut_bit-1) -1);
            dlmwrite(filename, [ '            ' num2str( addr) ': begin' ],'delimiter','', '-append') ;
            
            for ii=0:15
                dlmwrite(filename, [ '                rom[' num2str(ii) '] = '  num2str(real(out(ii+1)))  ';' ],'delimiter','', '-append') ;
            end
            dlmwrite(filename, [ '            end' ],'delimiter','', '-append') ;
        end 
    end
    dlmwrite(filename, ['            default: begin  '] ,'delimiter','', '-append') ;
    dlmwrite(filename, [ ...
        '                 rom[15] =0; rom[14]=0; rom[13]=0; rom[12]=0; '...
        'rom[11]=0; rom[10]=0; rom[9]=0; rom[8]=0; '...
        'rom[7]=0; rom[6]=0; rom[5]=0; rom[4]=0; '...
        'rom[3]=0; rom[2]=0; rom[1]=0; rom[0]=0;  ' ]...
        ,'delimiter','', '-append') ;
    dlmwrite(filename, ['           end  '] ,'delimiter','', '-append') ;
    dlmwrite(filename, '        endcase ','delimiter','', '-append') ;
    dlmwrite(filename, '	always @(posedge clk ) begin	 ','delimiter','', '-append') ;
    for ii=0:1:15
        dlmwrite(filename, ['                 z', num2str(ii), ' <= rom[', num2str(ii), '][' num2str(sim.lut_bit-1)  ':' num2str(sim.lut_bit) '-LUT_OUT];'],'delimiter','', '-append') ;
    end
     dlmwrite(filename, '	end	 ','delimiter','', '-append') ;
    dlmwrite(filename, 'endmodule','delimiter','', '-append') ;
end
  

for lut_num= 1:128
    filename = ['./vlog\lut_rom_imag_', num2str(lut_num), '.v'];
    dlmwrite(filename, ['module lut_rom_imag_' num2str(lut_num) '( clk, resetn, en,addr, z0, z1, z2, z3, z4, z5, z6, z7, z8, z9, z10, z11, z12, z13, z14, z15 ) ;' ],'delimiter','', '-append') ;  
    dlmwrite(filename, ['    parameter ADDR_BIT = ' num2str(addr_bits-4) ' ;' ],'delimiter','', '-append') ;    
    dlmwrite(filename, ['    parameter LUT_OUT = ' num2str(sim.lut_bit) ' ;' ],'delimiter','', '-append') ;  
    dlmwrite(filename, '    input clk, resetn, en;','delimiter','', '-append') ;
    dlmwrite(filename, '    input [ADDR_BIT-1:0] addr;','delimiter','', '-append') ;
    dlmwrite(filename, '    output signed [LUT_OUT-1:0] z0, z1, z2, z3, z4, z5, z6, z7;','delimiter','', '-append') ;
    dlmwrite(filename, '    output signed [LUT_OUT-1:0] z8, z9, z10, z11, z12, z13, z14, z15;','delimiter','', '-append') ;
    dlmwrite(filename, '    reg  signed [LUT_OUT-1:0] z0, z1, z2, z3, z4, z5, z6, z7;','delimiter','', '-append') ;
    dlmwrite(filename, '    reg  signed [LUT_OUT-1:0] z8, z9, z10, z11, z12, z13, z14, z15;','delimiter','', '-append') ;
    dlmwrite(filename, ['    reg signed [' num2str(sim.lut_bit-1) ':0] rom[15:0];'],'delimiter','', '-append') ;
   
    dlmwrite(filename, '    always @(addr)','delimiter','', '-append') ;
    dlmwrite(filename, '        case (addr)','delimiter','', '-append') ;
    for iaddr=1:length(input_sets)
        in = input_sets(iaddr) ;        
        for isize=1:fftsize/16 
            out = in * exp(  1i*2*pi/fftsize * (lut_num-1) *((isize-1)*16+(0:15)))/fftsize ;
            addr = isize + (iaddr-1) * fftsize/16 -1;
            out = Change_fixed_bit_lim( out, sim.lut_bit , sim.lut_max  );
            out = out /sim.lut_max  *(2^(sim.lut_bit-1) -1);
            dlmwrite(filename, [ '            ' num2str( addr) ': begin' ],'delimiter','', '-append') ;
            for ii=0:15
                dlmwrite(filename, [ '                rom[' num2str(ii) '] = '  num2str(imag(out(ii+1)))  ';' ],'delimiter','', '-append') ;
            end
            dlmwrite(filename, [ '            end' ],'delimiter','', '-append') ;
        end 
    end
    dlmwrite(filename, ['            default: begin  '] ,'delimiter','', '-append') ;
    dlmwrite(filename, [ ...
        '                 rom[15] =0; rom[14]=0; rom[13]=0; rom[12]=0; '...
        'rom[11]=0; rom[10]=0; rom[9]=0; rom[8]=0; '...
        'rom[7]=0; rom[6]=0; rom[5]=0; rom[4]=0; '...
        'rom[3]=0; rom[2]=0; rom[1]=0; rom[0]=0;  ' ]...
        ,'delimiter','', '-append') ;
    dlmwrite(filename, ['           end  '] ,'delimiter','', '-append') ;
    dlmwrite(filename, '        endcase ','delimiter','', '-append') ;
    dlmwrite(filename, '	always @(posedge clk ) begin	 ','delimiter','', '-append') ;
    for ii=0:1:15
        dlmwrite(filename, ['                 z', num2str(ii), ' <= rom[', num2str(ii), '][' num2str(sim.lut_bit-1)  ':' num2str(sim.lut_bit) '-LUT_OUT];'],'delimiter','', '-append') ;
    end
     dlmwrite(filename, '	end	 ','delimiter','', '-append') ;dlmwrite(filename, 'endmodule','delimiter','', '-append') ;
end
  

%% %% Make LUT memory (add 2 successive sc freq)

QAM0 =QAM_gain*(1+1j)*1/sqrt(2);
QAM1 =QAM_gain*(1-1j)*1/sqrt(2) ;
QAM2 =QAM_gain*(-1+1j)*1/sqrt(2);
QAM3 = QAM_gain*(-1-1j)*1/sqrt(2);
 
% addr 
% 0 : LTF_gain       LTF_gain 
% 1 : LTF_gain       -LTF_gain 
% 2 : QAM0            QAM0
% 3 : QAM0            QAM1
% 4 : QAM0            QAM2
% 5 : QAM0            QAM3
% 6 : QAM1            QAM0
% 7 : QAM1            QAM1
% 8 : QAM1            QAM2
% 9 : QAM1            QAM3


% 10 :- LTF_gain      -LTF_gain   => ~(0)
% 11 :- LTF_gain       LTF_gain   => ~(1)
% 12 : QAM3            QAM3       => ~2
% 13 : QAM3            QAM2       => ~3
% 14 : QAM3            QAM1       => ~4
% 15 : QAM3            QAM0       => ~5
% 16 : QAM2            QAM3       => ~6
% 17 : QAM2            QAM2       => ~7
% 18 : QAM2            QAM1       => ~8
% 19 : QAM2            QAM0       => ~9

% 0 : LTF_gain       LTF_gain 
% 1 : LTF_gain       -LTF_gain 
% 2 : QAM0            QAM0
% 3 : QAM0            QAM1
% 4 : QAM0            QAM2
% 5 : QAM0            QAM3
% 6 : QAM1            QAM0
% 7 : QAM1            QAM1
% 8 : QAM1            QAM2
% 9 : QAM1            QAM3
input_sets = [  [LTF_gain       LTF_gain]; ...            
                [LTF_gain       -LTF_gain];  ...    % QAM 
                [QAM0            QAM0]; ...
                [QAM0            QAM1] ;...
                [QAM0            QAM2]; ...
                [QAM0            QAM3]; ...
                [QAM1            QAM0]; ...
                [QAM1            QAM1] ;...
                [QAM1            QAM2]; ...
                [QAM1            QAM3]; ...
 ];        % LTF, Pilot       

addr_bits = ceil( log2( length(input_sets)* fftsize ));
% addr_bits = 5 + ceil( log2( fftsize ));
sim.lut_bit = sim.lut_bit +1 ;
sim.lut_max =  sim.lut_max*2;
parallel = 16; 
%%

for lut_num= 1:2:128
    filename = ['./vlog2\lut_rom_', num2str(lut_num), '.v'];
    dlmwrite(filename, ['module lut_rom_' num2str(lut_num) '( clk, resetn, en, addr, z0, z1, z2, z3, z4, z5, z6, z7, z8, z9, z10, z11, z12, z13, z14, z15 ) ;' ],'delimiter','', '-append') ;  
    dlmwrite(filename, ['    parameter ADDR_BIT = ' num2str(addr_bits-4) ' ;' ],'delimiter','', '-append') ;    
    dlmwrite(filename, ['    parameter LUT_OUT = ' num2str(sim.lut_bit) ' ;' ],'delimiter','', '-append') ;  
    dlmwrite(filename, '    input clk, resetn, en;','delimiter','', '-append') ;
    dlmwrite(filename, '    input [ADDR_BIT-1:0] addr;','delimiter','', '-append') ;
    dlmwrite(filename, '    output  [LUT_OUT*2-1:0] z0, z1, z2, z3, z4, z5, z6, z7;','delimiter','', '-append') ;
    dlmwrite(filename, '    output  [LUT_OUT*2-1:0] z8, z9, z10, z11, z12, z13, z14, z15;','delimiter','', '-append') ;
    dlmwrite(filename, '    reg   [LUT_OUT*2-1:0] z0, z1, z2, z3, z4, z5, z6, z7;','delimiter','', '-append') ;
    dlmwrite(filename, '    reg   [LUT_OUT*2-1:0] z8, z9, z10, z11, z12, z13, z14, z15;','delimiter','', '-append') ;
    dlmwrite(filename, ['    reg signed [' num2str(sim.lut_bit-1) ':0] romr[15:0];'],'delimiter','', '-append') ;
    dlmwrite(filename, ['    reg signed [' num2str(sim.lut_bit-1) ':0] romi[15:0];'],'delimiter','', '-append') ;
   
    dlmwrite(filename, '    always @(addr)','delimiter','', '-append') ;
    dlmwrite(filename, '        case (addr)','delimiter','', '-append') ;
    for iaddr=1:length(input_sets)
        in = input_sets(iaddr,:) ;        
        for isize=1:fftsize/parallel 
            
            out1 = in(1) * exp(  1i*2*pi/fftsize * (lut_num-1) *((isize-1)*parallel+(0:parallel-1)))/fftsize ;
            out2 = in(2) * exp(  1i*2*pi/fftsize * (lut_num) *((isize-1)*parallel+(0:parallel-1)))/fftsize ;
            addr = isize + (iaddr-1) * fftsize/parallel -1;
            out = Change_fixed_bit_lim( out1+out2, sim.lut_bit , sim.lut_max  );
            out = out /sim.lut_max  *(2^(sim.lut_bit-1) -1);
            dlmwrite(filename, [ '            ' num2str( addr) ': begin' ],'delimiter','', '-append') ;
            
            for ii=0:parallel-1
                dlmwrite(filename, [ '                romr[' num2str(ii) '] = '  num2str(real(out(ii+1)))  ';' ],'delimiter','', '-append') ;
                dlmwrite(filename, [ '                romi[' num2str(ii) '] = '  num2str(imag(out(ii+1)))  ';' ],'delimiter','', '-append') ;
            end
            dlmwrite(filename, [ '            end' ],'delimiter','', '-append') ;
        end 
    end
    dlmwrite(filename, ['            default: begin  '] ,'delimiter','', '-append') ;
    for ii=0:1:parallel-1
        dlmwrite(filename, ['               romr[', num2str(ii), '] =0 ;'],'delimiter','', '-append') ;
        dlmwrite(filename, ['               romi[', num2str(ii), '] =0 ;'],'delimiter','', '-append') ;
    end
    dlmwrite(filename, ['           end  '] ,'delimiter','', '-append') ;
    dlmwrite(filename, '        endcase ','delimiter','', '-append') ;
    dlmwrite(filename, '	always @(posedge clk ) begin	 ','delimiter','', '-append') ;
    for ii=0:1:parallel-1
        dlmwrite(filename, ['                 z', num2str(ii), ' <= addr[ADDR_BIT-1] ==1 ?  { ~romr[' , num2str(ii), '], ~romi[', num2str(ii), ']} :  { romr[', num2str(ii), '], romi[', num2str(ii), ']};'],'delimiter','', '-append') ;
    end
     dlmwrite(filename, '	end	 ','delimiter','', '-append') ;
    dlmwrite(filename, 'endmodule','delimiter','', '-append') ;
end
  