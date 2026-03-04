
%initialize variables

sideMtx = RAP_sideMtx(2,1:10)

EtOH_animals = ratsInfo.ratID(ratsInfo.treatment == "EtOH");
water_animals = ratsInfo.ratID(ratsInfo.treatment == "Control");

%RAP_all = table2array(RAP_all);
RAP_subjects = repmat(ratsInfo.ratID(:), 1, 14);

%Cycle through each box pairing from RAP_sideMtx. Determine what the pairing of the 
%subjects is (EtOH_EtOH, EtOH_water, by themselves water or etoh). Assign the subject
%numbers from the side pairing to their own matrix. Pull the consumption
%and licks for each rat into a matrix specific to their pairing or lone
%matrix for each day. 
for i = 1:numel(sideMtx)
     %initialize variables for each day
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
     for rat = 1:size(sideMtx{i}, 1)
        %pull out data for each day
        dayPairs = sideMtx{i};
        %pull out subject numbers
        subNum = dayPairs(rat,~isnan(dayPairs(rat,:)));

       

        % --- Data for unpaired animals --- %
        %determine if rats were alone in the box or paired with another rat
        %rat was by itself if a nan was present in the other box location

        if any(isnan(dayPairs(rat,:)))
            sub_loc = RAP_subjects(:,i) == subNum;
            % --- Data for mixed EtOH and water pairings --- %
            if any(ismember(subNum, water_animals))
                lone_water = [lone_water; RAP_all(sub_loc, i) RAP_totalLicks(sub_loc, i)];
                lone_water_subjects = [lone_water_subjects;subNum];
                %add subject number and data to matrix for EtOH animals
            elseif ismember(subNum, EtOH_animals)
                lone_EtOH = [lone_EtOH; RAP_all(sub_loc, i) RAP_totalLicks(sub_loc, i)];
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
                    mixPair_water = [mixPair_water; RAP_all(sub_loc, i) RAP_totalLicks(sub_loc, i)];
                    mixPair_water_subjects = [mixPair_water_subjects;subNum(m)];
                %pulling out data for mixed etoh and water pairings. Only
                %the etoh animals 
                elseif sum(ismember(subNum, water_animals)) == 1 & ismember(subNum(m), EtOH_animals)
                    mixPair_EtOH = [mixPair_EtOH; RAP_all(sub_loc, i) RAP_totalLicks(sub_loc, i)];
                    mixPair_EtOH_subjects = [mixPair_EtOH_subjects;subNum(m)];
                    %pulling out data for only EtOH paired animals
                elseif all(ismember(subNum, EtOH_animals))
                    EtOH_pairs = [EtOH_pairs; RAP_all(sub_loc, i) RAP_totalLicks(sub_loc, i)];
                    EtOH_pairs_subjects = [EtOH_pairs_subjects;subNum(m)];
                    %pulling out data for only water paired animals
                elseif all(ismember(subNum, water_animals))
                    water_pairs = [water_pairs; RAP_all(sub_loc, i) RAP_totalLicks(sub_loc, i)];
                    water_pairs_subjects = [EtOH_pairs_subjects;subNum(m)];
                end
            end
        end
     end
     EtOH_pairs_all{i} = EtOH_pairs;
     EtOH_pairs_subjects_all{i} = EtOH_pairs_subjects;
     mixPair_EtOH_all{i} = mixPair_EtOH;
     mixPair_EtOH_subjects_all{i} = mixPair_EtOH_subjects; 
end

%% Pull out grouped data %%

%grouped ratIDs
rats = ratsInfo.ratID(ratsInfo.treatment == "EtOH" & ratsInfo.strain == "P" & ratsInfo.sex == "F") %& (ratsInfo.drinkClass == "High" | ratsInfo.drinkClass == "Medium"));

data = [];
toAnalyze = mixPair_EtOH_all;
toAnalyze_subjects = mixPair_EtOH_subjects_all;

for i = 1:numel(sideMtx)
    %pull out the rats that are found in both the pairings I am interested
    %in and the ratsInfo group
    groupRats = [];
    groupRats = ismember(toAnalyze_subjects{i}, rats);
    %pull out the g/kg data for just the rats that are in groupRats
    dayData = toAnalyze{i}(groupRats, 1);
    data = [data;mean(dayData, 'omitnan')];
end 