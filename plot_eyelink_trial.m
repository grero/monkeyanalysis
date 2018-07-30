function plot_eyelink_trial(edfdata, eyetrials, trial,eye,draw_saccades)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Plot the x and y position of the eye for the given trial. 
    %Time starts at the start of the trial and end at the end
    %input:
    %   edfdata : eyelink data (edfdata = edfmex('data.edf'))
    %   eyetrials : trial structures parsed from the edfdata 
    %                        (eyetrials = parseEDFData(edfdata, rows, cols)
    %optional input:
    %   eye (default 1) : which eye to plot
    %   draw_saccades (defauult) : whether to plot saccades
    %eyetrials = parseEDFData(edfdata,rows,cols);
    k = 0;
    ss = 1;
    tt = 0;
    if nargin < 4
        eye = 1;
    end
    if nargin < 5
        draw_saccades = 0;
    end
    dt = 1000/edfdata.RECORDINGS(1).sample_rate; %get the sampling rate in ms
    while k < trial 
        if isempty(eyetrials(ss).trials)
            ss = ss + 1;
            tt = 1;
        elseif k > length(eyetrials(ss).trials)
            ss = ss + 1;
            tt = 1;
        else
            tt = tt +1;
        end
        k = k +1;
    end
    vidx  = (eyetrials(ss).trials(tt).start < edfdata.FSAMPLE.time)&(eyetrials(ss).trials(tt).end > edfdata.FSAMPLE.time);
    gx = double(edfdata.FSAMPLE.gx(eye,vidx));
    gy = double(edfdata.FSAMPLE.gy(eye,vidx));
    gx(gx>=1e8) = nan;
    gy(gy>=1e8) = nan;
    x = edfdata.FSAMPLE.time(vidx);
    t = 0:dt:(double(x(end)-x(1)));
    n = min(length(gx), length(t)); %slightly hackish
    plot(t(1:n), gx(1:n),'b');
    hold on
    plot(t(1:n),gy(1:n),'r');
    %add trial markers
    labels = {'x position', 'y position'};
    if isfield(eyetrials(ss).trials(tt), 'target') && ~isempty(eyetrials(ss).trials(tt).target)
        xx = eyetrials(ss).trials(tt).target.timestamp - x(1);
        plot([xx xx], get(gca, 'ylim'),'r','LineWidth',2.0)
        labels = [labels 'target'];
    end
    if isfield(eyetrials(ss).trials(tt), 'response_cue') && ~isempty(eyetrials(ss).trials(tt).response_cue)
        xx = eyetrials(ss).trials(tt).response_cue - x(1);
        plot([xx xx], get(gca, 'ylim'),'k', 'LineWidth', 2.0)
        labels = [labels 'response'];
    end
    if isfield(eyetrials(ss).trials(tt), 'reward')  && ~isempty(eyetrials(ss).trials(tt).reward)
        xx = eyetrials(ss).trials(tt).reward - x(1);
        plot([xx xx], get(gca, 'ylim'),'g', 'LineWidth', 2.0)
        labels = [labels 'reward'];
    end
    if draw_saccades && isfield(eyetrials(ss).trials(tt),'saccade')
        for s=1:length(eyetrials(ss).trials(tt).saccade)
            xx = eyetrials(ss).trials(tt).saccade(s).start_time - x(1);
            plot([xx xx], get(gca, 'ylim'),':k', 'LineWidth', 1.0)
        end
    end
    legend(labels);
    hold off
end