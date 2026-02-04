%% Classify Frontloading per each Rat %%

%% Calculate data for each rat

%time scale variable
time = 3600;
% calculate cumulative RAP data
consumptionOverTime = calc_cumulativeConsumption(RAP_all, RAP_lickTmSerMtx, RAP_totalLicks, cumulative_type = "g/kg", time = time);

data = consumptionOverTime;

days = [1 3 5 6 8 10];

all_results = {};
all_p_slopeDiff = [];
all_frontloaders = [];

half_session = size(data{1},2)/2; %calculate half point of the session 
Metabolic_Rate = 0.0001; %enter the metabolic rate in g/kg/your timescale (min or sec). g/kg/sec 

% calculate front loading data: slope before change point, slope after, and
% change point. find the fit for multiple different sets of data. Run with trials in rows
% and rats in columns 
for i = 1:numel(days)
    %reset p value variable holder
    p = [];
    %reset frontloader classification counter
    frontloaders = [];
    for j = 1:size(data{1},1)
        try 
            %calculate and assess fit of piecewise linear function onto
            %data
            [nm, vals, fitResult, gof, pv] = getPwlSlopesDD(data{days(i)}(j,:)', yintercept=0);
            res(j,:) = [vals(1) vals(2) vals(3) pv]; %[slope 1, slope 2, knot, pval]
            %calculate if slope1 is significantly greater than slope2 
            p(j,:) = compare_slopes(data{days(i)}(j,:),vals, fitResult, time);
            % figure(1)
            % plot(data{days(i)}(j,:),'ko-'); hold on
            % plot(fitResult,'r-');
            % xlabel('time(s)');
            % ylabel('cumulative g/kg')
            % titling = ['Day-' num2str(days(i)) '-rat-' num2str(ratsInfo.ratID(j))];
            % title(titling);
            % hold off
            % filename = fullfile('C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\graphs\frontloading\piecewiseLinearCode', [titling '.jpg']);
            % saveas(gcf, filename)

            %to classify frontloaders by day
            %knot is in the first half of the session
            %the first slope is greater than metabolic rate to ensure
            %intoxication is achieves
            %the first slope is significantly greater than the second slope
            if vals(3) < half_session & vals(1) > Metabolic_Rate & p(j,:) < 0.05
                frontloaders(j,:) = 1;
            else 
                frontloaders(j,:) = 0;
            end 
        catch 
            warning(['Day ' num2str(days(i)) ' row ' num2str(j) ' is not working'])
            res(j, :) = [NaN NaN NaN NaN];
            p(j,:) = NaN;
            frontloaders(j,:) = NaN;
            
        end
    end
    all_results{i} = res;
    all_p_slopeDiff = [all_p_slopeDiff p]; % Store p-values for the slope difference for each rat
    all_frontloaders = [all_frontloaders frontloaders]; %store frontloading classifications for each day 
end 

%classify true frontloaders as those who frontloaded at least 3 of the 5
%days with ethanol access
trueFrontloaders = sum(all_frontloaders, 2, "omitmissing") >= 4; 

slope1 = [];
slope2 = [];
%pull out slope1 and slope2 in separate variables 
for i = 1:numel(all_results)
    slope1 = [slope1 all_results{i}(:, 1)];
end 



%% Correlations between Slopes and k %%

slope_diff = slope1 - slope2

%find the average of slope1 only on those days that they were found to
%frontload
avg_slope1 = [];
for i = 1:numel(nl_k)
    loadDays = all_frontloaders(i, :);
    %convert NaNs to false
    if any(isnan(loadDays))
         loadDays(isnan(loadDays)) = 0;
    end
    avg_slope1 = [avg_slope1; mean(slope_diff(i, logical(loadDays)), 'omitnan')];
end

avg_slope1 = mean(slope_diff(:, [4:6]), 2, 'omitnan')
%standardize within strains 
group1 = ratsInfo.treatment == "EtOH" & ratsInfo.strain == "P" %& trueFrontloaders;
standard_p = zscore(avg_slope1(group1))

group2 = ratsInfo.treatment == "EtOH" & ratsInfo.strain == "Wistar" %& trueFrontloaders;
standard_w = zscore(avg_slope1(group2),[], 'omitnan')

nl_k = log(discounting_K);
nl_k_p = zscore(nl_k(group1));
nl_k_w = zscore(nl_k(group2));

%group = ratsInfo.treatment == "EtOH" & trueFrontloaders & ratsInfo.strain == "P";

[r, p] = corr([standard_p;standard_w], [nl_k_p;nl_k_w], "Type","Pearson", "Rows","complete")
scatter(standard_p, nl_k_p)
hold on;
scatter(standard_w, nl_k_w)
title("k vs. RAP slope difference")
xlabel("z-scored mean slope1-slope2")
ylabel("z-scored nl(k)")
hold off;
