function t = import_USVs(input_opts)

arguments
    input_opts.remove_USV = []; %import any noise USV ranges to remove. in kHz units
    input_opts.file_name string = []; %what is the name of the file with all the data 
end 

%% Navigate to export directory before running script
export_path = uigetdir();
export_csv = fullfile(export_path, input_opts.file_name + ".csv");

%% load table, force all variables as string to prevent issueTimes from getting formatted weird
opts = detectImportOptions(export_csv, Delimiter=",");
opts = setvartype(opts, opts.SelectedVariableNames, 'string');
t = readtable(export_csv, opts);
%% Remove any rows which didn't have exports
% maybe add removing single rats? will make medPC parser faster 
t = t(~cellfun(@isempty, t.export_path), :);

%% load all call tables into this session table
% For portability get the path relative to the
% export director, instead of using the raw original export path.
[~, mat_names, ext] = fileparts(t.export_path);
local_mat_paths = fullfile(export_path, mat_names+ext);

% Load just the calls. Currently, I have no need for audio_file_info
load_fun = @(x) load(x).calls;
t.calls = cellfun(load_fun, local_mat_paths, UniformOutput=false);

%% remove any files with no calls FOR NOW
t = t(~cellfun(@isempty, t.calls), :);

%% Synchronize time
%only run once 
for row = 1:height(t)
    %change start call time to align with issue time
    %call times
    rat_calls = t.calls{row};
    %per file issue time
    start_time = double(t.issueTime(row));
    %time elapsed from start of file to call box (can be negative)
    new_call_times = rat_calls.Box(:,1) - start_time;
    if any(isnan(new_call_times))
        keyboard   % drops into the debugger here
    end
    %add to box call times
    rat_calls.Box(:,1) = new_call_times;
    %change ridge time to also be elapsed time from issue time  
    subtract_start = @(x) x - start_time;
    rat_calls.ridge_time = cellfun(subtract_start, rat_calls.ridge_time, 'UniformOutput', false);
    t.calls{row} = rat_calls;
end 


% audio time
% % time 0 is start of the file when started on the Pis 
% [~,id,~] = fileparts(t.export_path);
% time_string = extractBefore(id, 16);
% audio_datetime = datetime(time_string, InputFormat="uuuuMMdd_HHmmss");
% audio_time = timeofday(audio_datetime);
% 
% %convert time to posix time 
% t.issueTime.TimeZone = 'America/Indianapolis';
% 
% 
% % issue time
% % when MedPC boxes were issued 
% t.issueTime = pad(t.issueTime, 6, 'left','0');
% issue_time = timeofday(datetime(t.issueTime, InputFormat="HHmmss"));
% 
% %add dates to of files to tables
% audio_datetime.Format = 'yyyyMMdd';
% t.date = audio_datetime;
% 
% %% find audio offset time and shift (ONLY RUN ONCE)
% % time distance between pi start and medPC issue 
% % maybe change? 
% audio_offset = seconds(audio_time-issue_time);
% for i=1:height(audio_offset)
%     calls = t.calls{i};
%     calls.Box(:,1) = calls.Box(:,1) + audio_offset(i);
% 
%     add_offset = @(x) x + audio_offset(i);
%     calls.ridge_time = cellfun(add_offset, calls.ridge_time, 'UniformOutput', false);
%     t.calls{i} = calls;
% end

%% Calculating mean call frequency %%
%add frequency to the calls 
for i = 1:height(t)
    calls = t.calls{i};
    call_freq = cellfun(@mean, calls.ridge_frequency);
    calls.frequency = call_freq;
    t.calls{i} = calls;
end 

%% DD: Remove Noise USVs 

if ~isempty(input_opts.remove_USV)

    %43-45, 35-36, 
    DD_removeUSV = [input_opts.remove_USV(1,1)*1000 input_opts.remove_USV(1,2)*1000;input_opts.remove_USV(2,1)*1000 input_opts.remove_USV(2,2)*1000];

    remove_calls = [];

    for a = 1:height(t)
        %calls for each file
        calls = t.calls{a};

        %pick out which calls are within the DD noise bands. No anticipatory
        %USVs, only those when the DD task is running
        meets_threshold = (isInRange(calls.frequency, DD_removeUSV(1,1), DD_removeUSV(1,2)) | isInRange(calls.frequency, DD_removeUSV(2,1), DD_removeUSV(2,2))) & calls.Box(:,1) >= 0;

        %only keep calls that aren't within the range
        calls_removed_noise = calls(~meets_threshold, :);

        %resave the calls table with the noise removed
        t.calls{a} = calls_removed_noise;
    end
end 
end 