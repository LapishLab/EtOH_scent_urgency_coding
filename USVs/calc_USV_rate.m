%% Calculate average USV_rate for each rat
function usv_rate = calc_USV_rate(t, session_length)

arguments 
    t
    session_length %needs to be an array of increasing time by a certain amount x. function returns number of squeaks divided by x to get rate  
end 


%% Graphing and calculating
%amount of the file to include. Based on audio offset time calculated for
%the files 
edges = session_length; %needs to be an array of increasing time by a certain amount x. number of squeaks in x  
tdif = diff(edges(1:2));

usv_rate = {};
% get rates across multiple bins 
% for a = 1:numel(thresholds)
%     usv_rate{a} = {};

    for i=1:height(t)
        % --- get usv rate --- %
        calls = t.calls{i};
        % %if you want to keep only USVs of a certain frequency 
        % meets_threshold = isInRange(calls.frequency, thresholds{a}(1), thresholds{a}(2));

        % find mean of all the time points of each pixel in a squeak 
        call_times = cellfun(@mean, calls.ridge_time);
        % number of USV counts in each time bin / total time = percentage of
        % bin_counts = histcounts(call_times, edges);
        % total squeaks in the file in each time bin
        usv_rate{i} = histcounts(call_times, edges) / tdif;
        %add rate back to the table

    end
%     %add usv_rate for each frequency bin to its own labeled column in the table 
%     t.(threshold_names(a)) = usv_rate{a}';
% end 
sem = @(x) std(x, 'omitnan')/sqrt(sum(~isnan(x(:,1))));
avg_nan = @(x) mean(x, 'omitnan');