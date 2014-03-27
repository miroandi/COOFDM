function [resto] = crc32(h)

    % Create CRC lookup table:
    CRC_Table  = zeros(1, 256);
    POLYNOMIAL = 79764919;      % 0x04c11db7L
    shift24    = 16777216;
    for i = 0:255
       % crc = bitshift(i, 24);
       crc = i * shift24;  % Faster
       for j = 0:7
          if crc >= 2147483648  % if bitget(crc, 32)
             %crc = bitand(bitxor(crc * 2, POLYNOMIAL), 4294967295);
             crc = rem(bitxor(crc * 2, POLYNOMIAL), 4294967296);
          else
             crc = crc * 2;
          end
       end  % for j
       % CRC_Table(i + 1) = bitand(crc, 4294967295);
       CRC_Table(i + 1) = rem(crc, 4294967296);
    end  % for i
    S  = 0;
    c1 = 16777216;     % 2^24
    c3 = 256;
    c5 = 4294967296;   % 2^32: REM instead of BITAND
    for n = 1:length(Data)
       m = rem(bitxor(fix(S / c1), Data(n)), c3);
       S = bitxor(rem(S * c3, c5), CRC_Table(m + 1));
    end
    S = sprintf('%.8X', S);
end