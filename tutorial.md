##How to use the functions in the monkeyAnalysis toolkit

The first thing to do is to load the information about the trials. This can be done using the getTrialInfo function. This function takes a single argument; the path to a .mat file containing trial information extracted from the pl2/plx plexon file. Typically, this file is called 'event_data.mat', and is located in the session directory. As an example, say we are working on data from Pancake recorded on the 16th of July. This data will be located in /opt/data2/newMonkey/Pancake/20130716/session01. Let's load the trial info

	trials = getTrialInfo('event_data.mat');

We now an array of structures containing information about each trial. A typical entry in this array might look like this:

	>> trials(1)

	ans = 

		   start: 5.2450
		 prestim: 4.3074
		 failure: 4.5574
			 end: 10.2849
		  target: []
		response: []
		  reward: []

There start, refers to the start of the trial in seconds. 'prestim' is the time of a marker indicating that the monkey has fixated for the required amount of time, and that the stimulus can be presented. This timestamp is in seconds relative to the trial start. In this particular example, the prestim-trigger was sent 4.3 seconds after the start of the trial. The marker 'failure' indicates that the monkey failed to complete the trial, and the timestamp encodes the time at which the monkey broke fixation, in seconds relative to trial start. In this example, the monkey broke fixation 4.56 seconds after the start of the trial. The marker 'end' repsents the timestamp of the end of the trial, in seconds relative to trial start. In this example, the trial ended 10.3 seconds after it started. 
The example shown above represents a failed trial. We might not want to bother with failed trials right now, so we'll need a function that can return only the trials we are interested in. Say we only want to analyze correct trials, meaning trial in whcich the monkey was rewarded. The function getTrialType does exactly that:

	>> rtrials = getTrialType(trials,'reward')

	rtrials = 

	1x550 struct array with fields:
		start
		prestim
		failure
		end
		target
		response
		reward

As we can see, the function takes two parameters; the trial structure itself and the name of the field we want to keep. For the session we are currently looking at, there were 550 correct trials. 
Once we have the information of the trial we are interested in, we need to load some neural data. We can start with looking at spike trains, which can be loaded using the function loadSpiketrains. This function accepts a single parameter, which is the .mat file containing all the spike trains for a ssession. This file is usually also located under the session directory, and its name follows the pattern <animal>_<date>_<session number>_Spiketrains.mat. For our current session, we load the spike trains like this:

	sptrains = loadSpiketrains('Pancake_160713_1_Spiketrains.mat')

	sptrains = 

			 channels: [1x110 struct]
		spikechannels: [13 26 38 40 54 56 59 107 109 110]

Here we see that the sptrain structure contains a field 'spikechannels', which indicates which channels had at least one single unit for this session. Let's look at the spike trains for channel 40:

	>> sptrains.channels(40)

	ans = 

		cluster: [1x4 struct]

Now we see that channel 40 had 4 units, and we can further examine one of these units


	>> sptrains.channels(40).cluster(1)

	ans = 

		spiketimes: [157865x1 double]

So the first unit on channel 40 had 157865 spikes, which are encoded in the field 'spiketimes' in units of milliseconds. 

In order to visualize how the activity of this unit changes over the trials, we first need to align each spike to a trial event. One good such event is the onset of the target. We can use the function 'createAlignedRaster' to do the alignment:

	>> [spikes,trial_idx] = createAlignedRaster(sptrains.channels(40).cluster(1),rtrials,'target');

As we can see, this function accepts three paramters; the spike train structure contaning the spike times we wish to align, the trial structure containing the timing info required for the alignment, and an event within a trial to which to align the spikes. The function returns two variables; 'spikes' is a an array containing the aligned spikes, and 'trial_idx' is trial index of each individual spike. We can now plot the aligned spike times using the function 'plotRaster':

	>> plotRaster(spikes,trial_idx,rtrials,'target')

Again, we have to supply the trial structure and the alignment event, as well as the aligned spikes with their trial labels.

![Raster example](http://bitbucket.org/rherikstad/monkeyanalysis/downloads/raster_example.png)

Each blue dot in this image is a spike.the horizontal axis represnts the time at which each spike happened, relative to the start of the trial (indicated by a black vertical line at zero), and the vertical axis is the trial index of each spike. The trials are sorted according to the location of the target at each trial, such that the bottom trials correspond to target at the upper left corner of the screen, while the top trials correspond to location at the lower right corner. For this paricular unit, we can see increases of spiking activity following a target for the bottom half of the screen (trials near the top). We can also see a sustained increase in activity for trial with targets near the center of the screen (middle trials). The vertical red line indicates the start of the response period, which is the cue for the monkey to make a response, indicating location of the target with an eye movement to that location. There is an increase in activity at a variable delay after the start of the response period for each trial, indicating the this cell encodes information about the onset of the eye movement.   

Instead of looking at invidual spikes, we can also quantify a cell's activity in terms of its firing rate. To do that, we count the number of spikes in windows of e.g. 50 ms and look at the distribution of these counts across trials. Continuing with the same as before unit, we can get the spike counts like this:

	>> [counts,bins] = getTrialSpikeCounts(sptrains.channels(56).cluster(1),rtrials,-200:50:3000,'alignment_event','target');

As we can see, the 'getTrialSpikeCounts' function takes 3 mandatory parameters; the first is a spike train containing spike times in units of the millseconds, the second is again a structure with trial timing information, and the third is the bins in which we want to count spikes. In this case, we want to count spikes from -200 ms before target onset to 3000 ms after target onset using 50 ms bins. We also supply an optional argument 'alignment_event', which again tells the function which event we want to align the spike counts to, i.e. 'target' in this case. The output of the function is the count matrix with dimensions number of trials X number of bins, as well the bins we used as input.

	>> size(counts)

	ans =

	   550   161

In this case, we have 550 trials and 161 bins.
Now we can plot the mean spike count for each bin, separated in the the 24 different locations, with the following command

	plotLocationPSTH(counts,bins,'target',rtrials)

![PSTH example](http://bitbucket.org/rherikstad/monkeyanalysis/downloads/psth_example.png)


