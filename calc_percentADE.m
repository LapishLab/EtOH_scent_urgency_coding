% Calculate the percentage 
%IAP_all = table2array(IAP_all);
%RAP_all = table2array(RAP_all);

%calculate percentage of consumption from friday to monday 
perc_ADE_IAP = [(IAP_all(:,3) ./ IAP_all(:,1)) (IAP_all(:,6) ./ IAP_all(:,4)) (IAP_all(:,9) ./ IAP_all(:, 7)) (IAP_all(:, 12) ./ IAP_all(:, 10))];

perc_ADE_RAP = [(RAP_all(:,5) ./ RAP_all(:, 1)) (RAP_all(:,10) ./ RAP_all(:, 6))];

%pull out specific group
group = ratsInfo.treatment == "EtOH"

% Filter the percentage arrays based on the specified group
transform_IAP = log10(perc_ADE_IAP(group, 4));
histogram(transform_IAP)


