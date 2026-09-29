function avg_iValue = calc_indifferencePoint(data, opts) 

arguments 
    data %data needs to be in the form of a cell for each day and data in rats 
    opts.range = [20:30]; %the range of trials that will be used to to calculate the indifference point   
end 

%% Calculate the indifference point 
% need iValue over time 
% data needs to be in the form of a cell for each day and data in rats 

avg_iValue = [];

for i = 1:size(data,2)
    for rat = 1:size(data{i},1)
        avg_iValue(i, rat) = mean(data{i}(rat, opts.range), 'omitnan');
    end 
end 