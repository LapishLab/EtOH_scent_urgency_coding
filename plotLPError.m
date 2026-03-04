function s = plotLPErrorMn(eDays, data, cenFun, varargin);
%% takes in a set of data that stretches across a certain number of days and
%creates a lineplot with error bars. Data has to be organized in rat x day.
%
SEM = std(data, 'omitnan') ./ (sqrt(size(data,1)));
    if cenFun == "mean";
    s = errorbar(eDays, mean(data, 1, 'omitnan'), SEM, varargin{:});
    end
    if cenFun == "median";
    s = errorbar(eDays, median(data, 1, 'omitnan'), SEM, varargin{:});
    end
end