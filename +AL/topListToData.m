function [topList,newTEC] = topListToData(startTime,endTime, ...
	TEC,topList)

%[topList,newTEC] = topListToData(startTime,endTime, ...
%                                            TEC,topList)
%
%If there are elements on the toplist that lies within the given
%timeinterval, they are removed from the toplist and added at the
%correct time among the other data in the TEC-matrix.

length_TEC = size(TEC,1)-2;

%Make a list of toplist elements within considered time interval
[~,indOk] = irf_tlim(topList,startTime,endTime);

nTopListOk = numel(indOk);

%If there are toplist elements in interval, they are sorted in the
%correct time order with earliest time first
if nTopListOk > 0
	
	[~,inSort]=sort(topList(indOk,1));
	indOkSorted = indOk(inSort);
	
	
	%Create a new TEC-matrix and then walk through the old TEC matric and the
	%relevant toplist elements adding them in the correct time order.
	newTEC =  TEC(1:2,:);
	
	i_on = 1;
	i_TEC = 3;
	i_start = 3;
	
	while i_TEC < length_TEC && i_on <= nTopListOk
		
		if  topList(indOkSorted(i_on),1) > TEC(i_TEC+1,1)
			
			i_TEC = i_TEC + 1;
			
		elseif topList(indOkSorted(i_on),1) >= TEC(i_TEC,1) && ...
				topList(indOkSorted(i_on),1) <= TEC(i_TEC+1,1)
			
			if i_TEC >= i_start
				newTEC = [newTEC ; TEC(i_start:i_TEC,:) ...
					; topList(indOkSorted(i_on),:)];
				i_start = i_TEC + 1;
				i_on = i_on + 1;
			else
				newTEC = [newTEC ; topList(indOkSorted(i_on),:)];
				i_on = i_on + 1;
			end
			
		elseif i_TEC == 3 && topList(indOkSorted(i_on),1) < TEC(i_TEC,1)
			
			newTEC = [newTEC ; topList(indOkSorted(i_on),:)];
			i_on = i_on + 1;
		end
		
	end
	
	
	if i_TEC >= length_TEC
		newTEC = [newTEC ; TEC(i_start:length_TEC,:) ; topList(indOkSorted(i_on:nTopListOk),:)];
	else
		newTEC = [newTEC ; TEC(i_start:length_TEC,:)];
	end
	
	newTEC = [newTEC ; TEC(length_TEC+1:length_TEC+2,:)];
	
	
	%Remove the relevant toplist elements from the toplist
	topList(indOk) = [];
	
	
else
	newTEC = TEC;
	
end


end

