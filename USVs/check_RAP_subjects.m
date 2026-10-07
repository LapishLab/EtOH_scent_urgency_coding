%% Check that all RAP subjects are in each day 
% collects subject numbers in columns that correspond with each day. 
% check that each column contains the same numbers
%inputs needed: calls table from import_USVs
function [missing_all, extra_all] = check_RAP_subjects(t, opts)

arguments
    t %calls table
    opts.reference_subjects double = []; %vector of subjects to compare to all the subjects on each day 
end 

subject_t_var = 'subject';   % subject column name 
if any(t.Properties.VariableNames == "date")
    day_var  = 'date';      % date column name 
elseif ~any(t.Properties.VariableNames == "date")
    [~, filename, ~] = fileparts(t.export_path);
    file_date = extractBefore(filename, "_");
    t.date = string(file_date);
    day_var  = 'date';      % date column name 
end 

%pull out subjects
row_subjects = arrayfun(@(s) str2double(split(s, "_")), t.(subject_t_var), 'UniformOutput', false);

%split subjects 
[days, ~, day_idx] = unique(string(t.(day_var)), 'stable');

%compile the subjects present each day in a different cell. check for
%repeats 
subjects_per_day = cell(numel(days), 1);
for d = 1:numel(days)
    subjects_per_day{d} = sort(vertcat(row_subjects{day_idx == d}));
    [u, ~, j] = unique(subjects_per_day{d});
    counts = accumarray(j, 1);
    repeated = u(counts > 1);
    if ~isempty(repeated)
        fprintf('Day %s has repeated IDs: %s\n', string(days(d)), mat2str(repeated'));
    end
end

missing_all = {};
extra_all = {};

% check that every day contains the same IDs
%pull reference from ratsInfo 
for d = 1:numel(days)
    if ~isequal(opts.reference_subjects, subjects_per_day{d})
        missing = setdiff(opts.reference_subjects, subjects_per_day{d});
        extra   = setdiff(subjects_per_day{d}, opts.reference_subjects);
        fprintf('Day %s does not have same subjects as ratsInfo reference. Missing: %s | Extra: %s\n', ...
            string(days(d)), mat2str(missing'), mat2str(extra'));
        missing_all{d} = missing; extra_all{d} = extra;
    end
end
