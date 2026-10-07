%only take calls within some specific session range

function t = filter_calls_sessionTime(t, range)

arguments 
    t %table with calls information contained in cells for each rat
    range %vector with two numbers 
    opts.field (1,1) string = "Box"   % which variable in calls to filter on
    opts.col (1,1) double = 1         % which column of that variable
end 

for i = 1:height(t)
    %calls from one row 
    calls = t.calls{i};
    %pull the chosen data from the calls
    data = calls.(opts.field)(:, opts.col);
    %logical statement of which calls were in specified time range
    calls_inTimeRange = isInRange(data, range(1), range(2));
    %pull out calls in the time range 
    calls = calls(calls_inTimeRange, :);
    %now only calls in the table will be in the time range  
    t.calls{i} = calls;
end 