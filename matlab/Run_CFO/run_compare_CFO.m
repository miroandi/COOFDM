

figure; hold on;
tmp = dlmread('CFO5.txt'); 
plot( tmp(70:307,1), tmp(70:307,2),'r*', 'Display', 'CFO5');

tmp = dlmread('CFO2.txt'); 
plot_range = [1:42 44:49];
plot( tmp(plot_range,1), tmp(plot_range,2),'g*', 'Display', 'CFO2'); 

tmp = dlmread('CFO7.txt'); 
plot_range = [1:42 44:49];
plot( tmp(:,1), tmp(:,2),'b*', 'Display', 'CFO2'); 


tmp = dlmread('CFO4.txt'); 
plot( tmp(70:474,1), tmp(70:474,2),'m*', 'Display', 'CFO4');

ylabel('Measured CFO(MHz)');
xlabel('Estimated CFO(MHz)');

figure;hold on;

wavelength = [1550.0638:0.01:1550.1038, 1550.1088, 1550.1138:0.01:1550.1338]

MSEE_4 = [ 5.473e-7 2.181e-7 1.947e-7 3.396e-7  2.963e-7 2.872e-7 2.907e-7 1.947e-7 3.267e-7];
plot( wavelength, MSEE_4, 'Display', 'CFO4');
wavelength = [1550.0638:0.01:1550.1038 1550.1088, 1550.1138:0.01:1550.1238]
MSEE_5 = [ 1.352e-7 3.819e-7 1.866e-010 2.177e-7 2.789e-7 1.839e-7 2.943e-7 4.132e-7];
plot( wavelength, MSEE_5, 'Display', 'CFO4');
xlabel('Given wavelength of LO laser(nm)');
ylabel('MSEE');

%%
tmp = dlmread('03April.txt');
figure( 'FileName', ['MSEEvsSNR_CFO0Hz.fig']);  hold on;        
plot( osnr2snr(tmp(:,1), 10e9), tmp(:,3), 'b*-', 'Display', 'Zhou');
plot( osnr2snr(tmp(:,1), 10e9), tmp(:,5), 'ms-', 'Display', 'Conven. CRT');
plot( osnr2snr(tmp(2:6,1), 10e9), tmp(2:6,7), 'ro-', 'Display', 'Prop. CRT');
plot( osnr2snr(tmp(:,1), 10e9), tmp(:,9), 'gd-', 'Display', 'Youn');

ylim( [1e-10 1e-6])
xlabel('OSNR')
ylabel('MSEE');

%%

figure( 'FileName', ['MSEEvsCFO.fig']);  hold on; 
X_coor =[1550.0638:0.01:1550.1438];
MSEE= [5.473e-7, 2.181e-7, 1.947e-7, 3.396e-7, 2.963e-7, 2.872e-7, 2.907e-7,1.947e-7, 3.267e-7];
plot( X_coor, MSEE, 'gd-', 'Display', 'Conven. CRT');
MSEE = [1.352e-7 3.819e-7 1.866e-10 2.177e-7 2.789e-7 1.839e-7 2.943e-7 4.132e-7 4.184e-7];
plot( X_coor, MSEE, 'gd-', 'Display', 'Prop. CRT');

ylim( [1e-10 1e-6])
xlabel('OSNR')
ylabel('MSEE');

