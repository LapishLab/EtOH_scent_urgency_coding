function [avg_data, avg_subjects, sum_pairs] = RAP_pairs_avg_subject(data, all_subjects);
%% Average animal consumption if in RAP Pairing across Multiple Days %%
% then can look at within subject pairings 
%inputs:
    % subjects: array of subject numbers that produced the data in the
    % matching row in data
    % data: some measured value from RAP (licks, g/kg cons, g/kg/lick)

%remove repeated numbers in subjects and sort in increasing order
summary_subjects = sort(unique(all_subjects));

avg_data = [];
avg_subjects = [];
sum_pairs = [];

%take the mean of the data if a subject is found multiple times in
%all_subjects
for i = 1:numel(summary_subjects)
    %location of all data for subjects
    match = all_subjects == summary_subjects(i);
    %calculate the mean of the data if there are multiple data points and
    %add to matrix
    avg_data = [avg_data; mean(data(match), 'omitnan')];
    sum_pairs = [sum_pairs; sum(match)];
    avg_subjects = [avg_subjects; summary_subjects(i)];
end