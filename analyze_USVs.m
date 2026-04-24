% This script requires https://github.com/raacampbell/shadedErrorBar
% Navigate to export directory before running script
export_path = uigetdir();
export_csv = fullfile(export_path, "export.csv");

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
% audio time
% time 0 is start of the file when started on the Pis 
[~,id,~] = fileparts(t.export_path);
time_string = extractBefore(id, 16);
audio_datetime = datetime(time_string, InputFormat="uuuuMMdd_HHmmss");
audio_time = timeofday(audio_datetime);

% issue time
% when MedPC boxes were issued 
t.issueTime = pad(t.issueTime, 6, 'left','0');
issue_time = timeofday(datetime(t.issueTime, InputFormat="HHmmss"));

%add dates to of files to tables
audio_datetime.Format = 'yyyyMMdd';
t.date = audio_datetime;

%% find audio offset time and shift (ONLY RUN ONCE)
% time distance between pi start and medPC issue 
% maybe change? 
audio_offset = seconds(audio_time-issue_time);
for i=1:height(audio_offset)
    calls = t.calls{i};
    calls.Box(:,1) = calls.Box(:,1) + audio_offset(i);

    add_offset = @(x) x + audio_offset(i);
    calls.ridge_time = cellfun(add_offset, calls.ridge_time, 'UniformOutput', false);
    t.calls{i} = calls;
end

%% Calculating mean call frequency %%
%add frequency to the calls 
for i = 1:height(t)
    calls = t.calls{i};
    call_freq = cellfun(@mean, calls.ridge_frequency);
    calls.frequency = call_freq;
    t.calls{i} = calls;
end 

%% Bin average USV rate and frequency

%amount of the file to include. Based on audio offset time calculated for
%the files 
edges = -1*60 : 10 : 22*60; 
tdif = diff(edges(1:2));

sad_threshold = 38*1000;
happy_threshold = 46*1000;

usv_rate = nan(height(t), length(edges)-1);
usv_freq = usv_rate;
for i=1:height(t)
    % --- get usv rate --- %
    calls = t.calls{i};
    %if you want to keep only USVs of a certain frequency 
    meets_threshold = calls.frequency == calls.frequency;

    % find mean of all the time points of each pixel in a squeak 
    call_times = cellfun(@mean, calls.ridge_time(meets_threshold));
    % number of USV counts in each time bin / total time = percentage of
    % total squeaks in the file in each time bin 
    usv_rate(i,:) = histcounts(call_times, edges) / tdif;

    % --- get usv frequency --- %
    % find mean frequency of each pixel of a squeak, in Hz not KHz
    call_freq = cellfun(@mean, calls.ridge_frequency(meets_threshold));
    % find which time bins have calls in them. Tin bins without calls
    % (should be mainly those at the start and end) are labeled as NaNs 
    binIndices = discretize(call_times, edges);
    outside_edges = isnan(binIndices);
    %keep only the data that is in time bins where calls are present 
    call_freq = call_freq(~outside_edges);
    binIndices=binIndices(~outside_edges);
    
    %find average squeak frequency in each time bin 
    sz = [length(edges)-1, 1];
    avg =  @(x) mean(x, 'omitnan');
    usv_freq(i,:) = accumarray(binIndices, call_freq, sz, avg, NaN);
end
sem = @(x) std(x, 'omitnan')/sqrt(sum(~isnan(x(:,1))));
avg_nan = @(x) mean(x, 'omitnan');

%% Grouping: strains and sex %% 
P = contains(t.strain, "P");
wistar = contains(t.strain, "Wistar");
P_male = contains(t.strain, "P") & contains(t.sex, "M");
P_female = contains(t.strain, "P") & contains(t.sex, "F");
wistar_male = contains(t.strain, "Wistar") & contains(t.sex, "M");
wistar_female = contains(t.strain, "Wistar") & contains(t.sex, "F");

%% Grouping: EtOH vs Control
EtOH = contains(t.treatment, "EtOH");
H2O = contains(t.treatment, "Control");

%% Grouping: baseline 
scentDays_wistar = ["20241016" "20241018" "20241023" "20241025"];
scentDays_P = ["20251105" "20251107" "20251112" "20251114"];

