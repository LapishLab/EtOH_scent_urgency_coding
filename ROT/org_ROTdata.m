function org_data = org_ROTdata(data, group, days)
%Concatenates the RAP data on top 
arguments 
    data %cell array: each cell has all the data from that day for all rats in it   
    group %logical statement: from ratsInfo, pulls information from data based on the location 
    days %specifies which cells from data to concatenate on top of each other 
end 

%variables to hold concatenated data 
org_data = [];

%concatenate data on top of each other 
for i = 1:numel(days)
    groupData = data{days(i)}(group,:);
    org_data = [org_data; groupData];
end 
