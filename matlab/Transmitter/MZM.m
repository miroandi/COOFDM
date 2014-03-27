function out  = MZM( in, MZmod, laser  )

    % Mache-Zender modulator 
    V1 = in ; 
    V2 = -in ; 
    % Lazer noise 
    % lzout = wiener2(optofdmout,[6 6]); %2*pi*laser.linewidth 
%     out    = sqrt(laser.launch_power)* 1/2 *( exp( 1j*pi/MZmod.Vpi * V1)+ ...
%          exp( 1j*pi/MZmod.Vpi * V2) );  
   
    % laser.launch_power/2 ; 
    % power sum of two polarization = laser.launch_power
    % each polarization : laser.launch_power/2 
    out    = sqrt(laser.launch_power)* 1/2 *( ...
      exp( 1j*pi/MZmod.Vpi_RF * V2 + 1j*pi*MZmod.Vbias2 /MZmod.Vpi_DC )+ ...
      exp( 1j*pi/MZmod.Vpi_RF * V1 + 1j*pi*MZmod.Vbias1 /MZmod.Vpi_DC )); 
    
end 

