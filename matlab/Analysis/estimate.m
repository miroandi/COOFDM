nm=1e-9;
fs = 10^-15 ;
ps = 10^-12; 
THz = 10 ^ 12 ;
MHz = 1e6;
GHz = 1e9;
kHz = 1e3;
km = 10^3;
mW = 1e-3;
um = 1e-6;
W = 1;
mV =1e-3;
ppm = 1e-6;
c = 2.99e8;  % Speed of light 
h =6.6e-34;  % Plank constant, J.s
Z0 = 377 ;                                       % ohm

j=sqrt(-1);
GDD=17;
lambda0 = 1550*nm; %m
%% Delay induced by chromatic dispersion
% time delay btw each subcarrier 
deltaF = 1/(params.SampleTime *params.NFFT *params.OVERSAMPLE);
deltaLambda =lambda0^2 /  c *deltaF ;
time_delay = GDD * ps/nm/km * sim.FiberLength * deltaLambda  ; 

%% Phase delay per subcarrier 
for sc=1:params.NFFT/2
    phase_delay = 2*pi*(time_delay*sc)/ (1/(sc*deltaF));
end 
maxidx = max(params.SubcarrierIndex1) ;
disp(['time delay for 1st subcarrier ', num2str( time_delay/ps  ), 'ps ']);
disp(['time delay for 50 ', num2str( time_delay*50/ps  ), 'ps ']);
disp(['time delay for maxidx( ', num2str(maxidx), ') : ',num2str( time_delay*maxidx/ps  ), 'ps ']);
sc=params.NFFT;
phase_delay = 2*(time_delay*sc)/ (1/(sc*deltaF));
disp(['phase_delay of  50 ', num2str( phase_delay  ), ' pi ']);
disp(['max of min. guard interval sample count', num2str( time_delay*sc/params.SampleTime  ), 'UI ']);
disp(['max of min. guard interval sample count', num2str( time_delay*2*maxidx/params.SampleTime  ), 'UI ']);
%% FFT size 
time_delay_outermost = time_delay * max(params.SubcarrierIndex1)  ;
FFTSize = lambda0^2 /  c * GDD * ps/nm/km * X_coor * km  /(params.SampleTime ^2 ); 

% disp(['Overlap OFDE size should be greater than ', num2str( Ne  ), ' at fiber length of ', num2str(sim.FiberLength/1e3), ' km']);

%% OFDE sizes 
time_delay_outermost = time_delay * max(params.SubcarrierIndex1)  ;
Ne = 1/(params.SampleTime) * time_delay_outermost;

disp(['Overlap OFDE size should be greater than ', num2str( Ne  ), ' at fiber length of ', num2str(sim.FiberLength/1e3), ' km']);
%% Delay induced by polarization mode dispersion
% Dp = 10*ps/sqrt(km) ;  %% Should be updated for the model
if ( sim.PMDtype == 1)
    time_delay= fiber.PMD;
else
    time_delay= 3*fiber.Dp*sqrt(fiber.FiberLength );
end

phase_delay = 2*(time_delay )/ (params.SampleTime);
disp(['phase_delay of  polarization mode dispersion @Dp=', num2str(fiber.Dp), ' ', num2str( phase_delay  ), ' pi ']);
disp(['guard interval sample count for PMD ', num2str( time_delay /params.SampleTime  ), 'UI ']); 

%% Sampling offset due to the sampling clock freq. offset
sampleoffset = sim.txfreqoff * params.SampleperSymbol *params.NSymbol ;
disp(['Sampling offset due to the sampling clock freq. offset : ', num2str(sampleoffset  ), ' Sample ']);