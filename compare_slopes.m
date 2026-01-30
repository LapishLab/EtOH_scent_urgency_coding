
function p = compare_slopes(ex, vals, fitResults, time)
%% Is slope1 > slope2 %%

%find y predicted value at knot because knot is not normally a whole number
knot_yPredicted = (vals(1) * vals(3))+0;

%calculate coefficients and standard error for the two slopes 
%model for first slope 
slope1_mdl = fitlm([1:floor(vals(3))], ex(1:floor(vals(3))), 'Intercept', false);

%model for the second slope
slope2_mdl = fitlm([ceil(vals(3)):time], ex(ceil(vals(3)):end));

%subtract slopes from each other 
slope_diff = slope1_mdl.Coefficients.Estimate - slope2_mdl.Coefficients.Estimate(2);

%divide slope different by standard error of the difference between
%regression coefficients
slope_error = sqrt((slope1_mdl.Coefficients.SE ^2) + (slope1_mdl.Coefficients.SE ^2));

%calculate t-statistic
t_stat = slope_diff / slope_error;

%find total degress of freedom 
t_stat_df = slope1_mdl.DFE + slope2_mdl.DFE;

%calculate the p-value
p = (1-tcdf(t_stat, t_stat_df));