function [sim,params]=  InitOFDM_default( sim_in, params_in )
% Default parameters 
	sim = sim_in ;
	params = params_in;
	sim.offset_QAM =0 ;
	sim.srrc_coef = SRRC(8,0.04); 
	sim.SRRC_en = 0;
end 
