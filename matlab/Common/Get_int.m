function [ out, out_int, out_frac ] = Get_int( in_coarse, in_fine, unit);
        
%unit: unit of integer 

         f_est1 = round( in_coarse*(unit))/(unit)  +  in_fine    ;
         out = round ( (in_coarse-f_est1)*unit)/(unit)  + f_est1    ;
         out_int = round ( (in_coarse-f_est1)*unit) + round( in_coarse*(unit))   ;
         out_frac = f_est1- round( in_coarse*(unit))/(unit)   ;
end
