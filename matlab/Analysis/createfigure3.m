function createfigure2(commonphase,H,  params, frame,sim, instr )
%
Y1 = frame.EVM_dB_sc;
Y2 = frame.EVM_dB_sym;
Y3 = commonphase;
Y4 = frame.fftout(1,:);
Y5 = frame.idealout(1,:);
Y6 = zeros(size(H));
for ii=1:(length(params.LTFindex))
    idx=params.LTFindex(ii);

    Y6(:,:,params.LTFindex(ii)) = inv(H(:,:,params.LTFindex(ii)));

end

% Create figure
figure1 = figure;


axes1 = axes('Parent',figure1,...
    'Position',[0.547654236038178 0.57156312913431 0.197350521335752 0.325081196769781]);
hold(axes1,'all');
plot(axes1,1:size(Y1,1), Y1(:,1),'b' );
xlim(axes1,[0 length(Y1)]); 
% ylim(axes1,[ -23 -13]);
xlabel(axes1,'subcarrier (X pol)');
ylabel(axes1,'EVM');


% Create axes
axes2 = axes('Parent',figure1,...
    'Position',[0.695528068506186 0.0606574425755113 0.26715303270242 0.10546097847712]);
% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes2,[1 300]);
hold(axes2,'all');
plot(1:length(Y2), Y2,'Parent',axes2,'DisplayName',['EVM']);
xlabel('symbol');

% Create axes
axes3 = axes('Parent',figure1,...
    'Position',[0.0401313717791762 0.228618421052632 0.20154322384404 0.255215210149908]);
box(axes3,'on');
hold(axes3,'all');




% Create axes
axes4 = axes('Parent',figure1,...
    'Position',[0.0347758322476486 0.566755840358354 0.218316460806586 0.34814990512334]);
Z4 = frame.fftout(1,:);
Z5 = frame.idealout(1,:);
plot(axes4,real(Z4), imag(Z4),'b*',real(Z5), imag(Z5),'r*','MarkerSize', 2)
xlim(axes4,[-1.5 1.5]);
ylim(axes4,[-1.5 1.5]); 
xlabel(axes4, 'X pol')
box(axes4,'on');
grid(axes4,'on');
hold(axes4,'all');

% Create axes
axes5 = axes('Parent',figure1,...
    'Position',[0.43208525879994 0.0738831615120274 0.22918971741319 0.0859106529209623],...
    'CLim',[1 2]);
hist(axes5, mod(frame.diff_rtx, params.Nsd), params.Nsd)
xlabel(axes5,'Subcarrier vs Number of error')
xlim(axes5,[1 params.Nsd]);
box(axes5,'on');
hold(axes5,'all');

% Create patch
% patch('Parent',axes5,'VertexNormals',VertexNormals1,'YData',YData1,...
%     'XData',XData1,...
%     'Vertices',Vertices1,...
%     'Faces',Faces1,...
%     'FaceColor','flat',...
%     'FaceVertexCData',FaceVertexCData1,...
%     'CData',CData1);

% Create axes
axes6 = axes('Parent',figure1,...
    'Position',[0.0338709730856541 0.0756013745704466 0.325911528150134 0.0859106529209623]);
box(axes6,'on');
hold(axes6,'all');
plot(1:length(Y3), Y3,'Parent',axes6,'Color',[1 0 0],'DisplayName','commonphase');

% Create axes
axes7 = axes('Parent',figure1,...
    'Position',[0.778862609016296 0.571563129134309 0.197350521335752 0.325081196769781]);
% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes7,[0 70]);
% Uncomment the following line to preserve the Y-limits of the axes
% ylim(axes7,[-26 -10]);
hold(axes7,'all');
plot(axes7,1:size(Y1,1), Y1(:,2),'b' );
xlim(axes7,[0 length(Y1)]); 
% ylim(axes7,[ -23 -13]);
xlabel(axes1,'subcarrier (X pol)');
% Create xlabel
xlabel('subcarrier');
ylabel('EVM');

% Create axes
axes8 = axes('Parent',figure1,...
    'Position',[0.288819600087804 0.566755840358354 0.218316460806586 0.34814990512334]);
% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes8,[-1.5 1.5]);
% Uncomment the following line to preserve the Y-limits of the axes
% ylim(axes8,[-1.5 1.5]);
Z4 = frame.fftout(2,:);
Z5 = frame.idealout(2,:);
plot(axes8,real(Z4), imag(Z4),'b*',real(Z5), imag(Z5),'r*','MarkerSize', 2)
xlim(axes8,[-1.5 1.5]);
ylim(axes8,[-1.5 1.5]); 
xlabel(axes8, 'X pol')
box(axes8,'on');
grid(axes8,'on');
hold(axes8,'all');

% Create axes
axes9 = axes('Parent',figure1,...
    'Position',[0.285611866546065 0.222039473684211 0.20154322384404 0.258504683834119]);
box(axes9,'on');
hold(axes9,'all');


axes10 = axes('Parent',figure1,...
    'Position',[0.778475805651682 0.210526315789473 0.20154322384404 0.258504683834119]);
box(axes10,'on');
hold(axes10,'all');



% Create axes
axes11 = axes('Parent',figure1,...
    'Position',[0.53299531088479 0.217105263157894 0.20154322384404 0.255215210149908]);
box(axes11,'on');
hold(axes11,'all');

phase_rot =  exp(  0 *1j*[0: (params.NFFT-1)]*2*pi/params.NFFT*(sim.syncpoint)) ;
hmax =1.1* max( [max(abs(Y6(1,1,:))),max(abs(Y6(1,2,:))),max(abs(Y6(2,1,:))),max(abs(Y6(2,2,:)))]);
H11(1:size(Y6,3))=Y6(1,1,1:size(Y6,3))  ;  
H11 = H11 .* phase_rot;
plot(axes3, 1:params.NFFT, abs(H11),'g',  1:params.NFFT, real(H11),'r',   1:params.NFFT, imag(H11),'b'); 
ylim(axes3, [-hmax hmax]);
xlim(axes3, [1 params.NFFT ]);
H12(1:size(Y6,3))=Y6(1,2,1:size(Y6,3));   
H12 = H12 .* phase_rot;
plot(axes9, 1:params.NFFT, abs(H12),'g',  1:params.NFFT, real(H12),'r',   1:params.NFFT, imag(H12),'b'); 
ylim(axes9, [-hmax hmax]);
xlim(axes9, [1 params.NFFT ]);
H21(1:size(Y6,3))=Y6(2,1,1:size(Y6,3));   
H21 = H21 .* phase_rot;
plot(axes11, 1:params.NFFT, abs(H21),'g',  1:params.NFFT, real(H21),'r',   1:params.NFFT, imag(H21),'b'); 
ylim(axes11, [-hmax hmax]);
xlim(axes11, [1 params.NFFT ]);
H22(1:size(Y6,3))=Y6(2,2,1:size(Y6,3));  
H22 = H22 .* phase_rot;  
plot(axes10, 1:params.NFFT, abs(H22),'g',  1:params.NFFT, real(H22),'r',   1:params.NFFT, imag(H22),'b'); 
ylim(axes10, [-hmax hmax]);
xlim(axes10, [1 params.NFFT ]);


annotation(figure1,'textbox',...
    [0.11402475780409 0.937219730941704 0.254113024757804 0.047085201793722],...
    'String',{'simulation'},...
    'FitBoxToText','off',...
    'EdgeColor','none');

