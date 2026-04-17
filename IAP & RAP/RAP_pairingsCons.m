
%what experimental days do you want to look at 
days = [7 9];

%initialize variables
%pull out the data for wistars (row 1) or P rats (row 2)
sideMtx = RAP_sideMtx(1,days);

%pull out ethanol and water animal subject numbers to compare to subject
%numbers in the box to determine what each animals reinforcer was. 
EtOH_animals = ratsInfo.ratID(ratsInfo.treatment == "EtOH");
water_animals = ratsInfo.ratID(ratsInfo.treatment == "Control");

%RAP_all = table2array(RAP_all);
RAP_subjects = repmat(ratsInfo.ratID(:), 1, numel(days));

data = [];
%specify which data to look at 
%frontloading slopes (only have it for EtOH days in RAP)
%limit frontloader data to only the days that are being looked at
% data = slope2_gkg; 
% frontloaders = all_frontloaders(:, [4:6]);

% total g/kg cons. Have to pull out only the EtOH days 
% data = RAP_all(:, days);

% g/kg/lick. Have to pull out only the EtOH days
% make any infinity values from not recording any licks set to 0 
% data = RAP_all(:, days)./RAP_totalLicks(:,days);
% data(isinf(data)) = 0;

%initialize variables
EtOH_pairs = [];
EtOH_pairs_subjects = [];
water_pairs = [];
water_pairs_subjects = [];
mixPair_EtOH = [];
mixPair_EtOH_subjects = [];
mixPair_water = [];
mixPair_water_subjects = [];
lone_water = [];
lone_water_subjects = [];
lone_EtOH = [];
lone_EtOH_subjects = [];

%Cycle through each box pairing from RAP_sideMtx. Determine what the pairing of the 
%subjects is (EtOH_EtOH, EtOH_water, by themselves water or etoh). Assign the subject
%numbers from the side pairing to their own matrix. Pull the consumption
%and licks for each rat into a matrix specific to their pairing or lone
%matrix for each day. 
for i = 1:numel(sideMtx)

    % %initialize variables
    % EtOH_pairs = [];
    % EtOH_pairs_subjects = [];
    % water_pairs = [];
    % water_pairs_subjects = [];
    % mixPair_EtOH = [];
    % mixPair_EtOH_subjects = [];
    % mixPair_water = [];
    % mixPair_water_subjects = [];
    % lone_water = [];
    % lone_water_subjects = [];
    % lone_EtOH = [];
    % lone_EtOH_subjects = [];

     for rat = 1:size(sideMtx{i}, 1)
        %pull out data for each day
        dayPairs = sideMtx{i};
        %pull out subject numbers
        subNum = dayPairs(rat,~isnan(dayPairs(rat,:)));
        %only pull out the data I am interested in looking at 

      
        % --- Data for unpaired animals --- %
        %determine if rats were alone in the box or paired with another rat
        %rat was by itself if a nan was present in the other box location

        if any(isnan(dayPairs(rat,:)))
            sub_loc = RAP_subjects(:,i) == subNum;
            %data for mixed EtOH and water pairings
            if ismember(subNum,water_animals)
                lone_water = [lone_water; data(sub_loc, i)];
                lone_water_subjects = [lone_water_subjects;subNum];
                %add subject number and data to matrix for EtOH animals
            elseif ismember(subNum, EtOH_animals)
                lone_EtOH = [lone_EtOH; data(sub_loc, i)];
                lone_EtOH_subjects = [lone_EtOH_subjects;subNum];
            end

            % --- Data for paired animals --- %
            %if no nans are present then two rats are paired together in the box
        elseif ~any(isnan(dayPairs(rat,:)))
            for m = 1:numel(subNum)
                sub_loc = RAP_subjects(:,i) == subNum(m);

                %pulling out data for mixed etoh and water pairings. Only
                %the water animals 
                if sum(ismember(subNum, water_animals)) == 1 & ismember(subNum(m), water_animals)
                    mixPair_water = [mixPair_water; data(sub_loc, i)];
                    mixPair_water_subjects = [mixPair_water_subjects;subNum(m)];
                %pulling out data for mixed etoh and water pairings. Only
                %the etoh animals 
                elseif sum(ismember(subNum, water_animals)) == 1 & ismember(subNum(m), EtOH_animals)
                    mixPair_EtOH = [mixPair_EtOH; data(sub_loc, i)];
                    mixPair_EtOH_subjects = [mixPair_EtOH_subjects;subNum(m)];
                %pulling out data for only EtOH paired animals
                elseif all(ismember(subNum, EtOH_animals))
                    EtOH_pairs = [EtOH_pairs; data(sub_loc, i)];
                    EtOH_pairs_subjects = [EtOH_pairs_subjects;subNum(m)];
                %pulling out data for only water paired animals
                elseif all(ismember(subNum, water_animals))
                    water_pairs = [water_pairs; data(sub_loc, i)];
                    water_pairs_subjects = [water_pairs_subjects;subNum(m)];
                end
            end
        end
     end
     % %add subjects for each day to an overall 'all' variable
     % %ethanol subject numbers
     EtOH_pairs_subjects_all{i} = EtOH_pairs_subjects;
     mixPair_EtOH_subjects_all{i} = mixPair_EtOH_subjects; 
     lone_EtOH_subjects_all{i} = lone_EtOH_subjects;
     % 
     % %water subject numbers
     water_pairs_subjects_all{i} = water_pairs_subjects;
     mixPair_water_subjects_all{i} = mixPair_water_subjects;
     lone_water_subjects_all{i} = lone_water_subjects;
     % 
     % %ethanol animal data
     EtOH_pairs_all{i} = EtOH_pairs;
     mixPair_EtOH_all{i} = mixPair_EtOH;
     lone_EtOH_all{i} = lone_EtOH;
     % %water animal data
     water_pairs_all{i} = water_pairs;
     mixPair_water_all{i} = mixPair_water;
     lone_water_all{i} = lone_water;
