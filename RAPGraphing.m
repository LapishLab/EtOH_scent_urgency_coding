%% Creating Graphs of RAP Variables
% this code graphs RAP consumption in different ways. Separate sections
% will show specifics





%% !!LinePlot and Swarmchart of Licks across days. Split by Sex
% need variable totLickMtx from anaRAP. Contains total licks in each cell
% with days on the x and rats on the y. Is already in order of increasing
% subject number. Remember to remove the rats that are out from the
% totLickMtx before running 

%split total number of licks up sex. Only use the EtOH consumers and days
%where EtOH was consumed in ogRAP
RAPtotLicksM = totLickMtx((ratsInfo.Trtm == "EtOH" & ratsInfo.Sex == "M"),:);
RAPtotLicksF = totLickMtx((ratsInfo.Trtm == "EtOH" & ratsInfo.Sex == "F"),:);

%create the line plot. Two separate lines for males and females. Days on x
%axis and licks on the y-axis
fig1 = figure()
f = plotZscLPError([1:10], RAPtotLicksF, "Mn", 'o-', 'Color', 'red');
hold on;
m = plotZscLPError([1:10], RAPtotLicksM, "Mn", 'x-', 'Color', 'blue');
xticks([1:10]); xlabel("Days"); ylabel("Mean Total Licks"); %ylim([-1.5 1.5]);
yline(0, '--')
title("EtOH Consumers, AllDays: RAP Cons in Licks Across Days");
legend("Females", "Males");
hold off;

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

%% export data for prism graphing

%Calcutating totLickData
%first align all of the data into matching bin sizes. Essentially takes
%count of how many licks are in each bin of 60 seconds 
% find minimum and maximum licking time points 
mnMxLickTm = minmax(cell2mat(cellfun(@(x) cell2mat(x'), lickTmSerMtx, 'UniformOutput',false)));
% create vector starting with 0 and going to the highest time series lick
% point. Increment up by 60.  
xA = [0:60:mnMxLickTm(2)];
%pull out a specific group
group = ratsInfo.Sex == "F" & ratsInfo.Trtm == "EtOH"
% i is the day by cycling through lick time series matrix
for i=1:size(lickTmSerMtx,2);
    %pull out the data for each day 
    hld = lickTmSerMtx{i}(group);
    %calculates number of licks in each time bin and cumulatively adds the
    %counts on top of each other as the time increases. binLick has rats as
    %rows and days as columns
    binLick(:,i) = cellfun(@(x) cumsum(histc(x,xA)), hld, 'UniformOutput',false);
end;

%make sure that the binLick variable starts with a 0 and can cut out the
%repeating number at the end
for i = 1:size(binLick,1);
    for m = 1:size(binLick,2);
        binLick{i,m} = [0 binLick{i,m}([1:end-1])];
    end;
end; 



%check to see if the last two numbers of each lick binned vector always
%match each other (they do) 
a = 0
for i = 1:size(binLick,1);
    for m = 1:size(binLick,2);
        ends = binLick{i,m}([end-1:end])
        equal = ends(1) ~= ends(2)
        a = a + equal
    end;
end;

%% Align all binned data
% find minimum and maximum licking time points 
mnMxLickTm = minmax(cell2mat(cellfun(@(x) cell2mat(x'), RAP_lickTmSerMtx, 'UniformOutput',false)));
% create vector starting with 0 and going to the highest time series lick
% point. Increment up by 60.  
xA = [0:60:mnMxLickTm(2)];
% i is the day by cycling through lick time series matrix
for i=1:size(RAP_lickTmSerMtx,2);
    hld = RAP_lickTmSerMtx{i};
    binLick(:,i) = cellfun(@(x) [0 cumsum(histc(x,xA))], hld, 'UniformOutput',false);
end;

%% Plot the binned data

%RAP experimental days you want to graph
days = [1:10];

%groups you want to graph together 
group1 = ratsInfo.strain == "Wistar" & ratsInfo.sex == "M" & ratsInfo.treatment == "EtOH";
group2 = ratsInfo.strain == "Wistar" & ratsInfo.sex == "F" & ratsInfo.treatment == "EtOH";
group3 = ratsInfo.strain == "P" & ratsInfo.sex == "M" & ratsInfo.treatment == "EtOH";
group4 = ratsInfo.strain == "P" & ratsInfo.sex == "F" & ratsInfo.treatment == "EtOH";

%initialize graph
fig = tiledlayout(1,10)

%graph cumulative licks per minute for each day of RAP
for i = 1:numel(days)
    nexttile
    plotLPError([1:62],cell2mat(binLick(group1,i)), "mn", 'o-');
    hold on; 
    plotLPError([1:62],cell2mat(binLick(group2,i)), "mn", 'o-');
    plotLPError([1:62],cell2mat(binLick(group3,i)), "mn", 'x-');
    plotLPError([1:62],cell2mat(binLick(group4,i)), "mn", 'x-');
    title(['Day ' num2str(i)]);
    ylim([0 1500])
end; 

fig.Title.String = "RAP Cumulative Licks over Time"
fig.Title.FontSize = 18
fig.XLabel.String = "Time (min)"
fig.YLabel.String = "Cumulative Licks"
fig.YLabel.FontSize = 18
fig.XLabel.FontSize = 18
lgd = legend("Wistar Male", "Wistar Female", "P Male", "P Female");


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