%% Check latency of consistent vs non-consistent trials %%
% variables needed: 
%    matchMtx: which trials are there matched choice and initial lever
%    presses on 
%    choice lever latencies

consistent_latency = [];
nonconsistent_latency = [];

%data for each day
for i = 1:numel(matchMtx)
    %pull out the data for each day 
    day_matches = logical(matchMtx{i});
    day_latencies = leverLatencies{i};
    %average all the latencies for consistent vs nonconsistent trials 
    % consistent_latency(i,1) = mean(day_latencies(day_matches), 'all');
    % nonconsistent_latency(i,1) = mean(day_latencies(~day_matches), 'all', 'omitnan')

    %data for each rat
    for m = 1:size(matchMtx{i},1)
        %reset variables for each rat
        perRat_consistent = [];
        perRat_nonconsistent = [];
        
        %finding consistent latencies for each day 
        perRat_consistent = day_latencies(m, day_matches(m,:));
        perRat_nonconsistent = day_latencies(m, ~day_matches(m,:));

        %hold the average latencies for each rat and day 
        consistent_latency(m, i) = mean(perRat_consistent, 'omitnan');
        nonconsistent_latency(m, i) = mean(perRat_nonconsistent, 'omitnan');
    end 
end 
