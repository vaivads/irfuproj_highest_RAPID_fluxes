function topList = removeFromTopList(topList,element)

%topList = AL.removeFromTopList(topList,element)
%
%Takes a topList containing rows of [time (electron flux) craft] and an element
%vector of the same form and removes it from the list if that element is on
%the list.


    length = size(topList,1);
    
    onList = false;
    index = 0;
    
    for i=1:length
        if topList(i,:) == element
            onList = true;
            index = i;
        end                
    end
    
    if onList
        
        if index == 1
            topList = [0 0 0 ; topList(2:length,:)];
        elseif index == length
            topList = [0 0 0 ; topList(1:length-1,:)];
        else
            topList = [0 0 0 ; topList(1:index-1,:) ; ...
                                  topList(index+1:length,:)];  
        end
        
    end
    
end

