function out = get_crt_8_17( int_8, int_17 );;

%     int_8 = max( -8, int_8);
%     int_8 = min(  8, int_8);
     if ( int_8 < -8 ) int_8 = int_8 + 17 ; end
    if ( int_8 > 8 ) int_8 = int_8 - 17 ;end
    int_17 = max( -4, int_17);
    int_17 = min(  4, int_17);
    out = 0 ;
	if ( int_8 ==0&& int_17 ==0) out= 0; end 
	if ( int_8 ==1&& int_17 ==1) out= 1; end 
	if ( int_8 ==2&& int_17 ==2) out= 2; end 
	if ( int_8 ==3&& int_17 ==3) out= 3; end 
	if ( int_8 ==4&& int_17 ==-4) out= 4; end 
	if ( int_8 ==4&& int_17 == 4) out= 4; end 
	if ( int_8 ==5&& int_17 ==-3) out= 5; end 
	if ( int_8 ==6&& int_17 ==-2) out= 6; end 
	if ( int_8 ==7&& int_17 ==-1) out= 7; end 
	if ( int_8 ==8&& int_17 ==0) out= 8; end 
	if ( int_8 ==-8&& int_17 ==1) out= 9; end 
	if ( int_8 ==-7&& int_17 ==2) out= 10; end 
	if ( int_8 ==-6&& int_17 ==3) out= 11; end 
	if ( int_8 ==-5&& int_17 ==-4) out= 12; end 
	if ( int_8 ==-5&& int_17 == 4) out= 12; end 
	if ( int_8 ==-4&& int_17 ==-3) out= 13; end 
	if ( int_8 ==-3&& int_17 ==-2) out= 14; end 
	if ( int_8 ==-2&& int_17 ==-1) out= 15; end 
	if ( int_8 ==-1&& int_17 ==0) out= 16; end 
	if ( int_8 ==0&& int_17 ==1) out= 17; end 
	if ( int_8 ==1&& int_17 ==2) out= 18; end 
	if ( int_8 ==2&& int_17 ==3) out= 19; end 
	if ( int_8 ==3&& int_17 ==-4) out= 20; end 
	if ( int_8 ==3&& int_17 == 4) out= 20; end 
	if ( int_8 ==4&& int_17 ==-3) out= 21; end 
	if ( int_8 ==5&& int_17 ==-2) out= 22; end 
	if ( int_8 ==6&& int_17 ==-1) out= 23; end 
	if ( int_8 ==7&& int_17 ==0) out= 24; end 
	if ( int_8 ==8&& int_17 ==1) out= 25; end 
	if ( int_8 ==-8&& int_17 ==2) out= 26; end 
	if ( int_8 ==-7&& int_17 ==3) out= 27; end 
	if ( int_8 ==-6&& int_17 ==-4) out= 28; end 
	if ( int_8 ==-6&& int_17 == 4) out= 28; end 
	if ( int_8 ==-5&& int_17 ==-3) out= 29; end 
	if ( int_8 ==-4&& int_17 ==-2) out= 30; end 
	if ( int_8 ==-3&& int_17 ==-1) out= 31; end 
	if ( int_8 ==-2&& int_17 ==0) out= 32; end 
	if ( int_8 ==-1&& int_17 ==1) out= 33; end 
	if ( int_8 ==0&& int_17 ==2) out= 34; end 
	if ( int_8 ==1&& int_17 ==3) out= 35; end 
	if ( int_8 ==2&& int_17 ==-4) out= 36; end 
	if ( int_8 ==2&& int_17 == 4) out= 36; end 
	if ( int_8 ==3&& int_17 ==-3) out= 37; end 
	if ( int_8 ==4&& int_17 ==-2) out= 38; end 
	if ( int_8 ==5&& int_17 ==-1) out= 39; end 
	if ( int_8 ==6&& int_17 ==0) out= 40; end 
	if ( int_8 ==7&& int_17 ==1) out= 41; end 
	if ( int_8 ==8&& int_17 ==2) out= 42; end 
	if ( int_8 ==-8&& int_17 ==3) out= 43; end 
	if ( int_8 ==-7&& int_17 ==-4) out= 44; end 
	if ( int_8 ==-7&& int_17 == 4) out= 44; end 
	if ( int_8 ==-6&& int_17 ==-3) out= 45; end 
	if ( int_8 ==-5&& int_17 ==-2) out= 46; end 
	if ( int_8 ==-4&& int_17 ==-1) out= 47; end 
	if ( int_8 ==-3&& int_17 ==0) out= 48; end 
	if ( int_8 ==-2&& int_17 ==1) out= 49; end 
	if ( int_8 ==-1&& int_17 ==2) out= 50; end 
	if ( int_8 ==0&& int_17 ==3) out= 51; end 
	if ( int_8 ==1&& int_17 ==-4) out= 52; end 
	if ( int_8 ==1&& int_17 == 4) out= 52; end 
	if ( int_8 ==2&& int_17 ==-3) out= 53; end 
	if ( int_8 ==3&& int_17 ==-2) out= 54; end 
	if ( int_8 ==4&& int_17 ==-1) out= 55; end 
	if ( int_8 ==5&& int_17 ==0) out= 56; end 
	if ( int_8 ==6&& int_17 ==1) out= 57; end 
	if ( int_8 ==7&& int_17 ==2) out= 58; end 
	if ( int_8 ==8&& int_17 ==3) out= 59; end 
	if ( int_8 ==-8&& int_17 ==-4) out= 60; end 
	if ( int_8 ==-8&& int_17 == 4) out= 60; end 
	if ( int_8 ==-7&& int_17 ==-3) out= 61; end 
	if ( int_8 ==-6&& int_17 ==-2) out= 62; end 
	if ( int_8 ==-5&& int_17 ==-1) out= 63; end 
	if ( int_8 ==-4&& int_17 ==0) out= 64; end 
	if ( int_8 ==-3&& int_17 ==1) out= 65; end 
	if ( int_8 ==-2&& int_17 ==2) out= 66; end 
	if ( int_8 ==-1&& int_17 ==3) out= 67; end 
	if ( int_8 ==0&& int_17 ==-4) out= 68; end 
	if ( int_8 ==0&& int_17 == 4) out= 68; end 
