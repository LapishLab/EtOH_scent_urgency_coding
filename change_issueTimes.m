%needs the already created variable audioFiles_subjectInfo.csv or whatever
%.csv you have made that includes subject identifying information for each
%behavior box 

original_table = t;
original_table.Properties.VariableNames(1) = "data_path";
newTable = table('Size', [0 6],... 
    'VariableTypes', repmat("string", 1, 6),... 
    'VariableNames', [original_table.Properties.VariableNames{:}, "boxClose"]);



% --- Import and reorganize excel sheet with Issue times --- %
%find import excel sheet with issue times 
%path for wistar RAP USV data 
dirPath = "E:\052224_11425_WistarUrgency\RAP";
excelFile = "RAP Raw Data.xlsx";
issueTimesPath = fullfile(dirPath, excelFile);
RAP_times = readtable(issueTimesPath, 'Sheet', 'issueTimes');

%reformat date
RAP_times.date.Format = 'yyyyMMdd';

%reformat box close times and issue times 
%if in wistar RAP, convert issue time to UTC as that is what the file names
%are in. Add four hours to conver to UTC from EDT
RAP_times.ET_BoxClose = days(RAP_times.ET_BoxClose) + hours(4);
RAP_times.ET_BoxClose.Format = 'hh:mm:ss';

RAP_times.ET_IssueTime = days(RAP_times.ET_IssueTime) + hours(4);
RAP_times.ET_IssueTime.Format = 'hh:mm:ss';

RAP_times.time = days(RAP_times.time) + hours(4);
RAP_times.time.Format = 'hh:mm:ss';

%format the time as a string and remove :
RAP_times.time = string(RAP_times.time);
RAP_times.time = erase(RAP_times.time, ':');

RAP_times.ET_BoxClose = string(RAP_times.ET_BoxClose);
RAP_times.ET_BoxClose = erase(RAP_times.ET_BoxClose, ':');

RAP_times.ET_IssueTime = string(RAP_times.ET_IssueTime);
RAP_times.ET_IssueTime = erase(RAP_times.ET_IssueTime, ':');


% --- Find file for each issue time and replace issue time --- % 
%use original rap times as well as box numbers to add new issue times
%warning, this won't work if there are issue times that are the same for
%different groups on a single day
for i = 1:size(original_table, 1)
    %pull out original information for each rat/group of rats
    rat_info = original_table(i,:);

    %find the filename and box specific to each rat/group of rats
    dataFile_parts = split(rat_info.data_path, '/');
    date = extractBefore(dataFile_parts(end), '_');
    boxNumber_filePart = dataFile_parts(contains(dataFile_parts, 'box', 'IgnoreCase', true));
    boxNumber = extractAfter(lower(boxNumber_filePart), 'box');
    
    %find row in RAP_times that pertains to a specific rat 
    timeRow = double(boxNumber) == RAP_times.box & rat_info.issueTime == RAP_times.time & date == RAP_times.date;
  
    %add new issue time and box close to the rat info row based on the
    %timeRow
    newIssueTime = RAP_times.ET_IssueTime(timeRow);
    newBoxClose = RAP_times.ET_BoxClose(timeRow);


    %add everything together with single rat_info and the new issue and box
    %close times. Only take 1:4 from single rat_info so that the old
    %issueTime isn't carried forward
    newTable{i,:} = [rat_info{:,1:4}, newIssueTime, newBoxClose];
end 
