
%initialize variables
%pull out the data for wistars (row 1) or P rats (row 2)
sideMtx = RAP_sideMtx(1,[6 8 10]);

%pull out ethanol and water animal subject numbers to compare to subject
%numbers in the box to determine what each animals reinforcer was. 
EtOH_animals = ratsInfo.ratID(ratsInfo.treatment == "EtOH");
water_animals = ratsInfo.ratID(ratsInfo.treatment == "Control");

%RAP_all = table2array(RAP_all);
RAP_subjects = repmat(ratsInfo.ratID(:), 1, 6);

data = [];
%specify which data to look at 
%frontloading slopes (only have it for EtOH days in RAP)
% data = slope1; 
% total g/kg cons. Have to pull out only the EtOH days 
data = RAP_all(:, [1 3 5 6 8 10]);
% g/kg/lick. Have to pull out only the EtOH days
% make any infinity values from not recording any licks set to 0 
% data = table2array(RAP_all(:, [1 3 5 6 8 10])./RAP_totalLicks(:,[1 3 5 6 8 10]));
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
     % EtOH_pairs_subjects_all{i} = EtOH_pairs_subjects;
     % mixPair_EtOH_subjects_all{i} = mixPair_EtOH_subjects; 
     % lone_EtOH_subjects_all{i} = lone_EtOH_subjects;
     % 
     % %water subject numbers
     % water_pairs_subjects_all{i} = water_pairs_subjects;
     % mixPair_water_subjects_all{i} = mixPair_water_subjects;
     % lone_water_subjects_all{i} = lone_water_subjects;
     % 
     % %ethanol animal data
     % EtOH_pairs_all{i} = EtOH_pairs;
     % mixPair_EtOH_all{i} = mixPair_EtOH;
     % lone_EtOH_all{i} = lone_EtOH;
     % %water animal data
     % water_pairs_all{i} = water_pairs;
     % mixPair_water_all{i} = mixPair_water;
     % lone_water_all{i} = lone_water;
end

%% Within-subject Comparisons Across Pairings %%

%average the data within subjects for each EtOH-EtOH paired animal
[samePair_avg_data, samePair_avg_subjects] = RAP_pairs_avg_subject(water_pairs, water_pairs_subjects);

%average the data within subject for each EtOH-H2O paired animal 
[mixPair_avg_data, mixPair_avg_subjects] = RAP_pairs_avg_subject(mixPair_water, mixPair_water_subjects);

%pull out ratIDs of group that you want to look at 
rats = ratsInfo.ratID(ratsInfo.treatment == "Control" & ratsInfo.strain == "Wistar" & ratsInfo.sex == "F") %& (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium"));

within_pairs_data = []; 
within_subjects = [];

for i = 1:numel(rats)
    loc1 = rats(i) == samePair_avg_subjects;
    loc2 = rats(i) == mixPair_avg_subjects;
    if any(loc1) & any(loc2)
        within_subjects = [within_subjects; rats(i)] ;
        within_pairs_data = [within_pairs_data; EtOH_avg_data(loc1) mixPair_EtOH_avg_data(loc2)];
    end 
end 


%% Pull out grouped data %%

%grouped ratIDs
rats = ratsInfo.ratID(ratsInfo.treatment == "EtOH" & ratsInfo.strain == "Wistar" & ratsInfo.sex == "M") & (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium"));

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