%% Import Frontloading Data for all RAP days %%

%% Organize the data in consumption (g/kg) per time unit %% 
% can be in second or minute bins 

%vectors holding details from the experiment
days = [1:size(RAP_all, 2)];
rats = [1:size(RAP_all, 1)];

%create minute or second time bins by making a vector of 1:60 or 1:3600 
trlTime = [0:3600];
%variable that will hold the data across all days
consumptionOverTime = {} ;

%for loop that organizes the data for front loading by calculating the amount of ethanol 
%consumed during each second time bin. 
for day = 1:numel(days);
    %variable that will hold the data for each day
    consBin = [];
    for rat = 1:numel(rats);
        %pull out the individual data for each rat on each day
        lickTms = RAP_lickTmSerMtx{day}{rat};
        %calculate the number of licks in each second time bin
        binLicks = histcounts(lickTms,trlTime);
        %divide each time bin by the total number of licks to get the
        %percentage of licks in each time bin
        percLick = binLicks./numel(lickTms);
        %multiple the lick per bin percentage by total consumption to find the amount
        %consumed during each second bin and add it to the array 
        indConsBin = percLick.*table2array(RAP_all(rat,day));
        consBin = [consBin;indConsBin];
    end;
    consumptionOverTime{day} = consBin;
end; 

%% Organize Data %% 
%determine which animals you want to look at. Probably ethanol or water consumers 
group = ratsInfo.treatment == "EtOH"; 
%call your data matrix here. Individual subjects on columns, data (not cumulative) over time in seconds on rows
%create vector of subject numbers
subjects = ratsInfo.ratID(group)';


subjectClassification = {};
changePoints = {};
firstSlope = {};
secondSlope = {};

for i = 1:numel(consumptionOverTime)
    %call your data matrix here. Individual subjects on columns, data (not cumulative) over time in seconds on rows
    data = consumptionOverTime{i}(group,:)';
    [subjectClassification{i}, changePoints{i}, firstSlope{i}, secondSlope{i}] = detectFrontloading_data(data, subjects);
end; 