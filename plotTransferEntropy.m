function plotTransferEntropy(cell1, cell2, trials,save)
    if nargin < 4
        save = 1;
    end
	fname = [cell1 cell2 'transferEntropy.mat'];
    [rm,rs,response] = getEventTimingDistr(trials,'response','target');
    distractors = [];
    if isfield(trials,'distractors')
       [dm,ds,distractors] = getEventTimingDistr(trials,'distractors','target');
    end
    %[rm,rs,response] = getEventTimingDistr(trials,'response');
    
	if exist(fname,'file')
		d = load(fname);
        d.step = double(d.step);
        nbins = length(d.bins);
        figure
        ax1 = subplot(2,1,1);
		shadedErrorBar(d.bins(1:nbins-d.step),100*squeeze(mean(d.ets(:,:,1,1)./d.e1s(:,:,1,1),2)), 100*squeeze(2*std(d.ets(:,:,1,1)./d.e1s(:,:,1,1),0,2)));
		hold on
		plot(d.bins(1:nbins-d.step),100*squeeze(d.et(:,1,1)./d.e1(:,1,1)),'.-')
		%xlabel('Time [ms]')
		ylabel(['Relative transfer entropy [%]'])
        set(ax1,'XTickLabel',[]);
        yl1 = ylim;
        %prettify plot
        set(gca,'Box','Off');
        set(gca, 'TickDir','out');
        plot([0 0], [yl1(1) yl1(2)],'k');
        if rm < d.bins(nbins-d.step)
            plot([rm rm], [yl1(1) yl1(2)],'r');
        end
        if ~isempty(distractors)
            if dm < d.bins(nbins-d.step)
                plot([dm dm], [yl1(1) yl1(2)],'g');
            end
        end
        set(get(ax1,'title'),'String','cell1 $\rightarrow$ cell2','interpreter','latex')
		%reverse
        ax2 = subplot(2,1,2);
		shadedErrorBar(d.bins(1:nbins-d.step),100*squeeze(mean(d.ets(:,:,2,1)./d.e1s(:,:,2,1),2)), 100*squeeze(2*std(d.ets(:,:,2,1)./d.e1s(:,:,2,1),0,2)));
		hold on
		plot(d.bins(1:nbins-d.step),100*squeeze(d.et(:,2,1)./d.e1(:,2,1)),'.-')
		xlabel('Time [ms]')
		ylabel(['Relative transfer entropy [%]'])
        %prettify plot
        set(gca,'Box','Off');
        set(gca, 'TickDir','out');
        yl2 = ylim;
        plot([0 0], [yl2(1) yl2(2)],'k');
        if rm < d.bins(nbins-d.step)
            plot([rm rm], [yl2(1) yl2(2)],'r');
        end
        if ~isempty(distractors)
            if dm < d.bins(nbins-d.step)
                plot([dm dm], [yl2(1) yl2(2)],'g');
            end
        end
        set(get(ax2,'title'),'String','cell2 $\rightarrow$ cell1','interpreter','latex')
        %equalize y-axis
        oylim = [min(yl1(1),yl2(1)),max(yl1(2),yl2(2))];
        set(ax1,'Ylim',oylim);
        set(ax2,'Ylim',oylim);
        if save
            fname = [cell1 cell2 'transferEntropy.pdf'];
            print('-dpdf',fname);
        end
    end
end
