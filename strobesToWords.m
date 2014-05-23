function words = strobesToWords(strobes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Convert int16 strobes to binary words
%Input:
%	strobes		:	strobes encoded as 16 bit integers
%Output:
%	words		:	matrix of doubles were each row is the binary represntation
%					of a strobe word
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%check the value of the first strobe to get the decoding
	if (strobes(1) == 4415) || (strobes(1) == 4606)
		%we are using an inverted scheme
		words = ~logical(dec2bin(strobes)-'0');
		words = double(words(:,end-7:end));
	elseif strobes(1) == -4416
		%this is the old scheme
		words = dec2bin(2^15-abs(strobes)) - '0';
		words = words(:,end-7:end);
    elseif strobes(1) == -256
        words = dec2bin(abs(strobes));
        words = words(:,end-1:-1:1);
    else
        words = nan;
		disp('Unknown strobe encoding');
	end
end
	 
	
