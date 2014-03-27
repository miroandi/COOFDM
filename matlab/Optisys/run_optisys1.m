% clear all;
% close all;

% create a COM server running OptiSystem
% optsys = actxserver('optisystem.application');

% This pause is necessary to allow OptiSystem to be opened before
% call open the project
pause(15);
NFFT =128;
% Open the OptiSystem file defined by the path
% optsys.Open(['D:\user\haeyoung\Project\2012\COOFDM\optisystem\100 Gbps Coherent Detection Dual-Polarization Optical OFDM System_ADS.osd']);

% Specify and define the parameters that will be varied
ParameterName1  = 'Fiberloop';
FiberSpan     = 4:4:40; % 
km=1000;
% Specify the results that will be transfered from OptiSystem
ResultName1     = 'Max. Gain (dB)';
ResultName2     = 'Min. Noise Figure (dB)';
ResultName3     = 'Output : Max. OSNR (dB)';

% Document        = optsys.GetActiveDocument;
% LayoutMngr      = Document.GetLayoutMgr;
% CurrentLyt      = LayoutMngr.GetCurrentLayout;
% Canvas          = CurrentLyt.GetCurrentCanvas;
syncpoint = 7; 
precomp_en=1;

dir_name = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Data50_subband2\';
for kk = 1:length(FiberSpan) 
    span= FiberSpan(kk) ;
    sim.FiberLength = FiberSpan(kk) * 50*km  ; 
    filename2 = [ dir_name, 'TX128_16QAM_2POL_I_', num2str(FiberSpan(kk)), '.tim'];
    filename3 = [ dir_name, 'TX128_16QAM_2POL_Q_', num2str(FiberSpan(kk)), '.tim'];
    filename4 = [ dir_name, 'TX128_16QAM_2POL_2I_', num2str(FiberSpan(kk)), '.tim'];
    filename5 = [ dir_name, 'TX128_16QAM_2POL_2Q_', num2str(FiberSpan(kk)), '.tim'];


    %Canvas.SetParameterValue( ParameterName2, filename2 );
    %Canvas.SetParameterValue( ParameterName3, filename3 );
    %Canvas.SetParameterValue( ParameterName4, filename4 );
    %Canvas.SetParameterValue( ParameterName5, filename5 );


    filename6 = [ dir_name, 'RX128_16QAM_2POL_I_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename7 = [ dir_name, 'RX128_16QAM_2POL_Q_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename8 = [ dir_name, 'RX128_16QAM_2POL_2I_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename9 = [ dir_name, 'RX128_16QAM_2POL_2Q_prop_', num2str(FiberSpan(kk)), 'span.tim'];

    %Canvas.SetParameterValue( ParameterName6, filename6 );
    %Canvas.SetParameterValue( ParameterName7, filename7 );
    %Canvas.SetParameterValue( ParameterName8, filename8 );
    %Canvas.SetParameterValue( ParameterName9, filename9 );                     
    %Canvas.SetParameterValue( ParameterName1, FiberSpan(kk) );

%                                                                                                                                                                                                                                                                                                      
    %Document.CalculateProject( true , true);
% 
    run('D:\user\haeyoung\Project\2012\COOFDM\matlab\check_ADS.m');

    BER4(kk)= ber;       
   
end
dlmwrite('ber4.txt', BER4) ;

dir_name = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Data50_subband4\';
for kk = 1:length(FiberSpan) 
    span= FiberSpan(kk) ;
    sim.FiberLength = FiberSpan(kk) * 50*km  ; 
    filename2 = [ dir_name, 'TX128_16QAM_2POL_I_', num2str(FiberSpan(kk)), '.tim'];
    filename3 = [ dir_name, 'TX128_16QAM_2POL_Q_', num2str(FiberSpan(kk)), '.tim'];
    filename4 = [ dir_name, 'TX128_16QAM_2POL_2I_', num2str(FiberSpan(kk)), '.tim'];
    filename5 = [ dir_name, 'TX128_16QAM_2POL_2Q_', num2str(FiberSpan(kk)), '.tim'];


    %Canvas.SetParameterValue( ParameterName2, filename2 );
    %Canvas.SetParameterValue( ParameterName3, filename3 );
    %Canvas.SetParameterValue( ParameterName4, filename4 );
    %Canvas.SetParameterValue( ParameterName5, filename5 );


    filename6 = [ dir_name, 'RX128_16QAM_2POL_I_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename7 = [ dir_name, 'RX128_16QAM_2POL_Q_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename8 = [ dir_name, 'RX128_16QAM_2POL_2I_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename9 = [ dir_name, 'RX128_16QAM_2POL_2Q_prop_', num2str(FiberSpan(kk)), 'span.tim'];

    %Canvas.SetParameterValue( ParameterName6, filename6 );
    %Canvas.SetParameterValue( ParameterName7, filename7 );
    %Canvas.SetParameterValue( ParameterName8, filename8 );
    %Canvas.SetParameterValue( ParameterName9, filename9 );                     
    %Canvas.SetParameterValue( ParameterName1, FiberSpan(kk) );

%                                                                                                                                                                                                                                                                                                      
    %Document.CalculateProject( true , true);
% 
    run('D:\user\haeyoung\Project\2012\COOFDM\matlab\check_ADS.m');

    BER5(kk)= ber;       
   
end
dlmwrite('ber5.txt', BER5) ;

dir_name = 'D:\user\haeyoung\Project\2012\COOFDM\optisystem\Data50_subband8\';
for kk = 1:length(FiberSpan) 
    span= FiberSpan(kk) ;
    sim.FiberLength = FiberSpan(kk) * 50*km  ; 
    filename2 = [ dir_name, 'TX128_16QAM_2POL_I_', num2str(FiberSpan(kk)), '.tim'];
    filename3 = [ dir_name, 'TX128_16QAM_2POL_Q_', num2str(FiberSpan(kk)), '.tim'];
    filename4 = [ dir_name, 'TX128_16QAM_2POL_2I_', num2str(FiberSpan(kk)), '.tim'];
    filename5 = [ dir_name, 'TX128_16QAM_2POL_2Q_', num2str(FiberSpan(kk)), '.tim'];


    %Canvas.SetParameterValue( ParameterName2, filename2 );
    %Canvas.SetParameterValue( ParameterName3, filename3 );
    %Canvas.SetParameterValue( ParameterName4, filename4 );
    %Canvas.SetParameterValue( ParameterName5, filename5 );


    filename6 = [ dir_name, 'RX128_16QAM_2POL_I_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename7 = [ dir_name, 'RX128_16QAM_2POL_Q_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename8 = [ dir_name, 'RX128_16QAM_2POL_2I_prop_', num2str(FiberSpan(kk)), 'span.tim'];
    filename9 = [ dir_name, 'RX128_16QAM_2POL_2Q_prop_', num2str(FiberSpan(kk)), 'span.tim'];

    %Canvas.SetParameterValue( ParameterName6, filename6 );
    %Canvas.SetParameterValue( ParameterName7, filename7 );
    %Canvas.SetParameterValue( ParameterName8, filename8 );
    %Canvas.SetParameterValue( ParameterName9, filename9 );                     
    %Canvas.SetParameterValue( ParameterName1, FiberSpan(kk) );

%                                                                                                                                                                                                                                                                                                      
    %Document.CalculateProject( true , true);
% 
    run('D:\user\haeyoung\Project\2012\COOFDM\matlab\check_ADS.m');

    BER6(kk)= ber;       
   
end
dlmwrite('ber6.txt', BER6) ;
% optsys.Quit;

figure;hold;
plot( 50* FiberSpan, BER4, 'rs', 'Display', 'Subband 2');
plot( 50* FiberSpan, BER5, 'g<', 'Display', 'Subband 4');
plot( 50* FiberSpan, BER6, 'bo', 'Display', 'Subband 8');
% plot( 50* FiberSpan, ber1(1:10), 'k*', 'Display', 'Subband 32');
xlabel('FiberLength (km)')
ylabel('BER')