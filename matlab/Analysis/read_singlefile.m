function [ bit_err, Q, bit_err_sim, err_num] =read_singlefile( matfile )

    tmp =dlmread(matfile);
    bit_err=tmp(1,1); 
    Q=tmp(2,1); 
    bit_err_sim=tmp(3,:); 
    err_num=tmp(4,:);
   
    
end 