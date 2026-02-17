%% Graphing iValues Across Trials for Baseline Impulsivity Curve 
% this produces a plot of the mean iValue across for each trial. One plot
% for each delay. Lines are split by groups that are specified below. 
%inputs: 
    % allDDiVals: contains the choice trails for each rat on each testing
    % day throughout all delays
    % ratsInfo
%output:
    % 


%create a variable for delays 
delays = [0 1 2 4 8 16];
%create vector with the number of trials 
trials = [1:30];

%% Graphing mean iValues across trials for all rats
% calculates mean with error bars across all trials.
% can describe specific groups that you want to look at 
% can choose which days you want to assess 

%initialize variables
indifference_points = []

%delay vector
delays = [0 1 2 4 8 16];

%create a vector of indifference points. average of the last two days for each rat
for i = 1:numel(delays)
    delayEnd = (i*4)
    days = 
    %days = [(delayEnd-1) (delayEnd)]; %variable column location of last 2 days for each delay
    iVals_delays =  %pull the last two columns of each delay out and find the mean
    indifference_points = [indifference_points iVals_delays]; %creates a matrix with each column containing the average of the last two days of each delay
end


%% Graphing organized DD8 testing week data 
% creates a graph for each day of DD8 on testing week with the scents.
% Plots ivalue across trials with the center point being the mean and error
% bars

%specify group conditions that you want to look at across all the rats.
%Will reorganize testing week data in the orgTWkiValsTrls function 
%CHANGE this to change the graphs 
%Repeat this section for as many groups as you want across the graphs
% day 3 and day 8 are CS+ and day 5 and day 10 are CS-
group1 = ratsInfo.Trtm == "Control" & ratsInfo.Sex == "M" & ratsInfo.DD_ScentTestGroup == 1;
group2 = ratsInfo.Trtm == "Control" & ratsInfo.Sex == "M" & ratsInfo.DD_ScentTestGroup == 2;

cond1 = orgTWkiValsTrls(group1, group2, allDDiVals);

%etoh scent

group1 = ratsInfo.Trtm == "EtOH" & ratsInfo.Sex == "M" & ratsInfo.DD_ScentTestGroup == 1;
group2 = ratsInfo.Trtm == "EtOH" & ratsInfo.Sex == "M" & ratsInfo.DD_ScentTestGroup == 2;

cond2 = orgTWkiValsTrls(group1, group2, allDDiVals);

%control scent 

group1 = ratsInfo.Trtm == "EtOH" & ratsInfo.Sex == "M" & ratsInfo.DD_ScentTestGroup == 2;
group2 = ratsInfo.Trtm == "EtOH" & ratsInfo.Sex == "M" & ratsInfo.DD_ScentTestGroup == 1;

cond3 = orgTWkiValsTrls(group1, group2, allDDiVals);



%days of testing week (2 weeks)
days = [1:10];
%new figure for all of the delay discounting data across the testing week 
fig2 = tiledlayout(1, 10);


% for loop that graphs the data for each delay discounting day of the two
% testing weeks
for i = 1:length(days)
    %find the organized data for each group (criteria of grouping set above) for each day 
    group1 = cond1
    group2 = cond2{i}
    %plot the rats of interest across trials
    nexttile
    hold on
    plotLPError(trials, group1, "mn", 'Color', 'blue');
    plotLPError(trials, group2, "mn", 'Color', 'red');
    title(['Day ' num2str(i)]);
    ylim([0 6]);
end;

%add specifying information for the whole graph 
fig2.Title.String = "Testing Wks Females: Delay Discounting Split by Loading Type";
fig2.YLabel.String = "iValue";
fig2.XLabel.String = "Trials";
lgd = legend("H2O", "Frontloader", "NonLoaders")
hold off; 

%% Graphing iVals Across Trials for ROT
% graphs the mean of each trial for each group with error bars
% input variables: TallDDiVals, ratsInfo

%create new figure
fig1 = tiledlayout(1,5)

group1_index = ratsInfo.Sex == "F" & ratsInfo.Trtm == "EtOH"
group3_index = ratsInfo.Sex == "F" & ratsInfo.Trtm == "Control"
group1= {};
group1_ratIDs = [];
group2 = {};
group3 = {};
group3_ratIDs = [];

%ROT days in the allDDiVals variable. Week after the scent weeks
days = [11:15]
%for loop that goes through 
for i = 1:length(days);
    %grouped animals for the graphing. Change as needed
    group1{i} = allDDiVals{days(i)}(group1_index, :); % & ratsInfo.Trtm == "EtOH", :);
    group1_ratIDs = [group1_ratIDs ratsInfo.ratID(group1_index)]; % & ratsInfo.Trtm == "EtOH")]
    %group2{i} = allDDiVals{days(i)}(ratsInfo.Sex == "M" & ratsInfo.Trtm == "EtOH", :);
    group3{i} = allDDiVals{days(i)}(group3_index, :); % & ratsInfo.Trtm == "EtOH", :);
    group3_ratIDs = [group3_ratIDs ratsInfo.ratID(group3_index)]

    %plot the groups 
    nexttile
    hold on;
    M = plotLPError(trials, group1{i}, "mn", 'o-', 'Color', 'red');
    %F = plotLPError(trials, group2{i}, "mn", 'x-', 'Color', 'magenta')
    WC = plotLPError(trials, group3{i}, "mn", 'x-', 'Color', 'blue');
    ylim([0 6]);
    hold off; 
