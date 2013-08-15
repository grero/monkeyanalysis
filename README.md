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
