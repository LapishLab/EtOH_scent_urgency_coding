function [LLMtx] = calc_leverLatency(Mtxoption,cenFun,data,hList)
%% Calculate Mean Lever Latency
% takes raw data across multiple days and finds the mean of the raw data
% for each day for each rat. Adds this data to a new matrix. Either can
% create one overall matrix, a matrix with the delay choice latencies, or a
% matrix with the immediate choice latencies 
% option 1 = overall matrix, option 2 = delay choice, option 3 = immediate
% choices

%set matrix to hold data
LLMtx = [];
allLLMtx = [];
dLLMtx = [];
imLLMtx = [];

%determine whether to function will be finding the mean or the median.
%it will check what the case is fro the central function input in the
%variable. Then everywhere it says func in the code, it will either use
%nanmean or nanmedian. 
switch cenFun;
    case 'mean';
        func = @(x) mean(x, 2, 'omitnan');
    case 'median';
        func = @(x) median(x, 2, 'omitnan');
end;
%set for loop that works through each day
for day = 1:length(data);
    %find mean of all data. some NaNs for females that didn't complete all
    %trials so have to use nanmean
    allLLMtx = [allLLMtx func(data{day})];
    %reset the matrices for each day 
    dLLDayMtx = [];
    imLLDayMtx = [];
    for rat = 1:length(hList{day});
        %find mean only of the trials that were delay choice trials
        %find delay choice trial column locations for a specific rat (row)
        dChoiceTrls = hList{day}(rat,:) == 3;
        %pull together the lever latencies from those columns and find the
        %mean. This is the overall mean for the delay lever choices for
        %that day 
        dChoiceLatency = func(data{day}(rat,dChoiceTrls));
        %add the lever latencies on top of each other for each day 
        dLLDayMtx(rat, 1) = dChoiceLatency;

        %find mean only of the trials that were immediate choice trials.
        %Repeat same as above
        imChoiceTrls = hList{day}(rat,:) == 4;
        imChoiceLatency = func(data{day}(rat,imChoiceTrls));
        imLLDayMtx(rat, 1) = imChoiceLatency;
    end; 
    %add the day mean information for the delay and immediate lever choices
    %to the overall matrix that will hold the data for all of the total
    %days
    dLLMtx = [dLLMtx dLLDayMtx];
    imLLMtx = [imLLMtx imLLDayMtx];
end; 

%% 
%determine function output based on what the option is. output will either
%be the mean/median of all trials, all delay choices, or all immediate
%choices
if Mtxoption == "all";
    LLMtx = allLLMtx;
elseif Mtxoption == "delay";
    LLMtx = dLLMtx;
elseif Mtxoption == "immediate"; 
    LLMtx = imLLMtx;
end; 
