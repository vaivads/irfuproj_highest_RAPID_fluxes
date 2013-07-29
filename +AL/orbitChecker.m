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


    length = size(timeList,1);
    
    if length == 0
        orbitList = [];
    elseif length == 1
        orbitList = [1 1];
    else
        orbitList = [];
        startIndex = 1;
        for i=2:length
            if timeList(i,1) ~= timeList(i-1,2)
                orbitList = [orbitList ; startIndex (i-1)];
                startIndex = i;
            end
        end
        orbitList = [orbitList ; startIndex length];
    end

end

