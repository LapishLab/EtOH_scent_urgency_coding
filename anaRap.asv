function [allData, totLickMtx, lickTmSerMtx, sideMtx, subNumMtx, checkLicks] = anaRap(dir_path, days, maxFiles, opts)
%% Get all of the RAP data and plot number of licks and timecourse of licks

%add description of arguments
arguments
    dir_path {mustBeText} % path to folder containing med associates files
    days {mustBeInteger} %number of experiment days
    maxFiles {mustBeInteger} %max number of MedPC files in each experiment day 
    opts.fix_file (1,1) logical = false %false automatically assumes you don't need to fix a medPC file, true will run the fixMedPCFile function
    opts.allData (1,1) logical = true %true automatically includes the allData variable in the output variable, false doesn't include it
    opts.totLickMtx (1,1) logical = true
    opts.lickTmSerMtx (1,1) logical = true
    opts.sideMtx (1,1) logical = true
    opts.subNumMtx (1,1) logical = true
    opts.checkLicks (1,1) logical = true
end; 

%% Import the RAP files
%premake matrix to hold data files. This is needed when there are a
%different number of files across days
allData = num2cell(zeros(days,maxFiles));

%change the "i" numbers in the for loop to reflect how many days of RAP you
%have
%change "pat" description to where the files come from
for i = 1:days;
    %path to file with medPC files for the renewal data
    pat = fullfile(dir_path, ['day' num2str(i)]);
    %path to file with medPC files for the original data
    %pat = ['E:\052224_ScentEtOHCohort\RAP\analysis_RapData\day' num2str(i) '\']
    % create a large cell array where rows is days and columns are 
    % MedPC files. each cell contains the MedPC file for the two rats
    % that ran in that box. Rat numbers are not consistent throughout the
    % cells of the columns 
    %restart matrix each time so that it is empty. Need this because the
    %number of files from each day is different
    data=[];
    data = importMA_blockArray_Batch(pat);
    %fixes the medPC file for 18 so that all the correct data from 18 is in
    %the 18 16 file
    % comment this area out if you don't need it! 
    %if i == 1 && opts.fix_file == true
     %   [data] = fixRAPMedPCFile(data);
    %end;
    % cycle through the data file and add the data into the correct
    % row/positions in the allData matrix. This is needed because the days
    % may contain different numbers of files 
    for m = 1:size(data,2)
        allData(i,m) = data(m);
    end; 
   
end;

%initalize variable for holding day, box, and subject number of rats that
%didn't have any licks 
checkLicks = [];

%% Organize data into matrices for plotting
% YY is the number of days of RAP you have
for YY = 1:size(allData,1)
    subNum=[]; totalLicks=[]; lickTimeSeries =[];
    %renew matrix each time that will hold the subject numbers for
    %the left and right sides
    left = [];
    right = [];
    % XX is the number of files that you have per day 
    for XX = 1:size(allData,2)

        %% Add subject numbers and data to variables %%
        % will skip this for loop and continue onto the next iteration if
        % it finds one of the cells that aren't filled with a struct.
        if ~isstruct(allData{YY,XX})
            warning(['Day ' num2str(YY) ' has ' num2str(XX-1) ' files'])
                continue;
        end; 

        % size of the subject number vector. Can be one or two depending
        % on how many rats were in the box.
        for i = 1:size(allData{YY,XX}.subjectNumber,2);
            % singular subject number
            sn(i) = allData{YY,XX}.subjectNumber(i);
            box_number = str2double(regexprep(allData{YY,XX}.header(contains(allData{YY,XX}.header, 'Box: '),:), '\D+', ''));
            % pull data if there is only one subject in the file 
            if size(allData{YY,XX}.subjectNumber,2) == 1;
                % check if there is data in A or B to determine if the rat
                % was on the left or right side. Then you can pull the
                % correct matrix of lick time series data from E or F 
                % pull data for left side because the licks are greater
                % than 0 on the left side. 
                % Rat was on the left side
                if allData{YY,XX}.A > 0
                    tl(i) = allData{YY,XX}.A;
                    ts{i} = allData{YY,XX}.E(allData{YY,XX}.E~=0);
                    %add the rat subject number to a left matrix because
                    %they were on the left side of the 2CAP chambers
                    left = [left;sn(i)];
                    right = [right;NaN];
                % pull data for right side because the licks are greater
                % than 0 on the right side. Rat was on the right side
                elseif allData{YY,XX}.B > 0
                    tl(i) = allData{YY,XX}.B;
                    ts{i} = allData{YY,XX}.F(allData{YY,XX}.F~=0);
                    %add the rat subject number to a right matrix because
                    %they were on the right side of the 2CAP chambers
                    right = [right;sn(i)];
                    left = [left;NaN];
                % if there are no licks in either A or B, automatically
                % assume that they are on the left side and shoot out a
                % warning to check it
                elseif allData{YY,XX}.A == 0 & allData{YY,XX}.B == 0
                    tl(i) = allData{YY,XX}.A;
                    ts{i} = allData{YY,XX}.E(allData{YY,XX}.E~=0);
                    left = [left;sn(i)];
                    right = [right;NaN];
                    %subject number and day of animals to check the box and
                    %licks for 
                    checkLicks = [checkLicks;[sn(i) box_number YY]];
                    warning(['Rat subject number ' num2str(sn(i)) ' in box ' num2str(box_number) ' on day ' num2str(YY) ' has no licks. Check side manually'])
                end;
            end; 
            
            % get data if the there are two subjects in the file. Two rats
            % in the box. adds the number of left licks to tl and the list of left lick
            % times to ts. Works if there are 2 rats in the box because the
            % number in the first spot of subject number will always correspond
            % with left side of the box. 
            if size(allData{YY,XX}.subjectNumber,2) == 2;
                if i==1;
                    tl(i) = allData{YY,XX}.A;
                    ts{i} = allData{YY,XX}.E(allData{YY,XX}.E~=0);
                    left = [left;sn(i)];
                elseif i==2;
                    tl(i) = allData{YY,XX}.B;
                    ts{i} = allData{YY,XX}.F(allData{YY,XX}.F~=0);
                    right = [right;sn(i)];
                end;
            end; 
        end;
        % add subject number, total licks, and times of licks to a vector.
        % Continually will add throughout the loop. Only contains
        % information from the day
        subNum = [subNum; sn']; clear sn;
        totalLicks = [totalLicks; tl']; clear tl;
        lickTimeSeries = [lickTimeSeries; ts']; clear ts;
    end
    % use the variables above to make a matrix of all the data from all the
    % days. rows are rats, columns are days 
    subNumMtx(:,YY) = subNum;
    totLickMtx(:,YY)= totalLicks;
    lickTmSerMtx{YY} = lickTimeSeries;
    sideMtx{YY} = [left,right];
end;

%% Organize data in order of increasing subject number %%
% cycle through each row of the subject number matrix. Sort and reorder it
% and then use the index of reording for the total lick and the lick time
% series matrix 

% i is the day number;
for i = 1:size(subNumMtx,2)
    %find the increasing order of the subject numbers and the indexing of
    %where they are to create the increasing sorted file
    [order, Index] = sort(subNumMtx(:,i));
    %use index to reorder the total licks matrix column and the time series matrix column for that day. total
    %licks will now be displayed in increasing rat order starting w/ rat 1
    totLickMtx(:,i) = totLickMtx(Index,i);
    lickTmSerMtx{i} = lickTmSerMtx{1,i}(Index);
    subNumMtx(:,i) = subNumMtx(Index,i);  
end; 

%% Organize output information %%

%Names of possible output variables 
variable_names = ["allData" "totLickMtx" "lickTmSerMtx" "sideMtx" "subNumMtx" "checkLicks"];
%array to hold all possible output variables in same order as name variable
variables = {allData, totLickMtx, lickTmSerMtx, sideMtx, subNumMtx, checkLicks};

out = {};

%cycle through each variable to see if it will be added to the output based
%on the input information 
for i = 1:size(variables,2)
    if opts.(variable_names(i)) == true
        out{i} = variables(i);
    end
end
