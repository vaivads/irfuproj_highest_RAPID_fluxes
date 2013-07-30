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



topListLength = size(topList,1);

doTopList = true;
iTop     = 1;

while doTopList
	if newElement(2) > topList(iTop)
		doTopList = false;
		topList = [topList(1:iTop-1);...
			newElement(2);...
			topList(iTop:topListLength-1)];
	else
		pos=pos+1;
	end
	if pos > topListLength
		doTopList = false;
	end
end



