%% Organize Wistar RAP Files %%
% path to first day with files 
pat = 'E:\052224_11425_WistarUrgency\RAP\100724_Renewal\analysisData';
days = 1:4;

fileTimes = [];
fileDates = [];
subNum = [];
boxNumber = [];
%first column is the original path. %second column is the new path 
fileMove = [];
experimentName = 'Wistar_Urgency';
fileType = 'med-pc';

%create table to hold info 
dataInfo_CSV = table('Size', [0 6], ...
          'VariableTypes', {'string', 'string', 'string', 'string', 'string'}, ...
          'VariableNames', {'original_path', 'new_path', 'subject', 'sex', 'treatment', 'issueTime'});


for i = 1:numel(days)
    %path to each individual day of files for that day 
    dayPath = fullfile(pat, ['day' num2str(days(i))]);
    %create variable that holds all medPC files 
    txtFiles = dir(fullfile(dayPath, '*.txt'));
    %read through each file one at a time
    for file = 1:size(txtFiles,1)
        %find path file and read text file in 
        filePath = fullfile(dayPath, indFile);
        fileContext = fileread(filePath);
        %pull out box number, date, time, and subject number(s) for each
        %file 
        boxNumber = str2double(erase(regexp(fileContext, 'Box:\s*\d+', 'match'), 'Box: '));
        %restructure box number to be 'box02' 
        boxNumber = sprintf('box%02d', boxNumber);
        % pull out the file time from the medPC file in HH:mm:dd structure 
        fileTimes{file, i} = timeofday(datetime(erase(regexp(fileContext, 'Start Time:\s*\d{2}:\d{2}:\d{2}', 'match'), 'Start Time: '))); 
        %pull out date from the medPC file and format liek yyyy-MM-dd
        fileDates = datetime(erase(regexp(fileContext, 'Start Date:\s*\d{2}/\d{2}/\d{2}', 'match'), 'Start Date: '), 'InputFormat', 'MM/dd/yy'); 
        fileDates.Format = 'yyyy-MM-dd';
        %determine group number based on medPC load time. Should add one to the group number once
        %the issue time changes. There could be an issue if files were
        %loaded up at different times in each group 
        if file == 1
            group = 1;
        elseif fileTimes{file,i} > fileTimes{file, i-1}
            group = group+1;
            %if (fileTimes{file,i} - fileTimes{file, i-1}) < 10 
        end 
        % find the number subjects 
        indSubject = regexp(fileContext, 'Subject:\s*([\d\s]+)', 'tokens');
        indSubject = strtrim(string(indSubject{1}));
        %create path to the box that will contain all file types for that
        %box on that date in that group
        boxPath = fullfile(sprintf('%s_%s_%s', fileDates, experimentName, ['group' num2str(group)]), boxNumber);
        %box to the specific type of data stored in the box folder 
        newPath = fullfile(boxPath, fileType);



    end 


end 