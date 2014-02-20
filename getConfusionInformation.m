function I = getConfusionInformation(N)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Input:
	%	N 	:	[m x n]		: confusion matrix where the entry n_ij is the number
	%						of times class i is identified as class j
	%Output:
	%	I	:	Mutual information between the rows and columns of N. I is maximal if N
	%			is diagonal
	%			
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Nt = sum(N(:));
	H1 = log2(N + (N==0));
	H2 = log2(sum(N,1)); %entropy of columns
	H3 = log2(sum(N,2)); %entropy of columns
	H4 = log2(Nt);
	H = N.*(H1 - repmat(H2,[size(N,1),1]) - repmat(H3, [1, size(N,2)]) + H4);
	H(isnan(H)) = 0;
	I = sum(sum(H))./Nt;
end
