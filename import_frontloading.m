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

%% Import frontloading data %%
% includes first slope, second slope, change point, and subject
% classification per day

%experiment days to look at 
days = [1 3 5 6 8 10 11 13];

%subject number vector thats needed to feed into the code 
subjects = ratsInfo.ratID';

%initialize variables
classifications = {};
change_points = [];
first_slopes = [];
second_slopes = [];

%find frontloading classification information for each day 
for i = 1:numel(days)
    Dataset = consumptionOverTime{days(i)};
    [clasify, chPts, fSlp, sSlp] = detectFrontloading_data(Dataset', subjects);
    classifications{i} = clasify;
    change_points(:, i) = chPts;
    first_slopes(:,i) = fSlp;
    second_slopes(:,i) = sSlp;
end 

%% Check how the data looks %%

% correlation between first slope and change point
% longer change points should have less first slopes 

change_point_vector = [change_points(:,1);change_points(:,2);change_points(:,3);change_points(:,4);change_points(:,5);change_points(:,6)];
first_slope_vector = [first_slopes(:,1);first_slopes(:,2);first_slopes(:,3);first_slopes(:,4);first_slopes(:,5);first_slopes(:,6)];

plot(change_point_vector, first_slope_vector, 'x')