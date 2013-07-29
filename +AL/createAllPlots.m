function [ ] = createAllPlots(TopFluxes)

%        [ ] = createAllPlots(TopFluxes)
%
%        Takes a TopFluxes cell structure, runs over all regions, all
%        channels, and all ten events in each list, and then makes a plot of
%        each. All plots are saved in a directory 'plots' that is created 
%        in the current folder.
%



    mkdir('plots');
    
    for region=8:19
        
        for channel=3:5
            
            regionIndex = region-7;
            channelIndex = channel-2;
            
            list = TopFluxes{regionIndex,channelIndex};
            
            for listPos=1:10
                
                time = list(listPos,1);
                
                craft = list(listPos,3);    
               
                AL.makePlot(time,region,channel,craft,listPos,'./plots');
                
            end
            
        end
        
    end
    
    
    
end
            
    
    
    
    
    
    
    
    
    
    
    
    

