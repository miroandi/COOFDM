function pmd =  estimate_pmd( fiber, L )
   pmd = fiber.Dp * sqrt(L);
   
%     pmd = fiber.Dp * sqrt(80*km) * L;
%     pmd = fiber.DGD * (L);
   if ( L < 1* 1000)
       disp('Too small fiber length');
   end
end 