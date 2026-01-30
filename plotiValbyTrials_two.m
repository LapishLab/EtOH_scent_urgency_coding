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
% calculates mean with error bars across all trials. Mean of the last 2
% days of testing. separate graph for each error 

%create tiled layout to hold all the graphs
fig1 = tiledlayout(1,6)

%specify what data variable you are using 
data = allDDiVals
%for loop that creates a graph of the average iValue across trials for each
%delay. Concatenates days of data on top of each other depending on what
%you specify
for i = 1:length(delays);
    %the column number of the last day for each delay
    delayEnd = (i*4);
    %pull out the four days of data for each delay 
    chunkData = allDDiVals(delayEnd-3:delayEnd);
    %specify which days you want to concatenate on top of each other
    days = [3:4];
    %specify the groups that you want to graph
    group1 = ratsInfo.treatment == "Control" & ratsInfo.strain == "Wistar"
    group2 = ratsInfo.treatment == "EtOH" & ratsInfo.strain == "Wistar"
    group3 = ratsInfo.treatment == "Control" & ratsInfo.strain == "P"
    group4 = ratsInfo.treatment == "EtOH" & ratsInfo.strain == "P"
    %concatenate the data on top of each other for all the days of interest
    %and for each group
    group1Data = concatenateData(chunkData,days,group1);
    group2Data = concatenateData(chunkData,days,group2);
    group3Data = concatenateData(chunkData,days,group3);
    group4Data = concatenateData(chunkData,days,group4);
    %start the next graph for each delay day
    nexttile
    %plot the mean iValue across trials for each delay. Copy and paste
    %extra lines as needed 
    FD = plotLPError(trials, group1Data, "mn");
    hold on;
    FND = plotLPError(trials, group2Data, "mn");
    FH2O = plotLPError(trials, group3Data, "mn");
    FH2O = plotLPError(trials, group4Data, "mn");

    % add extra labeling information
    title(['Delay ' num2str(delays(i))]);
    ylim([0 6]);
end;     

%add specifying information for the graph that stretches across all plots
fig1.Title.String = "DD for Male Rats Across Trials";
fig1.YLabel.String = "iValue";
fig1.XLabel.String = "Trials";
lgd = legend("EtOH", "H2O");


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

days = [16:17];

fig1 = tiledlayout(1,2)

data = allDDiVals;

%create a for loop that cycles through each day 
for day = days(1):days(end)
    %CHANGE these groups to whatever you want to graph
    group1 = data{day}(ratsInfo.Sex == "F" & ratsInfo.Trtm == "EtOH",:);
    %group2 = allDDiVals{day}(ratsInfo.Sex == "F" & ratsInfo.Trtm == "EtOH" & ratsInfo.DNDClass == "NonDrinker", :);
    group3 = data{day}(ratsInfo.Sex == "F" & ratsInfo.Trtm == "Control",:);
    titleName = ['Day' num2str(day)];
    nexttile;
    %plot the groups together on the graph
    hold on;
    fD = plotLPError(trials, group1, 'mn', 'o-', 'Color', 'red');
    %fND = plotLPError(trials, group2, "Mn", 'o-', 'Color', 'magenta');
    fH2O = plotLPError(trials, group3, "mn", 'o-', 'Color', 'blue');
    ylim([0 6]);
    title(titleName);
    hold off; 
end; 

%label the graph 
fig1.Title.String = "Male Baseline Prefeeding Week DD";
fig1.YLabel.String = "iValue";
fig1.XLabel.String = "Trials";
lgd = legend("EtOH", "Control");
hold off; 

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