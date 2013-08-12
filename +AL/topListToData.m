function [newTopList,newTEC] = topListToData(topList,TEC,startTime,endTime)

%[newTopList,newTEC] = topListToData(topList,TEC,startTime,endTime)
%
% Elements in toplist that are within time interval specified by startTime
% and endTime (epoch-times) are removed from the toplist and added to TEC
% matrix. TEC matrix is sorted. Removed elements from toplist are put to
% zero.
%
% Input: 
%	topList   - nx3 matrix
%	TEC       - mx3 matrix (time,flux,Cluster ID)
%   startTime - epoch time
%   endTime   - epoch time
%
% Output:
%   newTopList - nx3 matrix
%   newTEC     - (m+a)x3 matrix, where a are the number of topList elements
%	             within the time interval.

%Make a list of toplist elements within considered time interval
[~,indOk] = irf_tlim(topList,startTime,endTime);

nTopListOk = numel(indOk);

%If there are toplist elements in interval, they are sorted in the
%correct time order with earliest time first
if nTopListOk > 0
	
	[~,inSort]=sort(topList(indOk,1));
	indOkSorted = indOk(inSort);
	
	
	%Create a new TEC-matrix adding relevant toplist elements 
	newTEC = [TEC;topList(indOkSorted,:)];
	[~,inTECSort]=sort(TEC(:,1));
	newTEC = newTEC(inTECSort,:);
		
	%Remove the relevant toplist elements from the toplist
	newTopList          = topList;
	newTopList(indOk,:) = [];
	newTopList(end+numel(indOk),3) = 0; % substitute zeros instead of removed points
	
else
	newTEC     = TEC;
	newTopList = topList;
	
end
