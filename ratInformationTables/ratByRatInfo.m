function [ratsInfo_all] = ratByRatInfo(IAP_pat, ratSheet)
%% Organize rat by rat Identifying Information using the IAP Sheet
% Contains information about each rat so that I can use it for
% indexing and organizing graphs and data later. 
% input: path to excel file with rat information (can contain multiple), specific sheet in this
% file 
% ouptut: a variable that contains columns of classifying information for
% each rat row 

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
        ratsInfo_all = outerjoin(ratsInfo_all, ratsInfo_next, 'MergeKeys', true);
    else; 
        ratsInfo_all = ratsInfo_next;
    end; 
end; 

%remove any rats that didn't mean criteria 
ratsOut = [17 32 47 53];
ratsOut_location = sum(ratsInfo.ratID == ratsOut, 2);
ratsInfo(logical(ratsOut_location),:) = [];

%save variable to a specified folder 
save("C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\EtOH_scent_urgency_coding\variables\ratsInfo.mat", "ratsInfo_all")
