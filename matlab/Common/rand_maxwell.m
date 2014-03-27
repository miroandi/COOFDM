function out = rand_maxwell( len, mu);

    % len: number of sample to generation
    % mu : mean of maxwell distribution
    % a parameter of maxwell distribution

    a = mu /2 *sqrt(pi/2);

    x1 = random('Normal',0,a,1,len);
    x2 = random('Normal',0,a,1,len);
    x3 = random('Normal',0,a,1,len);

    out=sqrt(x1.^2 + x2.^2+ x3.^2);
end 