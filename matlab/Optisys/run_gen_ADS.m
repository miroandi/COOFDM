sim.precomp_en = 1;
NFFT =128; 
for ii=0:60
    i=1i;
    span = ii;
    run('D:\user\haeyoung\Project\2012\COOFDM\matlab\gen_ADS.m');

end

sim.precomp_en = 0;
NFFT =512
span=0 ; 

run('D:\user\haeyoung\Project\2012\COOFDM\matlab\gen_ADS.m');
