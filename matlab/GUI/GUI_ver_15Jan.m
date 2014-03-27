function varargout = GUI_ver_15Jan(varargin)
% GUI_VER_15JAN M-file for GUI_ver_15Jan.fig
%      GUI_VER_15JAN, by itself, creates a new GUI_VER_15JAN or raises the existing
%      singleton*.
%
%      H = GUI_VER_15JAN returns the handle to a new GUI_VER_15JAN or the handle to
%      the existing singleton*.
%
%      GUI_VER_15JAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_VER_15JAN.M with the given input arguments.
%
%      GUI_VER_15JAN('Property','Value',...) creates a new GUI_VER_15JAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_ver_15Jan_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_ver_15Jan_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_ver_15Jan

% Last Modified by GUIDE v2.5 15-Jan-2014 11:10:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_ver_15Jan_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_ver_15Jan_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_ver_15Jan is made visible.
function GUI_ver_15Jan_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
handles.CFOcomp_en = 0;
handles.Homodyne = 1;
handles.cfotype =5;
handles.CPE_en = 1;
handles.Oscill_en =0 ;
handles.cfotype = 5;
handles.sampling = 2;
handles.channelest = 2;
handles.elec =0 ;
handles.digfilter_en =1;
handles.interpol_en = 0;
handles.Qlist =[];
handles.deviceObj=[];
handles.deviceConnected =0;
% handles.graphic_en =0;
handles.graphic_only_en =0;
handles.stop_on_err =0 ;
handles.offset = 64468;
handles.en_interpol = 1;
handles.neginput =1 ;
handles.logfile = ['Test', datestr(now,'ddmmm'), '.txt'];
% ResetVal(hObject, eventdata, handles);
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = GUI_ver_15Jan_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
handles.CFOcomp_en = get(hObject,'Value');
a=handles.CFOcomp_en;
guidata(hObject, handles);



function checkbox3_Callback(hObject, eventdata, handles)

handles.Homodyne =  get(hObject,'Value') ;

a=handles.Homodyne;
disp2(handles.logfile, [' Homodyne', num2str(a)] );
guidata(hObject, handles);


function checkbox4_Callback(hObject, eventdata, handles)
handles.CPE_en = get(hObject,'Value');
a=handles.CPE_en;
disp2(handles.logfile, [' CPE enable', num2str(a)] );
guidata(hObject, handles);


function pushbutton1_Callback(hObject, eventdata, handles)

% [FileName,PathName]  = uigetfile('*.*');
% [FileName,PathName]  = uigetfile('\\LCRY0827N58314\Waveforms\24Apr13\*.*');
[FileName,PathName]  = uigetfile('D:\User\Haeyoung\COOFDM\OSC_Data\11Oct\*.*');
disp2(handles.logfile, ['Loading File ', FileName,' in PathName ', PathName]);
if ( FileName == 0 )
    return;
end
if ( FileName(1) == 'C')      
    handles.FileName = FileName( 3:size(FileName,2)); 
    FileName = handles.FileName ;
    set(handles.text4,'String', handles.FileName);

    RFileName = [ PathName, 'C1', FileName];
    a= importdata( RFileName );
    if (  size(a,2) == 2 )
        outi= reshape(a(:,2),1, []);
        handles.SampleTime = a(2,1) - a(1,1);
    else        
        outi= reshape(a,1, []);
%         handles.SampleTime = 1/10/1e9;
        a = str2num(get(handles.edit3,'String'));
        handles.SampleTime = 1/a/1e9;
    end
    if ( handles.neginput == 1 )
        handles.eouti =  -outi   ;
    else
        handles.eouti =  outi   ;
    end
    
    RFileName = [ PathName, 'C3', FileName];
    a= importdata( RFileName );
    outi= reshape(a(:,size(a,2)),1, []);
    handles.eoutq = outi   ;

    RFileName = [ PathName, 'C2', FileName];
    a= importdata( RFileName );
    outi= reshape(a(:,size(a,2)),1, []);
    if ( handles.neginput == 1 )
        handles.outi =  -outi   ;
    else
        handles.outi =  outi   ;
    end
   

    RFileName = [ PathName, 'C4', FileName];
    a= importdata( RFileName );
    outi= reshape(a(:,size(a,2)),1, []);
    handles.outq = outi   ;
else
%     handles.SampleTime = 1/20/1e9;
    
    a = str2num(get(handles.edit3,'String'));
    handles.SampleTime = 1/a/1e9;
    handles.FileName = FileName;
    IPosition = size(FileName,2)-4;
    FileName(IPosition) ='I';
    IFileName = [ PathName,  FileName];
    a= importdata( IFileName );
    outi= reshape(a(:,size(a,2)),1, []);
    handles.eouti = outi   ;
    handles.outi = outi   ;
    FileName(IPosition) ='Q';
    IFileName = [ PathName,  FileName];
    a= importdata( IFileName );
    outi= reshape(a(:,size(a,2)),1, []);
    handles.eoutq = outi   ;
    handles.outq = outi   ;
    set(handles.text4,'String', handles.FileName);
