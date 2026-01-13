%Analyze_Frontloading.m

%This script analyzes alcohol drinking patterns to assess if
%alcohol front-loading is present using the following
%criteria:
%1*. Of three detected change points, the change point with the best fit
%is the earliest and/or is within the first half of the session. This
%becomes the reference change point for criteria 2 & 3 -
%2. The pre-change point slope exceeds the rate of alcohol metabolism, providing
%evidence of intoxication
%3. The pre-change point slope is signficantly different than the
%post-change point slope
%The code will save a 'Subject_Number_Summary.mat' file and
%graphs which classify subjects as front-loaders, non-frontloaders, or
%inconclusive

%*Note: if criteria 1 is not met, subjects are classified as "inconclusive
%results." In many cases, these subjects have a lot of consumption at the
%end of the session, where the rate of this 'backloading' is greater than
%the rate of any frontloading. However, this does not necessarily mean that
%there was no substantial intake at the beginning of the session. Users of
%this code should consider the most clinically and experimentally relevant
%definition of front-loading when determining whether front-loading
%occurred. The categorizations determined by this code are only meant to
%serve as suggestions, not hard and fast rules.

%Data input should be volume consumed over time (i.e. g/kg/min or g/kg/sec). See example
%datasets. HAP2 and cHAP/HDID examples are in g/kg/min. Wistar rat example
%data are in g/kg/sec.

%% analyze change points
clear all
close all



%% Organize the data in consumption (g/kg) per time unit %% 
% can be in second or minute bins 

%vectors holding details from the experiment
days = [1:size(RAP_all, 2)];
rats = [1:size(RAP_all, 1)];

%create minute or second time bins by making a vector of 1:60 or 1:3600 
trlTime = [0:3600];
%variable that will hold the data across all days
consumptionOverTime = {} ;

%for loop that organizes the data for front loading by calculating the amount of ethanol 
%consumed during each second time bin. 
for day = 1:numel(days);
    %variable that will hold the data for each day
    consBin = [];
    for rat = 1:numel(rats);
        %pull out the individual data for each rat on each day
        lickTms = RAP_lickTmSerMtx{day}{rat};
        %calculate the number of licks in each second time bin
        binLicks = histcounts(lickTms,trlTime);
        %divide each time bin by the total number of licks to get the
        %percentage of licks in each time bin
        percLick = binLicks./numel(lickTms);
        %multiple the lick per bin percentage by total consumption to find the amount
        %consumed during each second bin and add it to the array 
        indConsBin = percLick.*table2array(RAP_all(rat,day));
        consBin = [consBin;indConsBin];
    end;
    consumptionOverTime{day} = consBin;
end; 


%% Load Info %%
%Thanks for using our code. Please load your data, specify timescale &
%metabolic rate below: 
dname = pwd; 
cd ([dname]); %go to the folder where Detect_Frontloading.m is saved
Dataset = consumptionOverTime{1}'; %call your data matrix here. Individual subjects on columns, data (not cumulative) over time on rows
Dir = "C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\graphs\frontloading\day1" %enter the name of the folder where you want your results to be saved
Time_Variable = 'Second'; %Change the timescale to match your data; 'Minute' or 'Second'
Metabolic_Rate = 0.0001 %enter the metabolic rate in g/kg/your timescale (min or sec). 
%See ChooseExample function for some commonly used metabolic rates.

%create the directories to move the data into
mkdir(Dir, 'Identified_Frontloaders');
mkdir(Dir, 'Inconclusive_Results');
mkdir(Dir, 'Identified_Non_Frontloaders');

%create vector of subject numbers
subjects = ratsInfo.ratID'

%initiate variables to hold the subject numbers of each group 
Inconclusive_Result_Subject_Numbers = [];
Frontloader_Subject_Numbers = [];
Non_Frontloader_Subject_Numbers = [];

M=3; k = 2; B = 100; alpha = 0.05; %inputs for PARCs function;
%see parcs.m for description of parameters. 

%Get appropriate axis label based on which example was chosen:
if Time_Variable == 'Second'
    Lgd = 'Metabolic Rate (g/kg/sec)';
else
    Lgd = 'Metabolic Rate (g/kg/min)';
end

%Make all graphs on same YAxis: 
MaxYAxis = max(max(cumsum(Dataset))); 

