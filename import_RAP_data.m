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
