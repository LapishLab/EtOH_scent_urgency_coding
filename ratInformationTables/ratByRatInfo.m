function [ratsInfo_all] = ratByRatInfo(IAP_pat, ratSheet)
%% Organize rat by rat Identifying Information using the IAP Sheet
% Contains information about each rat so that I can use it for
% indexing and organizing graphs and data later. 
% input: path to excel file with rat information (can contain multiple), specific sheet in this
% file 
% ouptut: a variable that contains columns of classifying information for
% each rat row 

%import the rat by rat information for the first cohort
%ratsInfo_all = readtable(IAP_pat(1), 'Sheet', ratSheet);
%remove any excess notes under the information table that doesn't align
%with the information in the column
%[max_ratID, max_index] = max(ratsInfo_all.ratID);
%ratsInfo_all([max_index+1:end], :) = [];

ratsInfo_all = []
%import rat by rat information for the following cohorts, matching and
%combining the tables into one by shared table column headers
for i = 1:size(IAP_pat, 1) 
    ratsInfo_next = readtable(IAP_pat(i), 'Sheet', ratSheet);
    %remove any excess notes under the information table that doesn't align
    %with the information in the column
    [max_ratID, max_index] = max(ratsInfo_next.ratID);
    ratsInfo_next([max_index+1:end], :) = [];
    %combine tables together
    if i > 1;
        ratsInfo_all = outerjoin(ratsInfo_all, ratsInfo_next, 'MergeKeys', true) 
    else; 
        ratsInfo_all = ratsInfo_next
    end; 
end; 


