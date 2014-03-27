 function pilotout  = NPilot( pilotin, params );
    j=sqrt(-1);

    % Set unused subcarrier to zero
    pilotout = []; %zeros( 1, params.NSymbol * params.NFFT  );  
    one_symbol = zeros( params.Nstream,  params.NFFT  ); 
    subcarrier_num = length(params.SubcarrierIndex);
    for nsymbol=1:params.NSymbol
        % Set subcarrier to mapper out 
        if ( params.en_DFT_S == 1 )
            one_symbol(:,params.SubcarrierIndex ) =  ifft( pilotin(:,subcarrier_num*(nsymbol-1)+1:nsymbol*subcarrier_num) );
        else
        one_symbol(:,params.SubcarrierIndex ) = pilotin(:,subcarrier_num*(nsymbol-1)+1:nsymbol*subcarrier_num) ;
        end
        % Set pilot to pilot 
        one_symbol(:,params.PilotIndex ) = ones(params.Nstream, 1) * params.Pilot;
        pilotout =[ pilotout, one_symbol];
    end
      

end



% combine data and pilot tones
% Pilot sub-carriers -21, -7, 7 and 21; ( HT-20MHz )
%       sub-carriers -53, -25, -11, 0,  11, 25, 53; ( HT-40MHz )
%                    1-2   29   42  52  62  75  102  103-104
% 52 + 3 