end
disp2(handles.logfile, ['OSC ',num2str(1/handles.SampleTime/1e9), ' GHz']);
handles.couti = handles.outi;
handles.coutq = handles.outq ;
guidata(hObject, handles);


function [stepidx,RxOVERSAMPLE,OSCOVERSAMPLE,offset,sync ]=setSampling(hObject, eventdata, handles)
a = str2num(get(handles.edit1,'String')); 
OSCOVERSAMPLE = round( 1/( a  * handles.SampleTime * 1e9) );
stepidx = 1;
RxOVERSAMPLE = 1 ;
if ( handles.sampling ~= 1 )   stepidx =  OSCOVERSAMPLE; end
 

if ( handles.sampling == 1 )   RxOVERSAMPLE =  2;  end
if ( handles.sampling == 1 )   
    OSCOVERSAMPLE =  OSCOVERSAMPLE/RxOVERSAMPLE;
    stepidx = OSCOVERSAMPLE; 
end
 

offset =0;
if ( handles.sampling ~= 1 &&   handles.sampling ~=6 )
    offset = handles.sampling -2;
end

sync = round(str2num(get(handles.edit2,'String')));
 

function [sim, params, couti, coutq, offset, maxidx, fiber]= InitStart(hObject, eventdata, handles)
    set(handles.proc,'String','Running...');
    [stepidx,RxOVERSAMPLE,OSCOVERSAMPLE,offset1,sync ]= ...
        setSampling(hObject, eventdata, handles);
    NFFT=128;
    if ( get(handles.checkbox21,'Value') == 1 )
            [sim, params, MZmod,fiber,laser, iolaser, txedfa, edfa, rxedfa, PD]= ...       
                 InitOFDM_11Sept( NFFT, RxOVERSAMPLE, handles.SampleTime *  stepidx  );
% InitOFDM_18June( NFFT, RxOVERSAMPLE, handles.SampleTime *  stepidx  ); 
% InitOFDM_21Aug( NFFT, RxOVERSAMPLE, handles.SampleTime *  stepidx  );    
% InitOFDM_11Sept( NFFT, RxOVERSAMPLE, handles.SampleTime *  stepidx  ); 
           
    else
            [sim, params, MZmod,fiber,laser, iolaser, txedfa, edfa, rxedfa, PD]= ...   
        InitOFDM_08Jan( NFFT, RxOVERSAMPLE, handles.SampleTime *  stepidx  );        
%                  InitOFDM_06Sept( NFFT, RxOVERSAMPLE, handles.SampleTime *  stepidx  );   
    end

    if ( get(handles.checkbox19,'Value') == 1 )
        handles.en_interpol = 1 ;
    else
        handles.en_interpol = 0 ;
    end
    
    if ( handles.CFOcomp_en ~= 0 && handles.Homodyne ~= 1 )
        sim.exp_cfo = 0 ;
    end
    sim.enIQbal =1;
    cutoff = min(0.99, 2*str2num(get(handles.edit9,'String'))/str2num(get(handles.edit3,'String'))); 
    [sim.txfilterb,sim.txfiltera] = butter(31,cutoff ,'low');
    sim.CFOcomp_en = get(handles.checkbox1,'Value'); % handles.CFOcomp_en; 
    sim.enCPEcomp =  handles.CPE_en ;
    sim.multi_level = get(handles.checkbox28,'Value');
    disp2(handles.logfile, ['Filename ',num2str(handles.cfotype)]);
    sim.cfotype = handles.cfotype;
    sim.stepidx = stepidx;
    sim.en_OFDE=0;
    
    params.ignore_edge_sb = get(handles.checkbox24,'Value');
    sim.decision_feedback_cpe = get(handles.checkbox25,'Value');
    sim.en_OFDE = get(handles.checkbox26,'Value');
    sim.nlpostcompen = get(handles.checkbox27,'Value');
    sim.FiberLength = str2num(get(handles.edit10,'String')) * 1e3;