baseline = (ismember(string(t.date), ["20251104", "20251103", "20241015", "20241014"]));



%% Grouping: DD Scent Types %%
%need DD_scent_counterbalanced_identifier from ratsInfo table 
scentDays_wistar = ["20241016" "20241018" "20241023" "20241025"];
scentDays_P = ["20251105" "20251107" "20251112" "20251114"];

%rat subject numbers for those that are part of "group 1". They had EtOH
%scent on the first scent day/wednesday of week one and the second scent
%day/friday of week 2 
group1 = ratsInfo.ratID(ratsInfo.DD_scent_counterbalanced_identifier == 1);
group2 = ratsInfo.ratID(ratsInfo.DD_scent_counterbalanced_identifier == 2);

%logical statement for which rats had the EtOH scent each day when the EtOH or water scents were present (4 days in total)  
firstDay_EtOH_scent = contains(t.treatment, "EtOH") & ismember(string(t.date), [scentDays_wistar(1) scentDays_P(1)]) & ismember(t.subject, string(group1));
firstDay_water_scent = contains(t.treatment, "EtOH") & ismember(string(t.date), [scentDays_wistar(1) scentDays_P(1)]) & ismember(t.subject, string(group2));
secondDay_EtOH_scent = contains(t.treatment, "EtOH") & ismember(string(t.date), [scentDays_wistar(2) scentDays_P(2)]) & ismember(t.subject, string(group2));
secondDay_water_scent = contains(t.treatment, "EtOH") & ismember(string(t.date), [scentDays_wistar(2) scentDays_P(2)]) & ismember(t.subject, string(group1));
thirdDay_EtOH_scent = contains(t.treatment, "EtOH") & ismember(string(t.date), [scentDays_wistar(3) scentDays_P(3)]) & ismember(t.subject, string(group2));
thirdDay_water_scent = contains(t.treatment, "EtOH") & ismember(string(t.date), [scentDays_wistar(3) scentDays_P(3)]) & ismember(t.subject, string(group1));
fourthDay_EtOH_scent = contains(t.treatment, "EtOH") & ismember(string(t.date), [scentDays_wistar(4) scentDays_P(4)]) & ismember(t.subject, string(group1));
fourthDay_water_scent = contains(t.treatment, "EtOH") & ismember(string(t.date), [scentDays_wistar(4) scentDays_P(4)]) & ismember(t.subject, string(group2));

control_scentDays = contains(t.treatment, "Control") & ismember(string(t.date), [scentDays_wistar scentDays_P]);

%% Grouping: Final Analysis %%
%(firstDay_water_scent | secondDay_water_scent | thirdDay_water_scent | fourthDay_water_scent)


group1 = wistar_male & baseline & H2O;
group2 = wistar_male & control_scentDays & H2O;
group3 = wistar_female & baseline & H2O;
group4 = wistar_female & control_scentDays & H2O;
group5 = P_male & baseline & H2O;
group6 = P_male & control_scentDays & H2O;
group7 = P_female & baseline & H2O;
group8 = P_female & control_scentDays & H2O;


%% RAP Grouping 

renewal_P = ["20251027" "20251028" "20251029" "20251030"];
renewal_wistar = ["20241007", "20241008", "20241009", "20241010"];
singles = t.treatment == "Control" | t.treatment == "EtOH";

%reduce table to just renewal 
condense = contains(t.strain, 'wistar') + ismember(string(t.date), renewal_P);
t = t(logical(condense), :);

w_male = contains(t.sex, "M") & ~singles  & contains(t.strain, "wistar") ;
w_female = contains(t.sex, "F") & ~singles & contains(t.strain, "wistar") ;
p_male = contains(t.sex, "M") & contains(t.strain, "P") & ~singles;
p_female = contains(t.sex, "F") & contains(t.strain, "P") & ~singles;

wistar = contains(t.strain, "wistar") & ~singles;
P = contains(t.strain, "P") & ~singles;

