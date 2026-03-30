%needs videos.csv 
% pulls out ones specific to the days and groups you are interested in
% Adds extra identifying information about the subject in each file. For
% example, this includes subject number, reinforcer, sex, and issueTime 

% pull out specific data from all data
%range for wistar DD
%date_range = datetime(2024, 10, 14):datetime(2024, 10, 25);

%range for wistar RAP
date_range = datetime(2024, 10, 14):datetime(2024, 10, 25);
date_range.Format = "yyyy-MM-dd";
date_range = string(date_range);
match = contains(t.data_path, date_range) & contains(t.data_path, "Wistar_Urgency");
specific_table = t(match, :); 

%find import excel sheet with issue times 
%path for wistar RAP USV data 
dirPath = "E:\052224_11425_WistarUrgency\RAP";
excelFile = "RAP Raw Data.xlsx";

issueTimesPath = fullfile(dirPath, excelFile);
RAP_times = readtable(issueTimesPath, 'Sheet', 'issueTimes');
RAP_times.date.Format = 'yyyyMMdd';
%time column in excel needs to be formatted as a time cell type 
RAP_times.time = days(RAP_times.time);
RAP_times.time.Format = 'hh:mm:ss';
%if in wistar RAP, convert issue time to UTC as that is what the file names
%are in. Add four hours to conver to UTC from EDT
RAP_times.time = RAP_times.time + hours(4);
RAP_times.time = string(RAP_times.time);
RAP_times.time = erase(RAP_times.time, ':');

%create new CSV table holding file path information,subject numbers, sex,
%and exposure type
dataInfo_CSV = table('Size', [0 4], ...
          'VariableTypes', {'string', 'string', 'string', 'string'}, ...
          'VariableNames', {'audio_file_path', 'subject', 'sex', 'treatment'});


for row = 1:size(specific_table,1)
    try 
        % -- Determine Sex and Exposure (EtOH or Control) -- %
        %pull out subject number from subject number file
        subjectNumbers = regexp(specific_table.subject(row), '_', 'split');
        %pull out location of the subjects
        subjectLocation = arrayfun(@(n) str2double(n) == ratsInfo.ratID, subjectNumbers, 'UniformOutput', false);
        %find and compare information if multiple subject numbers
        if size(subjectNumbers,2) > 1
            %check if their sex is the same
            bothSubjectsSex = [ratsInfo.sex(subjectLocation{1}) ratsInfo.sex(subjectLocation{2})];
            % Check if the sexes are the same. append the sex result.
            % Display warning if the sex doesn't match.
            if bothSubjectsSex{1} == bothSubjectsSex{2}
                sex = ratsInfo.sex(subjectLocation{1});
            else
                warning('Sex does not match for %s', specific_table.subject(row));
                sex = ratsInfo.Sex(subjectLocation{1});
            end
            %find the treatments for each subject and add them into one
            %variable where they are separated by an underscore
            treatment = strjoin([ratsInfo.treatment(subjectLocation{1}) ratsInfo.treatment(subjectLocation{2})], "_");
            %find the sex and treatments for when there is only one rat in
            %the box.
        elseif size(subjectNumbers,2) == 1
            sex = ratsInfo.sex(subjectLocation{1});
            treatment = ratsInfo.treatment(subjectLocation{1});
        end

        % % --- Connect data file path with issue time --- %
        % % Extract the date and time from the WAV file name
        % % date is the first cell and time is the second
        % dataFile_parts = split(specific_table.data_path(row), '/');
        % dateTimeParts = split(erase(dataFile_parts(end), '.WAV'), '_');
        % %extract box number from file path
        % boxNumber_filePart = dataFile_parts(contains(dataFile_parts, 'box', 'IgnoreCase', true));
        % boxNumber = extractAfter(lower(boxNumber_filePart), 'box');
        % %extract group number from file path
        % groupNumber_filePart = dataFile_parts(contains(dataFile_parts, 'group'));
        % groupNumber = extractAfter(regexp(groupNumber_filePart(1), "group.", "match"), "group");
        % %find the issue time
        % %Determine date, box#, and group number that matches with box issue time
        % date_match = string(RAP_times.date) == string(dateTimeParts{1});
        % boxNumber_match = double(RAP_times.box) == double(boxNumber);
        % groupNumber_match = RAP_times.group == double(groupNumber);
        % issueTime = RAP_times.time(date_match & boxNumber_match & groupNumber_match);
        % %check that an issue time was found
        % if numel(unique(issueTime)) ~= 1
        %     warning("No exact issue time found for %s", specific_table.data_path(row))
        % end

        %add all data into a new table
        dataInfo_CSV(end+1, :) = {specific_table.data_path(row), specific_table.subject(row), sex, treatment};
    catch 
        warning("Error adding detailed information to %s", specific_table.data_path(row))
    end 

end

  % Save the updated table back to a new CSV file
   %writetable(dataInfo_CSV, fullfile(dirPath, 'audioFiles_subjectInfo.csv'));