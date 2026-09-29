function [all_subject_numbers, all_sessionTime] = import_trialEnds(allData)
%calculates the total time of a DD session for each rat on each day using
%the medPC array N (end of trail times). Subtracts the first end of trial
%from the final end of trail
%TO-DO: somehow get total trial time, this is neglecting one trial 

%create variables  
all_trialEnds = cell(size(allData{1},1), numel(allData));
all_subject_numbers = nan(size(allData{1},1), numel(allData)); 
all_sessionTime = nan(size(allData{1},1), numel(allData)); 

%go through each day and pull out the trial ends for each rat  
for day = 1:numel(allData)
    for rat = 1:size(allData{day},1)
        %pull out data for just one rat
        trialEnds_ind = allData{day}{rat}.N;
        %find the last trial end time. This is the end of the session 
        sessionEnd = trialEnds_ind(end)/60;
        %find the first trial end time. This is the end of the first
        %trial in a whole session
        sessionStart = trialEnds_ind(1)/60;
        %total trial time 
        total_session_time = sessionEnd-sessionStart; 
        %save to variables 
        all_sessionTime(rat, day) = total_session_time;
        all_trialEnds{rat, day} = trialEnds_ind;
        all_subject_numbers(rat, day) = allData{day}{rat}.Subject;


    end
end 
