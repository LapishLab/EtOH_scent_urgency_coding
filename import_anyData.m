%This script include a section for importing any data type that is used in
%the EtOH_scent_urgency project. Import data types include:
% IAP Consumption Table
% RAP Cosumption Table
% RAP consumption over time  
% RAP Frontloading Classification Data
% DD curve data 

%% Create IAP Consumption Data Table %%
%combine the IAP and RAP g/kg consumption of the P and wistar cohorts
%variables needed: 

IAP_sheet = "EtOH_consumption_gkg";

%---Import Consumption Data---%
%wistars
wistar_IAP_path = 'E:\052224_11425_WistarUrgency\IAP\IAP Raw Data.xlsx';
wistar_IAP = readtable(wistar_IAP_path, 'Sheet', IAP_sheet);

%Ps
P_IAP_path = 'E:\072125_121225_Prat_urgency\IAP\072125_IAP_data.xlsx';
P_IAP = readtable(P_IAP_path, 'Sheet', IAP_sheet);

%remove rats that didn't meet criteria DD learning criteria 
ratsOut = [17 32 47 53];
ratsOut_location_IAP = sum(wistar_IAP.ratID == ratsOut, 2);
wistar_IAP(logical(ratsOut_location_IAP),:) = [];

%---Combine Across Cohorts---%
%find which columns match. Preserve original order
matching_variables = wistar_IAP.Properties.VariableNames(ismember(wistar_IAP.Properties.VariableNames, P_IAP.Properties.VariableNames));
%combine only the matching columns
IAP_all = [wistar_IAP(:, matching_variables); P_IAP(:, matching_variables)];
%separate out the consumption information and identifying rat information
IAP_ratsInfo = IAP_all(:,~contains(IAP_all.Properties.VariableNames, 'day'));
IAP_all = IAP_all(:,contains(IAP_all.Properties.VariableNames, 'day'));
%save variables to variable folder
save("C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\EtOH_scent_urgency_coding\variables\IAP_consumption", "IAP_all")






%% Create RAP Consumption Data Table %%
RAP_sheet = "all_consumption_gkg";

%---Import the consumption data---%
%wistars
wistar_RAP_path = "E:\052224_11425_WistarUrgency\RAP\RAP Raw Data.xlsx";
wistar_RAP = readtable(wistar_RAP_path, 'Sheet', RAP_sheet);

%remove rats that didn't meet DD learning criteria
ratsOut = [17 32 47 53];
ratsOut_location_RAP = sum(wistar_RAP.ratID == ratsOut, 2);
wistar_RAP(logical(ratsOut_location_RAP),:) = [];
%Ps
P_RAP_path = "E:\072125_121225_Prat_urgency\RAP\081725_RAP_data.xlsx";
P_RAP = readtable(P_RAP_path, 'Sheet', RAP_sheet);

%---Combine Across Cohorts---%
%find which columns match. Preserve original order
matching_variables = wistar_RAP.Properties.VariableNames(ismember(wistar_RAP.Properties.VariableNames, P_RAP.Properties.VariableNames));
RAP_all = [wistar_RAP(:, matching_variables); P_RAP(:, matching_variables)];
%separate out the consumption information and identifying rat information
RAP_ratsInfo = RAP_all(:,~contains(RAP_all.Properties.VariableNames, 'day'));
RAP_all = RAP_all(:,contains(RAP_all.Properties.VariableNames, 'day'));
%save variables to variable folder
save("C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\EtOH_scent_urgency_coding\variables\RAP_consumption", "RAP_all")






%% Import RAP Consumption over Time %%

%% Import Wistar RAP Data %%
dir_path = 'E:\052224_11425_WistarUrgency\RAP\analysisData';
days = 10;
maxFiles = 30;
wistar_RAP = anaRap(dir_path, days, maxFiles, fix_file = true, allData = false, sideMtx = false);

%% Import Wistar RAP Renewal Data %%
dir_path = 'E:\052224_11425_WistarUrgency\RAP\100724_Renewal\analysisData'
days = 4
maxFiles = 30;
wistar_RAP_renewal = anaRap(dir_path, days, maxFiles, allData = false, sideMtx = false);

%% Import P rat RAP Data %%
dir_path = 'E:\072125_121225_Prat_urgency\RAP\analysisData';
days = 10;
maxFiles = 24;
P_RAP = anaRap(dir_path, days, maxFiles, allData = false, sideMtx = false);

%% Import P rat Renewal RAP Data %%
dir_path = 'E:\072125_121225_Prat_urgency\RAP\RAP_renewal\analysisData';
days = 4;
maxFiles = 24;
P_RAP_renewal = anaRap(dir_path, days, maxFiles, allData = false, sideMtx = false);

%% Remove rats that didn't meet criteria %%
% remove any rats that didn't make criteria. Only in the wistars 
ratsOut = [17 32 47 53];
%only remove rats from the first three variables which are total licks,
%lick time series matrix and subject numbers matrix 
for i = 1:3
        %for total lick and subject number matrix
        if class(wistar_RAP{i}) == "double"
            wistar_RAP{i}(ratsOut, :) = [];
        %for lick time series matrix because there is mutliple cells in
        %total for each day all contained within one parent cell 
        elseif class(wistar_RAP{i}) == "cell"
            for m = 1:size(wistar_RAP{i}, 2)
                wistar_RAP{i}{m}(ratsOut, :) = [];
            end
        end 
end

