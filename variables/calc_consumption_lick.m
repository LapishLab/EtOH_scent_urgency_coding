function group_cons_lick = calc_consumption_lick(RAP_all, RAP_totalLicks, opts)
%% Calculate consumption per lick 
%variables needed: RAP_all, RAP_totalLicks

arguments 
    RAP_all %table that contains the total consumption for each rat each day 
    RAP_totalLicks %matrix with total licks for each rat on each day
    opts.days {mustBeVector} = [] %must be a x by 1 vector with the days you want to pull data from 
    opts.group (:,1) logical = [] %logical state of which rows/rats you want to analyze 
end 

%calculate consumption per lick for all data
cons_lick = table2array(RAP_all) ./ RAP_totalLicks;

%convert any infinity values to NaNs 
%some values were divide by zero because lick measurer was faulty 
cons_lick(isinf(cons_lick)) = 0;

%initialize variables
group_cons_lick = []

if isempty(opts.days) && isempty(opts.group)
    days = [1:14];
    group_cons_lick = mean(cons_lick, 2, 'omitnan');
elseif isempty(opts.group)
    group_cons_lick = mean(cons_lick(:, opts.days), 2, 'omitnan');
else 
    group_cons_lick = mean(cons_lick(opts.group, opts.days), 2, 'omitnan');
end 