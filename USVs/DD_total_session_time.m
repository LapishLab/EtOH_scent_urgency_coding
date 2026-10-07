%% Find Total Session Time %% 
%input: array of total session times, all_Data

%total session time 
[subject_numbers, session_times] = import_trialEnds(allData);

%convert session times to datetime
session_times = minutes(session_times);
session_times.Format = 'hh:mm:ss';

%add unique numeric identifier to dates 
dates = unique(string(sort(t.date)));
identifier = [1:10 1:10];
identify_dates = [dates identifier'];

%add new empty column to the table 
t.session_duration = duration(NaN(height(t), 1), 0, 0);
errors = cell(size(allData{1},1), numel(allData));

%add session times for each 
for day = 1:size(subject_numbers,2)
    for rat = 1:size(subject_numbers, 1)
        %use date and subject number to add total session time to
        %the table 
        %find subject number
        subject_ind = string(subject_numbers(rat, day));
        %find date 
        possible_dates = identify_dates(strcmp(identify_dates(:, 2), string(day)), 1);
        %find row on the table for the rat on the given day 
        match = strcmp(t.subject, subject_ind) & ismember(string(t.date), possible_dates);
        %check that there is only one match
        if sum(match) > 1
            warning("more than one table row found for rat %s on days %s, %s", subject_ind, possible_dates(1), possible_dates(2));
            %save error data to a variable 
            errors{rat, day} = t(match, :);
            
        elseif sum(match) < 1
            warning("no table row found for rat %s on days %s, %s", subject_ind, possible_dates(1), possible_dates(2));
        end 
        %add session time to the table
        t.session_duration(match) = session_times(rat, day);
    end 
end 