function [] = makePlot(time,region,channel,craft,listPosition,directory)

    %[] = makePlot(time,region,channel,craft,listPosition,directory)
    %
    %Makes a plot with 10 minutes around 'time' using data from Cluster
    %number 'craft'. Plot is saved in 'directory'. 'region', 'channel',
    %'listPosition' are numbers that are included in the filename.
   

    
    % specify time interval
    tStart = time - 600;
    tEnd = time + 600;
    tint=[tStart tEnd]; 
    
    
    % create filename
    tV = irf_time(time,'epoch2vector');
    
    if tV(2) < 10
        monthZero = '0';
    else
        monthZero = '';
    end
    
    if tV(3) < 10
        dayZero = '0';
    else
        dayZero = '';
    end
    
    if tV(4) < 10
        hourZero = '0';
    else
        hourZero = '';
    end
    
    if tV(5) < 10
        minZero = '0';
    else
        minZero = '';
    end
    
    if tV(6) < 10
        secZero = '0';
    else
        secZero = '';
    end
    
    timeStr = ['Date' num2str(tV(1))  monthZero num2str(tV(2)) ...
        dayZero num2str(tV(3)) 'Time' hourZero num2str(tV(4)) ...
        minZero num2str(tV(5)) secZero num2str(floor(tV(6)))]; 
    
    regionStr = ['Reg' num2str(region)];
    channelStr = ['Ch' num2str(channel)];
    listPosStr = ['L' num2str(listPosition)];
    craftStr = ['C' num2str(craft)];
    
    filename = [regionStr channelStr listPosStr craftStr timeStr];
    
    
    % initialize figure
    h=irf_plot(6,'newfigure'); % 5 subplots
    
    
    % new panel
    hca=irf_panel('FGM B GSM');
    try
    % read data
    BdataVariable = ['B_vec_xyz_gse__C' num2str(craft) '_CP_FGM_5VPS'];
    B=local.c_read(BdataVariable,tint,'mat');   
    gsmB=irf_gse2gsm(B);
    % plot
    irf_plot(hca,gsmB);
    ylabel(hca,'B [nT] GSM');
    irf_legend(hca,{'B_X','B_Y','B_Z'},[0.98 0.05])
    title(hca,[craftStr ' ' irf_time(time,'yyyymmdd')])
    catch
    end

  
    % new panel
    hca=irf_panel('CIS V');
    try
    % read data
    VdataVariable = ['velocity_gse__C' num2str(craft) '_CP_CIS_HIA_ONBOARD_MOMENTS'];    
    V=local.c_read(VdataVariable,tint,'mat');
    gsmV=irf_gse2gsm(V);
    % plot
    irf_plot(hca,gsmV)
    ylabel(hca,'V [km/s] GSM');
    irf_zoom(hca,'y',[-300 500])
    irf_legend(hca,{'V_X','V_Y','V_Z'},[0.2 0.95])
    catch
    end
    
    
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
    Units = irf_units % to get RE value
    R1RE=irf_gse2gsm(irf_tappl(R,'/Units.RE*Units.km')); 
    xx=get(gcf,'userdata');tst=xx.t_start_epoch;
    xlab={'X (RE)','Y (RE)','Z (RE)'};
    irf_timeaxis(h(5),tst,R1RE,xlab);
    irf_timeaxis(h(5),'nodate');
    irf_legend(h(1),filename,[1.0 1.001],'fontsize',8,'color',[0.5 0.5 0.5]);
    
    
    % add line marks
    tmarks=time;
    irf_pl_mark(h,tmarks,'black','LineWidth',0.1);
    

    % save plot to file
   
    cd(directory);
    print(gcf, '-dpng', filename);
    cd ..
    close all;
    

end
