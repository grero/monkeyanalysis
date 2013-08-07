function words = strobesToWords(strobes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Convert int16 strobes to binary words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	words = dec2bin(2^15-abs(strobes));
	%get the last 8 bits
	words = words(:,end-7:end);
end
	 
	
