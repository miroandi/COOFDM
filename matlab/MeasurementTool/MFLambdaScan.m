%http://prdportal.cos.agilent.com/owc_discussions/thread.jspa?threadID=18032&start=15&tstart=0

deviceObj = icdevice('hp816x', 'GPIB0::20::INSTR');
connect(deviceObj)

 groupWAVESCAN = get(deviceObj, 'Wavelengthscan');
 SETFASTSWEEPSPEED = 0;
 invoke(groupWAVESCAN,'enablehighsweepspeed',SETFASTSWEEPSPEED);
 
groupObj = get(deviceObj, 'MultiframeLambdaScan'); %creating group object to call functions in the group
invoke(groupObj,'registermainframe'); %registering mainframe

POWERUNIT = 0; %% 0 = dBm, 1 = W
POWER = 0; %% 0 dBm
OPTICALOUTPUT = 0; %% 0 = HighPower, 1 = LowSSE
NUMBEROFSCANS = 0; %% 0 = 1 Scan, 1 = 2 Scan, 2 = 3 Scan
PWMCHANNELS = 1; %% 1 = 1 Power Meter Channel
STARTWAVELENGTH = 1500e-9; %% Start wavelength in meters 
STOPWAVELENGTH = 1550e-9; %% Stop wavelength in meters   
STEPSIZE = 1e-11; %% Step wavelength in meters            

 SETSWEEPSPEED = 5e-10;
 invoke(groupObj,'setsweepspeed',SETSWEEPSPEED);

%setting up the parameters for executemflambdascan
[DATAPOINTS,CHANNELS] = invoke(groupObj,'preparemflambdascan',POWERUNIT,POWER,OPTICALOUTPUT,NUMBEROFSCANS,PWMCHANNELS,STARTWAVELENGTH,STOPWAVELENGTH,STEPSIZE);

WAVELENGTHARRAY = zeros(1,DATAPOINTS);
PWMCHANNEL = 0; %% 1st PM Channel
CLIPTOLIMIT = 0; %% 0 = False, 1 = True
CLIPPINGLIMIT = -100; %% Clipping Limit
POWERARRAY = zeros(1, DATAPOINTS);
LAMBDAARRAY = zeros(1, DATAPOINTS);
SETRESETTODEFAULT = 0;
SETINITIALRANGE = -40;
SETRANGEDECREMENT = -40;

invoke(groupObj,'setinitialrangeparams',PWMCHANNEL,SETRESETTODEFAULT,SETINITIALRANGE,SETRANGEDECREMENT);
 

[WAVELENGTHARRAY] = invoke(groupObj,'executemflambdascan', WAVELENGTHARRAY);

[START,STOP,AVERAGINGTIME,SWEEPSPEED] = invoke(groupObj,'getmflambdascanparametersq');

[POWERARRAY,LAMBDAARRAY] = invoke(groupObj,'getlambdascanresult',PWMCHANNEL,CLIPTOLIMIT,CLIPPINGLIMIT,POWERARRAY,LAMBDAARRAY);
LAMBDAARRAY = 1e9.*LAMBDAARRAY;
figure();
plot(LAMBDAARRAY,POWERARRAY);


invoke(groupObj,'unregistermainframe');
disconnect(deviceObj);
delete(deviceObj);
clear deviceObj;

% groupWAVESCAN = get(deviceObj, 'Wavelengthscan');
% SETFASTSWEEPSPEED = 0;
% invoke(groupWAVESCAN,'enablehighsweepspeed',SETFASTSWEEPSPEED);
% SETSWEEPSPEED = 5e-10;
% invoke(groupObj,'setsweepspeed',SETSWEEPSPEED);