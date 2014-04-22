%% ISFA 

function H_modified = ISFA( H_in, sim, params)


    min_sc = min(params.LTFindexE);
    max_sc = max(params.LTFindexE);
    H_amp_modified=H_in;
    if ( sim.en_ISFA == 0 )
        H_modified=H_in;
        return
    end
    
    if ( sim.ISFASize ~=0 )
        if ( params.RXstream == 1 )
            H_amp_modified =ISFA1_abs( H_in, sim,  params, min_sc, max_sc);
        else
            for ii=1:size(H_in,1)
                for jj=1:size(H_in,2)
                    H11(1:size(H_in,3))=H_in(ii,jj,1:size(H_in,3));
                    H_amp_modified(ii,jj,:) =ISFA1_abs( H11, sim, params, min_sc, max_sc);
                end
            end
        end
    end


            
    H_modified =H_amp_modified;
    if ( sim.ISFASize1 ~=0 )
        if ( params.RXstream == 1 )
            H_modified = ISFA1_phase( H_amp_modified, H_in, sim,  params, min_sc, max_sc);
        else
             for ii=1:size(H_in,1)
                for jj=1:size(H_in,2)
                    H11(1:size(H_in,3))=H_in(ii,jj,1:size(H_in,3));
                    H22(1:size(H_in,3))=H_amp_modified(ii,jj,1:size(H_in,3));
                    H_modified(ii,jj,:) =ISFA1_phase(H22,  H11, sim,  params, min_sc, max_sc);
                end
            end
        end
    end
   

    
end


function H_modified = ISFA1_abs( H, sim, params, min_sc, max_sc)

    H_modified = H;         
    H_in =H;

    for sc=params.LTFindex  
        tmp =sum(abs(params.LTF( max(min_sc, sc-sim.ISFASize):min(max_sc, sc+sim.ISFASize))));
        abs_H = sum( abs( H_in( max(min_sc, sc-sim.ISFASize):min(max_sc, sc+sim.ISFASize))))/tmp;
        if ( abs( H_in(sc))~= 0)
            H_modified(sc) = H_in(sc) * abs_H./abs( H_in(sc));
        end
        
    end

    for sc=params.LTFindex  
    sc_list = max(min_sc, sc-sim.ISFASize)-1+find( params.LTF( max(min_sc, sc-sim.ISFASize):min(max_sc, sc+sim.ISFASize)) ~= 0 );
        if ( length(sc_list) < (sim.ISFASize + 3))
            fit_H = polyfit(sc_list,abs(H_in(sc_list)),1);
            abs_H=fit_H(1) * sc + fit_H(2);
            if ( abs( H_in(sc))~= 0)
                H_modified(sc) = H_in(sc) * abs_H./abs( H_in(sc));
            end
        end
    end           
end


function H_modified = ISFA1_phase( H, H_in1, sim, params, min_sc, max_sc) % H_in: Original H, H : abs modified input 

        H_modified = H; 
        H = H .* exp( -1j*[0:(params.NFFT-1)]*2*pi/params.NFFT*(sim.syncpoint));
        H_in = H_in1 .* exp( -1j*[0:(params.NFFT-1)]*2*pi/params.NFFT*(sim.syncpoint));
        for sc=params.LTFindex           

            tmp =sum(abs(params.LTF( max(min_sc, sc-sim.ISFASize1):min(max_sc, sc+sim.ISFASize1))));
            real_H = sum( real( H( max(min_sc, sc-sim.ISFASize1):min(max_sc, sc+sim.ISFASize1))))/tmp;
            imag_H = sum( imag( H( max(min_sc, sc-sim.ISFASize1):min(max_sc, sc+sim.ISFASize1))))/tmp;
            if ( tmp < (1+2* sim.ISFASize1) ) 
                H_modified(sc) = H(sc);
            else
                H_modified(sc) =  real_H  + 1j* imag_H ;
            end
        end
        for sc=params.LTFindex           
            sc_list = max(min_sc, sc-sim.ISFASize1)-1+find( params.LTF( max(min_sc, sc-sim.ISFASize1):min(max_sc, sc+sim.ISFASize1)) ~= 0 );
            if ( length(sc_list) < (sim.ISFASize1 + 3))                    
                fit_H = polyfit(sc_list,real(H_in(sc_list)),1);
                real_H=fit_H(1) * sc + fit_H(2);
                fit_H = polyfit(sc_list,imag(H_in(sc_list)),1);
                imag_H=fit_H(1) * sc + fit_H(2);
                H_modified(sc) =  real_H  + 1j* imag_H ;
            end
        end 
       H_modified = H_modified .* exp(  1j*[0: (params.NFFT-1)]*2*pi/params.NFFT*(sim.syncpoint));
end