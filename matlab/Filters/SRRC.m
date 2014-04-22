% Square root raised cosine filter to combat with intersymbol interference.

function [response] = SRRC(os_factor,roll_off)

 %os_factor=oversampling factor
 
a=roll_off;
t=-32:1/os_factor:32; %Limiting the response to -4T to 4T
%This can be increased or decreased according to the requirement
 
p=zeros(1,length(t));
    for i=1:1:length(t)
        if t(i)==0
            p(i)= (1-a)+4*a/pi;
        else if t(i)==1/(4*a) || t(i)==-1/(4*a)
               p(i)=a/sqrt(2)*((1+2/pi)*sin(pi/(4*a))+(1-2/pi)*cos(pi/(4*a)));
              else
                p(i) = (sin(pi*t(i)*(1-a))+4*a*t(i).*cos(pi*t(i)*(1+a)))./(pi*t(i).*(1-(4*a*t(i)).^2));
             end
        end
    end
    response=p./sqrt(sum(p.^2)); %Normalization to unit energy

end