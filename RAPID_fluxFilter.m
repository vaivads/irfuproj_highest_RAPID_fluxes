function TopFluxes = RAPID_fluxFilter()
%    TopFluxes = RAPID_fluxFilter()
%
%    NOTE! As written this has to be run on a computer with access to
%    Cluster data on local disk.
%
%    This function will go through Cluster spacecraft data from the years
%    2001-2011. The RAPID instruments collect data on the flux of 
%    incoming electrons. This function produces toplists of the ten highest
%    electron fluxes in the RAPID data from all Cluster spacecraft, with 
%    separate lists for different regions and energy channels.
%
%
%OUTPUT: Cell structure containg flux toplists with ten elements, with
%        separate lists for data originating in channels 3,4, and 5, and
%        for all 12 regions between -8 > x > -9 Earth radii and -19 > x > -20 
%        Earth radii where x is the GSE coordinate.



%Creates a cell structure with lists to keep data in.
    list = zeros(10,3);
    TopFluxes = cell(12,3);
    for i=1:12
        for j=1:3
            TopFluxes{i,j} = list;
        end
    end


%Does one year and craft at a time. Note that Cluster doesn't occupy any 
%region of interest the first halv of each year.     
    for year=2001:2011 
        for cluster = 1:4

            TSTART = irf_time([year 06 01 00 00 00]);
            TEND = irf_time([year 12 31 00 00 00]);

            TopFluxes = AL.fluxChecker(TopFluxes,cluster,TSTART,TEND);

         end

    end

end

