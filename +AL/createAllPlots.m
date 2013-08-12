function [ ] = createAllPlots(TopFluxes)

%        [ ] = AL.createAllPlots(TopFluxes)
%
%        Takes a TopFluxes cell structure, runs over all regions, all
%        channels, and all ten events in each list, and then makes a plot of
%        each. All plots are saved in a directory 'plots' that is created
%        in the current folder.
%

global GLOBAL__AL

if ~exist('plots','dir'), mkdir('plots'); end

for iRegion=1:numel(TopFluxes)
	
	for iChannel = 1:numel(GLOBAL__AL.iChannelsToRecord)
		
		channel = GLOBAL__AL.iChannelsToRecord(iChannel);
		
		list = TopFluxes{iRegion,iChannel};
		
		for listPos=1:size(list,1)
			
			time   = list(listPos,1);
			flux   = list(listPos,2);
			craft  = list(listPos,3);
			region = iRegion + 7;
			
			AL.makePlot(time,region,channel,craft,flux,listPos,'./plots');
			
		end
		
	end
	
end