end

%% Within-subject Comparisons Across Pairings %%

%average the data within subjects for each EtOH-EtOH paired animal
[samePair_avg_data, samePair_avg_subjects, samePair_sum_pairs] = RAP_pairs_avg_subject(water_pairs, water_pairs_subjects);

%average the data within subject for each EtOH-H2O paired animal 
[mixPair_avg_data, mixPair_avg_subjects, mixPair_sum_pairs] = RAP_pairs_avg_subject(mixPair_water, mixPair_water_subjects);

%pull out ratIDs of group that you want to look at 
rats = ratsInfo.ratID(ratsInfo.treatment == "EtOH" & ratsInfo.strain == "P" & ratsInfo.sex == "F") % & (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium"));

%% Betwen subjects %%
%can use with averaged data or all data points 
%match group rats to the rats in the data

%initialize variables
same_group_data = [];
mix_group_data = [];

%looking at g/kg or g/kg/lick
for i = 1:numel(days)
    %find which subject numbers frontloaded on each i, on each day 
    RAP_subjects(frontloading)
    [same_group_loc] = ismember(water_pairs_subjects_all{i}, rats);
    same_group_data = water_pairs(same_group_loc);

    [mix_group_loc] = ismember(mixPair_water_subjects_all{i}, rats);
    mix_group_data = mixPair_water(mix_group_loc);
end

%looking at frontloading
for i = 1:numel(days)
    %check for NaNs from outliers and convert to 0 so they will be
    %converted to false
    frontloaders(isnan(frontloaders(:,i)),i) = 0;
    %find subject numbers of the rats that frontloaded on each day 
    frontloaders_subjects = RAP_subjects(logical(frontloaders(:, i)));
    %Pull out subject numbers of rats that frontloaded and are part of the
    %group of interest 
    frontloaders_rats = frontloaders_subjects(ismember(frontloaders_subjects, rats));

    %Pull out RAP consumption data only for the rats that frontloaded on each day and were in the rat
    %group of interest 
    [same_group_loc] = ismember(EtOH_pairs_subjects_all{i}, frontloaders_rats);
    same_group_data = [same_group_data; EtOH_pairs_all{i}(same_group_loc)];

    [mix_group_loc] = ismember(mixPair_EtOH_subjects_all{i}, frontloaders_rats);
    mix_group_data = [mix_group_data; mixPair_EtOH_all{i}(mix_group_loc)];
end

%% Within Subject Data %%
within_pairs_data = []; 
within_subjects = [];

for i = 1:numel(rats)
    loc1 = rats(i) == samePair_avg_subjects;
    loc2 = rats(i) == mixPair_avg_subjects;
    if any(loc1) & any(loc2)
        within_subjects = [within_subjects; rats(i)] ;
        within_pairs_data = [within_pairs_data; mixPair_avg_data(loc2) samePair_avg_data(loc1) ];
    end 
end 


%% Pull out grouped data %%

%grouped ratIDs
rats = ratsInfo.ratID(ratsInfo.treatment == "EtOH" & ratsInfo.strain == "P" & ratsInfo.sex == "M") %& (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium"));

groupData = [];
toAnalyze = EtOH_pairs_all;
toAnalyze_subjects = EtOH_pairs_subjects_all;

for i = 1:numel(sideMtx)
    %pull out the rats that are found in both the pairings I am interested
    %in and the ratsInfo group
    groupRats = [];
    groupRats = ismember(toAnalyze_subjects{i}, rats);
    if ~isempty(groupRats) 
        %pull out the g/kg data for just the rats that are in groupRats
        dayData = toAnalyze{i}(groupRats, 1);
        groupData = [groupData;mean(dayData, 'omitnan')];
    else
        groupData = [groupData;NaN];
    end 
end 