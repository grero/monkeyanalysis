function plot_eyelink_trial(edfdata, eyetrials, trial)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Plot the x and y position of the eye for the given trial. 
    %Time starts at the start of the trial and end at the end
    %input:
    %   edfdata : eyelink data (edfdata = edfmex('data.edf'))
    %   eyetrials : trial structures parsed from the edfdata 
    %                        (eyetrials = parseEDFData(edfdata, rows, cols)
    %eyetrials = parseEDFData(edfdata,rows,cols);
    k = 0;
    ss = 1;
    tt = 1;
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
    k
    vidx  = (eyetrials(ss).trials(tt).start < edfdata.FSAMPLE.time)&(eyetrials(ss).trials(tt).end > edfdata.FSAMPLE.time);
    gx = double(edfdata.FSAMPLE.gx(1,vidx));
    gy = double(edfdata.FSAMPLE.gy(1,vidx));
    gx(gx>=1e8) = nan;
    gy(gy>=1e8) = nan;
    x = edfdata.FSAMPLE.time(vidx);
    t = 0:0.5:(double(x(end)-x(1))+0.5);
    plot(t, gx,'b');
    hold on
    plot(t,gy,'r');
    legend('x', 'y');
    hold off
end