%     sim.Launchpower = str2num(get(handles.edit11,'String')) ;
    sim.Launchpower = 1e-3 *  10^( str2num(get(handles.edit11,'String'))/10);
    sim.Launchpower_dB =   str2num(get(handles.edit11,'String'));
    params.Nbpsc = str2num(get(handles.edit6,'String')); 
    sim.delay = zeros(1, params.NFFT);
    if ( OSCOVERSAMPLE == 1 )
        sim.rxLPF_en = 0;
    else
        sim.rxLPF_en =handles.digfilter_en ;
    end   


    sim.syncpoint = sync ;
    [sim, params ]=  ...
        ReInitOFDM(handles.logfile, sim, params, MZmod,fiber,laser, iolaser, txedfa, edfa, rxedfa, PD );
   
    %%  Data manipulation
    if ( params.RXstream == 2)
        couti = [ handles.eouti;  handles.outi; ];
        coutq = [ handles.eoutq; handles.outq; ];
     else
        if ( handles.elec == 1 )
            couti = handles.eouti;
            coutq = handles.eoutq; 
        else    
            couti = handles.outi;
            coutq = handles.outq; 
        end
     end

    if (  sim.rxLPF_en == 1)
        for ii=1:size(couti,1)
            couti(ii,:)  = filtfilt( sim.txfilterb, sim.txfiltera, couti(ii,:) );
            coutq(ii,:)  = filtfilt( sim.txfilterb, sim.txfiltera, coutq(ii,:) );
        end       
    end

    if (  handles.sampling  == 6) % Interpolation
        x=1:size(couti,2);
        couti = interp1(x,couti,x,'spline');
        coutq = interp1(x,coutq,x ,'spline');     
    end    
    
    sim.stepidx =stepidx;
    %%  Find start & end points , Synchronization 
    rxpacketlen = min(params.packetlen , size(couti,2)) +sim.zeropad +sim.zeropad1+ sim.zeropad2 + sim.zeropad3;
    
    % Enable/disable synchronization.
%     
    
    if ( get(handles.checkbox22,'Value') == 1 )
        if ( params.MIMO_emul == 1 )
            rxpacketlen_cs =rxpacketlen ;
            offset = NRxFindCS_MIMO_energy( ...
                   [complex(couti(:, 1:OSCOVERSAMPLE:rxpacketlen_cs * OSCOVERSAMPLE ) , ...
                           coutq(:, 1:OSCOVERSAMPLE:rxpacketlen_cs * OSCOVERSAMPLE));],  ...
                            params, sim,  sim.en_cs_plot ) ;
              
            
        else
        offset = NRxFindCS_energy( complex(couti(:, 1:OSCOVERSAMPLE:rxpacketlen * OSCOVERSAMPLE ) , ...
                           coutq(:, 1:OSCOVERSAMPLE:rxpacketlen * OSCOVERSAMPLE)), ...
                            params,sim,  sim.en_cs_plot) ;
        end
        offset = offset *OSCOVERSAMPLE ; 
    else
        offset = handles.offset  ;
%         offset =1;
%         offset=1308;
%         offset =7143*4;
%         offset =28751;
%         offset=109172-4*14 +1;
%         offset =(44333+5200)*4;
%  offset =54220;
    end
 

%% Enable Synchronization
sim.en_find_sync =get(handles.checkbox17,'Value');
    if ( get(handles.checkbox17,'Value') == 1 )
        rxpacketlen = rxpacketlen + 128 ;%*OSCOVERSAMPLE ;
        sim.en_find_sync =1;
    end
    maxidx = size(handles.couti, 2);
    offset = offset +  offset1 ;    
    
    
    disp2(handles.logfile, ['Start Idx: ',num2str(offset)]);
    sim.ISFASizelist = 0;
    sim.ISFASize1list = 0;
    %%  Find start & end points , Synchronization 
    if ( handles.channelest ==  2 )
        sim.en_ISFA =1;
        if ( get(handles.checkbox18,'Value') == 1 )
            sim.ISFASizelist = 0:2:str2num(get(handles.edit4,'String'));
            sim.ISFASize1list = 0:1:str2num(get(handles.edit5,'String'));
        else
            sim.ISFASizelist = str2num(get(handles.edit4,'String'));
            sim.ISFASize1list = str2num(get(handles.edit5,'String'));
        end 
    end
    if ( get(handles.checkbox29,'Value') == 1 )
        LP_max = str2num(get(handles.edit12,'String'));
        LP_step = 2*LP_max/4;
        sim.Launchpowerlist = -LP_max:LP_step:LP_max;
    else
        sim.Launchpowerlist = 0 ;
    end
    
      
    
    if ( get(handles.checkbox10,'Value') == 1 ) 
        sim.syncpointlist = 0:1:sync;
    else
        sim.syncpointlist = sync ;
    end
    
    sim.fsync_point = 0; 
    
    
    
