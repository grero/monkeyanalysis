##How to use the functions in the monkeyAnalysis toolkit

The first thing to do is to load the information about the trials. This can be done using the getTrialInfo function. This function takes a single argument; the path to a .mat file containing trial information extracted from the pl2/plx plexon file. Typically, this file is called 'event_data.mat', and is located in the session directory. As an example, say we are working on data from Pancake recorded on the 16th of July. This data will be located in /opt/data2/newMonkey/Pancake/20130716/session01. Let's load the trial info

	trials = loadTrialInfo('event_data.mat');

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

There start, refers to the start of the trial in seconds. 'prestim' is the time of a marker indicating that the monkey has fixated for the required amount of time, and that the stimulus can be presented. This timestamp is in seconds relative to the trial start. In this particular example, the prestim-trigger was sent 4.3 seconds after the start of the trial. The marker 'failure' indicates that the monkey failed to complete the trial, and the timestamp encodes the time at which the monkey broke fixation, in seconds relative to trial start. In this example, the monkey broke fixation 4.56 seconds after the start of the trial. The marker 'end' represents the timestamp of the end of the trial, in seconds relative to trial start. In this example, the trial ended 10.3 seconds after it started. 
The example shown above represents a failed trial. We might not want to bother with failed trials right now, so we'll need a function that can return only the trials we are interested in. Say we only want to analyze correct trials, meaning trial in which the monkey was rewarded. The function getTrialType does exactly that:

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
Once we have the information of the trial we are interested in, we need to load some neural data. We can start with looking at spike trains, which can be loaded using the function loadSpiketrains. This function accepts a single parameter, which is the .mat file containing all the spike trains for a session. This file is usually also located under the session directory, and its name follows the pattern <animal>_<date>_<session number>_Spiketrains.mat. For our current session, we load the spike trains like this:

	sptrains = loadSpiketrains('Pancake_230913_1_Spiketrains_area.mat')

	sptrains =

		DLPFC: [1x1 struct]
		FEF: [1x1 struct]
		area8: [1x1 struct]
		vDLPFC: [1x1 struct]

The spiketrains are segreated into different recording areas, in this case DLPFC, FEF, area8 and vDLPFc. Each sptrain structure contains a field 'spikechannels', which indicates which channels had at least one single unit for this session. Let's look at the spike trains for channel 40:

	sptrains.FEF.channels(8)

	ans =

		cluster: [1x1 struct]])

Now we see that the 8th FEF channel had a single unit, and we can further examine one of this unit

	sptrains.FEF.channels(8).cluster(1)

	ans =

		spiketimes: [2803698x1 double]]))

So the unit on channel 8 had 2803698 spikes, which are encoded in the field 'spiketimes' in units of milliseconds. 

In order to visualize how the activity of this unit changes over the trials, we first need to align each spike to a trial event. One good such event is the onset of the target. We can use the function 'createAlignedRaster' to do the alignment:

	>> [spikes,trial_idx] = createAlignedRaster(sptrains.channels(8).cluster(1),rtrials,'target');

As we can see, this function accepts three parameters; the spike train structure containing the spike times we wish to align, the trial structure containing the timing info required for the alignment, and an event within a trial to which to align the spikes. The function returns two variables; 'spikes' is an array containing the aligned spikes, and 'trial_idx' is trial index of each individual spike. We can now plot the aligned spike times using the function 'plotRaster':

	>> plotRaster(spikes,trial_idx,rtrials,'target')

Again, we have to supply the trial structure and the alignment event, as well as the aligned spikes with their trial labels.

