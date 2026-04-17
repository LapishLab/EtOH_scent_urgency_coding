function [all_probability_immediate, choiceProbability_mean, choiceProbability_SEM, n] = calc_choiceProbability(data)
%input: matrix of 3 and 4 that define immediate or delay choices
%set a cell to true to it is an immediate choice and set to delay if its a
%delay choice
arguments
    data %cell array: contains the data for the DD trial type. matrix of 3 and 4 that define immediate or delay choices
end 

%Determine the trials in which the immediate lever was chosen 
choices = data == 4;

%variable to hold probability of choice type
choiceProbability_mean = [];
choiceProbability_SEM = [];
n = [];
all_probability_immediate = [];

for i = 1:size(choices, 2)
    %sample size. N is based on number of rats that made a choice at that
    %trial number, some of the rats will have NaNs because they stopped
    %making choices so N will change based on that 
    trial_n = sum(~isnan(data(:, i)));
    %divide number of choice type by total animals for each trial to
    %determine the probability to make that type of choice in each trial. 
    probability_immediate = sum(choices(:, i))/trial_n;
    %Multiply by the N to make it binomal mean 
    binomalMean = probability_immediate * trial_n;
    %calculate standard of the mean
    SEM = sqrt((probability_immediate*(1-probability_immediate))/trial_n);
    %add all calculated information to a final variable to hold it all
    n = [n; trial_n];
    all_probability_immediate(i) = probability_immediate;
    choiceProbability_mean(i) = binomalMean;
    choiceProbability_SEM(i) = SEM;

end 