function pushbutton3_Callback(hObject, eventdata, handles)

    [sim, params, couti, coutq, offset, maxidx, fiber]= ...
        InitStart(hObject, eventdata, handles);
    sim.en_cs_plot=0;
    handles.sim = sim ;
    handles.offset =offset;
    handles.params = params;
    handles.fiber = fiber;
    handles.couti =couti;
    handles.coutq =coutq;
    sim.en_disp_env=1;
    
    
    %% Run Rx 
    dataf_t=[];    
    maxsim =floor( ((size(handles.couti,2)-offset +1)/sim.stepidx)/ (params.packetlen+sim.zeropad +sim.zeropad1 +sim.zeropad2 +sim.zeropad3  )) ;

    ioffsetmax = 0;
    if (get(handles.checkbox13,'Value') == 1 )    
        ioffsetmax = sim.stepidx-1;
    end
%     maxsim=1;
    for numsim=  1:maxsim    
        maxoffset = NRx1Frame( offset, ioffsetmax, maxidx, numsim, dataf_t, params, sim, handles);

        handles.maxoffset = maxoffset;
        handles.TotBitErr = handles.TotBitErr  +  (maxoffset.frame.Nbiterr) ;
        handles.TotBit =handles.TotBit+ params.totalbits /( params.Nstream) - params.MIMO_emul * params.Nsd * params.Nbpsc ;
            
        handles.TotFrame = handles.TotFrame + 1 ;
        handles.TotESNR = handles.TotESNR + maxoffset.frame.ESNR ;
        handles.SEE = handles.SEE + maxoffset.frame.cfo_err;  
        handles.sim.iqoffset = maxoffset.iqoffset;
        handles.list2 =[handles.list2, maxoffset.frame.diff_rtx];
        handles.list3 =[handles.list3, maxoffset.frame.diff_rtx2];
        handles.Qlist =[ handles.Qlist  handles.maxoffset.frame.Nbiterr]; 
        sim.fsync_point = sim.fsync_point + maxoffset.fsync_point;
%         maxoffset.fsync_point
        if ( size(handles.EVM_avg,2) == 0 )
            handles.EVM_avg =  10 .^(handles.maxoffset.EVM_dB_sc/10) ;
        else
            handles.EVM_avg = handles.EVM_avg + 10 .^(handles.maxoffset.EVM_dB_sc/10) ;
        end
        
        guidata(hObject, handles);    
        SetVal(hObject, eventdata, handles);
        %%
        
        if ( get(handles.checkbox14,'Value') == 1  )
                createfigure2( handles );
            pause(1);
        end
        
    end
    disp2(handles.logfile, ['Start Idx: ',num2str(offset)]);

    handles.BER = handles.TotBitErr / ( handles.TotBit );     
    handles.MeasuredSNR = handles.maxoffset.frame.snr;
    handles.MSEE = handles.SEE / handles.TotFrame ;
    handles.Q = 10*log10(2* handles.TotESNR/( handles.TotFrame ));

    set(handles.proc,'String','Done');
    SetVal(hObject, eventdata, handles);
    PrintVal(hObject, eventdata, handles);
    if (  get(handles.checkbox14,'Value') == 1 )
            createfigure2( handles );
    end

    disp2(handles.logfile, num2str(handles.Qlist));
    disp2(handles.logfile,['var/mean of error num ', num2str(var(handles.Qlist)/mean(handles.Qlist)^2)]);
    guidata(hObject, handles);
     

function pushbutton4_Callback(hObject, eventdata, handles)
 ResetVal(hObject, eventdata, handles);
 
function pushbutton5_Callback(hObject, eventdata, handles)
handles.sim.filname = handles.FileName;
fftout_sc = reshape( handles.maxoffset.fftout(1,:), handles.params.Nsd , size(handles.maxoffset.fftout, 2)/handles.params.Nsd );
% createfigure( handles.maxoffset.EVM_dB_sc, handles.maxoffset.EVM_dB_sym,...
%              handles.maxoffset.commonphase,  handles.maxoffset.fftout(1,:),  ...
%              handles.maxoffset.idealout(1,:), 1./ handles.maxoffset.H, ...
%              handles.maxoffset.noisyreceivein(1,:), handles.params,
%              handles.maxoffset.frame,handles.sim, ' '  )
if ( handles.params.RXstream == 2 )
    createfigure3( handles.maxoffset.commonphase, handles.maxoffset.H, handles.params, handles.maxoffset.frame, handles.sim, ' '  )
else
createfigure( handles.maxoffset.commonphase, handles.maxoffset.H, handles.params, handles.maxoffset.frame, handles.sim, ' '  )
end 
 
         
% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
 SelectSampling(hObject, eventdata, handles);

