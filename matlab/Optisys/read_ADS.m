function channelout = read_ADS( en,  dir_name, file, params )
    if ( en == 0 )
        channelout =0;
        return
    end
%     span =ceil( sim.FiberLength/edfa.length); 
%     qam_str = num2str( 2^params.Nbpsc );
%     alg_str = 'conv';
%     if ( sim.precomp_en ==1  ) alg_str = 'prev'; end    
%     file = ['RX', num2str(params.NFFT), '_', qam_str, 'QAM_', alg_str ];
    
    if ( params.Nstream == 1 )         
        data1 = importdata([dir_name, file, '_I.tim']);
        data2 = importdata([dir_name, file, '_Q.tim']);
        RX128_16QAM_I= data1.data(:,2);
        RX128_16QAM_Q= data2.data(:,2);
        channelout= complex(RX128_16QAM_I', RX128_16QAM_Q');
       
    else    
        data1 = importdata([dir_name, file, '_I.tim']);
        data2 = importdata([dir_name, file, '_Q.tim']);
        data3 = importdata([dir_name, file, '_2I.tim']);
        data4 = importdata([dir_name, file, '_2Q.tim']);
        RX128_16QAM_1I= data1.data(:,2);
        RX128_16QAM_1Q= data2.data(:,2);
        RX128_16QAM_2I= data3.data(:,2);
        RX128_16QAM_2Q= data4.data(:,2);
        channelout= [complex(RX128_16QAM_1I', RX128_16QAM_1Q'); complex(RX128_16QAM_2I', RX128_16QAM_2Q');];
    end
     disp(['Read file: ', file]);
end