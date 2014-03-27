function [ packetlen,channelout] = run_Opt( run_optisys, Document,Canvas,dir_in,  dir_name, params, sim, edfa,txedfa )

    packetlen =params.NSample+params.NSTF*params.lenSTF+max(sim.delay)+100+1000;
    zeropad = max(sim.delay)-min(sim.delay);
    if( mod( zeropad, 2) == 1 ) packetlen = packetlen +1 ; end
    span =ceil( sim.FiberLength/edfa.length); 
    qam_str = num2str( 2^params.Nbpsc );
    alg_str = 'conv';
    if ( sim.precomp_en ==1  ) alg_str = 'prev'; end  
    str1=['_', num2str(txedfa.NF_dB),'_',num2str(txedfa.gain_dB )];  
    str2=['_', num2str(edfa.NF_dB)];  
    file = ['RX', num2str(params.NFFT), '_', qam_str, 'QAM_', ...
            alg_str ,'_', num2str(span) ,'_', num2str(sim.SNR(1)), str1, str2 ];
    
    
    if ( run_optisys ==0 )
        channelout =0;
        channelout = read_ADS( sim.en_read_ADS,  dir_name, file, params );
        return
    end
    
    Canvas.SetParameterValue( 'Sequence length', packetlen *sim.MAXSIM  );
    Canvas.SetParameterValue( 'Bit rate', 1/params.SampleTime  );
    Canvas.SetParameterValue( 'NoiseFigure', txedfa.NF_dB);%50-sim.SNR(1) - 0.30);%1.9195 );
    Canvas.SetParameterValue( 'TXEDFAGain', txedfa.gain_dB  );
    Canvas.SetParameterValue( 'NoiseFigure1', edfa.NF_dB);
    ParameterName1  = 'Fiberloop';
    ParameterName2 = 'InFile1I';
    ParameterName3 = 'InFileQ';
    ParameterName4 = 'InFile2I';
    ParameterName5 = 'InFile2Q';
    ParameterName6 = 'OutFile1I';
    ParameterName7 = 'OutFile1Q';
    ParameterName8 = 'OutFile2I';
    ParameterName9 = 'OutFile2Q';

    
    if ( sim.precomp_en == 0  )
        txspan = 0;
    else
        txspan =span;
    end
    
    sbstr='';
    if ( sim.precomp_en ~= 0 )%&& sim.subband ~= 0 )        
        sbstr= ['_', num2str(sim.subband)];
    end
    
    txfile= [ 'TX', num2str(params.NFFT), '_', qam_str, 'QAM_', ...
            num2str(params.Nstream), 'POL_', num2str(txspan),  sbstr];
    filename2 =[ dir_in, txfile, '_I', '.tim'];
    filename3 =[ dir_in, txfile, '_Q', '.tim'];
    filename4 =[ dir_in, txfile, '_2I', '.tim'];
    filename5 =[ dir_in, txfile, '_2Q', '.tim'];
    Canvas.SetParameterValue( ParameterName2, filename2 );
    Canvas.SetParameterValue( ParameterName3, filename3 );
    if ( params.Nstream ==2)
        Canvas.SetParameterValue( ParameterName4, filename4 );
        Canvas.SetParameterValue( ParameterName5, filename5 );
    end
    

    filename6 = [ dir_name, file,  '_I.tim'];
    filename7 = [ dir_name, file,  '_Q.tim'];
    filename8 = [ dir_name, file,  '_2I.tim'];
    filename9 = [ dir_name, file,  '_2Q.tim'];
    
    Canvas.SetParameterValue( ParameterName6, filename6 );
    Canvas.SetParameterValue( ParameterName7, filename7 );
    if ( params.Nstream ==2)
        Canvas.SetParameterValue( ParameterName8, filename8 );
        Canvas.SetParameterValue( ParameterName9, filename9 );                     
    end
    Canvas.SetParameterValue( ParameterName1, span );
    Document.CalculateProject( true , true);

    channelout = read_ADS( sim.en_read_ADS,  dir_name, file, params );
    
end
    
    