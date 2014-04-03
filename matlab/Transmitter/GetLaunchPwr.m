function [pwr_mul, LP_dB] = GetLaunchPwr(laser, sim, MZmod, txedfa )
 mW = 1e-3;
pwr_mul= sqrt(laser.launch_power)* sim.txgain ;
    pwr_mul = pwr_mul * 128; %sim.dacout ;
    pwr_mul = pwr_mul *  pi/MZmod.Vpi_RF/sqrt(2)*10^(txedfa.gain_dB /20);
    pwr_mul = (pwr_mul )^2 ;
    LP_dB = 10*log10(pwr_mul) - 9.4857  ;
end
