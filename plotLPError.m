function s = plotLPErrorMn(eDays, data, cenFun, varargin);
%% takes in a set of data that stretches across a certain number of days and
%creates a lineplot with error bars. Data has to be organized in rat x day.
%
SEM = nanstd(data) ./ (sqrt(size(data,1)));
    if cenFun == "mn";
    s = errorbar(eDays, nanmean(data), SEM, varargin{:});
    end
    if cenFun == "mdn";
    s = errorbar(eDays, nanmedian(data), SEM, varargin{:});
    end
end