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
