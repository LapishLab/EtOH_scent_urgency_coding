%takes in a set of data that stretches across a certain number of days and
%creates a lineplot with error bars. Data has to be organized in rat x day.
%
function s = plotZscLPError(eDays, data, cenFun, varargin);
    %find the zscores across each animal (each row). Decreases between
    %subject variability because standardizes each score
    zScores = zscore(data, 0, 2);
    SEM = nanstd(zScores) / (sqrt(length(zScores)));
    if cenFun == "mean";
    s = errorbar(eDays, mean(zScores), SEM, varargin{:});
    end
    if cenFun == "median";
    s = errorbar(eDays, median(zScores), SEM, varargin{:});
    end
end