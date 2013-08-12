function [] = makePlot(time,region,channel,craft,flux,listPosition,directory)

% AL.makePlot(time,region,channel,craft,flux,listPosition,directory)
%
% Makes a plot with 10 minutes around 'time' using data from Cluster
% number 'craft'. Plot is saved in 'directory'. 'region', 'channel',
% 'listPosition' are numbers that are included in the filename.



% specify time interval
tint= time + [-600 600];

% create filename
timeStr    = irf_time(time,'yyyymmddhhmmss');
regionStr  = ['Reg' num2str(region)];
channelStr = ['_Ch' num2str(channel)];
listPosStr = ['_Top' num2str(listPosition,'%02d')];
craftStr   = ['C' num2str(craft)];

filename = [regionStr channelStr listPosStr '_' craftStr '_' timeStr];


% initialize figure
h=irf_plot(6,'newfigure'); % 5 subplots

idC = ['C' num2str(craft)]; % C1,C2.. depending on craft
% new panel
hca=irf_panel('FGM B GSM');
% read data
varName = ['B_vec_xyz_gse__' idC '_CP_FGM_5VPS'];
B=local.c_read(varName,tint,'mat');
gsmB=irf_gse2gsm(B);
% plot
irf_plot(hca,gsmB);
ylabel(hca,'B [nT] GSM');
irf_legend(hca,{'B_X','B_Y','B_Z'},[0.98 0.05])
title(hca,[craftStr ' ' irf_time(time,'yyyymmdd')])
irf_legend(0,{['Top ' num2str(listPosition) ', flux= ' num2str(flux,'%7.2f')]},[0,1],'fontsize',11);

% new panel
hca=irf_panel('CIS V');
% read data
varName = ['velocity__' idC '_CP_CIS-CODIF_HS_H1_MOMENTS'];
varLabel = {'V CODIF-H','[km/s] GSM'};
V=local.c_read(varName,tint,'mat');
if isempty(V),
	varName = ['velocity_gse__' idC '_CP_CIS_HIA_ONBOARD_MOMENTS'];
	varLabel = {'V HIA','[km/s] GSM'};
	V=local.c_read(varName,tint,'mat');
end
gsmV=irf_gse2gsm(V);
% plot
irf_plot(hca,gsmV)
ylabel(hca,varLabel);
irf_zoom(hca,'y',[-300 500])
irf_legend(hca,{'V_X','V_Y','V_Z'},[0.2 0.95])


% new panel
hca=irf_panel('CIS spectrogram');
try
	% read data
	ionFluxVariableName = ['flux__C' num2str(craft) '_CP_CIS_CODIF_H1_1D_PEF'];
	ionFluxDataobj      = irf_get_data(tint,ionFluxVariableName,'caa','dobj');
	colorbarLabel       = {'log_{10} dEF H^+','keV/cm^2 s sr keV'};
	if ionFluxDataobj.Variables{1,3}==0 % no CODIF data, try HIA
		ionFluxVariableName = ['flux__C' num2str(craft) '_CP_CIS_HIA_HS_1D_PEF'];
		ionFluxDataobj      = irf_get_data(tint,ionFluxVariableName,'caa','dobj');
		colorbarLabel       = {'log_{10} dEF ions','keV/cm^2 s sr keV'};
	end
	% plot
	plot(hca,ionFluxDataobj,ionFluxVariableName,...
		'colorbarlabel',colorbarLabel,'fitcolorbarlabel');
	caxis(hca,[3.9 6.1]);
	set(hca,'yscale','log')
	set(hca,'ytick',[1 1e1 1e2 1e3 1e4 1e5])
	ylabel(hca,'E [eV]')
	irf_colormap('default');
catch
end


% new panel
try
	hca=irf_panel('RAPID spectrogram');
	% read data
	electronFluxVariableName = ['Electron_Dif_flux__C' num2str(craft) '_CP_RAP_ESPCT6'];
	electronFluxDataobj = irf_get_data(tint, electronFluxVariableName,'caa','dobj');
	% plot
	plot(hca,electronFluxDataobj,electronFluxVariableName,'colorbarlabel',{'log10 dF','1/cm^2 s sr keV'},'fitcolorbarlabel');
	caxis(hca,[0.51 4.49]);
	ylabel(hca,'E [keV]');
	set(hca,'yscale','log');
	set(hca,'ytick',[5e1 1e2 2e2 5e2 1e3]);
catch
end


% new panel
hca=irf_panel('PEACE spectrogram');
try
	% read data
	pitchSpinVariableName = ['Data__C' num2str(craft) '_CP_PEA_PITCH_SPIN_DPFlux'];
	pitchSpinDataobj = irf_get_data(tint,pitchSpinVariableName,'caa','dobj');
	% plot
	plot(hca,pitchSpinDataobj,pitchSpinVariableName,'sum_dim1','colorbarlabel',{'log10 dPF','#/cm^2 s sr keV'},'fitcolorbarlabel');
	caxis(hca,[5.9 7.6]);
	set(hca,'yscale','log','ylim',[100 3e4]);
	set(hca,'ytick',[1 1e1 1e2 1e3 1e4 1e5]);
	ylabel('E [eV]');
catch
end


% changes to all figure
delete(h(6));h(6)=[];
irf_plot_axis_align
irf_zoom(h,'x',tint);
irf_pl_number_subplots(h);
% get satellite position
R=irf_get_data(tint,'sc_r_xyz_gse__CL_SP_AUX','caa','mat');
dR_Variable = ['sc_dr' num2str(craft) '_xyz_gse__CL_SP_AUX'];
dR=irf_get_data(tint,dR_Variable,'caa','mat');
R=irf_add(1,R,1,dR);
R1RE=irf_gse2gsm(irf_tappl(R,'/6372')); % RE=6372 km
xx=get(gcf,'userdata');tst=xx.t_start_epoch;
xlab={'X (RE)','Y (RE)','Z (RE)'};
irf_timeaxis(h(5),tst,R1RE,xlab);
irf_timeaxis(h(5),'nodate');
irf_legend(h(1),filename,[1.0 1.001],'fontsize',8,'color',[0.5 0.5 0.5]);


% add line marks
irf_pl_mark(h,time,'black','LineWidth',0.1);


% save plot to file
print(gcf, '-dpng', [directory filesep filename]);
close all;

end
