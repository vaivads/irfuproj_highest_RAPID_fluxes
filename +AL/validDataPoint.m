function [valid,magneticIndexCurrent] = validDataPoint(TEC,cluster, ...
    magneticTime,magneticIndexCurrent)

    %[valid,magneticIndexCurrent] = validDataPoint(TEC,cluster, ...
    %                                magneticTime,magneticIndexCurrent)
    %
    %
    %Takes five data points in a TEC matrix [time, (electron flux), craft], 
    %the Cluster space'craft' under consideration, vector with available 
    %magnetic field time points, and the current index in that same vector.
    %
    %The middle point of the five datapoints is the one whos validity is
    %to be checked. We don't want any of the surounding points to be NaN,
    %and the closest points shouldn't lie more than 13 seconds away from
    %the data point. This filter out activation and deactivation energy
    %spikes. If this is satisfied we then check if there is at least one
    %magnetic field data point within 0.2 seconds of the datapoint, and if
    %it is, we have a valid data point.
    %
    %OUTPUT: 'valid' is a true/false value. An updated
    %'magneticIndexCurrent'.
    
    
    
    %If datapoint comes from a different craft, then it has already been
    %checked for validity.
    if TEC(3,3) == cluster
        valid = true;
    else
        
        %Check surounding datapoints.
        if (isnan(TEC(1,2))==0 && isnan(TEC(2,2))==0 ...
            && isnan(TEC(4,2))==0 && isnan(TEC(5,2))==0) || ...
            TEC(3,1)-TEC(2,1) < 13 || TEC(4,1)-TEC(3,1) < 13
       
            
            time = TEC(3,1);
            mI = magneticIndexCurrent;
            valid = false;
            magneticLength = size(magneticTime,1);

            %Check if there is a magnetic field datapoint for current mI
            %index
            if abs(time-magneticTime(mI)) <= 0.2
                valid = true;
            else
                
               %Possible magnetic data is at higher or lower mI index.  
               cont = true;
               
               if magneticTime(mI) <= time
                   
                   while cont && mI < magneticLength 
                      mI = mI + 1;
                      if magneticTime(mI) > time
                          cont = false;
                      end
                   end
                   if abs(time-magneticTime(mI)) <= 0.2 || ...
                         abs(time-magneticTime(mI-1)) <= 0.2
                         valid = true;
                         cont = false;
                   end
                 
               elseif magneticTime(mI) >= time
                   
                  while cont && mI > 1
                      mI = mI - 1;
                      if magneticTime(mI) <= time
                          cont = false;
                      end
                  end
                  if abs(time-magneticTime(mI)) <= 0.2 || ...
                        abs(time-magneticTime(mI+1)) <= 0.2
                        valid = true;
                        cont = false;
                  end
                  
               end
               
            end
            
            magneticIndexCurrent = mI;
                 
        else
           %Failed check of surounding electron energy datapoints.
           valid = false;
           
       end
                         
    end
            
end






            
            