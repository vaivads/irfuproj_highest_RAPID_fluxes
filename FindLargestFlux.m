function [highestIndex,magneticIndexCurrent] = FindLargestFlux(TEC, ...
    cluster,magneticTime,magneticIndexCurrent)
    %[highestIndex,magneticIndexCurrent] = FindLargestFlux(TEC, ...
    %cluster,magneticTime,magneticIndexCurrent)
    %
    %Takes a series of datapoints, walks through them and picks out the
    %largest valid datapoint.
    %
    %INPUT: Time, electron flux, cluster matrix 'TEC' with two extra
    %datapoints before and two after the considered interval, 'cluster' craft 
    %number, vector with available magnetic field points, current index in the
    %magnetic field vector.
    %
    %OUTPUT: relative index in the considered interval for the top value,
    %and the updated magnetic field index.
    
    
    length=size(TEC,1);
    mI = magneticIndexCurrent;
    highestFlux = 0;
    highestIndex = 0;

    for i=3:length-2
        if TEC(i,2) > highestFlux
            
            [valid, magneticIndexCurrent] = AL.validDataPoint(TEC(i-2:i+2,:), ...
                   cluster,magneticTime,magneticIndexCurrent);
                
            if valid 
                highestFlux = TEC(i,2);
                highestIndex = i-2;
            end
                
        end
            
    end
                             
end

