function [P2, R2, Msym] = CrossCorr( in ,cor_pattern, search_range, k2  )
%         k2 = 1:corr_len ;     
        P2=zeros(1,size(in,2));
        R2=P2;
        Msym=R2;
        for d=search_range
            P2(d) = abs(sum(real( cor_pattern .* conj(in(d+k2)))))+ ... 
                    abs(sum(imag( cor_pattern .* conj(in(d+k2))))) ;
            R2(d) = sum(abs(in(d+k2)) .^2 );
            Msym(d) =  abs( P2(d) ) ^2 / R2(d) ^2  ;
        end     
end