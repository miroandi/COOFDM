function   OTD( in )

figure1 = figure;

hold on;
plot(abs(in(1,:)) .^2,'r','Display', 'Xpol')

if ( size(in, 1) == 2 )
    plot(abs(in(2,:)) .^2,'b','Display', 'Ypol')
    legend 'show';
end

mean_power=sum((mean(((abs(in) .^2))/1e-3, 2)));
str3 =[ 'mean power ', num2str(10*log10(mean_power)),' dBm'];
annotation(figure1,'textbox',...
    [0.277785714285714 0.935714285714286 0.481142857142857 0.0476190476190487],...
    'String',{ str3},...
    'FitBoxToText','off',...
    'EdgeColor','none');
end 
