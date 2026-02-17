function output = DDData_importAll(pat, dayNumbers, variables, opts)

%% Importing Delay Discounting Data from MedPC Files
% This function imports delay disconting medPC files and compiles all of
% the data into one variable. It also pulls the data for all the choice
% trials into one variable and the mean of the ivalue of the last 10 trials into another
% variable. 

% inputs: 
% days: which is a vector containing all the day numbers for the
% data you want to pull out. data needs to be stored in files named "day#"
% like "day26" for example 
% pat: CHARACTER path to the file with the data

% Outputs:
% allData: all the data for each delay discounting day and rat
% allDDiVals: matrix that contains all of the choice iValues for each rat
% on each day. Contains all the discounting curve DD data
% lastTenDDiVals: matrix with the mean of the iValue from the last 10
% trials for each rat across each day 

%% Describe inputs %%
arguments 
    pat {mustBeText} % path to folder containing individual folders with medPC files for each day 
    dayNumbers {mustBeInteger} % day numbers specific to day folders in the dir_path that you want to pull out 
    variables {mustBeText} %vector of strings that specific which variables you want from the function 
    opts.removeRats logical = false %false automatically assumes you don't need remove rats, if true then rats will be removed that didn't meet criteria 
end 


%% Initialize variable matrices %%
%create matrix that will hold the day numbers, will hold all the iValues
%for each animal, and a matrix of only the mean of the last 10 trials
allDDiVals = {};
lastTenDDiVals = []; 
allData = {};
day_dates = {};
init_latency = {};
choice_latency = {};
init_levers = {};
choice_levers = {};


