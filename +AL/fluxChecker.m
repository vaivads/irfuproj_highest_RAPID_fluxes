function  TopFluxes = fluxChecker(TopFluxes,cluster, TSTART, TEND)
%       topFluxes = fluxChecker(topFluxes,cluster, TSTART, TEND)
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

number_of_orbits = size(orbitList,1);

electronVariable = ['Electron_Dif_flux__C' num2str(cluster) '_CP_RAP_ESPCT6'];
magneticVariable = ['B_vec_xyz_gse__C' num2str(cluster) '_CP_FGM_5VPS'];

%For each orbit data is loaded, and the each region is considered
for current_orbit=1:number_of_orbits
	
	%Pick out the rows corresponding to the current orbit
	orbit_Start_Index = orbitList(current_orbit,1);
	orbit_End_Index = orbitList(current_orbit,2);
	
	%Pick out the entry and exit time for the current orbit (with
	%some margin)
	orbit_Start_Time = regionList(orbit_Start_Index,1)-60;
	orbit_End_Time   = regionList(  orbit_End_Index,2)+60;
	
	%Load electron flux and magnetic field data
	tint = [orbit_Start_Time orbit_End_Time];
	E_matrix = local.c_read(electronVariable,tint,'mat');
	M_matrix = local.c_read(magneticVariable,tint,'mat');
	
	%No point to look if there's no data for one or both available
	if isempty(E_matrix) == 0 && isempty(M_matrix) == 0
		
		%Some functions look at neighboring data points. Therefore
		%we add two rows before and after main data to avoid
		%errors.
		E_matrix = [0 0 0 0 0 0 0 ; 0 0 0 0 0 0 0 ; ...
			E_matrix ; 0 0 0 0 0 0 0 ; 0 0 0 0 0 0 0];
		
		E_length = size(E_matrix,1);
		
		magneticTime = M_matrix(:,1);
		
		electronIndex_Start = 1;
		magneticIndexCurrent = 1;
		
		%each region in the orbit is considered in turn
		for region_orbit=orbit_Start_Index:orbit_End_Index
			
			%find the index in the loaded data corresponding to the
			%entry time of the region
			while electronIndex_Start <= E_length-2 && E_matrix(electronIndex_Start,1) < regionList(orbit_Start_Index,1)
				electronIndex_Start = electronIndex_Start + 1;
			end
			
			electronIndex_End = electronIndex_Start;
			
			%find the index in the loaded data corresponding to the
			%exit time of the region
			while electronIndex_End <= E_length-2 && E_matrix(electronIndex_End,1) < regionList(region_orbit,2)
				electronIndex_End = electronIndex_End + 1;
			end
			electronIndex_End = electronIndex_End - 1;
			
			%exit index has to be larger than start index,
			%otherwise there probably is no data for the region and
			%we skip to the next
			if electronIndex_End >= electronIndex_Start
				
				region = regionList(region_orbit,3);
				regionIndex = abs(region) - 8;
				
				%Different data and lists for different instrument
				%channels
				for iChannel = 1:numel(GLOBAL__AL.iChannelsToRecord)
					
					channel = GLOBAL__AL.iChannelsToRecord(iChannel);
					
					startTime = regionList(region_orbit,1);
					endTime   = regionList(region_orbit,2);
					
					%Pick out the time data points and the
					%corresponding energy for the current channel
					timeValues = E_matrix(electronIndex_Start-2:electronIndex_End+2,1);
					electronValues = E_matrix(electronIndex_Start-2:electronIndex_End+2,channel+1);
					
					length = size(timeValues,1);
					
					%Add the number of the Cluster craft from which
					%the data originates
					craftValues = cluster*ones(length,1);
					
					%time,energy,craft-matrix
					TEC = [timeValues electronValues craftValues];
					
					activeList = TopFluxes{regionIndex,iChannel};
					
					[TopFluxes{regionIndex,iChannel},magneticIndexCurrent] = AL.fluxFilter(startTime,endTime,TEC,magneticTime,magneticIndexCurrent,cluster,activeList);
					
				end
				
				electronIndex_Start = electronIndex_End;
				
			end
			
		end
		
	end
	
end

end

