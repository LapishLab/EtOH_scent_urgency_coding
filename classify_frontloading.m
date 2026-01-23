%% Classify Frontloading per each Rat %%

% calculate cumulative RAP data
consumptionOverTime = calc_cumulativeConsumption(RAP_all, RAP_lickTmSerMtx, RAP_totalLicks, cumulative_type = "g/kg");

data = consumptionOverTime;

days = [1 3 5 6 8 10];

all_results = {};
% calculate front loading data: slope before change point, slope after, and
% change point. find the fit for multiple different sets of data. Run with trials in rows
% and rats in columns 
for i = 1:numel(days)
    for j = 1:size(data{1},1)
        try 
            [nm, vals, fitResult, gof, pv] = getPwlSlopesDD(data{days(i)}(j,:)');
            res(j,:) = [vals(1) vals(2) vals(3) pv]; %[slope 1, slope 2, knot, pval]
            % figure(1)
            % plot(data{days(i)}(j,:),'ko-'); hold on
            % plot(fitResult,'r-');
            % xlabel('time(s)');
            % ylabel('cumulative g/kg')
            % titling = ['Day-' num2str(days(i)) '-rat-' num2str(ratsInfo.ratID(j))];
            % title(titling);
            % hold off
            %  filename = fullfile('C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\graphs\frontloading\piecewiseLinearCode', [titling '.jpg']);
            %  saveas(gcf, filename)
        catch 
            warning(['Day ' num2str(days(i)) ' row ' num2str(j) ' is not working'])
            res(j, :) = [0 0 0 0];
        end
    end
    all_results{i} = res;
end 

%% 
Metabolic_Rate = 0.0001; %enter the metabolic rate in g/kg/your timescale (min or sec). 

%check if the change point is in the first half of the session 

