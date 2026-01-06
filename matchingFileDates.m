function [dates] = matchingFileDates(dayData,opts)
%% Checking dates in MedPC files %%
%check that the all the dates for the medPC files in a day are the same

arguments
    dayData cell %medPC files for a single day 
    opts.importer {mustBeText} = "" %specify which importer you are using to 
                                    %know how to pull out the data information. 
                                    %empty assumes the importer was David's
                                    %which doesn't have a header section 
end 

%% 
%create variable to hold all the dates
dates = [];

%go through each animal and pull out the date in their medPC struct 
    for i = 1:numel(dayData)
        if opts.importer == ""
            dates = [dates;string(dayData{i}.Start_Date)];
        elseif contains(opts.importer, "block", 'IgnoreCase', true)
            startDate = string(dayData{1}.header(contains(dayData{i}.header, "Start Date")));
            dates = [dates; erase(startDate, "Start Date: ")];
        end; 
    end

    %compare all the dates to each other. Display a warning if the dates are different  
    if ~all(dates == dates, "all")
        warning("Not all MedPC files are from the same date")
    end; 