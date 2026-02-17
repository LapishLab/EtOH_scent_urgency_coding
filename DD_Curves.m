%% Graphing DDCurve
% pulls out averaged data of the last 2 days at each delay 
% can be used to make discounting curves

%set the delay amounts in a vector
delays = [0 1 2 4 8 16]

%vector of all the averaged iVals for the last two days of each delay
data_sig_all = []

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