for XX = 1:numel(subjects);
    data = Dataset(:,XX);
    
    if data(1) ~= 0;
        data = [0; data]; %if there is not a leading zero, add one. B/c the cumulative
        %sum data works against frontloaders if they drank during the
        %first timepoint (this is a problem esp. w/ DID data)
    end
    
    %Run the PARCS function to detect change points
    %Then, run a basic regression to get stats on pre versus post strongest
    %change point 
    
    model = parcs(data,M);
    chPt = model.ch;
    model1 = bpb4parcs(model,k,B,alpha);
    
    time_axis = 1:length(data);
    y_pre = cumsum(data(1:chPt(1,1)));
    time_pre = time_axis(1:chPt(1,1))';
    stats_pre = regstats(y_pre, time_pre);
    
    y_post = cumsum(data(chPt(1,1):end));
    time_post = time_axis(chPt(1,1):end);
    stats_post = regstats(y_post, time_post);
    
    %CRITERIA 1
    %1.1: is the earliest change point the most significant?
    %1.2: is this change point within the first half of the session?
    %if neither of these are met; the results are classified as
    %inconclusive:
    
       half_session = length(data)/2;
    
    if chPt(1) > chPt(2) && chPt(1) > chPt(3) && chPt(1) > half_session
        Inconclusive_Result_Data{XX} = data;
        Inconclusive_Result_Subject_Numbers = [Inconclusive_Result_Subject_Numbers subjects(XX)];
        Criteria1 = 0;
        
        %if criteria 1 is not met, classify subject as inconclusive: 
        
        h = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'visible','off')
        hx = xline(chPt(1,1),'-',{'Change','Point'}, 'HandleVisibility','off', 'LineWidth', 3);
        hx.FontSize = 20;
        time_axis2 = (time_axis)'; %flip to fit curve
        cumulative_data = cumsum(data);
        [curve, goodness, output] = fit(time_axis2, cumulative_data, 'smoothingspline');
        hold on
        h1 = plot(curve, time_axis2, cumulative_data);
        Metabolic_rate_plot = Metabolic_Rate * time_axis;
        hold on; plot(time_axis, Metabolic_rate_plot, 'LineWidth', 5);
        title(['Subject Number ' num2str(subjects(XX))]);
        legend({"Cumulative" + newline + "Intake (g/kg)", 'Fit Data', sprintf(Lgd)}, 'location', 'northoutside');
        set(gca,'FontSize',20); xlabel(sprintf(Time_Variable));  ylabel({['Cumulative EtOH' newline 'Intake (g/kg)']});
        xlim([0 length(data)]); ylim([0 MaxYAxis]);
        set(h1,'LineWidth',5); set(h1, 'MarkerSize', 20);
        fig_name = strcat('Fig_Animal_',num2str(subjects(XX)));
        figuresdir = ([Dir '/Inconclusive_Results']);
        newname = fullfile(figuresdir, [fig_name '.png']);
        saveas(h, newname, 'png');
        close all
    else
        Criteria1 = chPt(1) < half_session;
        
        %CRITERIA 2
        %Determine if the slope prior to the change point is greater than the
        %metabolic rate is determined when you select the example at the
        %beginning
        
        Criteria2 = stats_pre.beta(2) > Metabolic_Rate;
        
        %CRITERIA 3
        %Is the pre-change point slope significantly higher than
        %the post change-point slope?
        
        t_stat_num = stats_pre.beta(2) - stats_post.beta(2);
        t_stat_den = sqrt((stats_pre.tstat.se(2)^2) + (stats_post.tstat.se(2)^2));
        t_stat = t_stat_num / t_stat_den;
        t_stat_df = stats_pre.tstat.dfe + stats_post.tstat.dfe;
        p = (1-tcdf(abs(t_stat), t_stat_df));
        Criteria3 = p < alpha && stats_pre.beta(2) > stats_post.beta(2);
        
        %group animals by front-loaders or non-front-loaders:
        if (Criteria1 == 1) && (Criteria2 == 1) && (Criteria3 == 1)
            Frontloader_Data{XX} = data;
            Frontloader_Subject_Numbers = [Frontloader_Subject_Numbers subjects(XX)];
            
            h = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'visible','off')
            hx = xline(chPt(1,1),'-',{'Change','Point'}, 'HandleVisibility','off', 'LineWidth', 3);
            hx.FontSize = 20;
            time_axis2 = (time_axis)'; %flip to fit curve
            cumulative_data = cumsum(data);
            [curve, goodness, output] = fit(time_axis2, cumulative_data, 'smoothingspline');
            hold on
            h1 = plot(curve, time_axis2, cumulative_data);
            Metabolic_rate_plot = Metabolic_Rate * time_axis;
            hold on; plot(time_axis, Metabolic_rate_plot, 'LineWidth', 5);
            title(['Subject Number ' num2str(subjects(XX))]);            
            legend({"Cumulative" + newline + "Intake (g/kg)", 'Fit Data', sprintf(Lgd)}, 'location', 'northoutside');
            set(gca,'FontSize',20); xlabel(sprintf(Time_Variable));  ylabel({['Cumulative EtOH' newline 'Intake (g/kg)']});
            xlim([0 length(data)]); ylim([0 MaxYAxis]);
            set(h1,'LineWidth',5); set(h1, 'MarkerSize', 20);
            fig_name = strcat('Fig_Animal_',num2str(subjects(XX)));
            figuresdir = ([Dir '\Identified_Frontloaders']);
            newname = fullfile(figuresdir(1), [fig_name '.png']);
            saveas(h, newname, 'png');
            close all
        else
            Non_Frontloader_Data{XX} = data;
            Non_Frontloader_Subject_Numbers = [Non_Frontloader_Subject_Numbers subjects(XX)];
            
            h = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'visible','off')
            hx = xline(chPt(1,1),'-',{'Change','Point'}, 'HandleVisibility','off', 'LineWidth', 3);
            hx.FontSize = 20;
            time_axis2 = (time_axis)'; %flip to fit curve
            cumulative_data = cumsum(data);
            [curve, goodness, output] = fit(time_axis2, cumulative_data, 'smoothingspline');
            hold on
            h1 = plot(curve, time_axis2, cumulative_data);
            Metabolic_rate_plot = Metabolic_Rate * time_axis;
            hold on; plot(time_axis, Metabolic_rate_plot, 'LineWidth', 5);
            title(['Subject Number ' num2str(subjects(XX))]);            
            legend({"Cumulative" + newline + "Intake (g/kg)", 'Fit Data', sprintf(Lgd)}, 'location', 'northoutside');
            set(gca,'FontSize',20); xlabel(sprintf(Time_Variable));  ylabel({['Cumulative EtOH' newline 'Intake (g/kg)']});
            xlim([0 length(data)]); ylim([0 MaxYAxis]);
            set(h1,'LineWidth',5); set(h1, 'MarkerSize', 20);
            fig_name = strcat('Fig_Animal_',num2str(subjects(XX)));
            figuresdir = ([Dir '/Identified_Non_Frontloaders']);
            newname = fullfile(figuresdir, [fig_name '.png']);
            saveas(h, newname, 'png');
            close all
        end
        clear h hx fig_name figuresdir newname raw data stats_pre stats_post t_stat t_stat_den t_stat_df t_stat_num Criteria1 Criteria2 Criteria3 model model1 time_axis time_axis2 Metabolic_rate_plot time_post time_pre y_post y_pre
    end
end

%save subject numbers into categories:
clearvars -except Frontloader_Subject_Numbers Inconclusive_Result_Subject_Numbers Non_Frontloader_Subject_Numbers

%create one vector with all the information for each subject 
%create a vector with the subject numbers sorted
subjectNumbers = sort([Frontloader_Subject_Numbers Non_Frontloader_Subject_Numbers Inconclusive_Result_Subject_Numbers]);
%create variable to hold the front loading classifications. Loader means
%they are a front loader, nonLoader means they aren's and inconclusive
%means neither 
loadingClassification = []
%determine which category the subject number is in and classify it
for i = 1:length(subjectNumbers);
    if sum(subjectNumbers(i) == Frontloader_Subject_Numbers) == 1;
        loadingClassification{i} = 'loader';
    elseif sum(subjectNumbers(i) == Non_Frontloader_Subject_Numbers) == 1;
        loadingClassification{i} = 'nonloader';
    elseif sum(subjectNumbers(i) == Inconclusive_Result_Subject_Numbers) == 1;
        loadingClassification{i} = 'inconclusive';
    end;
end;
%remember to save the variables 