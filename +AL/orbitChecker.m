function  orbitList = orbitChecker( timeList )

%orbitList = orbitChecker( timeList )
%
%The Cluster spacecrafts complete one Earth orbit in about 57 hours. At some
%time a craft will enter the first relevant region, move through a number
%of regions, and then exit into irrelevant regions. Here we will consider a
%orbit to start when the first relevant region is entered and end when
%exiting into irrelevant regions. This function makes a list where each row
%contains two indices corresponding to the row numbers of the rows in a
%timeList where an orbit starts and ends.
%
% OUTPUT:


length   = size(timeList,1);

if length == 0
	orbitList = [];
else
	indOrbit = find(diff( timeList(2:end,1)-timeList(1:end-1,2) ));
	orbitList = [indOrbit [indOrbit(2:end)-1;length]];
end
