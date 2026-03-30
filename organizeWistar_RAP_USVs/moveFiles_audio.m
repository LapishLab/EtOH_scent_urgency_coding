%% Organize Wistar Urgency RAP Audio %% 
%move audio files from old location on anna extreme drive to an organized
%location

%import issue times data for Wistars
issueTimesPath = "E:\052224_11425_WistarUrgency\RAP\RAP Raw Data.xlsx";
issueTimes = readtable(issueTimesPath, 'Sheet', 'issueTimes');
issueTimes.date.Format = 'yyyyMMdd';
issueTimes.issueTime = days(issueTimes.issueTime);
issueTimes.issueTime.Format = 'hh:mm:ss';
%issueTimes.issueTime= string(issueTimes.issueTime);
%issueTimes.issueTime = erase(issueTimes.issueTime, ':');

%convert issue times to UTC. The times are in eastern time, daylight
%savings (EDT) so add four hours 
issueTimes.issueTime = issueTimes.issueTime + hours(4);

%old USV location
USV_generalPath = 'E:\052224_11425_WistarUrgency\RAP\USVs';
%new USV location to be copied to 
copyTo_generalPath = 'E:\052224_11425_WistarUrgency\RAP\100724_Renewal';
experimentName = "Wistar_Urgency";

 
for i = 1:size(issueTimes, 1)
    % use date and box number in issue times table to create path to
    % unorganized audio files right now 
    %find all .wav files
    audioFilePath = fullfile(USV_generalPath, ['box' num2str(issueTimes.box(i))], string(issueTimes.date(i)));
    audioFileDir = dir(fullfile(audioFilePath, '*.WAV'));
    if isempty(audioFileDir)
        warning("no audio files in %s", audioFilePath)
    end
    
    try 
        %pull out the times of all of the .wav files in the folder
        audioFileNames = string({audioFileDir.name});
        audioFileTimes = split(audioFileNames, '_') ;
        audioFileTimes = datetime(erase(audioFileTimes(:,:,2), '.WAV'), 'InputFormat', 'HHmmss');
        audioFileTimes = timeofday(audioFileTimes);

        %calculate the general RAP time session
        indIssueTime = issueTimes.issueTime(i);
        sessionRange = [indIssueTime indIssueTime + hours(1)];

        filesToMove_loc = [];

        %copy over all files within the session range
        filesToMove_loc = find(audioFileTimes > sessionRange(1) & audioFileTimes < sessionRange(2));
        %also include the file before those within the time range as this is
        %probably the first part of the session
        filesToMove_loc = [filesToMove_loc(1)-1 filesToMove_loc];
        %include the file after the time range if it is within 15 minutes of
        %the end time range
        try audioFileTimes(filesToMove_loc(end)+1)
            if audioFileTimes(filesToMove_loc(end)+1) < (sessionRange(2)+minutes(15))
                filesToMove_loc = [filesToMove_loc filesToMove_loc(end)+1];
            end
        catch
            warning("End of the audioFiles")
        end
        all_oldPaths = {};

        %copy all audio files to their correct location
        for m = 1:numel(filesToMove_loc)
            %path to where the USVs are currently at
            oldPath = fullfile(audioFileDir(filesToMove_loc(m)).folder, audioFileDir(filesToMove_loc(m)).name);
            %prepare folder names to create new file path
            newBox = sprintf('box%02d', issueTimes.box(i));
            newGroup = ['group' num2str(issueTimes.group(i))];
            indDate = issueTimes.date(i);
            indDate.Format = 'yyyy-MM-dd';
            newParentFolder = sprintf('%s_%s_%s',string(indDate), experimentName, newGroup) ;
            newPath = fullfile(copyTo_generalPath, newParentFolder, newBox, 'mic');
            %move files from old location to new location
            copyfile(oldPath, newPath);
            %add old paths to an array
            all_oldPaths{m} = oldPath;
        end

        %add all old file paths to the end of the table
        issueTimes.oldPaths{i} = all_oldPaths;

    catch 
        warning("Error Processing Files in %s", audioFilePath)
    end 
end 