function  SelectSampling(hObject, eventdata, handles)
% cfotype = 5 ;
if hObject == handles.radiobutton1 %  
     sampling = 1 ;
 elseif hObject == handles.radiobutton2  
     sampling = 2 ;
 elseif hObject == handles.radiobutton3 % 
     sampling = 3 ;
 elseif hObject == handles.radiobutton5% 
     sampling = 4 ;
 elseif hObject == handles.radiobutton6 % 
     sampling = 5 ;
else    % hObject == handles.radiobutton8
     sampling = 6;
end
 
handles.sampling  = sampling ; 
disp2(handles.logfile, ['sampling ',num2str(handles.sampling)]);
guidata(hObject, handles);


function ResetVal(hObject, eventdata, handles)
str1arr =  {'BER',  'Q', 'MSEE', ...
            'M. SNR','Total bit err', 'Total bits','Total Frames', 'SEElist(dB)'};
handles.str1arr = str1arr;
set(handles.str11,'String',str1arr(1));
set(handles.str12,'String',str1arr(2));
set(handles.str13,'String',str1arr(3));
set(handles.str15,'String',str1arr(4));
set(handles.str16,'String',str1arr(5));
set(handles.str17,'String',str1arr(6));
set(handles.str18,'String',str1arr(7));

handles.BER = 0 ;
handles.Q = 0 ;
handles.SEE = 0 ;
handles.MSEE = 0 ;
handles.IntegralError = 0 ;
handles.MeasuredSNR = 0 ;
handles.TotBitErr = 0 ;
handles.TotBit = 0 ;
handles.TotFrame = 0 ;
handles.TotESNR = 0 ;
handles.Qlist =[];
handles.EVM_avg = [];
handles.list2 =[];
handles.list3 =[];
set(handles.proc,'String','Read');
SetVal(hObject, eventdata, handles);
guidata(hObject, handles);


function SetVal(hObject, eventdata, handles)
set(handles.val11,'String',[ num2str(handles.BER, '%1.1e ')] );
set(handles.val12,'String',[ num2str( handles.Q ),'  ' ] );
set(handles.val13,'String',[ num2str(handles.MSEE)] );
set(handles.val15,'String',[ num2str(handles.MeasuredSNR,'%2.2f'), ' dB'] );
set(handles.val16,'String',[ num2str(handles.TotBitErr)] );
set(handles.val17,'String',[ num2str(handles.TotBit)] );
set(handles.val18,'String',[ num2str(handles.TotFrame)] );



function PrintVal(hObject, eventdata, handles)
disp2(handles.logfile, [ handles.str1arr(1), ': ', num2str(handles.BER,'%1.1e   ')] );
disp2(handles.logfile, [ handles.str1arr(2), ': ', num2str((handles.Q),'%4.1f')  ]  );
disp2(handles.logfile, [ handles.str1arr(3), ': ', num2str(handles.MSEE,'%4.1e')] );
disp2(handles.logfile, [ handles.str1arr(4), ': ', num2str(handles.MeasuredSNR,'%3.1e'), ' dB'] );
disp2(handles.logfile, [ handles.str1arr(5), ': ', num2str(handles.TotBitErr)] );
disp2(handles.logfile, [ handles.str1arr(6), ': ', num2str(handles.TotBit)] );
disp2(handles.logfile, [ handles.str1arr(7), ': ', num2str(handles.TotFrame)] );
disp2(handles.logfile, [ handles.str1arr(8), ': ', num2str(handles.Qlist) ] );


function pushbutton6_Callback(hObject, eventdata, handles)
figure;hold on;
% time_signal =handles.maxoffset.noisyreceivein(1,1:handles.params.packetlen);
if (  get(handles.checkbox6,'Value') == 1 )
    time_signal =handles.maxoffset.noisyreceivein(1,:);
    pol_str=' X pol ';
else
    time_signal =handles.maxoffset.noisyreceivein(2,:);
    pol_str=' Y pol ';
end

x_coor = 1:size(time_signal,2);
x_coor = handles.params.SampleTime * x_coor * 1e9;
plot( x_coor, real (time_signal),'r','Display', 'Xpol real')
plot( x_coor, imag (time_signal),'b','Display', 'Xpol imag')


if ( size( time_signal, 1) == 2 )
    plot(( time_signal(2,:)),'b','Display', 'Ypol')
end

legend 'show';
ipower=mean(abs( real(time_signal(1,:)))) ;% - mean( real(time_signal(1,:))) ;
qpower=mean(abs( imag(time_signal(1,:)))) ;%  - mean( imag(time_signal(1,:))) ;
mean_power=sum((mean(((abs(time_signal) .^2))/1e-3, 2)));
str3 =[ 'mean power ', num2str(10*log10(mean_power)),' dBm'];
str1 =['i ', num2str(ipower), ' q ', num2str(qpower), pol_str ];
title( str1 );
ylabel( 'amlitude ( V)');
xlabel('time(ns)');


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)

