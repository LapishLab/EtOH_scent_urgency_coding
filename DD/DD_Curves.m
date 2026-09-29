%% Graphing DDCurve
% pulls out averaged data of the last 2 days at each delay 
% can be used to make discounting curves

%set the delay amounts in a vector
delays = [0 1 2 4 8 16]

%vector of all the averaged iVals for the last two days of each delay
data_sig_all = []

%% Calculate the lever latencies 

leverLatencies = all_output{2}; %initial lever latencies
leverChoices = all_output{3}; %choice lever choices 

[LLMtx] = calc_leverLatency("all","mean",leverLatencies,leverChoices);

%[LLMtx_immediate] = calc_leverLatency("immediate","mean",leverLatencies,leverChoices);


%% Pulls out significant slope1/2/knot from DD 

data_sig_all = []

%data from the piecewise linear function 
data = all_results

%pull out only the slopes that were found to be fitted statistically
%significantly
for day = 1:numel(data)
    data_sig = []
    for rat = 1:size(data{1},1)
        if data{day}(rat,4) < 0.05
            data_sig(rat,:) = data{day}(rat,3);
        elseif data{day}(rat,4) > 0.05
            data_sig(rat,:) = NaN;
        end 
    end 
    data_sig_all(:,day) = data_sig;
end

%% Find average of last two days 

%data must be organized as rat on row and day on columns 
data = w_test_output{2};

data_mn_non = [];
%create for loop to move through the matrix of DDiVals and find the average of the last
%2 days for each delay. They delays are contained in sets of 4 in the
%matrix
for i = 1:numel(delays);
    %the column number of the last day for each delay
    delayEnd = (i*4);
    %specify the groups that you want to graph
    % concatenate the data for each day next to each other 
    %data_mn = [data_mn [data(:,delayEnd-1) data(:,delayEnd)]];
    data_mn_non(:,i) = mean([data(:,delayEnd-1) data(:,delayEnd)],2,'omitnan');
end;

%% Plot the curves 
% with different groups 

group1 = ratsInfo.strain == "Wistar" & ratsInfo.sex == "M" & ratsInfo.treatment == "Control";
group2 = ratsInfo.strain == "Wistar" & ratsInfo.sex == "M" & ratsInfo.treatment == "EtOH" & ratsInfo.drinkClass ~= "Low";

group3 = ratsInfo.strain == "Wistar" & ratsInfo.sex == "F" & ratsInfo.treatment == "Control";
group4 = ratsInfo.strain == "Wistar" & ratsInfo.sex == "F" & ratsInfo.treatment == "EtOH" & ratsInfo.drinkClass ~= "Low";

group5 = ratsInfo.strain == "P" & ratsInfo.sex == "M" & ratsInfo.treatment == "Control";
group6 = ratsInfo.strain == "P" & ratsInfo.sex == "M" & ratsInfo.treatment == "EtOH";

group7 = ratsInfo.strain == "P" & ratsInfo.sex == "F" & ratsInfo.treatment == "Control";
group8 = ratsInfo.strain == "P" & ratsInfo.sex == "F" & ratsInfo.treatment == "EtOH";

groups = {group1};

% go through each group and graph the piecewise linear aspect for each
% delay 
close(gcf)
for i = 1:numel(groups)
    plotLPError(delays, data_mn_immediate(groups{i}, :), 'mean', 'Color', 'blue');
    hold on;
    plotLPError(delays, data_mn_delay(groups{i},:), 'mean', 'Color', 'red');
    ylim([0.6 3.5])
end 

%legend("Wistar M", "Wistar F", "P M", "P F")
legend("immediate", "delay")
title("DD choice lever latencies across delay and immediate choices, Control wistar males")
xlabel("Delay")
ylabel("Mean Choice Latencies")

%% Plot the Curves
%for each animal 

subjectNumbers = w_test_output{end}(:, 1);
save_file = "C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\032426_LOFC_fiber\graphs\dailyDD";
data = data_mn_non;

for i = 1:numel(subjectNumbers)
    graph_name = "DD_curve_subject" + num2str(subjectNumbers(i)) 
    save_path = fullfile(save_file, graph_name)
    close(gcf)
    plot(delays, data(i, :))
    hold on 
    title(graph_name)
    ylabel("Ivalue")
    ylim([0 6])
    xlabel("Delay")
    hold off
    saveas(gcf, save_path, 'png')
 end