end;

%add specifying information for the whole graph 
fig1.Title.String = "Male ROT";
fig1.YLabel.String = "iValue";
fig1.XLabel.String = "Trials";
lgd = legend("EtOH", "Control "); 

close(gcf)


%get data for prism graphing 

baseline_males = nanmean(cat(3, group1{1}, group1{2}), 3);
baseline_females = nanmean(cat(3, group3{1}, group3{2}), 3);
ROT_males = nanmean(cat(3, group1{3}, group1{5}), 3);
ROT_females = nanmean(cat(3, group3{3}, group1{5}), 3);

fig2 = tiledlayout(1,2)
nexttile
plotLPError(trials, baseline_males, "mn", 'o-', 'Color', 'blue');
hold on;
plotLPError(trials, baseline_females, "mn", 'o-', 'Color', 'red');
ylim([0 6]);
title("ROT Male Baseline");
legend(["EtOH" "Control"]);
hold off; 

nexttile
plotLPError(trials, ROT_males, "mn", 'o-', 'Color', 'red');
hold on;
plotLPError(trials, ROT_females, "mn", 'o-', 'Color', 'blue');
ylim([0 6])
title("ROT Male Testing")
legend(["EtOH" "Control"])
hold off; 


%% Plot IValue Across trials per Day 
% rather than taking an average of the last two days, plot the variation in
% ivalue per trial for the different groups for each day
% inputs: ratsInfo, allDDiVals 

%specific rat information 
ratsInfo = ratsInfo(ratsInfo.strain == "Wistar", :)

dayNumbers = [1:6];

%fig1 = tiledlayout(1,2);

data = w_allDDiVals;

%create a for loop that cycles through each day 
for day = 1:numel(dayNumbers)
    fig1 = figure()
    %CHANGE these groups to whatever you want to graph
    group1 = data{day}(ratsInfo.strain == "Wistar" & ratsInfo.sex == "F" & ratsInfo.treatment == "Control",:);
    %group2 = allDDiVals{day}(ratsInfo.Sex == "F" & ratsInfo.Trtm == "EtOH" & ratsInfo.DNDClass == "NonDrinker", :);
    group3 = data{day}(ratsInfo.strain =="Wistar" & ratsInfo.sex == "F" & ratsInfo.treatment == "EtOH",:);
    titleName = ['Wistar-Females-Day' num2str(day)]; %CHANGE this
    %nexttile;
    %plot the groups together on the graph
    hold on;
    fD = plotLPError(trials, group1, 'mn', 'o-', 'Color', 'blue');
    %fND = plotLPError(trials, group2, "Mn", 'o-', 'Color', 'magenta');
    fH2O = plotLPError(trials, group3, "mn", 'o-', 'Color', 'red');
    ylim([0 6]);
    legend("Water", "EtOH")
    title(titleName);
    hold off; 
    %path = 'C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\graphs\dailyDD';
    path = 'C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\graphs\dailyDD\DD0_learning'
    filename = fullfile(path, [titleName '.png']);
    saveas(gcf, filename);
end; 
% 
% %label the graph 
% fig1.Title.String = "Male Baseline Prefeeding Week DD";
% fig1.YLabel.String = "iValue";
% fig1.XLabel.String = "Trials";
% lgd = legend("EtOH", "Control");
% hold off; 

%% Plot iValue across all DD Days
%creates a graph for ivalue across trials for each day and saves each
%daily graph to a specific location. 

days = [1:24]

pat= "C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\052224_11425ScentEtOHCohort\Codes\ScentEtOH_FinalAnalysis\graphs\DD\DailyDD"
data = allDDiVals
for day = 1:length(days);
    group1 = data{day}(ratsInfo.Sex == "F" & ratsInfo.Trtm == "EtOH",:);
    group2 = data{day}(ratsInfo.Sex == "F" & ratsInfo.Trtm == "H2O", :);
    fig1 = figure()
    etoHF = plotLPError(trials, group1, 'mn', '-o', 'Color', 'red')
    hold on; 
    h2oF = plotLPError(trials,group2, 'mn', 'x-', 'Color', 'blue')
    ylim([0 6]);
    legend("EtOH", "Water");
    title(['F day' num2str(days(day))]);
    xlabel("Trials");
    ylabel("iValue");
    filename = fullfile(pat, ['combF_day' num2str(days(day)) '.jpg'])
    exportgraphics(gcf, filename); 
end