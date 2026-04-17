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

group1 = ratsInfo.treatment == "EtOH" & ratsInfo.strain == "P" & ratsInfo.sex == "F";
%group2 = ratsInfo.drinkClass == "Medium";
%group3 = ratsInfo.drinkClass == "Low" & ratsInfo.sex == "F"
group4 = ratsInfo.treatment == "Control" & ratsInfo.strain == "P" & ratsInfo.sex == "F";
%create a vector of indifference points. average of the last two days for each rat
for i = 1:numel(delays)
    delayEnd = (i*4);
    days = [(delayEnd-1) (delayEnd)]; %variable column location of last 2 days for each delay

    % -- Pull out mean of last 10 DD iVals -- %
    %indifference_points = [indifference_points iVals_delays]; %creates a matrix with each column containing the average of the last two days of each delay

    % -- Pull out mean of all choice trial iVals -- %
    iVals_delays1 = mean(cat(3, allDDiVals{days(1)}(group1,:), allDDiVals{days(2)}(group1, :)),3, 'omitnan'); %pull the last two columns of each delay out and find the mean
    %iVals_delays2 = mean(cat(3, allDDiVals{days(1)}(group2,:), allDDiVals{days(2)}(group2, :)),3, 'omitnan');
    %iVals_delays3 = mean(cat(3, allDDiVals{days(1)}(group3,:), allDDiVals{days(2)}(group3, :)),3, 'omitnan');
    iVals_delays4 = mean(cat(3, allDDiVals{days(1)}(group4,:), allDDiVals{days(2)}(group4, :)),3,'omitnan');

    plotLPError(trials, iVals_delays1, "mean", 'Color', 'red')
    hold on;
    %plotLPError(trials, iVals_delays2, "mean", 'Color', [1, 0.5, 0])
    %plotLPError(trials, iVals_delays3, "mean", 'Color', 'yellow')
    plotLPError(trials, iVals_delays4, "mean", 'Color', 'blue')
    ylim([0 6])
    title(['Delay' num2str(delays(i)) ' Wistar High/Low F']);
    legend('Drinkers', 'Control', 'Location','southwest')
    hold off;
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

%% Graphing iVals Across Trials for ROT %%
% graphs the mean of each trial for each group with error bars
% input variables: ratsInfo, 5 days of ROT

%create new figure
fig1 = tiledlayout(1,5);

%groups to graph together. CHANGE as NEEDED
group1 = ratsInfo.strain == "Wistar" & ratsInfo.sex == "M" & ratsInfo.treatment == "Control"% & (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium");
group2 = ratsInfo.strain == "P" & ratsInfo.sex == "M" & ratsInfo.treatment == "Control"; %& (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium");M%group3 = ratsInfo.strain == "Wistar" & ratsInfo.sex == "M" & ratsInfo.treatment == "EtOH" & (ratsInfo.drinkClass == "Low");

%variable to hold the data you are graphing. data should be formatted as a
%cell with each cell holding all the information for that day 
data = all_output;

trials = 1:30;

%ROT days in the allDDiVals variable. Week after the scent weeks
days = [1:5]
%for loop that goes through 
for i = 1:numel(days);
    
    %plot the groups 
    %nexttile
    hold on;
    M = plot(trials,  calc_choiceProbability(data{i}(group1,:)), 'o-', 'Color', 'blue');
    WC = plot(trials, calc_choiceProbability(data{i}(group2,:)), 'x-', 'Color', 'red');
    %P = plot(trials, calc_choiceProbability(data{i}(group3,:)), 'x-', 'Color', 'black');
    if i == 3 | i == 5
        xline(10);
        xline(15);
    end 
    legend("wistar", "P");
    title("ROT day1, males");
    ylabel("% Immediate Trials");
    ylim([0 1]);
    hold off; 
    close(gcf)
end;

%add specifying information for the whole graph 
fig1.Title.String = "Wistar Female ROT, Includes high/low EtOH group";
fig1.YLabel.String = "iValue";
fig1.XLabel.String = "Trials";
lgd = legend("Control", "EtOH Drinkers", "EtOH NonDrinkers"); 

%% Plotting combined ROT Data across trials %%
% Combining ROT data from wednesday and friday into one and graph the
% combined data across trials 
% inputs needed: choice lever choices for only choice trials on the full week of ROT, ratsInfo 

data = all_output;

%groups of interest. Change the number of groups as needed 
group1 = ratsInfo.strain == "P" & ratsInfo.sex == "F" & ratsInfo.treatment == "Control"; %& (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium");
group2 = ratsInfo.strain == "P" & ratsInfo.sex == "F" & ratsInfo.treatment == "EtOH" %& (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium");


%concatenate data on top of each other 
dayBefore_data1 = org_ROTdata(data, group1, [1:2]);
ROT_data1 = org_ROTdata(data, group1, [3 5]);

dayBefore_data2 = org_ROTdata(data, group2, [1:2]);
ROT_data2 = org_ROTdata(data, group2, [3 5]);

%calculate the mean and SEM
[percentImmediate1, group1_binomalMean, group1_SEM, n1] = calc_choiceProbability(ROT_data1);
[percentImmediate2, group2_binomalMean, group2_SEM, n2] = calc_choiceProbability(ROT_data2);

chiSquareResults = [];

%Calculate the chi-square probability comparison
for i = 1:numel(percentImmediate1)
    [h,p, chi2stat,df] = prop_test([group1_binomalMean(i) group2_binomalMean(i)], [n1(i) n2(i)], true);
    % Store the chi-square results for each day
    chiSquareResults(i, :) = [h, p, chi2stat, df];
end 

sig_difference = find(chiSquareResults(:,1));

%Pull out the areas where there is a significant difference 

%plot with errorbars 
g1 = errorbar(percentImmediate1, group1_SEM, 'x-', 'Color', 'blue');
hold on 

g2 = errorbar(percentImmediate2, group2_SEM, 'o-', 'Color', 'red');

plot(sig_difference,zeros(numel(sig_difference)), 'r*')
xline([10 15])
ylabel("Binomal Mean of Immediate Choices")
xlabel("Trials")
title("ROT immediate choices across trials, ROT days, wistar females, chi-square differences between groups")
legend("Control", "EtOH");
hold off 






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