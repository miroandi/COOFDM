% clear all;
% close all;

enable_optisys = 0 ;
% create a COM server running OptiSystem
if ( enable_optisys == 1 )
    optsys = actxserver('optisystem.application');
end

% This pause is necessary to allow OptiSystem to be opened before
% call open the project
pause(15);
NFFT =128;
% Open the OptiSystem file defined by the path
if ( enable_optisys == 1 ) 
    optsys.Open(['D:\user\haeyoung\Project\2012\COOFDM\optisystem\100 Gbps Coherent Detection Dual-Polarization Optical OFDM System_ADS.osd']);
end

% Specify and define the parameters that will be varied
ParameterName1  = 'Fiberloop';
FiberSpan     = 4:4:60; % 
km=1000;
% Specify the results that will be transfered from OptiSystem
ResultName1     = 'Max. Gain (dB)';
ResultName2     = 'Min. Noise Figure (dB)';
ResultName3     = 'Output : Max. OSNR (dB)';

if ( enable_optisys == 1 ) 
    Document        = optsys.GetActiveDocument;
    LayoutMngr      = Document.GetLayoutMgr;
    CurrentLyt      = LayoutMngr.GetCurrentLayout;
    Canvas          = CurrentLyt.GetCurrentCanvas;
end

% dir_name = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Data50_sync_subband8\';
dir_name = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Data50_pmd_01ps_p_km_determine\';
ParameterName2 = 'InFile1I';
ParameterName3 = 'InFileQ';
ParameterName4 = 'InFile2I';
ParameterName5 = 'InFile2Q';

ParameterName6 = 'OutFile1I';
ParameterName7 = 'OutFile1Q';
ParameterName8 = 'OutFile2I';
ParameterName9 = 'OutFile2Q';


filename2 = [ dir_name, 'TX128_16QAM_2POL_I_0.tim'];
filename3 = [ dir_name, 'TX128_16QAM_2POL_Q_0.tim'];
filename4 = [ dir_name, 'TX128_16QAM_2POL_2I_0.tim'];
filename5 = [ dir_name, 'TX128_16QAM_2POL_2Q_0.tim'];

if ( enable_optisys == 1 ) 
    Canvas.SetParameterValue( ParameterName2, filename2 );
    Canvas.SetParameterValue( ParameterName3, filename3 );
    Canvas.SetParameterValue( ParameterName4, filename4 );
    Canvas.SetParameterValue( ParameterName5, filename5 );
end

syncpoint = 10;

% syncpoint = sync;
precomp_en=0;
for kk = 1:length(FiberSpan) 
        span= FiberSpan(kk) ;
        sim.FiberLength = FiberSpan(kk) * 50*km  ; 
    
        filename6 = [ dir_name, 'RX128_16QAM_2POL_I_conv_', num2str(FiberSpan(kk)), 'span.tim'];
        filename7 = [ dir_name, 'RX128_16QAM_2POL_Q_conv_', num2str(FiberSpan(kk)), 'span.tim'];
        filename8 = [ dir_name, 'RX128_16QAM_2POL_2I_conv_', num2str(FiberSpan(kk)), 'span.tim'];
        filename9 = [ dir_name, 'RX128_16QAM_2POL_2Q_conv_', num2str(FiberSpan(kk)), 'span.tim'];
        
        if ( enable_optisys == 1 ) 
            Canvas.SetParameterValue( ParameterName6, filename6 );
            Canvas.SetParameterValue( ParameterName7, filename7 );
            Canvas.SetParameterValue( ParameterName8, filename8 );
            Canvas.SetParameterValue( ParameterName9, filename9 );
            Canvas.SetParameterValue( ParameterName1, FiberSpan(kk) );

            Document.CalculateProject( true , true); 
        end
        
%         run('D:\user\haeyoung\Project\2012\COOFDM\matlab\check_ADS.m');
        
%         BER1( kk)= ber;       
   
end

% dlmwrite('ber.txt', BER1) ;


syncpoint = 7; 

