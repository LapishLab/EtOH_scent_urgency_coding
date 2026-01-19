%% Creating Graphs of RAP Data
% this code graphs RAP consumption in different ways. Separate sections
% will show specifics



%% Correlation Check with Licks and Consumption %%
days = [1 3 5 6 8 10 11 13]

group1 = ratsInfo.strain == "Wistar" & ratsInfo.treatment == "EtOH" & ratsInfo.sex == "M"
group2 = ratsInfo.strain == "Wistar" & ratsInfo.treatment == "EtOH"
group3 = ratsInfo.strain == "P" & ratsInfo.treatment == "Control"
group4 = ratsInfo.strain == "P" & ratsInfo.treatment == "EtOH"

%graph
w = scatter(RAP_totalLicks(group2,days), table2array(RAP_all(group2, days)),36, 'r', 'filled')
hold on;
p = scatter(RAP_totalLicks(group4,days), table2array(RAP_all(group4, days)),36, 'k', 'filled')
title("EtOH Consumers")
legend([w(1) p(1)], {"Wistars","Ps"})
xlabel("Licks")
ylabel("g/kg Consumption")
hold off; 

%% Acute deprivation affect %% 

%groups to assess 
group1 = ratsInfo.strain == "Wistar" & ratsInfo.treatment == "EtOH" & ratsInfo.sex == "M"
group2 = ratsInfo.strain == "Wistar" & ratsInfo.treatment == "EtOH" %& ratsInfo.sex == "F"
group3 = ratsInfo.strain == "P" & ratsInfo.treatment == "EtOH" & ratsInfo.sex == "M"
group4 = ratsInfo.strain == "P" & ratsInfo.treatment == "EtOH" %& ratsInfo.sex == "F"

monday = mean(table2array(RAP_all(:, [1 6])), 1)
friday = [5;10]
% Look at week by week effects
m = scatter(table2array(RAP_all(group2,friday)), table2array(RAP_all(group2, monday)), 'r', 'filled')
hold on; 
p = scatter(table2array(RAP_all(group4,friday)), table2array(RAP_all(group4, monday)), 'k', 'filled')
xlabel("Friday Consumption (g/kg)")
ylabel("Monday Consumption (g/kg)")
legend([w(1) p(1)], {"Wistars","Ps"})
title("Acute Deprivation Effect RAP")
xlim([0 3])
ylim([0 3])
hold off; 

% look at week averages

%% Calculate consumption per lick 

%calculate consumption per lick for all data
cons_lick = table2array(RAP_all) ./ RAP_totalLicks;

%groups
group = ratsInfo.strain == "P" & ratsInfo.treatment == "EtOH" & ratsInfo.sex == "F";

%convert any infinity values to NaNs 
%some values were divide by zero because lick measurer was faulty 
cons_lick(isinf(cons_lick)) = NaN

%find data for the specific group on ethanol days
etoh_cons_lick = cons_lick(group, [5 10]);

%find data for the specific group on water days
h2o_cons_lick = cons_lick(group, [2 4 7 9]);

%find the mean across rows/subjects
mn_cons_lick = mean(etoh_cons_lick, 2, 'omitnan');

%% Line Plot of Consumption Across days %%
% can be z-scored

%specify data to graph. If using consumption, you have to convert the table
%to an array
data = RAP_totalLicks;
days = [1:14];

%choose which groups to graph together by finding index in ratsInfo
group1 = data((ratsInfo.strain == "P" & ratsInfo.treatment == "Control" & ratsInfo.sex == "M"),:);
group2 = data((ratsInfo.strain == "P" & ratsInfo.treatment == "Control" & ratsInfo.sex == "F"),:);
group3 = data((ratsInfo.strain == "P" & ratsInfo.treatment == "EtOH" & ratsInfo.sex == "M"), :);
group4 = data((ratsInfo.strain == "P" & ratsInfo.treatment == "EtOH" & ratsInfo.sex == "F"), :);

%create the line plot
fig1 = figure()
f = plotZscLPError(days, group1(:, days), "mean", 'o-');
hold on;
m = plotZscLPError(days, group2(:, days), "mean", 'o-');
m = plotZscLPError(days, group3(:, days), "mean", 'x-');
m = plotZscLPError(days, group4(:, days), "mean", 'x-');

xticks([1:14]); xlabel("Days"); ylabel("Standard Deviations"); %ylim([-1.5 1.5]);
yline(0, '--')
title("RAP Licks across all days for Ps");
legend("Control Males", "Control Females", "EtOH Males", "EtOH Females");
xline(10.5, ':k', "Renewal Start");
hold off;

%% swarmchart 
%create a swarmchart of the data. Females are red and males are blue 
fig2 = figure()
f = plotSwarm([1:6], RAPtotLicksF, 'o', 'red', 'DisplayName', 'Female')
hold on;
m = plotSwarm([1:6], RAPtotLicksM, 'x', 'blue', 'DisplayName', 'Male')
legend()
ylim([0 2500]); xticks([1:6])
xlabel("Days"); ylabel("Total Licks"); title("Swarmchart of Licks Across RAP Days")

%% Categorized Subplots

%!! things to change for each graph !! 
TTFLMtx = cTTFLMtx(lickTmSerMtx)
data = TTFLMtx
days = [1:10]

