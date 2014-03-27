
% sim.en_optisyschannel =0;
% sim.en_read_ADS =0;
% sim.en_gen_ADS =0;

Canvas =0;
Document=0;
if ( sim.en_optisyschannel == 1 )
    optsys = actxserver('optisystem.application');
    % This pause is necessary to allow OptiSystem to be opened before
    % call open the project
    pause(25);
end

if ( params.Nstream == 1)
    
    dir1 = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Single_Pol\Data_';
else
    
    dir1 = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Dual_Pol\Data_';
end

str2 ='';%_nolinewidth';
if ( sim.mode == 2 ||  sim.mode == 4 )
    str1 ='_SNR\';
else
    if ( sim.mode == 3 )        
        str1 ='_PWR\'; %'_SNR\';
    else        
        str1 ='\'; %'_SNR\';
    end
end

str4='_';
if (params.Nbpsc ==2 )
    str4='4QAM_';
end
if (params.Nbpsc ==3 )
    str4='8QAM_';
end

if ( sim.precomp_en ==  1)
    dir_data = [dir1, num2str( params.NFFT), '_',str4, num2str(sim.subband),str2, str1];
else
    dir_data = [dir1, num2str( params.NFFT), '_no_precomp',str4,str2, str1];
end
[status, result] = system([ 'mkdir ', dir_data],'-echo');

if ( params.Nstream == 1)
    dir_opti = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Single_Pol\';        
    dir_in = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Single_Pol\INPUT\' ;
    opti_file = 'Single Polarization CO-OFDM_ADS.osd';
else
    dir_opti = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Dual_Pol\';        
    dir_in = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Dual_Pol\INPUT\' ;
    opti_file = 'Dual Polarization CO-OFDM_ADS.osd';
end

if ( sim.en_optisyschannel == 1 ) 
    optsys.Open([dir_opti,opti_file]);  
end

if ( sim.en_optisyschannel == 1 ) 
    Document        = optsys.GetActiveDocument;
    LayoutMngr      = Document.GetLayoutMgr;
    CurrentLyt      = LayoutMngr.GetCurrentLayout;
    Canvas          = CurrentLyt.GetCurrentCanvas;
    Canvas.SetParameterValue( 'Bit rate', 1/params.SampleTime  );
    
end
