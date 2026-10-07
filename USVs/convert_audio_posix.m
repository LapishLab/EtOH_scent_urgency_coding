function convert_audio_posix(input_opts)
%uses chosen path to folder which should be filled with audio files.
%Creates a new folder and saves all audio files with start time, ridge
%time,and box call time changed to posix time 

arguments
    input_opts.file_name string = "export"; %what is the name of the file with all the data
end 

%% Navigate to export directory before running script
export_path = uigetdir();
export_csv = fullfile(export_path, input_opts.file_name + ".csv");

%make new posix folder
out_dir = fullfile(export_path, "posix");
if ~isfolder(out_dir), mkdir(out_dir); end

%% load table, force all variables as string to prevent issueTimes from getting formatted weird
opts = detectImportOptions(export_csv, Delimiter=",");
opts = setvartype(opts, opts.SelectedVariableNames, 'string');
t = readtable(export_csv, opts);
%% Remove any rows which didn't have exports
% maybe add removing single rats? will make medPC parser faster 
t = t(~cellfun(@isempty, t.export_path), :);

%% Convert issue times to posix time
%check for a date column in t (TODO: use file_ID if present) 
if ~any(t.Properties.VariableNames == "date")
    [~, filename] = fileparts(t.export_path);
    %find date from filename 
    parts = extractBefore(filename(:,1), "_");
    %add date to t 
    t.date = datetime(parts, "InputFormat","yyyyMMdd");
    t.date.Format = "yyyyMMdd";
    t.date.TimeZone = 'America/Indianapolis';

end 

%convert issue time to datetime
if isstring(t.issueTime(:,1))
    %make sure there are 6 digits, will add leading zero if there are only
    %5. this was breaking the code because it wasn't registering times
    %before 10am
    padded = compose("%06d", double(t.issueTime));
    convert_date = datetime(padded, 'InputFormat', 'HHmmss');
    t.issueTime = convert_date;
    t.issueTime.TimeZone = 'America/Indianapolis';
end 

%check that the date between issue time and in the date column matches.
%make them match if they don't
match = string(dateshift(t.issueTime, 'start', 'day')) == string(dateshift(t.date, 'start', 'day'));
if any(~match)
    t.issueTime = timeofday(t.issueTime(:,1)) + dateshift(t.date, 'start', 'day');
end 

%convert issueTime to posix time 
t.issueTime = posixtime(t.issueTime);


%% load all call tables into this session table
% For portability get the path relative to the
% export director, instead of using the raw original export path.
[~, mat_names, ext] = fileparts(t.export_path);
local_mat_paths = fullfile(export_path, mat_names+ext);
%load the audio file info 
for i = 1:numel(local_mat_paths)
    %load in each individual call file 
    call_file = load(local_mat_paths(i));

    % Add posix time to ex.audio_file_info table
    call_file.audio_file_info.file_time.TimeZone = 'America/Indianapolis';
    call_file.audio_file_info.posix_time = posixtime(call_file.audio_file_info.file_time);

    %check for calls in the file. skip if no calls 
    if ~isempty(call_file.calls)
        % Convert ridge_times and box times to posix
        offset = call_file.audio_file_info.posix_time(1);% NOTE: might not want to use 1st file in an attempt to get better than second resolution

        add_offset = @(x) x + offset;
       
        call_file.calls.ridge_time = cellfun(add_offset, call_file.calls.ridge_time, 'UniformOutput', false);
        call_file.calls.Box = double(call_file.calls.Box);
        call_file.calls.Box(:,1) = call_file.calls.Box(:,1) + offset;
    end

    %new audio file location
    [all, name, ext] = fileparts(local_mat_paths(i));
    new_file = fullfile(all, "posix", [name + ext]);

    %resave audio file to the same file. Everything else should be the same
    %except for the audio file time
    save(new_file, '-struct', 'call_file')
end

%% resave t with issue time in posix 

t_path = fullfile(all, "posix", input_opts.file_name + ".csv");
writetable(t, t_path);