Etoh = contains(t.treatment, 'EtOH_EtOH') & ismember(string(t.date), renewal_wistar([1 3]));
water = ismember(t.treatment, {'EtOH_EtOH', 'EtOH_Control', 'Control_EtOH', 'Control_Control'}) & ismember(string(t.date), renewal_wistar([2 4]));
mixed = (contains(t.treatment, 'EtOH_Control') | contains(t.treatment, 'Control_EtOH')) & ismember(string(t.date), renewal_wistar([1 3]));

%% File Time Cutoff %% 

%DD experiment 
DD_sessionTime = -1*60:10:25*60;
RAP_sessionTime = -1*60:10:60*60;

%% Check USV frequency spread %%
histogram(usv_freq(P, :)/1000, 'BinWidth', 1)
hold on 
title("DD USV frequency spread P")
xlabel("Frequency (kHz)")
ylim([0 4500])
xline([36, 46])
hold off

%sad cutoff: 38 kHz
%happy start: 46 kHz
%% USV Counts Graphing 

groups = {group1, group2, group3, group4};
group_data = {};
jitterAmount = 0.5;

%set some time threshold to keep calls within a certain time frame 
time_frame = [-1*60, 22*60];

for i = 1:numel(groups)
    %pull out all of the calls for each member of each group of interest 
    calls = t.calls(groups{i}); 
    %cycle through the calls and only include calls that fit within a
    %certain time frame 
    for m = 1:numel(calls)
        %pull out the times when each squeak occurred 
        call_times = calls{m}.Box(:,1);
        %determine which calls fall within a time frame that you want to
        %look at 
        keep = isInRange(call_times, time_frame(1), time_frame(2));
        %only keep the calls within the time frame
        calls{m} = calls{m}(keep, :);
    end
    %USV count number. Each group will be contained in its own cell 
    group_data{i} = cellfun(@height, calls);
    bar(i, mean(group_data{i}))
    hold on
    x = i + jitterAmount*(rand(size(group_data{i})) - 0.5);
    scatter(x, group_data{i}, 25, 'k', 'filled', 'MarkerFaceAlpha', 0.6)
    h = errorbar(i, mean(group_data{i}), sem(group_data{i}), 'Color', 'red');
    h.LineWidth = 4;
    h.CapSize = 20;
end 

xticks([1 2 3 4])
ylim([0 1000])
xticklabels({"Wistar Male Baseline", "Wistar Male EtOH Scent", "Wistar Female Baseline", "Wistar Female EtOH Scent"})
ylabel("USV counts")
title("Baseline vs EtOH scent days, Ps both weeks")


%% 1 vs 2 rats USVs
two_rats = contains(t.treatment, '_');

