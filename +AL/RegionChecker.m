function timeList = RegionChecker(startTime,endTime,craft)

%timeList = RegionChecker(startTime,endTime,craft)
%
%Walks through position data for a given Cluster spacecraft between two given
%times, and creates a list where each row gives the time a relevant region
%is entered, the time that same region is exited, and the number
%corresponding to that region. Relevant region are -8 > x > -9, -9 > x > -10 etc.
%until -19 > x > -20, where x is the spacecraft location in GSE coordinates,
%given in Earth radii.

    %Earth radii (km)
    Re = 6371;
    
    %Initiates an empty timeList
    timeList = [];
    
    %Loads position data for time interval
    tint = [startTime endTime];
    R = local.c_read(['R' num2str(craft)],tint,'mat');
    
    if isempty(R) == 0
    
        %Number of time point with position data. If more than one point is
        %available, we can check the intervals.
        length = size(TX,1);

        if length > 1
        
            %Get initial conditions.
            tStart = TX(1,1);
            
            currentRegion = floor(TX(1,2)/Re);

            if currentRegion <= -9 && currentRegion >= -20
                currentRelevant = true;
            else
                currentRelevant = false;
            end

            
            %Walk through the data points. In each step the region number
            %for the next region is computed. If current and next region is
            %the same, we move on. If they are different we handle the
            %situation appropriately.
            for i=2:length

                nextRegion = floor(TX(i,2)/Re);
                
                if nextRegion <= -9 && nextRegion >= -20
                    nextRelevant = true;
                else
                    nextRelevant = false;
                end


                if nextRegion ~= currentRegion
                    
                    
                    if currentRelevant == true || nextRelevant == true

                        %Inside a relevant region, moving into another relevant
                        %region.
                        if currentRelevant == true && nextRelevant == true
                            
                             %Use linear interpolation to approximate time
                             %of passage between regions.
                             R1 = TX(i-1,2);
                             R2 = TX(i,2);
                             T1 = TX(i-1,1);
                             T2 = TX(i,1);

                             if R2 < R1 
                                boundaryX = floor(R1/Re)*Re;
                             else
                                boundaryX = floor(R2/Re)*Re;
                             end

                             deltaX = boundaryX - R1;
                             K = (T2-T1)/(R2-R1);
                             boundaryT = T1 + K*deltaX;
                             %Save region just passed though to timeList
                             timeList = [timeList ; tStart boundaryT currentRegion];
                             tStart = boundaryT;
                        end

                        %Inside a relevant region, moving out into
                        %irrelevant regions.
                        if  currentRelevant == true && nextRelevant == false
                            %Save region just passed though to timeList
                            timeList = [timeList ; tStart TX(i,1) currentRegion]; 
                        end

                        %Moving from irrelevant regions into a relevant
                        %region
                        if currentRelevant == false && nextRelevant == true
                            %Set start time of region being entered.
                            tStart = TX(i-1,1);
                        end

                    end

                end
                %Update at the end of each time step
                currentRelevant = nextRelevant;
                currentRegion = nextRegion;

            end

            %If the last datapoint lies inside a relevant region, that
            %regionis saved to timeList
            if currentRelevant == true
                timeList = [timeList ; tStart TX(length,1) currentRegion];
                
            end 
        
        end
            
    end
       

end
