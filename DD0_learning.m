%% Reaching DD0 Learning Criteria %%

%% Calculate Data %%
% determine at what trial and what learning criteria is reached for each
% rat
% learning criteria: 10 trials in a row where mean iValue is above 5.0
% inputs needed: allDDiVals

% label and import data
data = p_allDDiVals;

% criteria level
ival_criteria = 5.0; 
binSize = 10;

% new variables to hold the data
% the starting trial number of the 10 trial bin in which the highest iValue
% mean was reached
trialStart = [];
% the highest iValue mean 
high_iVal = []; 

% moving bin that takes the mean iValue for each rat acorss 10 trials 
% adds the highest value to the rat for each day as well as the starting
% trial for that highest mean 
for day = 1:numel(data)
    for rat = 1:size(data{day},1)
        ratData = data{day}(rat, :);
        binNumbers = numel(ratData) - binSize + 1;
        for bin = 1:binNumbers
            iVals_mean(bin) = mean(ratData(bin:(bin+binSize-1)))
        end 
        meets_criteria = find(iVals_mean > ival_criteria);
        if ~isempty(meets_criteria)
            high_iVal(rat, day) = iVals_mean(meets_criteria(1));
            trialStart(rat, day) = meets_criteria(1);
        else
            [high_iVal(rat,day) trialStart(rat, day)] = max(iVals_mean);
        end 
    end
end 

%% Assess Overall Learning %%
% check if any animal never reached the ivalue mean learning criteria

%vector to hold the classification of learners and non-learners  
learning = [];

for i = 1:size(high_iVal,1)
    learning(i) = any(high_iVal(i,:) > ival_criteria);  
end

%% Consistency of Reaching Criteria/Trials to criteria %% 
%percentage of days after criteria was reached in which criteria was
%consistently reached 
%the day during DD0 where critera was first reached
day_learned = [];
consistency = [];
trials_criteria = [];
days_criteria = [];


for i = 1:size(high_iVal,1)
    ratData = high_iVal(i,:)
    met_criteria = find(ratData >= ival_criteria);
    %find the number of days it look to reach criteria 
    day_learned(i) = met_criteria(1)
    %how many days they learned/met criteria divided by the total number of
    %days after they first met_criteria
    consistency(i) = (numel(met_criteria)-1)/(numel(ratData) - met_criteria(1));

    %determine how the number of trials to criteria varied between days where
    %criteria was reached.
    if numel(met_criteria) > 1
        trials_criteria(i,:) = [trialStart(i, met_criteria(1)) trialStart(i, met_criteria(2))];
        days_criteria(i,:) = [met_criteria(1) met_criteria(2)];
    else 
        trials_criteria(i,:) = [NaN NaN];
        days_criteria(i,:) = [NaN NaN];
    end 
end

%pull out the data for each groups that you need
ratsInfo = ratsInfo(ratsInfo.strain == "P", :);
group = ratsInfo.sex == "M" & ratsInfo.treatment == "Control";