figure(2); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
shadedErrorBar(x, usv_rate(two_rats,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'blue', 'DisplayName', '2 rats'})
shadedErrorBar(x, usv_rate(~two_rats,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', '1 rat'})

xlabel("Time (minutes)")
ylabel("USV Rate (Hz)")
legend()


%% USV rates over time %%

figure(1); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
shadedErrorBar(x, usv_rate(group7,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'blue', 'DisplayName', '2days Before'})
shadedErrorBar(x, usv_rate(group8,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', 'Scent days'})
%shadedErrorBar(x, usv_rate(mixed,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'red', 'DisplayName', 'water-EtOH'})
%shadedErrorBar(x, usv_rate(p,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'black', 'DisplayName', 'p'})
xlabel("Time (minutes)")
ylabel("USV Rate (Hz)")
title("DD Scent Days both Weeks, Control animals, P females")
ylim([0 1])
legend()

%% Male vs Female
M = contains(t.sex, 'M');

figure(4); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
shadedErrorBar(x, usv_rate(M,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'blue', 'DisplayName', 'Male'})
shadedErrorBar(x, usv_rate(~M,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', 'Female'})
xlabel("Time (minutes)")
ylabel("USV Rate (Hz)")
legend()

%%%%%%%%%%%%%%% LICK STUFF NEEDS ACCESS TO MED FILES %%%%%%%%%%%%%%%%%%%%%
%% Load the med structs into the table
% go back up to find med-pc folder in datastar and then parses them out 
for i=1:height(t)
    t.med_struct{i} = getMedFile(t.session_path{i}, t.subject{i});
end

% For now just drop any rows that couldn't load the med data
t = t(~cellfun(@isempty, t.med_struct), :);

%% Bin Licks
% Defaults to same bin edges as used for USVs
lick_rate_l = nan(height(t), length(edges)-1);
lick_rate_r = nan(height(t), length(edges)-1);
for i=1:height(t)
    med = t.med_struct{i};
    if ~isempty(med.E)
        lick_rate_l(i,:) = histcounts(med.E, edges) / tdif;
    end
    if ~isempty(med.F)
        lick_rate_r(i,:) = histcounts(med.F, edges) / tdif;
    end
end
all_licks = cat(1, lick_rate_l, lick_rate_r);
%% usv rate vs licks
% find functions that use the ridges for time and frequency of squeaks
figure(1); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
shadedErrorBar(x, usv_rate, {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', 'USVs'})
shadedErrorBar(x, all_licks, {avg_nan, sem}, 'lineProps',{ 'Color', 'blue','DisplayName', 'Licks'})
xlabel("Time (minutes)")
ylabel("Rate (Hz)")
legend()

%% usv frequency vs licks
figure(11); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
yyaxis left
shadedErrorBar(x, usv_freq/1000, {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', 'USVs'})
ax = gca;
ax.YColor = 'green';
ylabel("USV frequency (kHz)")
yyaxis right
shadedErrorBar(x, all_licks, {avg_nan, sem}, 'lineProps',{ 'Color', 'blue','DisplayName', 'Licks'})
ax = gca;
ax.YColor = 'blue';
ylabel("Lick rate (Hz)")
xlabel("Time (minutes)")

legend()


%%
function tf = isInRange(x, lowerBound, upperBound)
    tf = (x >= lowerBound) & (x <= upperBound);
end

function counts = callNumber(callColumn)
    counts = [];
    for i = 1:size(callColumn)
        counts = [counts; size(callColumn{i},1)];
    end 
end 

function med_struct = getMedFile(session_path,subject_str)
    medDir = getMedDir(session_path);
    file_names = string({dir(medDir).name})';
    sub_parts = extractBefore(extractAfter(file_names, 'Subject'), '.txt'); %Annoyingly, extractBetween errors when some don't match pattern 
    subject_str =  split(subject_str, '_');
    subject_str = strip(subject_str, "left", "0");
    
    correct = true(size(file_names));
    for i=1:length(subject_str)
        correct = correct & contains(sub_parts, subject_str{i});
    end
    if sum(correct)==1
        med_path = fullfile(medDir, file_names(correct));
        med_struct = importMA(med_path, remove_trailing_zeros=true);
    elseif sum(correct)>1
        warning("too many matches for %s", session_path)
        med_struct = [];
    elseif sum(correct)==0
        warning("no matches for %s", session_path)
        med_struct = [];
    end    
end
function medDir = getMedDir(session_path)
    root = nthParent(session_path,3);
    med_folder = dir(fullfile(root, "med-pc*")).name;
    medDir = fullfile(root, med_folder);
end

function parent = nthParent(path, N) 
    parent = fileparts(path);
    if N>1
        parent = nthParent(parent, N-1);
    end
    % Wow. a legitimate use of recursion.
end


% \ *************************** Variables *************************
% \ A = Number of left licks.
% \ B = Number of right licks.
% \ C = Record of whether the left sipper has been tripped enough
% \     times (0 = No, 1 = Yes).
% \ D = Record of whether the right sipper has been tripped enough
% \     times (0 = No, 1 = Yes).
% \ E = List of left lick times in seconds.
% \ F = List of right lick times in seconds.
% \ G = Total number of licks
% \ H = Array for PiSync ON times
% \ I = Pi sync signal counter
% \ J = List of Beam State Transition Counters
% \ K = PiSync ON time in ms
% \ L = Array for PiSync OFF times
% \ P = List of Beam 1 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ Q = List of Beam 2 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ R = List of Beam 3 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ S = List of Beam 4 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ U = List of Beam 5 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ V = List of Beam 6 Break Times (-1, -1, followed by alternating Break and Unbreak transitions starting with an break transition)
% \ T = Time in Seconds
