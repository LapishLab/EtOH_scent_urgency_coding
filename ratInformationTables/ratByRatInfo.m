function [ratsInfo] = ratByRatInfo(IAP_pat, ratSheet)
%% Organize rat by rat Identifying Information using the IAP Sheet
% Organizes a bunch of information about each rat so that I can use it for
% indexing and organizing graphs and data later. 
% input: path to excel file with rat information, specific sheet in this
% file, RAP and IAP Cons tables already made
% ouptut: a variable that contains columns of classifying information for
% each rat row 

%Read the rat by rat individual data from the IAP excel sheet into a table 
ratsInfo = readtable(IAP_pat, 'Sheet', ratSheet);

%rename the ratID title
ratsInfo.Properties.VariableNames(1) = "ratID";

%use function to remove the rats that didn't make it 
%ratsInfo = removeRats(ratsInfo);

%Create the group numbers for the CS+ and CS- scents
%Group1: got the CS+ on Wednesday in week 1 and Friday in Week 2
%Group2: got the CS+ on Friday in week 1 and Wednesday in Week 2
%scentWksGrp = (string(ratsInfo.W1_CS_Access) == "Wednesday");
%ratsInfo.scentTrtmGrp(scentWksGrp) = 1;
%ratsInfo.scentTrtmGrp(~scentWksGrp) = 2;

%switch the CPPish Scent Side Assignment to show the side for the CS+
%rather than the CS- 
%CSMSide = string(ratsInfo.CPP_CS_SideAssignment) == "Left";
%ratsInfo.CPPishCSPlSide(CSMSide) = "R";
%ratsInfo.CPPishCSPlSide(~CSMSide) = "L";

%Add a column for Control and EtOH Clarification
%ratsInfo.Properties.VariableNames("Treatment") = "Trtm";
%ratsInfo.Trtm([1:20]) = "H2O";
%ratsInfo.Trtm([21:end]) = "EtOH";


%rename the CS scent columns so I know which includes the CS+ scent and
%which includes the CS-
ratsInfo.Properties.VariableNames(6) = "control_scent";
ratsInfo.Properties.VariableNames(7) = "EtOH_scent";


%Remove the columns that I don't need
ratsInfo([41:end], :) = []

%use function to add a new column with each rat's classification as an EtOH
%drinker or EtOH nondrinker. Water drinkers are labeled as control 
%[ratsInfo] = drinkingBehGroups(ratsInfo, IAPConsRaw, RAPConsRaw)

%use function of add a new column with each rat's front-loading
%classification 
%[ratsInfo] = plotFrontLoadingHist(ratsInfo)