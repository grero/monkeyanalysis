function plot_target(row,column,screen_width,screen_height,nrows,ncols)
    xmargin = screen_width/20;
    ymargin = screen_height/20;
    xdiff = (screen_width-2*xmargin)/ncols;
    ydiff = (screen_height-2*ymargin)/nrows;
    %plot grid
    figure
    hold on
    for i = 0:nrows
            plot([xmargin,screen_width-xmargin],[ymargin+i*ydiff,ymargin+i*ydiff],'k')
    end
    for i = 0:ncols
            plot([xmargin+i*xdiff, xmargin+i*xdiff], [ymargin, screen_height-ymargin],'k')
    end
    %highlight target
    rp = rectangle('Position',[xmargin + (column-1)*xdiff, ymargin + (nrows-row)*ydiff,xdiff, ydiff],'FaceColor','red');
end
