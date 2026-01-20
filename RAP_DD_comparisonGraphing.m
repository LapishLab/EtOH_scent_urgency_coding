%% Organize DD curve Data %%
% variables needed: allDDiVals

%initialize variables
indifference_points = []

%delay vector
delays = [0 1 2 4 8 16];

%create a vector of indifference points. average of the last two days for each rat
for i = 1:numel(delays)
    days = [(4*i-1) (4*i)]; %variable column location of last 2 days for each delay
    iVals_delays = mean(lastTenDDiVals(:,[days]),2); %pull the last two columns of each delay out and find the mean
    indifference_points = [indifference_points iVals_delays]; %creates a matrix with each column containing the average of the last two days of each delay
end

discounting_K = getKvalue(delays,indifference_points)

%% Compare K value with drinking amounts 
%variables needed: IAP_consumption, RAP_consumption, ratsInfo 

%find mean of the last week of IAP
IAP_week4_mn = mean(table2array(IAP_all(:, end-2:end)), 2); 

%find mean of the last week of RAP
RAP_week2_mn = mean(table2array(RAP_all(:, 4:6)), 2);

%group
group1 = ratsInfo.treatment == "EtOH" & ratsInfo.strain == "Wistar"
group2 = ratsInfo.treatment == "EtOH" & ratsInfo.strain == "P"

%compare RAP to discounting 
w = scatter(discounting_K(group1), RAP_week2_mn(group1), 'ColorVariable', 'red')
hold on 
p = scatter(discounting_K(group2), RAP_week2_mn(group2), 'ColorVariable', 'blue')
xlabel("Discounting (k)")
ylabel("Consumption (g/kg)")
hold off

%compare IAP to discounting 
w = scatter(discounting_K(group1), IAP_week4_mn(group1), 'ColorVariable', 'red')
hold on 
p = scatter(discounting_K(group2), IAP_week4_mn(group2), 'ColorVariable', 'blue')
hold off

