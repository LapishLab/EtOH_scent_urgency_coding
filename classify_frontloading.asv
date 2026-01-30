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
% calculate front loading data: slope before change point, slope after, and
% change point. find the fit for multiple different sets of data. Run with trials in rows
% and rats in columns 
for i = 1:numel(days)
    %reset p value variable holder
    p = [];
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
        catch 
            warning(['Day ' num2str(days(i)) ' row ' num2str(j) ' is not working'])
            res(j, :) = [0 0 0 0];
            
        end
    end
    all_results{i} = res;
    all_p_slopeDiff = [all_p_slopeDiff p]; % Store p-values for the slope difference for each rat
end 

%% 
Metabolic_Rate = 0.0001; %enter the metabolic rate in g/kg/your timescale (min or sec). 

%check if the change point is in the first half of the session 
%calculate standard error of each line 