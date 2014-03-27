function [P1, R1, Msym, R2] = AutoCorr( in ,search_idx, CorLen, Interval  )
        k = 1:CorLen;
        InputLength = round( size(in,2)); 
        EndIdx=InputLength-2*CorLen;
        P1=zeros(1, EndIdx);
        R1=zeros(1, EndIdx);
        Msym=zeros(1, EndIdx);
        R2=zeros(1, EndIdx);
        for isample=search_idx+1+Interval :EndIdx;     
            P1(isample)= sum(sum( in(:,isample+k) .* conj(in(:,isample+ Interval + k ))));
            R1(isample) = sum(sum (abs( in (:, isample +k )) .^2 ));     
            Msym(isample) =  abs( P1(isample) ) ^2 / R1(isample) ^2 ;   
            R2(isample) =   (abs( in ( isample   )) .^2 );   
        end
end