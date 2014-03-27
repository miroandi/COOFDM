function  [Y1, Y2, Y3, Y4, sampleTime] = LecroyOscRead(deviceObj, a , en_interpol)
% set(deviceObj.Acquisition(1), 'Timebase',a);
% Execute device object function(s).
% set(deviceObj.Acquisition(1), 'Delay', 5e-7);%10e-7);
groupObj = get(deviceObj, 'Trigger');
groupObj = groupObj(1);
invoke(groupObj, 'trigger');
groupObj = get(deviceObj, 'Waveform');
groupObj = groupObj(1);
[Y1_PRE,X1,YUNIT,XUNIT,HEADER] = invoke(groupObj, 'readwaveform', 'channel1');
[Y3_PRE,X3,YUNIT,XUNIT,HEADER] = invoke(groupObj, 'readwaveform', 'channel3');
[Y2_PRE,X2,YUNIT,XUNIT,HEADER] = invoke(groupObj, 'readwaveform', 'channel2');
[Y4_PRE,X4,YUNIT,XUNIT,HEADER] = invoke(groupObj, 'readwaveform', 'channel4');
sampleTime = get(deviceObj.Acquisition(1), 'Timebase');
sampleTime = a;

time_list =[X1(1) X2(1) X3(1)  X4(1)] ;
time_idx = find ( time_list == min(time_list) ) ;
time_list = (X1(1) - time_list)/1e-12;
% en_interpol =1;
ps=1e-12;
ts = 0e-12;
if (  en_interpol == 1 )
    Y1 = interp1(X1,Y1_PRE,X1+ts,'spline');
    Y2 = interp1(X2,Y2_PRE,X1+0*ps,'spline');
    Y3 = interp1(X3,Y3_PRE,X1 - 7*ps,'spline');
    Y4 = interp1(X4,Y4_PRE,X1+0*ps,'spline');
    
%     Y1 = interp1(X1,Y1_PRE,X1+0*ts,'spline');
%     Y2 = interp1(X2,Y2_PRE,X1+24*ps,'spline');
%     Y3 = interp1(X3,Y3_PRE,X1 - 7*ps,'spline');
%     Y4 = interp1(X4,Y4_PRE,X1+20*ps,'spline');
    disp('Spline interpolated');
else
    Y1 = Y1_PRE;
    Y2 = Y2_PRE;
    Y3 = Y3_PRE;
    Y4 = Y4_PRE;
end
end