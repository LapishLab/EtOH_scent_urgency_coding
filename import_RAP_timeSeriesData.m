%% Import Wistar RAP Data %%
dir_path = 'E:\052224_11425_WistarUrgency\RAP\analysisData';
days = 10;
maxFiles = 30;
wistar_RAP = anaRap(dir_path, days, maxFiles, fix_file = true, sideMtx = false);

%% Import Wistar RAP Renewal Data %%
dir_path = 'E:\052224_11425_WistarUrgency\RAP\100724_Renewal\analysisData'
days = 4
maxFiles = 30;
wistar_RAP_renewal = anaRap(dir_path, days, maxFiles, sideMtx = false);

%% Import P rat RAP Data %%
dir_path = 'E:\072125_121225_Prat_urgency\RAP\analysisData';
days = 10;
maxFiles = 24;
P_RAP = anaRap(dir_path, days, maxFiles, sideMtx = false);

%% Import P rat Renewal RAP Data %%
dir_path = 'E:\072125_121225_Prat_urgency\RAP\RAP_renewal\analysisData';
days = 4;
maxFiles = 24;
P_RAP_renewal = anaRap(dir_path, days, maxFiles, allData = false, sideMtx = false);

%% Combine Wistar Data with P Rat Data %%
ratsOut = [17 32 47 53];



%% Align all binned data
% find minimum and maximum licking time points 
mnMxLickTm = minmax(cell2mat(cellfun(@(x) cell2mat(x'), lickTmSerMtx, 'UniformOutput',false)));
% create vector starting with 0 and going to the highest time series lick
% point. Increment up by 60.  
xA = [0:60:mnMxLickTm(2)];
% i is the day by cycling through lick time series matrix
for i=1:size(lickTmSerMtx,2);
    % ask about from here on? 
    hld = lickTmSerMtx{i};
    binLick(:,i) = cellfun(@(x) cumsum(histc(x,xA)), hld, 'UniformOutput',false);
end;

%% Plot the binned data. 
for i = 1:size(binLick,2);
    subplot(1,size(binLick,2),i);
    hld = cell2mat(binLick(:,i));
    %kW = find(subNumMtx(:,i)<=16);
    %kE = find(subNumMtx(:,i)>16);
    kW = [1:16]
    kE = [17:size(binLick,1)]
%     plot(mean(hld(kW,:)),'b.-'); hold on;
%     plot(mean(hld(kE,:)),'r.-'); hold on;
    errorbar(xA,mean(hld(kW,:)),std(hld(kW,:)./sqrt(length(kW))),'bo-'); hold on;
    errorbar(xA,mean(hld(kE,:)),std(hld(kE,:)./sqrt(length(kE))),'ro-'); hold on;
%     ylabel('mean licks/60 sec')
    ylabel('Cumlative number of licks')
    xlabel('Time (min)')
    title(['Day ' num2str(i)])
    ylim([0 800])
end;