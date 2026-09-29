function [choice_omissions initial_omissions] = import_choice_omissions(allData)

%% Script that pulls out omission numbers for choice trials %%
%medPC array M
%data needs to be organized as cells for days. Within each cell is all the
%medPC structures

%preallocate variable to hold data
choice_omissions = NaN(size(allData{1},1), size(allData, 2));
initial_omissions = NaN(size(allData{1},1), size(allData, 2));

%go through each rat in each day and pull out array M where choice
%omissions are stores 
for day = 1:numel(allData)
    for rat = 1:numel(allData{day})
        %pull out trial types
        trial_type = allData{day}{rat}.H;
        %pull out omissions 
        choice_omissions(rat, day) = sum(trial_type == 2);
        initial_omissions(rat, day) = sum(trial_type == 1);
    end 
end 