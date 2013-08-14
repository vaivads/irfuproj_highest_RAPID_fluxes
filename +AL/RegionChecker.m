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

% no position data available > return
if isempty(R),
	return
end

% if only one position available return without defining region intervals
if size(R,1) == 1,
	return;
end

XRe = [R(:,1) R(:,2)/Re];    % used for defining regions
XRe = [XRe floor(XRe(:,2))]; % add column with region identifier

XRe((XRe(:,3) > -9),3)  = NaN; % put to NaN points that are not classified regions
XRe((XRe(:,3) < -20),3) = NaN;
indRegionStart = isnumber( XRe( [1 ~isequal(XRe(2:end,3),XRe(1:end-1,3))] ) ); 
indRegionEnd   = isnumber( XRe( [~isequal(XRe(2:end,3),XRe(1:end-1,3)) size(XRe,1)] ) ); 
timeList = [R(indRegionStart,1) R(indRegionEnd,1)];

indRegionInterp = (indRegionStart(2:end) - indRegionEnd(1:end-1)) == 1; % find times that should be interpolated

for iInterp = 1:numel(indRegionInterp)
	if timeList(iInterp+1,1) - timeList(iInterp,2) < 600, % do interpolation only if the time difference less than 10min
		tBoundary = timeList(iInterp,2) + ...
			( XRe(indRegionStart(iInterp),2) - XRe(indRegionEnd(iInterp+1),2) )...
			/ (timeList(iInterp+1,1) - timeList(iInterp,2)); 
		timeList(iInterp  ,2) = tBoundary;
		timeList(iInterp+1,1) = tBoundary;
	else
		% dont do interpolation because too large time step
	end
end
