% This script requires https://github.com/raacampbell/shadedErrorBar
%first import USV data 

%% Fix DD Subjects

%scent week 
day = "20251106";
old_subject = 97;
new_subject = 67;
ind_group = 1;
t = fix_DD_subjects(t, day, ind_group, old_subject, new_subject);

day = "20251107";
old_subject = 86;
new_subject = 59;
ind_group = 3;
t = fix_DD_subjects(t, day, ind_group, old_subject, new_subject);

day = "20251114";
old_subject = 95;
new_subject = 98;
ind_group = 4;
t = fix_DD_subjects(t, day, ind_group, old_subject, new_subject);

day = "20241022";
old_subject = 12;
new_subject = 15;
ind_group = 3;
t = fix_DD_subjects(t, day, ind_group, old_subject, new_subject);

%% Frequency Thresholds %%

%DD thresholds 
DD_threshold_happy = 46 * 1000;
DD_threshold_sad = 30 * 1000;

% DD thresholds
thresholds = {[0 DD_threshold_sad], [DD_threshold_sad DD_threshold_happy], [DD_threshold_happy 100*1000]};
threshold_names = ["usv_rate_low", "usv_rate_middle", "usv_rate_high"];

DD_sessionTime = -1*60:10:22*60; 



%% File Time Cutoff %% 
 
DD_sessionTime = -1*60:10:22*60;

%% DD: Remove Noise USVs 
DD_removeUSV = [43*1000 45*1000;35*1000 36*1000];

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

%% Bin average USV rate and frequency

%amount of the file to include. Based on audio offset time calculated for
%the files 
edges = DD_sessionTime; 
tdif = diff(edges(1:2));

%CHANGE THIS!! usv rate bins 
thresholds = {[0 DD_threshold_sad], [DD_threshold_happy 100*1000]};

usv_rate = {};
usv_freq = usv_rate;
% get rates across multiple bins 
for a = 1:numel(thresholds)
    %prealocate size of variable to hold USV rates
    %usv_rate{a} = nan(height(t), length(edges)-1);
    usv_rate{a} = {};

    for i=1:height(t)
        % --- get usv rate --- %
        calls = t.calls{i};
        %if you want to keep only USVs of a certain frequency 
        meets_threshold = isInRange(calls.frequency, thresholds{a}(1), thresholds{a}(2));

        % find mean of all the time points of each pixel in a squeak 
        call_times = cellfun(@mean, calls.ridge_time(meets_threshold));
        % number of USV counts in each time bin / total time = percentage of
        % total squeaks in the file in each time bin
        bin_counts = histcounts(call_times, edges);
        usv_rate{a}{i} = histcounts(call_times, edges) / tdif;

        % % --- get usv frequency --- %
        % % find mean frequency of each pixel of a squeak, in Hz not KHz
        % call_freq = cellfun(@mean, calls.ridge_frequency(meets_threshold));
        % % find which time bins have calls in them. Tin bins without calls
        % % (should be mainly those at the start and end) are labeled as NaNs
        % binIndices = discretize(call_times, edges);
        % outside_edges = isnan(binIndices);
        % %keep only the data that is in time bins where calls are present
        % call_freq = call_freq(~outside_edges);
        % binIndices=binIndices(~outside_edges);
        %
        % %find average squeak frequency in each time bin
        % sz = [length(edges)-1, 1];
        % avg =  @(x) mean(x, 'omitnan');
        % usv_freq(i,:) = accumarray(binIndices, call_freq, sz, avg, NaN);
    end
end 


sem = @(x) std(x, 'omitnan')/sqrt(sum(~isnan(x(:,1))));
avg_nan = @(x) mean(x, 'omitnan');


%% Grouping: ROT
ROT_wistar = ["20241028" "20241029" "20241030" "20241031" "20241101"];
ROT_P = ["20251117" "20251118" "20251119" "20251120" "20251121"];

ROT_days_1 = ismember(string(t.date), [ROT_wistar([3]) ROT_P([3])]);
ROT_days_2 = ismember(string(t.date), [ROT_wistar([5]) ROT_P([5])]);
ROT_baseline_1 = ismember(string(t.date), [ROT_wistar([1]) ROT_P([1])]);
ROT_baseline_2 = ismember(string(t.date), [ROT_wistar([2]) ROT_P([2])]);

%% Grouping: strains and sex %% 
Ps = contains(t.strain, "P");
wistars = contains(t.strain, "Wistar");
males =  contains(t.sex, "M");
females = contains(t.sex, "F");
pairs = contains(t.treatment, '_');


%% Grouping: EtOH vs Control
EtOH = contains(t.treatment, "EtOH");
H2O = contains(t.treatment, "Control");

%% Grouping: DD baseline 
scentDays_wistar = ["20241016" "20241018" "20241023" "20241025"];
scentDays_P = ["20251105" "20251107" "20251112" "20251114"];

baseline = (ismember(string(t.date), ["20251104", "20251103", "20241015", "20241014"]));
control_scentDays = contains(t.treatment, "Control") & ismember(string(t.date), [scentDays_wistar scentDays_P]);



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

