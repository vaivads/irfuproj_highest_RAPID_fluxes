function  TopFluxes = fluxChecker(TopFluxes,cluster, TSTART, TEND)
%       topFluxes = AL.fluxChecker(topFluxes,cluster, TSTART, TEND)
%
%       Updates the 'topFluxes' structure after going through the data
%       from Cluster spacecraft number 'cluster' in the given time interval.
%
%       A timetable over the relevant regions is created, and for each
%       orbit(here a consecutive run through relevant regions) electron
%       flux and magnetic field data is loaded. Then the relevant data is
%       picked out for each region (and channel) in the orbit and sent for
%       analysis.

global GLOBAL__AL


%Create timetable over every relevant region
regionList = AL.RegionChecker(TSTART,TEND,cluster);

%Create list that describes which regions in the regionList belongs
%to each orbit
orbitList = AL.orbitChecker(regionList);

nOrbits = size(orbitList,1);

electronVariable = ['Electron_Dif_flux__C' num2str(cluster) '_CP_RAP_ESPCT6'];
magneticVariable = ['B_vec_xyz_gse__C' num2str(cluster) '_CP_FGM_5VPS'];

%For each orbit data is loaded, and the each region is considered
for iOrbit=1:nOrbits
	
	%Pick out the rows corresponding to the current orbit
	indOrbitStart = orbitList(iOrbit,1);
	indOrbitEnd   = orbitList(iOrbit,2);
	
	%Pick out the entry and exit time for the current orbit (with 1min margin)
	orbitStartTime = regionList(indOrbitStart,1)-60;
	orbitEndTime   = regionList(  indOrbitEnd,2)+60;
	
	%Load electron flux and magnetic field data
	tint = [orbitStartTime orbitEndTime];
	Ematrix = local.c_read(electronVariable,tint,'mat');
	Ematrix = clean_spp_times(Ematrix);
	Ematrix = clean_other_times(Ematrix);
	Bmatrix = local.c_read(magneticVariable,tint,'mat');
	
	%No point to look if there's no data for one or both available
	if ~isempty(Ematrix) && ~isempty(Bmatrix)
		
		%Some functions look at neighboring data points. Therefore
		%we add two rows before and after main data to avoid
		%errors.
		Ematrix = [0 0 0 0 0 0 0 ; 0 0 0 0 0 0 0 ; ...
			Ematrix ; 10e10 0 0 0 0 0 0 ; 10e0 0 0 0 0 0 0];
		
		timeB = Bmatrix(:,1);
		indB  = 1;
		
		% to speed up calculations assuming monotonically increasing time
		% and use offset where to start analyse intervals
		indE = 1;
		
		%each region in the orbit is considered in turn
		for regionOrbit = indOrbitStart:indOrbitEnd
			
			indEStart = find(Ematrix(indE:end,1) > regionList(regionOrbit,1),1)...
				+ indE - 1;
			indE = indEStart;
			if Ematrix(indE,1) > regionList(regionOrbit,2)
				continue; % the starting point does not belong to the region
			end
			indEEnd   = find(Ematrix(indE:end,1) > regionList(regionOrbit,2),1) ...
				+ indE - 1 - 1; % second -1 to take previous index
			indE = indEEnd;
			
			region = regionList(regionOrbit,3);
			regionIndex = abs(region) - 8;
			
			%Different data and lists for different instrument
			%channels
			for iChannel = 1:numel(GLOBAL__AL.iChannelsToRecord)
				
				channel = GLOBAL__AL.iChannelsToRecord(iChannel);
				
				startTime = regionList(regionOrbit,1);
				endTime   = regionList(regionOrbit,2);
				
				%Pick out the time data points and the
				%corresponding energy for the current channel
				timeValues     = Ematrix(indEStart-2:indEEnd+2,1);
				electronValues = Ematrix(indEStart-2:indEEnd+2,channel+1);
				
				length = size(timeValues,1);
				
				%Add the number of the Cluster craft from which
				%the data originates
				scId = cluster*ones(length,1);
				
				%time,energy,craft-matrix
				TEC = [timeValues electronValues scId];
				
				activeList = TopFluxes{regionIndex,iChannel};
				
				[TopFluxes{regionIndex,iChannel},indB] = AL.fluxFilter(startTime,endTime,TEC,timeB,indB,cluster,activeList);
				
			end
			
			
		end
		
	end
	
end

	function matrix = clean_spp_times(matrix)
		% remove times that are within SPP events that are known to saturate RAPID
		% instrument
		
		if isempty(matrix), return; end

		tintArray = [...
			irf_time('2001-09-24T12:00:00Z/2001-09-29T03:20:00Z','iso2tint');...
			];
		
		for it = 1:size(tintArray,1)
			tint=tintArray(it,:);
			if matrix(end,1) < tint(1) || matrix(1,1) > tint(2),
				% SPP outside matrix interval, do nothing.
			else
				% remove SPP points
				[~,ind] = irf_tlim(matrix(:,1),tint);
				matrix(ind,:) = [];
			end
		end
	end
	function matrix = clean_other_times(matrix)
		% remove times that are within SPP events that are known to saturate RAPID
		% instrument

		if isempty(matrix), return; end
		
		tintArray = [...
			irf_time('2001-11-06T01:59:00Z/22001-11-06T07:00:00Z','iso2tint');...
			];
		
		for it = 1:size(tintArray,1)
			tint=tintArray(it,:);
			if matrix(end,1) < tint(1) || matrix(1,1) > tint(2),
				% tint outside matrix interval, do nothing.
			else
				% remove bad points
				[~,ind] = irf_tlim(matrix(:,1),tint);
				matrix(ind,:) = [];
			end
		end
	end

end