%% Combine data %%
%combine RAP with RAP renewal data and combine wistar and P rat data. The
%first 10 days of data will always be for the RAP prior to the DD curve and
%the last 4 will be the RAP data from the renewal portion after the rats
%learned the DD curve. 

%check that each of the subsequent combined datasets are in the correct
%orientation. Subject number matrix order should match ratID order from
%ratsInfo variable. 
RAP_subjectNumbers = [[wistar_RAP{3} wistar_RAP_renewal{3}];[P_RAP{3} P_RAP_renewal{3}]];
if all(RAP_subjectNumbers == repmat(ratsInfo.ratID, 1, 14), 'all') ~= true 
    warning("Individual rat data is not in the same order across experimental days")
end

%matrix with total licks for both wistars and Ps  
RAP_totalLicks = [[wistar_RAP{1} wistar_RAP_renewal{1}];[P_RAP{1} P_RAP_renewal{1}]];

%matrix with time series matrix data for both wistars and Ps 
RAP_lickTmSerMtx = {};
%can change this if combining other matrices of different sizes
matrixSize = size(wistar_RAP{2}, 2);
for i = 1:matrixSize
    RAP_start_lickTmSerMtx{i} = [wistar_RAP{2}{i};P_RAP{2}{i}];
end

matrixSize = size(wistar_RAP_renewal{2}, 2);
for i = 1:matrixSize
    RAP_renewal_lickTmSerMtx{i} = [wistar_RAP{2}{i};P_RAP{2}{i}];
end

RAP_lickTmSerMtx = [RAP_start_lickTmSerMtx RAP_renewal_lickTmSerMtx];

%% Save Data %%
save("C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\EtOH_scent_urgency_coding\variables\RAP_lickTmSerMtx.mat", "RAP_lickTmSerMtx")
save("C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\EtOH_scent_urgency_coding\variables\RAP_totalLicks.mat", "RAP_totalLicks")







%% Import RAP Frontloading Classification Data %% 

%% Organize the data in consumption (g/kg) per time unit %% 
% can be in second or minute bins 
% used to find and calculate the RAP data

%vectors holding details from the experiment
days = [1:size(RAP_all, 2)];
rats = [1:size(RAP_all, 1)];

%create minute or second time bins by making a vector of 1:60 or 1:3600 
trlTime = [0:3600];
%variable that will hold the data across all days
consumptionOverTime = {} ;

%for loop that organizes the data for front loading by calculating the amount of ethanol 
%consumed during each second time bin. 
for day = 1:numel(days);
    %variable that will hold the data for each day
    consBin = [];
    for rat = 1:numel(rats);
        %pull out the individual data for each rat on each day
        lickTms = RAP_lickTmSerMtx{day}{rat};
        %calculate the number of licks in each second time bin
        binLicks = histcounts(lickTms,trlTime);
        %divide each time bin by the total number of licks to get the
        %percentage of licks in each time bin
        percLick = binLicks./numel(lickTms);
        %multiple the lick per bin percentage by total consumption to find the amount
        %consumed during each second bin and add it to the array 
        indConsBin = percLick.*table2array(RAP_all(rat,day));
        consBin = [consBin;indConsBin];
    end;
    consumptionOverTime{day} = consBin;
end; 

%% Import data %%
% includes change points, first slopes, second slopes, and individual
% subject frontloading classification per experiment day

%experiment days to look at 
days = [1 3 5 6 8 10 11 13];

%subject number vector thats needed to feed into the code 
subjects = ratsInfo.ratID';

%initialize variables
classifications = {};
change_points = [];
first_slopes = [];
second_slopes = [];

%find frontloading classification information for each day 
for i = 1:numel(days)
    Dataset = consumptionOverTime{days(i)};
    [clasify, chPts, fSlp, sSlp] = detectFrontloading_data(Dataset', subjects);
    classifications{i} = clasify;
    change_points(:, i) = chPts;
    first_slopes(:,i) = fSlp;
    second_slopes(:,i) = sSlp;
end 







%% Import DD Curve Data %%

% --- Wistar Data --- % 
%path to files. must be char not string
pat = 'E:\052224_11425_WistarUrgency\Delay Discounting\DD Data\analysisData';
%experiment days to import
dayNumbers = [3:26];
%import data
[w_allData, w_allDDiVals, w_lastTenDDiVals, w_day_dates] = DDData_importAll(pat, dayNumbers, removeRats = true);

% --- P Data --- %
%path to files. must be char not string
pat = 'E:\072125_121225_Prat_urgency\DD\analysisData';
%experiment days to import
dayNumbers = [12:35];
%import data%
[p_allData, p_allDDiVals, p_lastTenDDiVals, p_day_dates] = DDData_importAll(pat, dayNumbers);

% --- Combine Together --- %
%initialize variables to hold everything
allData = {};
allDDiVals = {};

%add the allData and allDDiVals together since they are in cell arrays
for i = 1:numel(dayNumbers)
    allData{i} = [w_allData{i};p_allData{i}]
    allDDiVals{i} = [w_allDDiVals{i};p_allDDiVals{i}];
end; 

%add the lastTenDDiVals variables together since they are doubles 
lastTenDDiVals = [w_lastTenDDiVals;p_lastTenDDiVals];

%% Save Data %%
save("C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\EtOH_scent_urgency_coding\variables\allData.mat", "allData");
save("C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\EtOH_scent_urgency_coding\variables\allDDiVals.mat", "allDDiVals");
save("C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\EtOH_scent_urgency_coding\variables\lastTenDDiVals.mat", "lastTenDDiVals");