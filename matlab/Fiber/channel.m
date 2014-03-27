    
function noisyreceivein =  channel( osignal_tx, fiber, edfa, sim, params ) 
    [d1, d2] = size(osignal_tx);
    % Channel      
  
    % Fiber : Nonlinear Schrodinger Equation 
    %tStart = tic
    %tElapsed = toc(tStart)

    noisyosignal_tx=osignal_tx;
    if ( d1 == 1 )
    	noisyosignal_tx = [noisyosignal_tx; zeros(1, length(noisyosignal_tx));];
    end
    
    span =floor((sim.FiberLength)/edfa.length);
    lastLength=sim.FiberLength-span*edfa.length;
    if ( d1 == 1 )
        fiber.PMD = 0;
    else
        if ( sim.PMDtype == 0 )
            fiber.PMD = fiber.Dp * sqrt(sim.FiberLength ) /span;               
        else
            fiber.PMD =fiber.PMD/span;
        end
    end
    if (sim.backtoback == 1)        
        receiverin=noisyosignal_tx;
    else
        fiber_in =noisyosignal_tx;
        
        for Nfiber=1:span
            fiber.FiberLength=edfa.length;
            
            fiberout  = NLSE_2Pol( fiber_in, fiber) ;
            fiber_in  = EDFA( fiberout, edfa, params) ;
%             fiber_tmp(Nfiber,:) = fiber_in(1,:);
        end 
        if ( lastLength ~= 0 )
            fiber.FiberLength=lastLength;
            fiberout  = NLSE_2Pol( fiber_in, fiber) ;
            fiber_in = fiberout;
        end
       receiverin  = fiber_in;
    end 
    
%     DGD= rand_maxwell( 1, fiber.Dp * sqrt(sim.FiberLength));

    noisyreceivein=receiverin(1:d1, :);
        
       
end
