function [onset,offset] = getSignificantInterval(I,Is,bins,limit,minnbins)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Find the region(s) where the values in I exceed the specified limit 
	%of the distribution of values in Is
	%Input:
	%	I		:		vector of values
	%	Is		:		matrix of ntrials X nvalues, where each column should be compared
	%					to the corresponding column in I
	%	bins	:		the bins in which I and Is are computed
	%	limit	:		the percentile of Ish which I should exceed to be considered
	%					significant
	%	minnbins	:		the number of consecutive bins with I > limit(Ish) for 
	%					the result to be considered significant
	%Output:
	%	onset	:		onset of the significant region(s)
	%	offset	:		offset of the significant region(s)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 5
		minnbins = 5;
	end
	if nargin < 4
		limit = 95;
    end
    if size(I,2) ~= size(Is,2)
        I = I';
    end
	sidx = find(I>prctile(Is,limit,1));
	onset = [];
	offset = [];
	if ~isempty(sidx)
        n = 1;
        for i=2:length(sidx)
            if sidx(i) - sidx(i-1) == 1
                n = n + 1;
            else
                if n >= minnbins
                    onset = [onset;sidx(i-n+1)];
                    offset = [offset;sidx(i)];
                end
                n = 1;
            end
        end
        if n >= minnbins
            
            if (i == length(sidx))
                onset = [onset;sidx(i-n+1)];
                offset = [offset;sidx(i)];
            end
        end
        if isempty(onset)
            onset = nan;
            offset = nan;
        end
        
    else
        onset = nan;
        offset = nan;
	end
end