% mean_dc = 0.0031 - 0.0016i;
mean_dc = 0.0020-1.4789e-005 + 1j*(-0.0015-3.4560e-005);
mean_dc = 0.0017-0.0015i;
mean_dc = 0.0016-0.0000034537+(-0.0014+0.00002784)*1j;
% mean_dc =100;
for ii=-0:20:0
    x=2:size(handles.couti(:, :),2)-1;
    if (  get(handles.checkbox6,'Value') == 1 )        
        coutq(1,:) =   interp1(x,handles.coutq(1, x),x + 0.01* ii,'spline');    
        couti(1,:) =  handles.couti(1, x)  ;    
    else    
        coutq(1,:) = interp1(x,handles.coutq(2, x),x +  0.01* ii,'spline');    
        couti(1,:) =  handles.couti(2, x ) ;    
    end
           
    OFD( complex(   couti(1,:), coutq(1,:) )-mean_dc, 1/ handles.SampleTime);
% OFD( (  handles.optchannelout(1,:)), 1/ handles.SampleTime)
end 

function checkbox5_Callback(hObject, eventdata, handles)
 handles.Oscill_en = get(hObject,'Value');
a=handles.Oscill_en;
disp2(handles.logfile, [' OSCILL enable', num2str(a)] );
guidata(hObject, handles);


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
handles.elec = get(hObject,'Value');
a=handles.elec;
guidata(hObject, handles);

function checkbox7_Callback(hObject, eventdata, handles)
handles.digfilter_en = get(hObject,'Value');
guidata(hObject, handles);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[Y1, Y2, Y3, Y4, sampleTime,deviceObj] = LecroyOscData(hObject, handles);
handles.SampleTime = sampleTime;
if (   get(handles.checkbox23,'Value') == 1 )
    handles.eouti = - Y1   ;
    handles.outi = -Y2   ;
else
    handles.eouti =  Y1   ;
    handles.outi =  Y2   ;
end
handles.eoutq = Y3   ;
handles.outq = Y4   ;
handles.couti = handles.outi;
handles.coutq = handles.outq  ;
if ( handles.deviceConnected == 0 )
    handles.deviceConnected =1;
    handles.deviceObj = deviceObj;
end
handles.FileName='Oscill';
guidata(hObject, handles);


function [Y1, Y2, Y3, Y4, sampleTime,deviceObj] = LecroyOscData(hObject, handles)
%  pause(2);
deviceObj = 0;
if ( isempty (handles.deviceObj ))
    deviceObj = LecroyOscConnect();
    handles.deviceObj = deviceObj;
end
if ( handles.deviceConnected == 0 )
    connect(handles.deviceObj );
    handles.deviceConnected =1;
end

a = str2num(get(handles.edit3,'String'));
disp( [ 'Oscilloscope ', num2str(a), ' GHz']);
[Y1, Y2, Y3, Y4, sampleTime] = LecroyOscRead(handles.deviceObj, 1/a/1e9, handles.en_interpol );
handles.SampleTime = 1/a/1e9; 
guidata(hObject, handles);

% disconnect(handles.deviceObj );


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function checkbox10_Callback(hObject, eventdata, handles)


function checkbox13_Callback(hObject, eventdata, handles)

handles.sweep_offset = get(hObject,'Value');
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkbox13


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)

MaxIter =  str2num(get(handles.edit7,'String')); 
MaxErr =  str2num(get(handles.edit8,'String')); 
sweep_time =  99 +3;
sweep_en =0;

if ( sweep_en == 1 )
    X_coor =  490:10:1385;
else
    X_coor = 1;
end
%490
%for wvl= 800:20:1040;
% for wvl= 490:10:1385;
for wvl= X_coor
    s1 = clock;
if ( sweep_en == 1 )    
    handles.BER = 0 ;
    handles.Q = 0 ;
    handles.SEE = 0 ;
    handles.MSEE = 0 ;
    handles.IntegralError = 0 ;
    handles.MeasuredSNR = 0 ;
    handles.TotBitErr = 0 ;
    handles.TotBit = 0 ;
    handles.TotFrame = 0 ;
    handles.TotESNR = 0 ;
    handles.Qlist =[];
    handles.EVM_avg = [];
    handles.list2 =[];
    handles.list3 =[];
