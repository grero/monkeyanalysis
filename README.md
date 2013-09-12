#This is the README file for the monkeyAnalysis code

##Introduction

These are codes to analyze data recorded from the monkeys performing a delayed memory saccade task.

##Getting started

To extract experimental markers, as well as high pass- low pass-filtered continuous data, use the following function:

	FilterPl2.m

To convert stimulus markers from int16's to binary words, use the following function:

	strobesToWords.m

To replay the experiment, use the following function:

	function ans = replayExperiment(offset,nsamples,edfdata,l)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Replay the experiment from the eye link data contained in the edfdata structure.
		%Inputs:
		%	offset		:		time point index from which to start the replay
		%	nsamples	:		number of time points to replay
		%	edfdata		:		eye link data structure contraining the experiment
		%	l			:		reference to a line plot handle
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To load and parse the stimulus markers, use the following function


	function trials = loadTrialInfo(fname)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Load and parse the event markers contained in the file pointed to by
		%fname
		%Input:
		%   fname		:		name of file containing the marker information. The file should contain two variables;
		%   					sv is the int16 representation of the strobe words and ts is the marker timestamps in seconds
		%Output:
		%	trials		:		struct array with inforamtion about each trial
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To load spike trains produced by the Plexon Offline sorter, use the following function

	function sptrains = loadPlexonSpiketrains(fname)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Load spike trains from a .txt file produced by the Plexon offline sorter
	%Input:
	%   fname         :         name of text file containing the sorted spikes.
	%                           the file consist of tab-delimited rows where
	%                           the first column indicates the channel, the
	%                           second column the unit and the third column the
	%                           spike time, in seconds.
	%Output:
	%   sptrains.spikechannels    :    channels with at least one unit
	%   sptrains.channels(i).cluster(j).spiketimes   :    the spike times of
	%                                                     unit j on channel j,
	%                                                     in units of miliseconds
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To convert a matrix of 8 bit words to their string representation, use the following function

	function names = wordsToString(words)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Return the string representation of the 8 bit strobe words
	%Input:
	%	words		:	matrix where each row represents a single
	%					8 bit strobe word
	%Output:
	%	names		:	the string representation of each strobe
	%					word
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To return trials of a certain type, use the following function

	function rtrials  = getTrialType( trials,type )
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Return a subset of the trials of the specified type. The type should
	%correspond to a field in the trial structure e.g. 
	%getTrialType(trials,'target') will return all trials in which a
	%target appeared. 
	%Input:
	%   trials          :    trial structure obtained from loadTrialInfo
	%   type            :    string indicating which trial type to get.
	%                        Possible values are: 'target' and'failure'. 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To align a spike train to trial events, use the following funcction

	function [spikes,trial_idx] = createAlignedRaster(sptrain,trials,alignment_event)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Align spike train to trial start
	%Input:
	%	sptrain     	:   flat vector with spiketimes in miliseconds
	%   trials      	:    trial structure obtained from loadTrialInfo
	%	alignment_event	:	event to which to align the spike trains. The event
	%Output:
	%   spikes      	:       spike time shifted to aligned with the start of
	%                           each trial
	%   trial_idx   	:       index of the trial to which each spike belongs
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To plot the trial aligned raster, use the following function

	function plotRaster(spikes,trial_idx,trials,alignment_event)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Plot raster with trials arranged according to location
		%Input:
		%	spikes		:		timestamps of spikes to be plotted, in
		%						units of ms
		%	trial_idx	:		the trial index of spike
		%	trials		:		structure array containing information about the 
		%						trials used to aligned the spikes
		%	alignment_event:	the event used to align the spikes, .e.g. 'target'
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To plot aligned rasters for multiple spike trains, use the following function

	function plotRasters(sptrains,trials,alignment_event)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Plot rasters for the specified spike trains. The plots
		%are saved under the current directory as gXXcXXsLocationInformation.pdf
		%Input:
		%	sptrains		:		structure array of spike strains
		%	trials			:		structure array of trial information
		%	alignment_event	:		the event to which to align the spike trains
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To compute the spike count for a spike train, use the following function

	function [counts, bins] = getTrialSpikeCounts(sptrain,trials,bins, alignment_event)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Get the spike count for the supplied spike train in the given bins
		%Input:
		%	sptrain				:		array of spike times, in ms
		%	trials				:		structure array containing trial information
		%	bins				:		the bins (in ms) in which to compute spike counts
		%	alignment_event		:		event to which to align the spike trains. The event
		%								must be a field in the trials structure array,
		%								e.g. 'response' or 'target'. If the event is not 
		%								a member of trials, it default to 'prestim', i.e. 
		%								start of fixation
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To plot PSTH for different target locations, use the following function

	function plotLocationPSTH(counts,bins,alignment_event,trials)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Plot raster for different target locations
		%Input:
		%	counts			:	[ntrials X nbins] matrix of spike counts
		%	bins			:	the bins used to compute the spike counts
		%	alignment_event	:	the event to which the spike counts were 
		%						aligned
		%	trials			:	structure array of trials information
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To compute the information encoded about target location, use the following function

	function [H,Hc,bins,bias] = computeInformation(counts,bins,trials,shuffle,sort_event)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Compute the information contained in the counts matrix.
		%Input:
		%	counts		:		[ntrials X nbins-1]		:		matrix of spike counts
		%	bins		:		[nbins,1]				:		the bins use to compute the spike counts
		%	trials		:		structure array containing information about the trials used
		%	shuffle		:		whether we should also compute shuffle information. Defaults to 0 (no)
		%	sort_event	:		the event used to sort the trials. This defaults to 'target'
		%Output:
		%	H			:		Total entropy for each time bin
		%	Hc			:		Conditional entropy for each time bin
		%	bins		:		bins used to compute the spike counts
		%	bias		:		the Panzeri-Treves bias correction factor for the information
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To plot information encoded about target, use the following function

	function plotLocationInformation(I,bins,alignment_event,trials,Is)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Plot raster for different target locations
		%Input:
		%	I		 		:	[nbins,1] Information encoded about the target locationo
		%						per bin
		%	bins			:	the bins used to compute the spike counts
		%	alignment_event	:	the event to which the spike counts were 
		%						aligned
		%	trials			:	structure array of trials information
		%	Is				:	[optional] shuffle information obtained by shuffle trial labels
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To compute and plot information for several spike trains, use the following function

	function analyzeLocationInformation(sptrains,trials,bins,alignment_event)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Compute and plot the information for several spike trains. The plots
		%are saved under the current directory as gXXcXXsLocationInformation.pdf
		%Input:
		%	sptrains		:		structure array of spike strains
		%	trials			:		structure array of trial information
		%	bins			:		the bins into which the spike trains should be discretized
		%	alignment_event	:		the event to which to align the spike trains. Defaults 
		%							to target
		%	sort_event		:		the event used to sort the trials. Defaults
		%							to 'target'
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To compute visual response fields, use the following function

	function F = computeSpatioTemporalFields(counts,bins,alignment_event,trials)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Plot raster for different target locations
		%Input:
		%	counts			:	[ntrials X nbins] matrix of spike counts
		%	bins			:	the bins used to compute the spike counts
		%	alignment_event	:	the event to which the spike counts were 
		%						aligned
		%	trials			:	structure array of trials information
		%Output:
		%	F	[nrows X ncols X nbins]	:	mean triggered response for each location
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To plot visual response fields, use the following function

	function plotResponseFields(F)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Plot raster for different target locations
		%Input:
		%	F			    :	[rnows X ncols X nbins] matrix of mean reponse triggered on target
		%	bins			:	the bins used to compute the spike counts
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
To compute and plot visual response fields for multiple cells, use the following function

	function analyzeResponseFields(sptrains,trials,bins,alignment_event)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Compute and plot the information for several spike trains. The plots
		%are saved under the current directory as gXXcXXsLocationInformation.pdf
		%Input:
		%	sptrains		:		structure array of spike strains
		%	trials			:		structure array of trial information
		%	bins			:		the bins into which the spike trains should be discretized
		%	alignment_event	:		the event to which to align the spike trains
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To compute the response onset of a cell based on when the information about target becomes significant, use the following function

	function [onset,offset] = getResponseOnset(sptrain,bins,trials,alignment_event,sort_event)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Compute the response onset of the a cell by identifying where the information
		%about target locatoin exceeds the 95th percentile of the shuffled information
		%for at least 5 bins
		%Input:
		%	sptrain			:		structure with a field 'spiketimes' corresponding to the 
		%							spike times of this cell
		%	bins			:		bins used to compute spike counts
		%	trials			:		structure array with trial information
		%	alignment_event	:		event used to align the spikes. Defaults to 'target'
		%	sort_event		:		event used to sort the trials. Defaults to the same as 
		%							alignment event
		%Output:
		%	onset			:		the response onset of the cell, relative to alignment_event
		%	offset			:		the end of the response period, i.e. where the information drops
		%							below the 95th percentile
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To compute the response onset for a population of cells, use the following function

	function [onset,offset] = analyzeResponseOnset(sptrains,trials,bins,alignment_event,sort_event)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Compute and plot the information for several spike trains. The plots
		%are saved under the current directory as gXXcXXsLocationInformation.pdf
		%Input:
		%	sptrains		:		structure array of spike strains
		%	trials			:		structure array of trial information
		%	bins			:		the bins into which the spike trains should be discretized
		%	alignment_event	:		the event to which to align the spike trains. Defaults 
		%							to target
		%	sort_event		:		the event used to sort the trials. Defaults
		%							to 'target'
		%Output:
		%	onset			:		array of response onsets for each spike train
		%	offset			:		array of response offsets for each spike train
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To compute the information transfer between two spike trains, use the following function

	function [E11,E112,bins] = computeInformationTransfer(sptrains, bins, history, trials, alignment_event,shuffle)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Input:
		%	sptrains	:	cell-array of spike trains to compute information transfer between
		%	bins		:	primary bins, i.e. bins for which we want to predict
		%	history		:	how far back to look from each bin, i.e. if the bin size is 20 ms
		%					and history is specified as 50ms, the 50ms prior to each bin will be
		%					used as the history for that bin
		%	trials		:	structure array containing information about trials
		%	alignment_event	:	event to which to align the spike trains
		%	shuffle			:	whether to compute shuffle information
		%Output:
		%	E11			:	Entropy of the spike counts in spike train 1 conditioned on its
		%					own history
		%	E112		:	Entropy of the spike counts in spike train 1 conditioned on both its
		%					own history ond that of spike train 2.
		%					The difference between these two quantities is the amount of
		%					information transfered from spike train 2 to spike train 1
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

To compute and plot the transfer information for all pairs of spike trains contained in the structure 'sptrains',
use the following function

	function analyzeInformationTransfer(sptrains,trials,bins,history, alignment_event)
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%Compute and plot the information for several spike trains. The plots
		%are saved under the current directory as gXXcXXsLocationInformation.pdf
		%Input:
		%	sptrains		:		structure array of spike strains
		%	trials			:		structure array of trial information
		%	bins			:		the bins into which the spike trains should be discretized
		%	alignment_event	:		the event to which to align the spike trains
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

