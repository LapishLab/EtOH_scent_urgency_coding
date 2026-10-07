%import and analyze USvs for RAP


csv_name = 'export_P'
t = import_USVs(file_name = csv_name)

sem = @(x) std(x, 'omitnan')/sqrt(sum(~isnan(x(:,1))));
avg_nan = @(x) mean(x, 'omitnan');

%% Check same subjects each day 
ratsInfo_subjects = ratsInfo.ratID(ratsInfo.strain == 'P');
[missing, extra]= check_RAP_subjects(t, reference_subjects=rat_subjects); %will spit out a warning if extra or missing subjects on days 

%% Frequency Thresholds %%

%RAP thresholds
sad_threshold = 33*1000;
happy_threshold = 52*1000;

%total session time 
RAP_sessionTime = -1*60:10:60*60;

%% Grouping: RAP renewal 
renewal_P = ["20251027" "20251028" "20251029" "20251030"];
renewal_wistar = ["20241007" "20241008" "20241009" "20241010"];

reduce table to just renewal 
condense = contains(t.strain, 'wistar') + ismember(string(t.date), renewal_P);
t = t(logical(condense), :);

EtOH_days = ismember(string(t.date), [renewal_P(1) renewal_P(3)]);
EtOH_pairs = contains(t.treatment, 'EtOH_EtOH'); 
water_pairs = contains(t.treatment, 'Control_Control'); 
mixed_pairs = (contains(t.treatment, 'EtOH_Control') | contains(t.treatment, 'Control_EtOH'));


%% Grouping: strains and sex %% 
Ps = contains(t.strain, "P");
wistars = contains(t.strain, "Wistar");
males =  contains(t.sex, "M");
females = contains(t.sex, "F");
pairs = contains(t.treatment, '_');


%% Grouping: EtOH vs Control
EtOH = contains(t.treatment, "EtOH");
H2O = contains(t.treatment, "Control");
pairs = contains(t.treatment, '_');

%% Reduce table to specific group
days = ismember(t.date, renewal_P([1 3]));
pairs = contains(t.treatment, '_');


specific_table = t(days & pairs,:);

%% Reduce table to certain time length

RAP_sessionTime = -1*60:10:60*60; 

for m = 1:height(specific_table)
    calls = specific_table.calls{m};
    calls_inTimeRange = isInRange(calls.Box(:,1), RAP_sessionTime(1), RAP_sessionTime(end));
    specific_table.calls(m) = {calls(calls_inTimeRange, :)};
end

%% USV histogram 

%pull out all the frequencies 
freqs = cellfun(@(c) c.frequency(:), specific_table.calls, UniformOutput=false);
all_freqs = vertcat(freqs{:});

%create a histogram 
histogram(all_freqs/1000, FaceColor=[0.3 0.3 0.3], BinWidth = 1)
%legend("Control", "EtOH");
title("P RAP USV Frequency Histogram", FontSize=16, FontName='Arial',FontWeight="Bold")
xline([33, 52])
xlabel("Frequency (kHz)", FontSize=12, FontName='Arial', FontWeight="Bold")
ylabel("Counts", FontSize=16, FontName='Arial', FontWeight="Bold")
ax = gca
ax.FontSize=30

xlim([20 100])


%% USV_rate 

RAP_sessionTime = -5*60:10:60*60; 

%calculate usv rate. Need the t calls table as it is formatted so reduce it
%before if you only want to analyze specific rows 

usv_rate = calc_USV_rate(specific_table, RAP_sessionTime)

%concat rate
all_usv_rate = [zeros(numel(usv_rate), 1) cat(1, usv_rate{:})];

shadedErrorBar(RAP_sessionTime, all_usv_rate, {avg_nan, sem}, 'lineProps',{ 'Color', 'green', 'DisplayName', 'Baseline (monday)'})

