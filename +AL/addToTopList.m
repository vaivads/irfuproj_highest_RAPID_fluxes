function topList = addToTopList(newElement,topList)
%        topList = addToTopList(newElement,topList)
%
%        Takes a sorted list of fixed length and a new element and checks
%        if the element is larger than the samllest element on the list.
%        If it is, then it is placed at the appropriate place on the list.
%
%
%INPUT:  A new element in a vector of the form [time (electron flux) craft],
%        where time is the time of the event given in epoch, electron flux is
%        the amount of electron flux, craft is which Cluster spacecraft the
%        data point is from. A topList containing a matric with rows of the same
%        structure as the element vector. List is ordered according
%        to the second column, with the smallest value in the first row.
%
%
%OUTPUT: An updated version of the input topList. If the new element was
%        added, the smallest element is dropped from the list.

closestTimeInterval = 8*60; % two points cannot be closer than 8 min

topListLength = size(topList,1);

indClose = find(abs(topList(:,1)-newElement(1)) < closestTimeInterval);
if indClose % there is topList element withiin closest time interval allowed
	if numel(indClose) == 2, % new element inbetween two elements
		if newElement(2) > topList(indClose(1),2) && ...
				newElement(2) > topList(indClose(2),2) % replace 2 events with one
			topList(indClose,:)=[]; % remove 2 events, will be replaced by new one
		end
	elseif numel(indClose) == 1,
		if newElement(2) > topList(indClose,2) % if higher flux replace with the new one
			topList(indClose,:)=[]; % remove old element, will be replaced by new one in the next loop
		end
	end
	
	% sort top list to move zeros to end
	[~,ind] = sort(topList(:,2),1,'descend');
	topList = topList(ind,:);
	
end


doTopList = true;
iTop     = 1;
while doTopList
	if newElement(2) > topList(iTop)
		doTopList = false;
		topList = [topList(1:iTop-1,:);...
			newElement;...
			topList(iTop:topListLength-1,:)];
	else
		iTop=iTop+1;
	end
	if iTop > topListLength
		doTopList = false;
	end
end



