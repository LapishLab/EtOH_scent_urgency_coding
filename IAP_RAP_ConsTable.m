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

%% Create RAP Consumption Data Table 
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


