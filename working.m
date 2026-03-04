group = ratsInfo.treatment == "EtOH" & ratsInfo.strain == "Wistar"  & ratsInfo.sex == "F" & (ratsInfo.drinkClass == "High"| ratsInfo.drinkClass == "Medium");


delays = [0 1 2 4 8 16];
tocalc = LLMtx;
data = [];
for i = 1:numel(delays)
    delayEnd = i*4;
    %pull out the last 2 days of each delay 
    %data = [data tocalc(group, [delayEnd-1 delayEnd])];
    
    %mean of last 2 days of each delay
    data = [data median(tocalc(group, [delayEnd-1 delayEnd]), 2,'omitnan')];
    
    %trial specific mean of the last 2 days of each delay
    %data(:,i) = mean(cat(3, allDDiVals{delayEnd-1}(group, :), lastTenDDiVals{delayEnd}(group,:)),3,'omitnan')
end 

%% 
group = ratsInfo.treatment == "EtOH" & ratsInfo.strain == "Wistar";
group2 = ratsInfo.treatment == "EtOH" & ratsInfo.strain == "P";
p = IAP_all{group, [10:end]};
p2 = IAP_all{group2, [10:end]};

fig1 = figure();
histogram(p, 'BinWidth', 0.7, 'FaceColor', [0.5 0 0.5]);
hold on
histogram(p2, 'BinWidth',0.7, 'FaceColor',  [0.1 0.5 0.3]);
xlabel("Cons (g/kg)", 'FontSize', 45, 'FontName', 'arial', 'FontWeight','bold');
ylabel("Counts", 'FontSize', 45, 'FontName', 'arial', 'FontWeight','bold');
xline(1.5, ':', 'LineWidth',3)
xline(3.5, ':', 'LineWidth',3)
ax = gca
ax.FontSize = 30;
ax.FontSize = 30;
hold off

%% IAP & RAP

group = ratsInfo.strain == "Wistar" & ratsInfo.sex == "M" & ratsInfo.treatment == "EtOH" & (ratsInfo.drinkClass == "High"| ratsInfo.drinkClass == "Medium");
p = RAP_totalLicks(group,[1 3 5 6 8 10]);