end
ii=0;
%     for ii=1:MaxIter
     while( handles.TotFrame < MaxIter )  
        ii = ii +1;
        [Y1, Y2, Y3, Y4, sampleTime,deviceObj] = LecroyOscData(hObject, handles);
        handles.SampleTime = sampleTime;

        if (   get(handles.checkbox23,'Value') == 1 )
            handles.eouti = - Y1   ;
            handles.outi = -Y2   ;
        else
            handles.eouti =  Y1   ;
            handles.outi =  Y2   ;
        end
        handles.eoutq = Y3   ;
        handles.outq = Y4   ;
        handles.couti = handles.outi;
        handles.coutq = handles.outq  ;
        if ( handles.deviceConnected == 0 )
            handles.deviceConnected =1;
            handles.deviceObj = deviceObj;
        end

        handles.FileName='Oscill';
        guidata(hObject, handles);
 
        [sim, params, couti, coutq, offset, maxidx, fiber]= InitStart(hObject, eventdata, handles);
        sim.en_cs_plot=1;
        sim.OSNR = 10;

        handles.sim = sim ;
        handles.params = params;
        handles.couti =couti;
        handles.coutq =coutq;
        handles.fiber = fiber;

 
        %% Run Rx 
        dataf_t=[];
        idx =0;
        rxpacketlen = params.packetlen  ;
        maxsim =floor( ((size(handles.couti,2)-offset +1)/sim.stepidx)/ (params.packetlen+sim.zeropad +sim.zeropad1 +sim.zeropad2 +sim.zeropad3  )) ;
        ioffsetmax = 0;
        if (get(handles.checkbox13,'Value') == 1 )    
            ioffsetmax = sim.stepidx-1;
        end
         
%         maxsim=1;
        for numsim=1:maxsim    
            maxoffset = NRx1Frame( offset, ioffsetmax, maxidx, numsim, dataf_t, params, sim, handles);
    
            if ( 10*log10(maxoffset.frame.ESNR) > 10 )
                handles.maxoffset = maxoffset;
                handles.TotBitErr = handles.TotBitErr  + maxoffset.frame.Nbiterr ;          
                handles.TotBit =handles.TotBit+ params.totalbits /(params.Nstream) - params.MIMO_emul * params.Nsd * params.Nbpsc ;

                handles.TotFrame = handles.TotFrame + 1 ;
                handles.TotESNR = handles.TotESNR + maxoffset.frame.ESNR ;
                handles.SEE = handles.SEE + maxoffset.frame.cfo_err;  
                handles.sim.iqoffset = maxoffset.iqoffset;
                sim.fsync_point = sim.fsync_point + maxoffset.fsync_point;
                if ( size(handles.EVM_avg,2) == 0 )
                    handles.EVM_avg =  10 .^(handles.maxoffset.EVM_dB_sc/10) ;
                else
                    handles.EVM_avg = handles.EVM_avg + 10 .^(handles.maxoffset.EVM_dB_sc/10) ;
                end
                handles.EVM_avg = handles.EVM_avg + 10 .^(handles.maxoffset.EVM_dB_sc/10) ;
                guidata(hObject, handles);    

                handles.Qlist =[ handles.Qlist,   (maxoffset.frame.Nbiterr) ];
                handles.list2 =[handles.list2, maxoffset.frame.diff_rtx];
                handles.list3 =[handles.list3, maxoffset.frame.diff_rtx2];
    %         SetVal(hObject, eventdata, handles)
            end
        end

        
        disp2(handles.logfile, ['Start Idx: ',num2str(offset)]);
        handles.BER = handles.TotBitErr ./( handles.TotBit);
        handles.MeasuredSNR = handles.maxoffset.frame.snr;
        handles.MSEE = handles.SEE / handles.TotFrame ;
        handles.Q = 10*log10(2* handles.TotESNR/( handles.TotFrame ));
%         if ( 10*log10(maxoffset.frame.ESNR) > 10 )
%             handles.Qlist =[ handles.Qlist,   (maxoffset.frame.Nbiterr) ];
%             handles.list2 =[handles.list2, maxoffset.frame.diff_rtx];
%             handles.list3 =[handles.list3, maxoffset.frame.diff_rtx2];

            set(handles.proc,'String','Done');
            SetVal(hObject, eventdata, handles);
%             PrintVal(hObject, eventdata, handles);
            guidata(hObject, handles);

            if ( get(handles.checkbox14,'Value') == 1 )
                createfigure2( handles );
                disp2(handles.logfile, ['Number of frames: ',num2str(ii)]);
                pause(1);
            end
            if ( handles.stop_on_err  == 1  && sum(maxoffset.frame.Nbiterr) > MaxErr )
                createfigure2( handles );
                break;
            end
