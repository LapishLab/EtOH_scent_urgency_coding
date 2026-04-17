%% Graphing iVals Across Trials for ROT %%
% graphs the mean of each trial for each group with error bars
% input variables: ratsInfo, 5 days of ROT

%create new figure
fig1 = tiledlayout(1,5);

%groups to graph together. CHANGE as NEEDED
group1 = ratsInfo.strain == "Wistar" & ratsInfo.sex == "M" & ratsInfo.treatment == "EtOH" & (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium");
group2 = ratsInfo.strain == "P" & ratsInfo.sex == "M" & ratsInfo.treatment == "EtOH"; %& (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium");M%group3 = ratsInfo.strain == "Wistar" & ratsInfo.sex == "M" & ratsInfo.treatment == "EtOH" & (ratsInfo.drinkClass == "Low");

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
group1 = ratsInfo.strain == "Wistar" & ratsInfo.treatment == "EtOH" & (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium");
group2 = ratsInfo.strain == "P" & ratsInfo.treatment == "EtOH"; %& (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium");


%concatenate data on top of each other 
dayBefore_data1 = org_ROTdata(data, group1, [1:2]);
ROT_data1 = org_ROTdata(data, group1, [3 5]);

dayBefore_data2 = org_ROTdata(data, group2, [1:2]);
ROT_data2 = org_ROTdata(data, group2, [3 5]);

%calculate the mean and SEM
[percentImmediate1, group1_binomalMean, group1_SEM, n1] = calc_choiceProbability(dayBefore_data1);
[percentImmediate2, group2_binomalMean, group2_SEM, n2] = calc_choiceProbability(dayBefore_data2);

%Calculate the chi-square probability comparison
for i = 1:numel(percentImmediate1)
    [h,p, chi2stat,df] = prop_test([group1_binomalMean(i) group2_binomalMean(i)], [n1(i) n2(i)], true);
    % Store the chi-square results for each day
    chiSquareResults(i, :) = [h, p, chi2stat, df];
end 

sig_difference = find(chiSquareResults(:,1));

%Pull out the areas where there is a significant difference 

%plot with errorbars 
g1 = errorbar(group1_binomalMean, group1_SEM, 'x-', 'Color', 'blue');
hold on 

g2 = errorbar(group2_binomalMean, group2_SEM, 'o-', 'Color', 'red');

plot(sig_difference,zeros(numel(sig_difference)), 'r*')
%xline([10 15])
ylabel("Binomal Mean of Immediate Choices")
xlabel("Trials")
title("ROT immediate choices across trials, 2days before, chi-square differences between groups")
legend("Wistar", "P");
hold off 
