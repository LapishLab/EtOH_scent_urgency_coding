function [allData, allDDiVals, lastTenDDiVals, day_dates] = DDData(pat, dayNumbers)

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

%% Create array of days 
%create matrix that will hold the day numbers, will hold all the iValues
%for each animal, and a matrix of only the mean of the last 10 trials
allDDiVals = [];
lastTenDDiVals = []; 
allData = [];
day_dates = {};

%% Create allData variable with all DD days  
%Change numbers in the for loop depending on how many days you have
for day = 1:length(dayNumbers);
    %add day naming information to the path name so you can get the full
    %path name to the folder with all the MedPC files
    fullPath = [pat '\day' num2str(dayNumbers(day)) '\'];
    %import all of the files for each rat on each day
    allData{day} = importMA_Batch(fullPath, output_path = "C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\072125_121225_Prat_Urgency\Codes\variables");
    
    %check the dates to make sure that all of the files in one allData file
    %are aligning with each other

    %save all the dates for a day to a single vector
    dates = [];
    for i = 1:size(allData{day},1)
        dates = [dates;string(allData{day}{i}.Start_Date)];
    end; 
    %compare all the dates to each other 
    if ~all(dates == dates(1))
        warning("Not all MedPC files are from the same date")
    end; 
    %save the day and corresponding date to an overall vector so I can
    %check that the days and dates are aligning correctly 
    day_dates(day,:) = {dayNumbers(day), dates(1)};


    %create a for loop that finds the location of and removes rats who didn't make
    %testing criteria
    % can comment out if you don't need this 
    for rat = 1:size(allData{day},2);
        %if allData{day}{rat}.subjectNumber == 53 | allData{day}{rat}.subjectNumber == 17| allData{day}{rat}.subjectNumber == 32|allData{day}{rat}.subjectNumber == 47;
            %allData{day}{rat} = [];
        %end;
    end;


    %determines which cells are empty. logical array with 1 for full cells and 0 for empty 
    emptyCells = ~cellfun('isempty', allData{day});
    %removes the empty cells by using indexing to only keep the cells with
    %a 1
    allData{day} = allData{day}(emptyCells);


    %create a NaN matrix for adding the iValue data for each rat to. rows
    %are rats and columns are trials. want to reset this every loop 
    iVal_matrix = nan(size(allData{day},1),30);
    %add a for loop for creating a vector of iValues for each rat from
    %their choice trials
    for rat = 1:size(allData{day},1);
        %logical index of the trials that are choice delay or immediate
        %trials
        choiceTrls = allData{day}{rat}.H == 3 | allData{day}{rat}.H == 4;
        %create new vector with iValues from only the choice trials for a singular rat. Index
        %into iValue O vector with choiceTrls to do this
        rat_iVals = allData{day}{rat}.O(choiceTrls);
        %add the iValue numbers for each rat to the rats row in the matrix.
        %Some of the rats don't fully have 30 trials and I will keep
        %their empty slots as Nans at the end of the matrix.
        iVal_matrix(rat, [1:size(rat_iVals,1)]) = rat_iVals';

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
            lastTenDDiVals(rat,day) = mean(iVal_matrix(rat,[1:nanCell_locations(1)-1]));
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
    %add iValMatrix to the output variable allDDiVals
    allDDiVals{day} = iVal_matrix;
end; 

%clearvars -except allData allDDiVals lastTenDDiVals day_dates