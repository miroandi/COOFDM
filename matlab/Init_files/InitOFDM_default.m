function [sim,params]=  InitOFDM_default( sim_in, params_in )
% Default parameters 
	sim = sim_in ;
	params = params_in;
	sim.offset_QAM =0 ;
	sim.srrc_coef = SRRC(8,0.04, 32); 
	sim.SRRC_en = 0;
    sim.srrc_ov = 8 ;
    params.rec_window = 1;
    sim.CD_residual =1;
end 
