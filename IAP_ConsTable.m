%% Create IAP Consumption Data Table %%
%combine the IAP g/kg EtOH consumption of both the P rat and Wistar
%cohorts 

IAP_sheet = "EtOH_consumption_gkg";

%% ---Import the Wistar IAP Consumption Data--- %%

wistar_IAP_path = 'E:\052224_11425_WistarUrgency\IAP\IAP Raw Data.xlsx';
wistar_IAP = readtable(wistar_IAP_path, 'Sheet', IAP_sheet);

%remove rats that didn't meet criteria
ratsOut = [17 32 47 53];
ratsOut_location = sum(wistar_IAP.ratID == ratsOut, 2);
wistar_IAP(logical(ratsOut_location),:) = [];

%% ---Import the Prat IAP Consumption Data--- %%

P_IAP_path = 'E:\072125_121225_Prat_urgency\IAP\072125_IAP_data.xlsx';
P_IAP = readtable(P_IAP_path, 'Sheet', IAP_sheet);

%% ---Combine IAP Information across cohorts---%%

%find which columns match. Preserve original order
matching_variables = wistar_IAP.Properties.VariableNames(ismember(wistar_IAP.Properties.VariableNames, P_IAP.Properties.VariableNames));
%combine only the matching columns
IAP_all = [wistar_IAP(:, matching_variables); P_IAP(:, matching_variables)];
%separate out the consumption information and identifying rat information
IAP_ratsInfo = IAP_all(:,~contains(IAP_all.Properties.VariableNames, 'day'));
IAP_all = IAP_all(:,contains(IAP_all.Properties.VariableNames, 'day'));
%save variables to variable folder
save("C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\EtOH_scent_urgency_coding\variables\IAP_consumption", "IAP_all")