all_EtOH_scent = (firstDay_EtOH_scent | secondDay_EtOH_scent | thirdDay_EtOH_scent | fourthDay_EtOH_scent);
all_water_scent = (firstDay_water_scent | secondDay_water_scent | thirdDay_water_scent | fourthDay_water_scent);

%% Grouping: Final Analysis %%

group1 = wistars & males & baseline;
group2 = wistars & females & baseline;
group3 = Ps & males & baseline;
group4 = Ps & females & baseline;

%% USV frequency Histogram %%


group1 = t.sex == t.sex
close(gcf)
groups = {group1};
%collect all the USVs frequencies 
all_freq = [];

%look through each row in the table. Pull out the frequencies for all the
%calls within a certain time range. 
for i = 1:numel(groups)
    %only pull out calls for each group
    specific_table = t(groups{i},:);
    %only pull out calls in a certain time range
    for m = 1:height(specific_table)
        calls = specific_table.calls{m};
        calls_inTimeRange = isInRange(calls.Box(:,1), RAP_sessionTime(1), RAP_sessionTime(end));
        specific_table.calls(m) = {calls(calls_inTimeRange, :)};
    end
    all_calls = [];
    %concatenate all call frequencies on top of each other
    all_calls = cellfun(@(t)t.frequency, specific_table.calls, UniformOutput=false);
    %convert to kHz
    all_frequency = vertcat(all_calls{:});

    % [x, f] = ksdensity(all_frequency);
    % plot(f, x)
    % hold on

    %calls_inFrequency = isInRange(calls.frequency, 0, sad_threshold);
end 

histogram(all_frequency/1000, FaceColor=[0.3 0.3 0.3], BinWidth = 1)
%legend("Control", "EtOH");
title("DD USV Frequency Histogram", FontSize=20, FontName='Arial',FontWeight="Bold")
xline([30, 46])
xlabel("Frequency (kHz)", FontSize=16, FontName='Arial', FontWeight="Bold")
ylabel("Counts", FontSize=16, FontName='Arial', FontWeight="Bold")
ax = gca
ax.FontSize=30

xlim([20 100])
% histogram(all_freq, 'BinWidth', 1)
% hold on 
% title("RAP USV frequency spread P males single")
% xlabel("Frequency (kHz)")
% ylim([0 800])
%xline([34, 52])
% %hold off

%sad cutoff: 38 kHz
%happy start: 46 kHz
%% Counts in Frequency Bins %%

freq_range = {[0 34], [34 52], [52 100]};

data = {};
for i = 1:numel(freq_range)
    data{i} = calc_freqBins(t(group1, :), freq_range{i});
    [x, f] = ksdensity(data{i}.frequency);
    plot(x, f, LineWidth=2)
end 

%% USV Counts Graphing 

groups = {group1, group2, group3, group4, group5, group6, group7, group8};
group_data = {};
jitterAmount = 0.5;

%set some time threshold to keep calls within a certain time frame 
time_frame = [-60 0];

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
        keep = isInRange(call_times, RAP_sessionTime(1), RAP_sessionTime(end));
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
%ylim([0 1000])
xticklabels({"Wistar M", "Wistar F", "P M", "P F"})
ylabel("USV counts")
title("Sex and strain differences in anticipatory USVs")


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

close(gcf)
figure(1); clf; hold on;
x = (edges(1:end-1)+diff(edges)/2) / 60;
shadedErrorBar(x, usv_rate(group1,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', 'Baseline (monday)'})
shadedErrorBar(x, usv_rate(group2,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'red', 'DisplayName', 'Baseline (tuesday)'})
shadedErrorBar(x, usv_rate(group3, :), {avg_nan, sem}, 'lineProps',{ 'Color', 'blue', 'DisplayName', 'ROT day (wednesday)'})
shadedErrorBar(x, usv_rate(group4,:), {avg_nan, sem}, 'lineProps',{ 'Color', 'black', 'DisplayName', 'ROT day (Friday)'})
xlabel("Time (minutes)")
ylabel("USV Rate (Hz)")
title("DD ROT, P males")
ylim([0 0.9])
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

%% USV frequency swarmchart %%

close(gcf)
groups = {group10,group11,group12};

for i = 1:numel(groups)
    %pull out all the frequency and time stamps for each group 
    %all the calls for each animal in the group
    grouped_calls = t.calls(groups{i});
    %cycle through each animal and pull out the call times and associated
    %frequency. Concatenate all the animals on top of each other. 
    time_frequency_calls = [];
    for m = 1:height(grouped_calls)
        %find calls within the time range of RAP
        tf = isInRange(grouped_calls{m}.Box(:, 1), DD_sessionTime(1), DD_sessionTime(end));
        time_frequency_calls = [time_frequency_calls; [grouped_calls{m}.Box(tf, 1) grouped_calls{m}.frequency(tf, 1)]];
    end 
    %plot the time and call frequency on a swarmchart
    swarmchart(time_frequency_calls(:,1), (time_frequency_calls(:,2)/1000));
    ylim([0 90])
    hold on
end 

legend("Control", "EtOH", "H2O");
ylabel("Frequency (kHz)")
xlabel("Time")
title("P Females DD Scent Days")


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