%% Fill variables with Data %%  
%Change numbers in the for loop depending on how many days you have
for day = 1:numel(dayNumbers);
    %add day naming information to the path name so you can get the full
    %path name to the folder with all the MedPC files
    fullPath = [pat '\day' num2str(dayNumbers(day)) '\'];
    %import all of the files for each rat on each day
    dayData = importMA_Batch(fullPath, output_path = "C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\072125_121225_Prat_Urgency\Codes\variables");
    dates = matchingFileDates(dayData);
    allData{day} = dayData;
    %save the day and corresponding date to an overall vector so I can
    %check that the days and dates are aligning correctly 
    day_dates(day,:) = {dayNumbers(day), dates(1)};


    %create a for loop that finds the location of and removes rats who didn't make
    %testing criteria. only needed for wistars
    if opts.removeRats == true
        for rat = 1:size(allData{day},1)
            if allData{day}{rat}.Subject == 53 || allData{day}{rat}.Subject == 17|| allData{day}{rat}.Subject == 32 || allData{day}{rat}.Subject == 47
                allData{day}{rat} = [];
            end
        end
    end


    %determines which cells are empty. logical array with 1 for full cells and 0 for empty 
    emptyCells = ~cellfun('isempty', allData{day});
    %removes the empty cells by using indexing to only keep the cells with
    %a 1
    allData{day} = allData{day}(emptyCells);


    %create a NaN matrix for adding the iValue data for each rat to. rows
    %are rats and columns are trials. want to reset this every loop 
    %Some of the rats didn't complete 30 choice trials. Any uncompleted trials
    %at the end will be specificed by NaNs
    iVal_matrix = nan(size(allData{day},1),30);
    %empty individual day/rat variables so they can be refilled with data for the new day
    init_latency_ind = nan(size(allData{day},1),30);
    choice_latency_ind = nan(size(allData{day},1),30);
    init_levers_ind = nan(size(allData{day},1),30);
    choice_levers_ind = nan(size(allData{day},1),30);
    %add a for loop for creating a vector of iValues for each rat from
    %their choice trials
    for rat = 1:size(allData{day},1);
         % -- Vectors for information only on Choice Trials -- %
        % initial lever latencies, choice trials, delay lever latencies %
        %create new vector with iValues from only the choice trials for a singular rat. Index
        %into iValue O vector with choiceTrls to do this
        %logical index of the trials that are choice delay or immediate
        %trials
        choiceTrls = allData{day}{rat}.H == 3 | allData{day}{rat}.H == 4;
        %hold the ivalue assignment only for the choice trials 
        iVal_matrix(rat, [1:sum(choiceTrls)]) = allData{day}{rat}.O(choiceTrls)';
        %Hold the initiate lever latencies only for the choice trials
        init_latency_ind(rat, [1:sum(choiceTrls)]) = allData{day}{rat}.E(choiceTrls)';
        %hold the choice lever latencies only for the choice trials 
        choice_latency_ind(rat, [1:sum(choiceTrls)]) = allData{day}{rat}.F(choiceTrls)';
        %hold whether the lever pressed was on the immediate or delay side
        %for the initial lever
        init_levers_ind(rat, [1:sum(choiceTrls)]) = allData{day}{rat}.A(choiceTrls)';
        %hold whether the lever pressed was the immediate or delay lever
        %for the choice lever
        choice_levers_ind(rat, [1:sum(choiceTrls)]) = allData{day}{rat}.H(choiceTrls)';

    
        % -- Calculate the indifference point for each rat -- %
        %use an if statement to check to see if the last choice trial is a
        %NaN. Some females don't complete all the 30 trials. If they don't,
        %they have a NaN in the uncompleted trials. Use this to take the
        %mean of the last 10 completed trials which won't be the same last
        %10 for each rat
        %locations in the rat iValue vector that have NaN values 
        nanCell_locations = find(isnan(iVal_matrix(rat,:)));
        %find the mean of the last 10 completed trials if the rat completes
        %less than 10 choice trials
        if ~isempty(nanCell_locations) & nanCell_locations(1) <= 10 
            lastTenDDiVals(rat,day) = mean(iVal_matrix(rat,:), 'omitnan');
        %find the mean of the last 10 trials if the rat completes more than
        %10 choice trials but less than the full 30 
        elseif ~isempty(nanCell_locations)
            lastTenDDiVals(rat,day) = mean(iVal_matrix(rat,[nanCell_locations(1)-10:nanCell_locations(1)-1]));
        else;
            %Nans are not in any of the trials here. Can simply take the
            %mean of the last 10 trials 
            lastTenDDiVals(rat, day) = mean(iVal_matrix(rat,[end-9:end]));
        end;
    end; 
    
    % -- Add day data to overall matrix -- %
    allDDiVals{day} = iVal_matrix;
    init_latency{day} = init_latency_ind;
    choice_latency{day} = choice_latency_ind;
    init_levers{day} = init_levers_ind;
    choice_levers{day} = choice_levers_ind;
end; 

%% Determine output variables %%
output = cell(1,numel(variables));

if any(contains(variables, "all", 'IgnoreCase', true) & contains(variables, "ival", 'IgnoreCase', true))
    loc = contains(variables, "all", 'IgnoreCase', true) & contains(variables, "ival", 'IgnoreCase', true);
    output{loc} = allDDiVals;
end
if any(contains(variables, "ten", 'IgnoreCase', true) & contains(variables, "ival", 'IgnoreCase', true))
    loc = contains(variables, "ten", 'IgnoreCase', true);
    output{loc} = lastTenDDiVals;
end
if any(contains(variables, "allData", 'IgnoreCase', true))
    loc = contains(variables, "allData", 'IgnoreCase', true);
    output{loc} = allData;
end
if any(contains(variables, "date", 'IgnoreCase', true))
    loc = contains(variables, "date", 'IgnoreCase', true);
    output{loc} = day_dates;
end
if any(contains(variables, "choice", 'IgnoreCase', true))
    loc_lat = contains(variables, "choice", 'IgnoreCase', true) & contains(variables, "lat", 'IgnoreCase', true);
    output{loc_lat} = choice_latency;
    loc_levers = contains(variables, "choice", 'IgnoreCase', true) & contains(variables, "lev", 'IgnoreCase', true);
    output{loc_levers} = choice_levers;
end
if any(contains(variables, "init", 'IgnoreCase', true))
    loc_lat = contains(variables, "init", 'IgnoreCase', true) & contains(variables, "lat", 'IgnoreCase', true);
    output{loc_lat} = init_latency;
    loc_levers = contains(variables, "init", 'IgnoreCase', true) & contains(variables, "lev", 'IgnoreCase', true);
    output{loc_levers} = init_levers;
end