%         end
        if ( ii==1)
    %         path='D:MUser\Haeyoung\COOFDM\matlab_29May\OSC_Data_5June\';
    %         file = ['cfo',num2str(handles.sim.cfotype),'_test76_35dB_' , num2str(wvl), '.dat'];
    %         dlmwrite( [path, 'C1_', file], (handles.eouti )','newline' , 'pc');
    %         dlmwrite( [path, 'C2_', file], (handles.outi)','newline' , 'pc');
    %         dlmwrite( [path, 'C3_', file], (handles.eoutq)','newline' , 'pc');
    %         dlmwrite( [path, 'C4_', file], (handles.outq)','newline' , 'pc');
        end
        if ( ii==1)
            H= abs(handles.maxoffset.H);
        else
            H= abs(handles.maxoffset.H) + H;
        end
        disp2(handles.logfile, num2str(handles.Qlist))
    end %for ii=20 
    work_time = etime(clock, s1)
    if ( sweep_en == 1 )
        pause_time = sweep_time - work_time 
    else
        pause_time = 0;
    end
    
    if ( pause_time < 0 )
        disp2(handles.logfile, 'Time over');
        error('Time over');
    else
        pause(  pause_time ); 
        s1 = clock;
    end
    disp(datestr(now,' ss MM '))
    disp2( ['BER', num2str(handles.sim.cfotype),'.txt'], [num2str(handles.BER,'%1.2e '),' ', num2str(handles.MSEE,'%4.2e'), ' ',num2str(maxoffset.frame.cfo_phase*10e9/2/pi/1e6)]);
    disp2(handles.logfile, num2str(handles.Qlist))
    
end
PrintVal(hObject, eventdata, handles);
disp2(handles.logfile,['var/mean of error num ', num2str(var(handles.Qlist)/mean(handles.Qlist)^2)]);
% H = H/ii;




function edit3_Callback(hObject, eventdata, handles)
 


% --- Executes on key press with focus on edit1 and none of its controls.
function edit1_KeyPressFcn(hObject, eventdata, handles)
 

% --- Executes on key press with focus on edit3 and none of its controls.
function edit3_KeyPressFcn(hObject, eventdata, handles)

% --- Executes when selected object is changed in uipanel4.
function uipanel4_SelectionChangeFcn(hObject, eventdata, handles)
SelectAlg(hObject, eventdata, handles);


function  SelectAlg(hObject, eventdata, handles)
if hObject == handles.radiobutton12 % Proposed 
     cfotype = 5 ;
 elseif hObject == handles.radiobutton13 % Conv, CRT 
     cfotype = 4 ;
 elseif hObject == handles.radiobutton14 % EOE 
     cfotype = 7 ;
 elseif hObject == handles.radiobutton15  % Zhou identical size 4  
     cfotype = 2;
 elseif hObject == handles.radiobutton16  % Proposed, TS1  
     cfotype = 8;
end
handles.cfotype  = cfotype ; 
guidata(hObject, handles);


% --- Executes when selected object is changed in uipanel3.
function uipanel3_SelectionChangeFcn(hObject, eventdata, handles)
if hObject == handles.radiobutton1 % Zero forcing    
     channelest = 1 ;
 elseif hObject == handles.radiobutton10 % ISFA  
     channelest = 2 ;
else 
     channelest = 3;
end
handles.channelest  = channelest ; 
guidata(hObject, handles);


% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.graphic_en = get(hObject,'Value');
disp( ['Graphic enable ', num2str(get(hObject,'Value'))]);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox14



% --- Executes during object creation, after setting all properties.
function err_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to err_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate err_num


% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stop_on_err = get(hObject,'Value');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox16



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uiputfile('D:\User\Haeyoung\COOFDM\OSC_Data\13Jan14\*.dat','Save Frame data  As'); 
dlmwrite( [path, 'C1_', file], (handles.eouti )','newline' , 'pc');
dlmwrite( [path, 'C2_', file], (handles.outi)','newline' , 'pc');
dlmwrite( [path, 'C3_', file], (handles.eoutq)','newline' , 'pc');
dlmwrite( [path, 'C4_', file], (handles.outq)','newline' , 'pc');


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of checkbox17


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
print_parameters(handles.logfile, handles.sim, handles.params)


% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
   
    handles.en_interpol = get(hObject,'Value');
    guidata(hObject, handles);

% --- Executes on button press in checkbox21.
function checkbox21_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox21


% --- Executes on button press in checkbox22.
function checkbox22_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox22


% --- Executes on button press in checkbox23.
function checkbox23_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox23
    handles.neginput = get(hObject,'Value');
    guidata(hObject, handles);


% --- Executes on button press in checkbox24.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox24



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox25.
function checkbox25_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox25



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox26.
function checkbox26_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox26



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox27.
function checkbox27_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox27



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox28.
function checkbox28_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox28


% --------------------------------------------------------------------
function uipanel4_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox29.
function checkbox29_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox29



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
