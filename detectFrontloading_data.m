function [subjectClassification changePoint_all firstSlope_all secondSlope_all] = detectFrontloading_data(Dataset, subjects)

%% Analyze_Frontloading.m %%
%inputs needed:
%   data:single day of RAP consumption data over time (not cumulative) organized with time over rows and subjects in columns
%   subjects: vector of subject numbers 

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


%% Load Info %%
Time_Variable = 'Second'; %Change the timescale to match your data; 'Minute' or 'Second'
Metabolic_Rate = 0.0001; %enter the metabolic rate in g/kg/your timescale (min or sec). 
%See ChooseExample function for some commonly used metabolic rates.

%initiate variables
%will hold the inconclusive, frontloading, or non frontloading
%classification for animals
subjectClassification = {};
%hold the first change point
changePoint_all = [];
%hold the slope before the first change point
firstSlope_all = [];
%hold the slope after the first change point
secondSlope_all = [];

%% Classify drinking behavior %%

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
    chPt = model.ch; %produces 3 change points
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
    
    %if these if statements are true, the animal is classified as inconclusive.
    %the first change point is greater than the other two means that the most signiticant change
    %point isn't the earliest in the session.  criteria1 = false/0 
    if chPt(1) > chPt(2) && chPt(1) > chPt(3) || chPt(1) < chPt(2) && chPt(1) > chPt(3) || chPt(1) > chPt(2) && chPt(1) < chPt(3) 
        %if criteria 1 is not met, classify subject as inconclusive.  
        Criteria1 = 0;
        subjectClassification(XX,1:2) = {subjects(XX), "Inconclusive"};
        changePoint_all = [changePoint_all; chPt(1)];
        firstSlope_all = [firstSlope_all; stats_pre.beta(2)];
        secondSlope_all = [secondSlope_all; stats_post.beta(2)]; 
    else
        %if the first change point is in the first half of the session,
        %they move on to the next stage of analysis 
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
            %add subject number for frontloader
            subjectClassification(XX,1:2) = {subjects(XX), "Frontloader"};
            changePoint_all = [changePoint_all; chPt(1)];
            firstSlope_all = [firstSlope_all; stats_pre.beta(2)];
            secondSlope_all = [secondSlope_all; stats_post.beta(2)];
        else
            subjectClassification(XX,1:2) = {subjects(XX), "Non_frontloader"};
            changePoint_all = [changePoint_all; chPt(1)];
            firstSlope_all = [firstSlope_all; stats_pre.beta(2)];
            secondSlope_all = [secondSlope_all; stats_post.beta(2)];
        end 
        clear h hx fig_name figuresdir newname raw data stats_pre stats_post t_stat t_stat_den t_stat_df t_stat_num Criteria1 Criteria2 Criteria3 model model1 time_axis time_axis2 Metabolic_rate_plot time_post time_pre y_post y_pre
    end
end