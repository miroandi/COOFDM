function [out] = digfilt( en, in, coef )

if ( en  == 0 )
    out = in ;
    return;
else
    ovsample = 8 ;
    for ii=1:size(in,1)
        firout = downsample(conv(upsample(in(ii, :),ovsample),   coef),ovsample,1);
        out(ii,:) = firout((size( coef, 2)-1)/2/ovsample+(1:size(in,2)));
%         firout =  (conv(upsample(in(ii, :),ovsample),   coef)  );
%         out(ii,:) = firout;
    end 
    out =mean( mean(abs(in)))/mean(mean(abs(out))) * out;
end
        