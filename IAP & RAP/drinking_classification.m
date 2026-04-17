% variables needed: RAP_all, IAP_all, ratsInfo

%wistar high and medium drinking cutoffs
IAP_high = 3.5;
RAP_high = 0.8;
IAP_medium = 1;
RAP_medium = 0.4;

%add new column to rats info column for drinking classification
ratsInfo.drinkClass = strings(size(ratsInfo, 1), 1);

%take the mean of the last week of IAP and RAP
IAP_mn = mean(table2array(IAP_all(:, [end-2:end])), 2, 'omitnan');
RAP_mn = mean(table2array(RAP_all(:, [6 8 10])), 2, 'omitnan');

%assign drinking classifications to the rats 
high_rats = (IAP_mn > IAP_high | RAP_mn > RAP_high) & ratsInfo.strain == "Wistar" & ratsInfo.treatment == "EtOH";
medium_rats = ((IAP_mn > IAP_medium & IAP_mn < IAP_high) | (RAP_mn > RAP_medium & RAP_mn < RAP_high)) & ratsInfo.strain == "Wistar" & ratsInfo.treatment == "EtOH" & ~high_rats;
low_rats = ratsInfo.strain == "Wistar" & ratsInfo.treatment == "EtOH" & ~high_rats & ~medium_rats;

%add the drink class to the ratsInfo table
ratsInfo.drinkClass(high_rats) = "High";
ratsInfo.drinkClass(medium_rats) = "Medium";
ratsInfo.drinkClass(low_rats) = "Low";



