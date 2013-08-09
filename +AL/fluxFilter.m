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

[topList,TEC] = AL.topListToData(topList,TEC,startTime,endTime);

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
	if TEC(index,2) > topList(end,2)
		
		%Point is checked for validity
		[validPoint,magneticIndexCurrent] = AL.validDataPoint(TEC(index-2:index+2,:),...
			cluster,magneticTime,magneticIndexCurrent);
		
		% if valid add to the toplist
		if validPoint
			topList = AL.addToTopList(TEC(index,:),topList);			
		end
		
	end
	
	index = index + 1;
	
end
