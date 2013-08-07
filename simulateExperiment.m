function ans = simulateExperiment(offset,nsamples,edfdata,l)
    if nargin == 3
        figure
        axis
        l = plot(edfdata.FSAMPLE.gx(1,1),edfdata.FSAMPLE.gy(1,1),'.');
        rectangle('Position', [144,90,1440-2*144,900-2*90]);
        xdiff = (1440-2*144)/5;
        ydiff = (900-2*90)/5;
        for j=0:4
            line([144, 1440-144], [90+j*ydiff 90+j*ydiff],'Color','k');
        end
        for i=0:4
            line([144+i*xdiff, 144+i*xdiff], [90 900-90],'Color','k');
        end
        hold on
        fill([144+2*xdiff, 144+3*xdiff, 144+3*xdiff, 144+2*xdiff],...
            [90+3*ydiff, 90+3*ydiff, 90+2*ydiff, 90+2*ydiff],[0.5,0.5,0.5]);
        xlim([0,1440]);
        ylim([0,900]);
    end
    lifetime = -1;
    for i=1:nsamples,
        set(l,'XData',edfdata.FSAMPLE.gx(1,offset+i),'YData',edfdata.FSAMPLE.gy(1,offset+i));
        pause(0.01);
        if lifetime == -1
            k = rand;
        else
            k = 1;
        end
        if k < 0.1
            px = randi(5)-1;
            py = randi(5)-1;
            if (px ~= 2) && (py ~= 2)
                h = fill([144+px*xdiff, 144+(px+1)*xdiff, 144+(px+1)*xdiff, 144+px*xdiff],...
                [90+(py+1)*ydiff, 90+(py+1)*ydiff, 90+py*ydiff, 90+py*ydiff],'r');
                lifetime = 0;
            end
        end
        if lifetime>-1
            lifetime = lifetime + 1;
        end
        if lifetime >= 100
            delete(h);
            lifetime = -1;
        end
        drawnow
    end
end
