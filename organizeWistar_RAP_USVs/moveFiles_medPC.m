%% Organize Wistar Urgency RAP Files %%
%Moves the medPC files as they are organized into day folders on my extreme
%drive into group then box folders. All within
%"E:\052224_11425_WistarUrgency\RAP\100724_Renewal" location on my drive.
%Then, they can be copied to datastar. 

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
medPC_filesMove = table('Size', [0 3], ...
          'VariableTypes', {'string', 'string', 'string'}, ...
          'VariableNames', {'original_path', 'new_path', 'subject'});


for i = 1:numel(days)
    %path to each individual day of files for that day 
    dayPath = fullfile(pat, ['day' num2str(days(i))]);
    %create variable that holds all medPC files 
    txtFiles = dir(fullfile(dayPath, '*.txt'));
    %read through each file one at a time
    for file = 1:size(txtFiles,1)
        %find path file and read text file in 
        filePath = fullfile(dayPath, txtFiles(file).name);
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
        elseif fileTimes{file,i} > fileTimes{file-1, i}
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
        newPath = fullfile('E:\052224_11425_WistarUrgency\RAP\100724_Renewal', boxPath, fileType);
        %add data to the table 
        medPC_filesMove(end+1, :) = {filePath, newPath, indSubject};
        %move files from old location to new location
        copyfile(filePath, newPath)
    end 


end 