% syncpoint = sync;
precomp_en=1;
for kk = 1:length(FiberSpan) 
    span= FiberSpan(kk) ;
    sim.FiberLength = FiberSpan(kk) * 50*km  ; 
    filename2 = [ dir_name, 'TX128_16QAM_2POL_I_', num2str(FiberSpan(kk)), '.tim'];
    filename3 = [ dir_name, 'TX128_16QAM_2POL_Q_', num2str(FiberSpan(kk)), '.tim'];
    filename4 = [ dir_name, 'TX128_16QAM_2POL_2I_', num2str(FiberSpan(kk)), '.tim'];
    filename5 = [ dir_name, 'TX128_16QAM_2POL_2Q_', num2str(FiberSpan(kk)), '.tim'];

    
    if ( enable_optisys == 1 ) 
        Canvas.SetParameterValue( ParameterName2, filename2 );
        Canvas.SetParameterValue( ParameterName3, filename3 );
        Canvas.SetParameterValue( ParameterName4, filename4 );
        Canvas.SetParameterValue( ParameterName5, filename5 );
    end


    filename6 = [ dir_name, 'RX128_16QAM_2POL_I_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename7 = [ dir_name, 'RX128_16QAM_2POL_Q_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename8 = [ dir_name, 'RX128_16QAM_2POL_2I_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename9 = [ dir_name, 'RX128_16QAM_2POL_2Q_prop_', num2str(FiberSpan(kk)), 'span.tim'];

    if ( enable_optisys == 1 ) 
        Canvas.SetParameterValue( ParameterName6, filename6 );
        Canvas.SetParameterValue( ParameterName7, filename7 );
        Canvas.SetParameterValue( ParameterName8, filename8 );
        Canvas.SetParameterValue( ParameterName9, filename9 );                     
        Canvas.SetParameterValue( ParameterName1, FiberSpan(kk) );                                                                                                                                                                                                                                                                                                    
        Document.CalculateProject( true , true);
    end

    run('D:\user\haeyoung\Project\2012\COOFDM\matlab\check_ADS.m');

%     BER2(kk)= ber;       
   
end

% dlmwrite('ber1.txt', BER2) ;

% kk =30;
% 
% filename2 = [ dir_name, 'TX128_16QAM_2POL_I_', num2str(kk), '.tim'];
% filename3 = [ dir_name, 'TX128_16QAM_2POL_Q_', num2str(kk), '.tim'];
% filename4 = [ dir_name, 'TX128_16QAM_2POL_2I_', num2str(kk), '.tim'];
% filename5 = [ dir_name, 'TX128_16QAM_2POL_2Q_', num2str(kk), '.tim'];
% %Canvas.SetParameterValue( ParameterName2, filename2 );
% %Canvas.SetParameterValue( ParameterName3, filename3 );
% %Canvas.SetParameterValue( ParameterName4, filename4 );
% %Canvas.SetParameterValue( ParameterName5, filename5 );
% 
%     
% for kk = 1:length(FiberSpan) 
% 
%     filename6 = [ dir_name, 'RX128_16QAM_2POL_I_prop_', num2str(FiberSpan(kk)), 'span.tim'];
%     filename7 = [ dir_name, 'RX128_16QAM_2POL_Q_prop_', num2str(FiberSpan(kk)), 'span.tim'];
%     filename8 = [ dir_name, 'RX128_16QAM_2POL_2I_prop_', num2str(FiberSpan(kk)), 'span.tim'];
%     filename9 = [ dir_name, 'RX128_16QAM_2POL_2Q_prop_', num2str(FiberSpan(kk)), 'span.tim'];
% 
%     %Canvas.SetParameterValue( ParameterName6, filename6 );
%     %Canvas.SetParameterValue( ParameterName7, filename7 );
%     %Canvas.SetParameterValue( ParameterName8, filename8 );
%     %Canvas.SetParameterValue( ParameterName9, filename9 );                    
%     %Canvas.SetParameterValue( ParameterName1, FiberSpan(kk) ); 
%     
%     %Document.CalculateProject( true , true);
%     run('D:\user\haeyoung\Project\2012\COOFDM\matlab\check_ADS.m');
% 
%     BER2(kk)= ber;       
%    
% end
% dlmwrite('ber2.txt', BER2) ;

NFFT =512;
syncpoint = 40; 

% syncpoint = sync*4;

precomp_en=0;

filename2 = [ dir_name, 'TX512_16QAM_2POL_I_0.tim'];
filename3 = [ dir_name, 'TX512_16QAM_2POL_Q_0.tim'];
filename4 = [ dir_name, 'TX512_16QAM_2POL_2I_0.tim'];
filename5 = [ dir_name, 'TX512_16QAM_2POL_2Q_0.tim'];

if ( enable_optisys == 1 ) 
    Canvas.SetParameterValue( ParameterName2, filename2 );
    Canvas.SetParameterValue( ParameterName3, filename3 );
    Canvas.SetParameterValue( ParameterName4, filename4 );
    Canvas.SetParameterValue( ParameterName5, filename5 );
end


for kk = 1:length(FiberSpan) 
                             
        
        span= FiberSpan(kk) ;
        sim.FiberLength = FiberSpan(kk) * 50*km  ; 
        filename6 = [ dir_name, 'RX512_16QAM_2POL_I_conv_', num2str(FiberSpan(kk)), 'span.tim'];
        filename7 = [ dir_name, 'RX512_16QAM_2POL_Q_conv_', num2str(FiberSpan(kk)), 'span.tim'];
        filename8 = [ dir_name, 'RX512_16QAM_2POL_2I_conv_', num2str(FiberSpan(kk)), 'span.tim'];
        filename9 = [ dir_name, 'RX512_16QAM_2POL_2Q_conv_', num2str(FiberSpan(kk)), 'span.tim'];
        
        if ( enable_optisys == 1 ) 
            Canvas.SetParameterValue( ParameterName6, filename6 );
            Canvas.SetParameterValue( ParameterName7, filename7 );
            Canvas.SetParameterValue( ParameterName8, filename8 );
            Canvas.SetParameterValue( ParameterName9, filename9 );
            Canvas.SetParameterValue( ParameterName1, FiberSpan(kk) );

            Document.CalculateProject( true , true);       
        end
        run('D:\user\haeyoung\Project\2012\COOFDM\matlab\check_ADS.m');
        
        BER3(kk)= ber;       
   
end
dlmwrite('ber3.txt', BER3) ;
if ( enable_optisys == 1 ) 
    optsys.Quit;
end


figure;hold;
semilogy( 50* FiberSpan, BER1, 'r');
semilogy( 50* FiberSpan, BER2, 'b');
semilogy( 50* FiberSpan, BER3, 'g');
xlabel('FiberLength (km)')
ylabel('BER')