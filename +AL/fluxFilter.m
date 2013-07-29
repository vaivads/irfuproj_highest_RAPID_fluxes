function [topList, magneticIndexCurrent] = fluxFilter(startTime,endTime, ... 
    TEC,magneticTime,magneticIndexCurrent,cluster,topList)

%   [topList, magneticIndexCurrent] = fluxFilter(startTime,endTime, ... 
%                  TEC,magneticTime,magneticIndexCurrent,cluster,topList)
%
%   Takes data for one particular relevant region, energy channel and spacecraft
%   then walks through the data points and if a higher flux than the lowest value
%   on the toplist is found, validity is checked, and if so 'topList' is updated.
%
%   Data points on the toplist has to be separated by at least 8 minutes.
%   That means that one needs to make sure that no larger data point than
%   the one under consideration lies within 8 minutes of it before it can
%   be added to the toplist. This necessitates walking forward in steps until
%   one finds the largest datapoint with no other larger one within 8 minutes
%   uptime. And then moving backward to add possible points smaller than
%   the largest one but still large enough to qualify the updated toplist.



    %Since the same time intervals are considered multiple times for
    %different Cluster spacecraft, data points on the toplist that lies in the
    %interval under consideration has to be included in the data to be
    %analysed. Here those data points are removed from the topList and
    %added to the data.
    [topList,TEC] = AL.topListToData(startTime,endTime, ...
        TEC,topList);

    interval = 480; 
    iFinal = 0;
    
    
    %Start at 3 and stop 2 before end since data contains neighboring
    %data points for validity comparison.
    electronIndexStart = 3;
    electronIndexEnd = size(TEC,1) - 2;
    
    index = electronIndexStart;
    
    
    %This loop walks through all the data points
    while index <= electronIndexEnd
        
        
        %Possible data point is found
        if TEC(index,2) > topList(1,2)
            
            %Point is checked for validity
            [validPoint,magneticIndexCurrent] = AL.validDataPoint(TEC(index-2:index+2,:),...
                cluster,magneticTime,magneticIndexCurrent);
            
            % if valid we need to look ahead if there is a larger point
            % within 8 minutes
            if validPoint    
          
               
                forward = true;
                iCurrent = index;

                while forward

                    %Look how many points lies within 8 minutes uptime
                    iNext = iCurrent;
                    while iNext <= electronIndexEnd && (TEC(iNext,1) - TEC(iCurrent,1)) < interval 
                        iNext = iNext + 1;
                    end
                    iNext = iNext - 1;
                   
                    %Check if the current point is largest or if one uptime
                    %is larger
                    [localTopIndex, magneticIndexCurrent] = AL.FindLargestFlux(TEC(iCurrent-2:iNext+2,:), ...
                        cluster,magneticTime,magneticIndexCurrent);

                    iTop = iCurrent - 1 + localTopIndex;
                    
                    %If current was largest stop moving forward, otherwise
                    %move on until no point is larger 8 minutes uptime
                    if iCurrent == iTop
                        forward = false;
                    else
                        iCurrent = iTop;
                    end


                end


                %When we have made sure that we stand on a datapoint with
                %no one larger within 8 minutes uptime, we can add that
                %point to the list. But at this point there may be smaller
                %points that we passed that still are large enough to
                %qualify for the toplist if we moved ahead more than 8
                %minutes. 

                iFinal = iNext;
                magneticIndexFinal = magneticIndexCurrent;    
                backward = true;

                while backward
                    %look how many data points downtime lies within 8
                    %minutes.
                    iPre = iCurrent;
                    while iPre >= index && (TEC(iCurrent,1) - TEC(iPre,1)) < interval 
                        iPre = iPre - 1;
                    end
                    iPre = iPre + 1;
                    
                    %Find largest point within 8 minutes
                    [localTopIndex, magneticIndexCurrent] = AL.FindLargestFlux(TEC(iPre-2:iCurrent+2,:), ...
                        cluster,magneticTime,magneticIndexCurrent);

                    iTop =iPre - 1 + localTopIndex;

                    %If it qualifies for toplist, add it to list.
                    if TEC(iTop,2) > topList(1,2)
                        topList = AL.addToTopList(TEC(iTop,:),topList);
                    end
                    
                    %Move current index 8 minutes downtime
                    iPre = iTop;
                    while iPre >= index && (TEC(iTop,1) - TEC(iPre,1)) < interval 
                        iPre = iPre - 1;
                    end
                    iPre = iPre + 1;

                    if iPre <= index
                        backward = false;
                    end

                    iCurrent = iPre - 1;

                end

                %We have now returned back to index, the first point that
                %was large enough to be added tot the list. But all point
                %up to iFinal has been ckecked properly and we skip ahead.
                index = iFinal;
                magneticIndexCurrent = magneticIndexFinal;

            end
        
        end
            
        index = index + 1;
              
    end
    
   
end


