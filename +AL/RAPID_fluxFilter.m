function TopFluxes = RAPID_fluxFilter()
%  TopFluxes = AL.RAPID_fluxFilter()
%
%  NOTE! As written this has to be run on a computer with access to
%  Cluster data on local disk.
%
%  This function will go through Cluster spacecraft data from the years
%  2001-2011. The RAPID instruments collect data on the flux of 
%  incoming electrons. This function produces toplists of the ten highest
%  electron fluxes in the RAPID data from all Cluster spacecraft, with 
%  separate lists for different regions and energy channels.
%
%
%OUTPUT: Cell structure containg flux toplists with ten elements, with
%        separate lists for data originating in channels 3,4, and 5, and
%        for all 12 regions between -8 > x > -9 Earth radii and -19 > x > -20 
%        Earth radii where x is the GSE coordinate.

global GLOBAL__AL

%Defaults that cannot be override by global 
nRegions           = 12; % number of region divisions
startDateOfYears   = [ 6  1 0 0 0]; % [month date hour minute second]
endDateOfYears     = [12 31 0 0 0]; % [month date hour minute second]

%Defaults that are override by GLOBAL__AL.(varName) if given
default_global('nTopEventsToRecord',10);
default_global('iChannelsToRecord',[3 4 5]);
default_global('listCluster',1:4);
default_global('listYears',2001:2011);

nChannels = numel(GLOBAL__AL.iChannelsToRecord);


%Creates a cell structure with lists to keep data in.
    TopFluxes      = cell(nRegions,nChannels);
	[TopFluxes{:}] = deal(zeros(nTopEventsToRecord,3)); % 3 is [time (electron flux) spacecraft]

%Does one year and craft at a time. Note that Cluster doesn't occupy any 
%region of interest the first halv of each year.     
    for year=listYears 
        for cluster = listCluster

            TSTART = irf_time([year startDateOfYears]);
            TEND   = irf_time([year endDateOfYears]);

            TopFluxes = AL.fluxChecker(TopFluxes,cluster,TSTART,TEND);

         end

    end

end

function default_global(varName,defaultValue)
global GLOBAL__AL
if ~isfield(GLOBAL__AL,varName)
	GLOBAL__AL.(varName) = defaultValue;
end
assignin('caller',varName,GLOBAL__AL.(varName));

end
