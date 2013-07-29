function [topList,newTEC] = topListToData(startTime,endTime, ...
	TEC,topList)

%[topList,newTEC] = topListToData(startTime,endTime, ...
%                                            TEC,topList)
%
%If there are elements on the toplist that lies within the given
%timeinterval, they are removed from the toplist and added at the
%correct time among the other data in the TEC-matrix.

global GLOBAL__AL

length_TEC = size(TEC,1)-2;

%Make a list of toplist elements within considered time interval
onInterval = [];

for i=1:GLOBAL__AL.nTopEventsToRecord
	if topList(i,1) >= startTime && topList(i,1) <= endTime
		onInterval = [onInterval ; topList(i,:)];
	end
end

length_on = size(onInterval,1);

%If there are toplist elements in interval, they are sorted in the
%correct time order with earliest time first
if length_on > 0
	
	
	for j=1:length_on
		for k=j:length_on
			if onInterval(k,1) <= onInterval(j,1)
				temp = onInterval(j,:);
				onInterval(j,:) = onInterval(k,:);
				onInterval(k,:) = temp;
			end
		end
	end
	
	
	%Create a new TEC-matrix and then walk throuh the old TEC matric and the
	%relevant toplist elements adding them in the correct time order.
	newTEC =  TEC(1:2,:);
	
	i_on = 1;
	i_TEC = 3;
	i_start = 3;
	
	while i_TEC < length_TEC && i_on <= length_on
		
		if  onInterval(i_on,1) > TEC(i_TEC+1,1)
			
			i_TEC = i_TEC + 1;
			
		elseif onInterval(i_on,1) >= TEC(i_TEC,1) && ...
				onInterval(i_on,1) <= TEC(i_TEC+1,1)
			
			if i_TEC >= i_start
				newTEC = [newTEC ; TEC(i_start:i_TEC,:) ...
					; onInterval(i_on,:)];
				i_start = i_TEC + 1;
				i_on = i_on + 1;
			else
				newTEC = [newTEC ; onInterval(i_on,:)];
				i_on = i_on + 1;
			end
			
		elseif i_TEC == 3 && onInterval(i_on,1) < TEC(i_TEC,1)
			
			newTEC = [newTEC ; onInterval(i_on,:)];
			i_on = i_on + 1;
		end
		
	end
	
	
	if i_TEC >= length_TEC
		newTEC = [newTEC ; TEC(i_start:length_TEC,:) ; onInterval(i_on:length_on,:)];
	else
		newTEC = [newTEC ; TEC(i_start:length_TEC,:)];
	end
	
	newTEC = [newTEC ; TEC(length_TEC+1:length_TEC+2,:)];
	
	
	%Remove the relevant toplist elements from the toplist
	for m=1:length_on
		topList = AL.removeFromTopList(topList,onInterval(m,:));
	end
	
	
	
else
	newTEC = TEC;
	
end


end

