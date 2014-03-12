function data = getEyelinkData(EE)
    if ischar(EE)
        EE = edfmex(EE);
    end
        
    %get the screen resolution
    pos = sscanf(EE.FEVENT(1).message, '%*s %*d %*d %d %d',[1,inf]);
    width = pos(1);
    height = pos(2);
    %parse eye events
    fixations = [];
    saccstart = [];
    saccend = [];
    for i=1:length(EE.FEVENT) 
        gstx = EE.FEVENT(i).gstx;
        gsty = EE.FEVENT(i).gsty;
        genx = EE.FEVENT(i).genx;
        geny = EE.FEVENT(i).geny;
        if strcmpi(EE.FEVENT(i).codestring,'startfix')
            fixations = [fixations [gstx; gsty]];
        elseif strcmpi(EE.FEVENT(i).codestring, 'endsacc')
            saccend = [saccend [genx; geny]];
            saccstart = [saccstart [gstx; gsty]];
        end
    end
    data.fixations = fixations;
    data.sacc_start = saccstart;
    data.sacc_end = saccend;
    data.screen_width = width;
    data.screen_height = height;
end