% 	if ( int_8 ==1&& int_17 ==-3) out= 69; end 
% 	if ( int_8 ==2&& int_17 ==-2) out= 70; end 
% 	if ( int_8 ==3&& int_17 ==-1) out= 71; end 
% 	if ( int_8 ==4&& int_17 ==0) out= 72; end 
% 	if ( int_8 ==5&& int_17 ==1) out= 73; end 
% 	if ( int_8 ==6&& int_17 ==2) out= 74; end 
% 	if ( int_8 ==7&& int_17 ==3) out= 75; end 
% 	if ( int_8 ==8&& int_17 ==-4) out= 76; end 
% 	if ( int_8 ==8&& int_17 == 4) out= 76; end 
% 	if ( int_8 ==-8&& int_17 ==-3) out= 77; end 
% 	if ( int_8 ==-7&& int_17 ==-2) out= 78; end 
% 	if ( int_8 ==-6&& int_17 ==-1) out= 79; end 
% 	if ( int_8 ==-5&& int_17 ==0) out= 80; end 
% 	if ( int_8 ==-4&& int_17 ==1) out= 81; end 
% 	if ( int_8 ==-3&& int_17 ==2) out= 82; end 
% 	if ( int_8 ==-2&& int_17 ==3) out= 83; end 
% 	if ( int_8 ==-1&& int_17 ==-4) out= 84; end 
% 	if ( int_8 ==-1&& int_17 == 4) out= 84; end 
% 	if ( int_8 ==0&& int_17 ==-3) out= 85; end 
% 	if ( int_8 ==1&& int_17 ==-2) out= 86; end 
% 	if ( int_8 ==2&& int_17 ==-1) out= 87; end 
% 	if ( int_8 ==3&& int_17 ==0) out= 88; end 
% 	if ( int_8 ==4&& int_17 ==1) out= 89; end 
% 	if ( int_8 ==5&& int_17 ==2) out= 90; end 
% 	if ( int_8 ==6&& int_17 ==3) out= 91; end 
% 	if ( int_8 ==7&& int_17 ==-4) out= 92; end 
% 	if ( int_8 ==7&& int_17 == 4) out= 92; end 
% 	if ( int_8 ==8&& int_17 ==-3) out= 93; end 
% 	if ( int_8 ==-8&& int_17 ==-2) out= 94; end 
% 	if ( int_8 ==-7&& int_17 ==-1) out= 95; end 
% 	if ( int_8 ==-6&& int_17 ==0) out= 96; end 
% 	if ( int_8 ==-5&& int_17 ==1) out= 97; end 
% 	if ( int_8 ==-4&& int_17 ==2) out= 98; end 
% 	if ( int_8 ==-3&& int_17 ==3) out= 99; end 
% 	if ( int_8 ==-2&& int_17 ==-4) out= 100; end 
% 	if ( int_8 ==-2&& int_17 == 4) out= 100; end 
% 	if ( int_8 ==-1&& int_17 ==-3) out= 101; end 
% 	if ( int_8 ==0&& int_17 ==-2) out= 102; end 
% 	if ( int_8 ==1&& int_17 ==-1) out= 103; end 
% 	if ( int_8 ==2&& int_17 ==0) out= 104; end 
% 	if ( int_8 ==3&& int_17 ==1) out= 105; end 
% 	if ( int_8 ==4&& int_17 ==2) out= 106; end 
% 	if ( int_8 ==5&& int_17 ==3) out= 107; end 
% 	if ( int_8 ==6&& int_17 ==-4) out= 108; end 
% 	if ( int_8 ==6&& int_17 == 4) out= 108; end 
% 	if ( int_8 ==7&& int_17 ==-3) out= 109; end 
% 	if ( int_8 ==8&& int_17 ==-2) out= 110; end 
% 	if ( int_8 ==-8&& int_17 ==-1) out= 111; end 
% 	if ( int_8 ==-7&& int_17 ==0) out= 112; end 
% 	if ( int_8 ==-6&& int_17 ==1) out= 113; end 
% 	if ( int_8 ==-5&& int_17 ==2) out= 114; end 
% 	if ( int_8 ==-4&& int_17 ==3) out= 115; end 
% 	if ( int_8 ==-3&& int_17 ==-4) out= 116; end 
% 	if ( int_8 ==-3&& int_17 == 4) out= 116; end 
% 	if ( int_8 ==-2&& int_17 ==-3) out= 117; end 
% 	if ( int_8 ==-1&& int_17 ==-2) out= 118; end 
% 	if ( int_8 ==0&& int_17 ==-1) out= 119; end 
% 	if ( int_8 ==1&& int_17 ==0) out= 120; end 
% 	if ( int_8 ==2&& int_17 ==1) out= 121; end 
% 	if ( int_8 ==3&& int_17 ==2) out= 122; end 
% 	if ( int_8 ==4&& int_17 ==3) out= 123; end 
% 	if ( int_8 ==5&& int_17 ==-4) out= 124; end 
% 	if ( int_8 ==5&& int_17 == 4) out= 124; end 
% 	if ( int_8 ==6&& int_17 ==-3) out= 125; end 
% 	if ( int_8 ==7&& int_17 ==-2) out= 126; end 
% 	if ( int_8 ==8&& int_17 ==-1) out= 127; end 

	if ( int_8 ==-1&& int_17 ==-1) out =-1; end 
	if ( int_8 ==-2&& int_17 ==-2) out =-2; end 
	if ( int_8 ==-3&& int_17 ==-3) out =-3; end 
	if ( int_8 ==-4&& int_17 ==-4) out =-4; end 
    if ( int_8 ==-4&& int_17 == 4) out =-4; end 
	if ( int_8 ==-5&& int_17 ==3) out =-5; end 
	if ( int_8 ==-6&& int_17 ==2) out =-6; end 
	if ( int_8 ==-7&& int_17 ==1) out =-7; end 
	if ( int_8 ==-8&& int_17 ==0) out =-8; end 
	if ( int_8 ==8&& int_17 ==-1) out =-9; end 
	if ( int_8 ==7&& int_17 ==-2) out =-10; end 
	if ( int_8 ==6&& int_17 ==-3) out =-11; end 
	if ( int_8 ==5&& int_17 ==-4) out =-12; end 
	if ( int_8 ==5&& int_17 == 4) out =-12; end 
	if ( int_8 ==4&& int_17 ==3) out =-13; end 
	if ( int_8 ==3&& int_17 ==2) out =-14; end 
	if ( int_8 ==2&& int_17 ==1) out =-15; end 
	if ( int_8 ==1&& int_17 ==0) out =-16; end 
	if ( int_8 ==0&& int_17 ==-1) out =-17; end 
	if ( int_8 ==-1&& int_17 ==-2) out =-18; end 
	if ( int_8 ==-2&& int_17 ==-3) out =-19; end 
	if ( int_8 ==-3&& int_17 ==-4) out =-20; end 
	if ( int_8 ==-3&& int_17 == 4) out =-20; end 
	if ( int_8 ==-4&& int_17 ==3) out =-21; end 
	if ( int_8 ==-5&& int_17 ==2) out =-22; end 
	if ( int_8 ==-6&& int_17 ==1) out =-23; end 
	if ( int_8 ==-7&& int_17 ==0) out =-24; end 
	if ( int_8 ==-8&& int_17 ==-1) out =-25; end 
	if ( int_8 ==8&& int_17 ==-2) out =-26; end 
	if ( int_8 ==7&& int_17 ==-3) out =-27; end 
	if ( int_8 ==6&& int_17 ==-4) out =-28; end 
	if ( int_8 ==6&& int_17 == 4) out =-28; end 
	if ( int_8 ==5&& int_17 ==3) out =-29; end 
	if ( int_8 ==4&& int_17 ==2) out =-30; end 
	if ( int_8 ==3&& int_17 ==1) out =-31; end 
	if ( int_8 ==2&& int_17 ==0) out =-32; end 
	if ( int_8 ==1&& int_17 ==-1) out =-33; end 
	if ( int_8 ==0&& int_17 ==-2) out =-34; end 
	if ( int_8 ==-1&& int_17 ==-3) out =-35; end 
	if ( int_8 ==-2&& int_17 ==-4) out =-36; end 
	if ( int_8 ==-2&& int_17 == 4) out =-36; end 
	if ( int_8 ==-3&& int_17 ==3) out =-37; end 
	if ( int_8 ==-4&& int_17 ==2) out =-38; end 
	if ( int_8 ==-5&& int_17 ==1) out =-39; end 
	if ( int_8 ==-6&& int_17 ==0) out =-40; end 
	if ( int_8 ==-7&& int_17 ==-1) out =-41; end 
	if ( int_8 ==-8&& int_17 ==-2) out =-42; end 
	if ( int_8 ==8&& int_17 ==-3) out =-43; end 
	if ( int_8 ==7&& int_17 ==-4) out =-44; end 
	if ( int_8 ==7&& int_17 == 4) out =-44; end 
	if ( int_8 ==6&& int_17 ==3) out =-45; end 
	if ( int_8 ==5&& int_17 ==2) out =-46; end 
	if ( int_8 ==4&& int_17 ==1) out =-47; end 
	if ( int_8 ==3&& int_17 ==0) out =-48; end 
	if ( int_8 ==2&& int_17 ==-1) out =-49; end 
	if ( int_8 ==1&& int_17 ==-2) out =-50; end 
	if ( int_8 ==0&& int_17 ==-3) out =-51; end 
	if ( int_8 ==-1&& int_17 ==-4) out =-52; end 
	if ( int_8 ==-1&& int_17 == 4) out =-52; end 
	if ( int_8 ==-2&& int_17 ==3) out =-53; end 
	if ( int_8 ==-3&& int_17 ==2) out =-54; end 
	if ( int_8 ==-4&& int_17 ==1) out =-55; end 
	if ( int_8 ==-5&& int_17 ==0) out =-56; end 
	if ( int_8 ==-6&& int_17 ==-1) out =-57; end 
	if ( int_8 ==-7&& int_17 ==-2) out =-58; end 
	if ( int_8 ==-8&& int_17 ==-3) out =-59; end 
	if ( int_8 ==8&& int_17 ==-4) out =-60; end 
	if ( int_8 ==8&& int_17 == 4) out =-60; end 
	if ( int_8 ==7&& int_17 ==3) out =-61; end 
	if ( int_8 ==6&& int_17 ==2) out =-62; end 
	if ( int_8 ==5&& int_17 ==1) out =-63; end 
	if ( int_8 ==4&& int_17 ==0) out =-64; end 
	if ( int_8 ==3&& int_17 ==-1) out =-65; end 
	if ( int_8 ==2&& int_17 ==-2) out =-66; end 
	if ( int_8 ==1&& int_17 ==-3) out =-67; end 
