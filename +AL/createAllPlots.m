function [ ] = createAllPlots(TopFluxes)

%        [ ] = createAllPlots(TopFluxes)
%
%        Takes a TopFluxes cell structure, runs over all regions, all
%        channels, and all ten events in each list, and then makes a plot of
%        each. All plots are saved in a directory 'plots' that is created
%        in the current folder.
%

global GLOBAL__AL

mkdir('plots');

for region=8:19
	
	for iChannel = 1:numel(GLOBAL__AL.iChannelsToRecord)
		
		channel = GLOBAL__AL.iChannelsToRecord(iChannel);
		
		iRegion = region-7;
		
		list = TopFluxes{iRegion,iChannel};
		
		for listPos=1:size(list,1)
			
			time  = list(listPos,1);			
			craft = list(listPos,3);
			
			AL.makePlot(time,region,channel,craft,listPos,'./plots');
			
		end
		
	end
	
end