% !! pull out different groups of animals by changing the specifications
% here !!
group1 = data(ratsInfo.Trtm == "EtOH" & ratsInfo.Sex == "F" & ratsInfo.DNDClass == "Drinker", days);
group2 = data(ratsInfo.Trtm == "EtOH" & ratsInfo.Sex == "F" & ratsInfo.DNDClass  == "NonDrinker", days);
group3 = data(ratsInfo.Trtm == "H2O" & ratsInfo.Sex == "F", days);
group4 = data(ratsInfo.Trtm == "EtOH" & ratsInfo.Sex == "M" & ratsInfo.DNDClass  == "Drinker", days);
group5 = data(ratsInfo.Trtm == "EtOH" & ratsInfo.Sex == "M" & ratsInfo.DNDClass == "NonDrinker", days);
group6 = data(ratsInfo.Trtm == "H2O" & ratsInfo.Sex == "M", days);
%use tiledlayout to make a plot with two subplots. 
fig1 = tiledlayout(2,1);
%first plot 
nexttile;
FD = plotZscLPError([1:length(days)], group1, "Mn", '-', 'Color', 'red')
hold on; 
FND = plotZscLPError([1:length(days)], group2, "Mn", '-', 'Color', 'magenta')
Fwc = plotZscLPError([1:length(days)], group3, "Mn", '-', 'Color', 'blue')
title("Females", 'FontSize',14)
ylim([-1 2])
xlim([ 0 11])
hold off;

%second plot
nexttile
MD = plotZscLPError([1:length(days)], group4, "Mn", '-', 'Color', 'red')
hold on; 
MND = plotZscLPError([1:length(days)], group5, "Mn", '-', 'Color', 'magenta')
Mwc = plotZscLPError([1:length(days)], group6, "Mn", '-', 'Color', 'blue')
title("Males", 'FontSize',14)
ylim([-1 2])
xlim([ 0 11])
hold off; 

%add common labels onto the subplot
fig1.Title.String = "zScored RAP Consumption in Licks"
fig1.Title.FontSize = 18
fig1.XLabel.String = "Days"
fig1.YLabel.String = "Standard Deviations"
fig1.YLabel.FontSize = 18
fig1.XLabel.FontSize = 18
lgd = legend("Frontloader", "NonFrontLoader", "Control")
lgd.Layout.Tile = 'east';
lgd.FontSize = 14

%% Align all binned data
% find minimum and maximum licking time points 
mnMxLickTm = minmax(cell2mat(cellfun(@(x) cell2mat(x'), RAP_lickTmSerMtx, 'UniformOutput',false)));
% create vector starting with 0 and going to the highest time series lick
% point. Increment up by 60 for minutes or by 1 for seconds.  
xA = [0:1:mnMxLickTm(2)];
% i is the day by cycling through lick time series matrix. Cumulative licks
% across the time series will be calculated for each rat on each day 
for i=1:size(RAP_lickTmSerMtx,2)
    hld = RAP_lickTmSerMtx{i};
    binLick(:,i) = cellfun(@(x) cumsum(histcounts(x,xA)), hld, 'UniformOutput',false);
end

%% Plot the binned data

%RAP experimental days you want to graph
days = [1 3 5 6 8 10];

%groups you want to graph together 
%group1 = ratsInfo.strain == "P" & ratsInfo.sex == "M" & ratsInfo.treatment == "EtOH";
%group2 = ratsInfo.strain == "P" & ratsInfo.sex == "F" & ratsInfo.treatment == "EtOH";
%group3 = ratsInfo.strain == "P" & ratsInfo.sex == "M" & ratsInfo.treatment == "Control";
%group4 = ratsInfo.strain == "P" & ratsInfo.sex == "F" & ratsInfo.treatment == "Control";

%initialize graph
pat = 'C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\graphs\frontloading_individual'

%graph cumulative licks per minute for each day of RAP
for rat = 1:size(binLick, 1)
    fig = tiledlayout(1,numel(days));
    for i = 1:numel(days)
        nexttile;
        plot([1:3600], binLick{rat, i}, 'x-');
        hold on;
        title(['Day ' num2str(days(i))]);;
        hold off; 
    end
    subject = ['Subject' num2str(ratsInfo.ratID(rat))];
    fig.Title.String = subject ;
    fig.XLabel.String = "Time (min)";
    fig.YLabel.String = "Cumulative Licks";
    filename = fullfile(pat, [subject '.png']);
    saveas(gcf,filename);
end
 

% fig.Title.String = "P Control RAP Cumulative Licks over Time"
% fig.Title.FontSize = 18
% fig.XLabel.String = "Time (min)"
% fig.YLabel.String = "Cumulative Licks"
% fig.YLabel.FontSize = 18
% fig.XLabel.FontSize = 18
% lgd = legend("Control Male", "Control Female");


%% Plot the binned data. 
for i = 1:size(binLick,2);
    subplot(1,size(binLick,2),i);
    hld = cell2mat(binLick(:,i));
    %kW = find(subNumMtx(:,i)<=16);
    %kE = find(subNumMtx(:,i)>16);
    kW = [1:16]
    kE = [17:size(binLick,1)]
%     plot(mean(hld(kW,:)),'b.-'); hold on;
%     plot(mean(hld(kE,:)),'r.-'); hold on;
    errorbar(xA,mean(hld(kW,:)),std(hld(kW,:)./sqrt(length(kW))),'bo-'); hold on;
    errorbar(xA,mean(hld(kE,:)),std(hld(kE,:)./sqrt(length(kE))),'ro-'); hold on;
%     ylabel('mean licks/60 sec')
    ylabel('Cumlative number of licks')
    xlabel('Time (min)')
    title(['Day ' num2str(i)])
    ylim([0 800])
end;