% 	if ( int_8 ==0&& int_17 ==-4) out =-68; end 
% 	if ( int_8 ==-1&& int_17 ==3) out =-69; end 
% 	if ( int_8 ==-2&& int_17 ==2) out =-70; end 
% 	if ( int_8 ==-3&& int_17 ==1) out =-71; end 
% 	if ( int_8 ==-4&& int_17 ==0) out =-72; end 
% 	if ( int_8 ==-5&& int_17 ==-1) out =-73; end 
% 	if ( int_8 ==-6&& int_17 ==-2) out =-74; end 
% 	if ( int_8 ==-7&& int_17 ==-3) out =-75; end 
% 	if ( int_8 ==-8&& int_17 ==-4) out =-76; end 
% 	if ( int_8 ==8&& int_17 ==3) out =-77; end 
% 	if ( int_8 ==7&& int_17 ==2) out =-78; end 
% 	if ( int_8 ==6&& int_17 ==1) out =-79; end 
% 	if ( int_8 ==5&& int_17 ==0) out =-80; end 
% 	if ( int_8 ==4&& int_17 ==-1) out =-81; end 
% 	if ( int_8 ==3&& int_17 ==-2) out =-82; end 
% 	if ( int_8 ==2&& int_17 ==-3) out =-83; end 
% 	if ( int_8 ==1&& int_17 ==-4) out =-84; end 
% 	if ( int_8 ==0&& int_17 ==3) out =-85; end 
% 	if ( int_8 ==-1&& int_17 ==2) out =-86; end 
% 	if ( int_8 ==-2&& int_17 ==1) out =-87; end 
% 	if ( int_8 ==-3&& int_17 ==0) out =-88; end 
% 	if ( int_8 ==-4&& int_17 ==-1) out =-89; end 
% 	if ( int_8 ==-5&& int_17 ==-2) out =-90; end 
% 	if ( int_8 ==-6&& int_17 ==-3) out =-91; end 
% 	if ( int_8 ==-7&& int_17 ==-4) out =-92; end 
% 	if ( int_8 ==-8&& int_17 ==3) out =-93; end 
% 	if ( int_8 ==8&& int_17 ==2) out =-94; end 
% 	if ( int_8 ==7&& int_17 ==1) out =-95; end 
% 	if ( int_8 ==6&& int_17 ==0) out =-96; end 
% 	if ( int_8 ==5&& int_17 ==-1) out =-97; end 
% 	if ( int_8 ==4&& int_17 ==-2) out =-98; end 
% 	if ( int_8 ==3&& int_17 ==-3) out =-99; end 
% 	if ( int_8 ==2&& int_17 ==-4) out =-100; end 
% 	if ( int_8 ==1&& int_17 ==3) out =-101; end 
% 	if ( int_8 ==0&& int_17 ==2) out =-102; end 
% 	if ( int_8 ==-1&& int_17 ==1) out =-103; end 
% 	if ( int_8 ==-2&& int_17 ==0) out =-104; end 
% 	if ( int_8 ==-3&& int_17 ==-1) out =-105; end 
% 	if ( int_8 ==-4&& int_17 ==-2) out =-106; end 
% 	if ( int_8 ==-5&& int_17 ==-3) out =-107; end 
% 	if ( int_8 ==-6&& int_17 ==-4) out =-108; end 
% 	if ( int_8 ==-7&& int_17 ==3) out =-109; end 
% 	if ( int_8 ==-8&& int_17 ==2) out =-110; end 
% 	if ( int_8 ==8&& int_17 ==1) out =-111; end 
% 	if ( int_8 ==7&& int_17 ==0) out =-112; end 
% 	if ( int_8 ==6&& int_17 ==-1) out =-113; end 
% 	if ( int_8 ==5&& int_17 ==-2) out =-114; end 
% 	if ( int_8 ==4&& int_17 ==-3) out =-115; end 
% 	if ( int_8 ==3&& int_17 ==-4) out =-116; end 
% 	if ( int_8 ==2&& int_17 ==3) out =-117; end 
% 	if ( int_8 ==1&& int_17 ==2) out =-118; end 
% 	if ( int_8 ==0&& int_17 ==1) out =-119; end 
% 	if ( int_8 ==-1&& int_17 ==0) out =-120; end 
% 	if ( int_8 ==-2&& int_17 ==-1) out =-121; end 
% 	if ( int_8 ==-3&& int_17 ==-2) out =-122; end 
% 	if ( int_8 ==-4&& int_17 ==-3) out =-123; end 
% 	if ( int_8 ==-5&& int_17 ==-4) out =-124; end 
% 	if ( int_8 ==-6&& int_17 ==3) out =-125; end 
% 	if ( int_8 ==-7&& int_17 ==2) out =-126; end 
% 	if ( int_8 ==-8&& int_17 ==1) out =-127; end 
end
