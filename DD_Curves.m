%% Graphing DDCurve
% pulls out averaged data of the last 2 days at each delay 
% can be used to make discounting curves

%set the delay amounts in a vector
delays = [0 1 2 4 8 16]

%vector of all the averaged iVals for the last two days of each delay
data_sig_all = []

%lastTenDDiVals = consistMtx
data = all_results

%pull out only the slopes that were found to be fitted statistically
%significantly
for day = 1:numel(data)
    data_sig = []
    for rat = 1:size(data{1},1)
        if data{day}(rat,4) < 0.05
            data_sig(rat,:) = data{day}(rat,1);
        elseif data{day}(rat,4) > 0.05
            data_sig(rat,:) = NaN;
        end 
    end 
    data_sig_all(:,day) = data_sig;
end


data_mn = []
%create for loop to move through the matrix of DDiVals and find the average of the last
%2 days for each delay. They delays are contained in sets of 4 in the
%matrix
for i = 1:numel(delays);
    %the column number of the last day for each delay
    delayEnd = (i*4);
    %specify the groups that you want to graph
    % concatenate the data for each day next to each other 
    data_mn(:,i) = mean([data_sig_all(:,delayEnd-1) data_sig_all(:,delayEnd)],2,'omitnan');
end;



% %create discounting curve split by males and females and ethanol and water
% %drinkers
% fig2 = tiledlayout(2,1)
% %first graph has only water consumers
% t1 = nexttile
% plotLPError(delays, avgiVals(ratsInfo.Sex == "M" & ratsInfo.Trtm == "EtOH", :), "mn", 'o-', 'Color', 'red')
% hold on;
% %plotLPError(delays, avgiVals(ratsInfo.Sex == "M" & ratsInfo.Trtm == "EtOH" & ratsInfo.DNDClass == "NonDrinker", :), "mn", 'x-', 'Color', 'm')
% plotLPError(delays, avgiVals(ratsInfo.Sex == "M" & ratsInfo.Trtm == "Control", :), "mn", 'x-', 'Color', 'blue')
% title("Males")
% hold off; 
% 
% %second graph has only ethanol consumers
% t2 = nexttile 
% plotLPError(delays, avgiVals(ratsInfo.Sex == "F" & ratsInfo.Trtm == "EtOH", :), "mn", 'o-', 'Color', 'red')
% hold on;
% %plotLPError(delays, avgiVals(ratsInfo.Sex == "F" & ratsInfo.Trtm == "EtOH" & ratsInfo.DNDClass == "NonDrinker", :), "mn", 'x-', 'Color', 'm')
% plotLPError(delays, avgiVals(ratsInfo.Sex == "F" & ratsInfo.Trtm == "Control", :), "mn", 'x-', 'Color', 'blue')
% title("Females")
% hold off; 

% 
% %link the axes so that are both showing the full 0 to 6 limit. link x as
% %well to show the delay ticks 
% linkaxes([t1 t2], ['y' 'x'])
% t1.YLim = [0 6]
% t1.XTick = [delays]
% t2.XTick = [delays]
% lgd = legend("EtOH", "Water")
% fig2.Title.String = "Discounting Across Delays Split by Sex"
% fig2.YLabel.String = "iValue"
% fig2.XLabel.String = "Delay (s)"

%% split 

%create discounting curve graphs split by sex and drinking status 
fig2 = tiledlayout(2,1)
%first graph has the females
t1 = nexttile
plotLPError(delays, avgiVals(ratsInfo.Sex == "F" & ratsInfo.DNDClass == "Drinker", :), "mn", 'o-', 'Color', 'red')
hold on;
plotLPError(delays, avgiVals(ratsInfo.Sex == "F" & ratsInfo.DNDClass == "NonDrinker", :), "mn", 'o-', 'Color', 'blue')
title("Females")
hold off; 

%second graph has the males
t2 = nexttile 
mD = plotLPError(delays, avgiVals(ratsInfo.Sex == "M" & ratsInfo.DNDClass == "Drinker", :), 'mn', 'x-', 'Color', 'red')
hold on;
mND = plotLPError(delays, avgiVals(ratsInfo.Sex == "M" & ratsInfo.DNDClass == "NonDrinker", :), 'mn', 'x-', 'Color', 'blue')
title("Males")
hold off; 

%link the axes so that are both showing the full 0 to 6 limit. link x as
%well to show the delay ticks 
linkaxes([t1 t2], ['y' 'x'])
t1.YLim = [0.5 1]
t1.XTick = [delays]
lgd = legend("Drinkers", "NonDrinkers")
fig2.Title.String = "Consistency Across Delays Split by Sex and Drinking Class"
fig2.YLabel.String = "Consistency"
fig2.XLabel.String = "Delay (s)"