![Raster example](http://bitbucket.org/rherikstad/monkeyanalysis/downloads/raster_example.png)

Each blue dot in this image is a spike.the horizontal axis represents the time at which each spike happened, relative to the start of the trial (indicated by a black vertical line at zero), and the vertical axis is the trial index of each spike. The trials are sorted according to the location of the target at each trial, such that the bottom trials correspond to target at the upper left corner of the screen, while the top trials correspond to location at the lower right corner. For this particular unit, we can see increases of spiking activity following a target for the bottom half of the screen (trials near the top). We can also see a sustained increase in activity for trial with targets near the center of the screen (middle trials). The vertical red line indicates the start of the response period, which is the cue for the monkey to make a response, indicating location of the target with an eye movement to that location. There is an increase in activity at a variable delay after the start of the response period for each trial, indicating the this cell encodes information about the onset of the eye movement.   

Instead of looking at individual spikes, we can also quantify a cell's activity in terms of its firing rate. To do that, we count the number of spikes in windows of e.g. 50 ms and look at the distribution of these counts across trials. Continuing with the same as before unit, we can get the spike counts like this:

	>> [counts,bins] = getTrialSpikeCounts(sptrains.channels(56).cluster(1),rtrials,-200:50:3000,'alignment_event','target');

As we can see, the 'getTrialSpikeCounts' function takes 3 mandatory parameters; the first is a spike train containing spike times in units of the milliseconds, the second is again a structure with trial timing information, and the third is the bins in which we want to count spikes. In this case, we want to count spikes from -200 ms before target onset to 3000 ms after target onset using 50 ms bins. We also supply an optional argument 'alignment_event', which again tells the function which event we want to align the spike counts to, i.e. 'target' in this case. The output of the function is the count matrix with dimensions number of trials X number of bins, as well the bins we used as input.

	>> size(counts)

	ans =

	   550   161

In this case, we have 550 trials and 161 bins.
Now we can plot the mean spike count for each bin, separated in the 24 different locations, with the following command

	>> plotLocationPSTH(counts,bins,'target',rtrials)

![PSTH example](http://bitbucket.org/rherikstad/monkeyanalysis/downloads/psth_example.png)

Here, we recognize the same trend as we saw above for the rasters, i.e. a marked increase in activity right after target onset (vertical red line) for locations near the bottom of the screen, particularly in the center column, 4th row.
The modulation of neural activity with target location can be quantified using the mutual information. Essentially, the mutual information between two stochastic variables tells us how much the uncertainty, quantified by the entropy, is reduced if we observe the other variable. We can compute the mutual information between spike counts and target location using the following function

	>> [H,Hc,bins] = computeInformation(counts,bins,rtrials);

As we can see, the function takes three inputs; the count matrix we computed above, the bins over which the counts were computed, and the trial structure containing info about the trial events. The output is the unconditional entropy H, the entropy conditioned on target location, Hc, and the bins. The mutual information is the difference between H and Hc. We can plot the mutual information as function of time from target onset using the following code

	>> plotLocationInformation(H-Hc, bins, 'target',rtrials)

![PSTH example](http://bitbucket.org/rherikstad/monkeyanalysis/downloads/info_example.png)

In the plot, as before, the black vertical line indicates the target onset, while the red lines indicate the distribution (median and quartiles) of the onset of the response period. For this cell, we can see a peak in information at ~80 ms after target onset. Interestingly, there is also a peak after response period onset, which is likely linked to the correct eye movement response of the monkey. Looking at the plot, though, the information trace is quite noisy. We would like to have some measure of significance of the different information peaks. To do so, we can re-compute the conditional entropy after breaking up the relationship between the spikes and the target location. We do this by shuffling the trial labels, such that e.g. spikes elicited by a target at the upper left-hand corner of the screen get re-assigned to a target at the lower-middle part of the screen. We repeat this shuffling 100 times to get a distribution of the shuffled information. Importantly, since we have disrupted the relationship between stimulus, i.e. target location, and neural response, the resulting information is completely spurious. The shuffling procedure is taken care by the same function that we used above, by suppling a fourth argument, which is simply a '1', indicating that we want to shuffle the trials,

	>> [Hs,Hcs,bins] = computeInformation(counts,bins,rtrials,1);

We can now re-plot the information, supplying the shuffled information as the 5th argument,

	>> plotLocationInformation(H-Hc, bins, 'target',rtrials,Hs-Hcs)

![PSTH example](http://bitbucket.org/rherikstad/monkeyanalysis/downloads/info_example_2.png)

The green line now indicates the mean + 3 times the standard deviation of the shuffled information, and represents a lower bound that the true information should exceed in ordered to be considered significant. We see that the information peaks after target onset are in fact above the level expected by chance, as are the peaks after response onset, which suggests that these peaks represent true information about target location.

