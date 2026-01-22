function consumptionOverTime = calc_cumulativeConsumption(RAP_all, RAP_lickTmSerMtx, RAP_totalLicks, opts)
%% Calculate Cumulative Consumption %% 
% calculates cumulative consumption in licks or g/kg across seconds or
% minutes
%variables needed: RAP_all, RAP_lickTmSerMtx, RAP_totalLicks

arguments 
    RAP_all %table with total consumption across all days 
    RAP_lickTmSerMtx %licks across time
    RAP_totalLicks %table with total licks across all days 
    opts.cumulative_type {mustBeText} = "" %used to determine cumulative licks or g/kg over time, use licks or g/kg
end 

%% Organize the data in consumption (g/kg) per time unit %% 
% can be in second or minute bins 
% used to find and calculate the RAP data
% variables needed: RAP_all, 

if contains(opts.cumulative_type, "g/kg")
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
            %consumed during each second bin and add it to the array. Then
            %find the cumulative sum of the data
            indConsBin = cumsum(percLick.*table2array(RAP_all(rat,day)));
            consBin = [consBin;indConsBin];
        end;
        consumptionOverTime{day} = consBin;
    end; 
elseif contains(opts.cumulative_type, "licks")

    %% Organize the data in licks per time unit %% 
    binLick = []
    % find minimum and maximum licking time points 
    mnMxLickTm = minmax(cell2mat(cellfun(@(x) cell2mat(x'), RAP_lickTmSerMtx, 'UniformOutput',false)));
    % create vector starting with 0 and going to the highest time series lick
    % point. Increment up by 60 for minutes or by 1 for seconds.  
    xA = [0:1:mnMxLickTm(2)];
    % i is the day by cycling through lick time series matrix. Cumulative licks
    % across the time series will be calculated for each rat on each day 
    for i=1:size(RAP_lickTmSerMtx,2)
        hld = RAP_lickTmSerMtx{i};
        binLick = [binLick;cell2mat(cellfun(@(x) cumsum(histcounts(x,xA)), hld, 'UniformOutput',false))];
        consumptionOverTime{i} = binLick
        binLick = []
    end
end 