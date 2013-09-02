function plotResponseFields(F)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Plot raster for different target locations
	%Input:
	%	F			    :	[rnows X ncols X nbins] matrix of mean reponse triggered on target
	%	bins			:	the bins used to compute the spike counts
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	figure
	%plot the response maximum response
    %assuming the fields F were compute in a clumn-wise fashion ,we need to
    %tranpose first
	imagesc(max(permute(F,[2,1,3]),[],3));
    set(gca,'XTick',[], 'YTick',[]);
	c = colorbar;
    ylabel(c, 'Peak firing rate [Hz]');
end
