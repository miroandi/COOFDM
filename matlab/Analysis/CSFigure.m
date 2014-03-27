function CSFigure( in, cs, Msym, idx, idx2)
        figure
        subplot(2,1,2);
        hold on
        plot( cs ,   'g','DisplayName', 'CS', 'LineWidth', 2 );
        subplot(2,1,1);
        hold on        
        plot(real(in(1,:)),  'DisplayName', 'real(in)', 'LineWidth', 2 );
        plot(idx, real(in(1,idx)), 'rs');
        plot(idx2, real(in(1,idx2)), 'md');
        subplot(2,1,2);
        plot(idx, real(cs(idx)), 'rs');
        plot(idx2, real(cs(1,idx2)), 'md');
        plot(Msym, 'b');
        legend show
end
        