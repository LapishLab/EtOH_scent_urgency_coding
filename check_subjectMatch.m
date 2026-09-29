function check_subjectMatch(subject_numbers)

%input should be a matrix of subject numbers. Columns are days and rows are
%subjects. Takes column pairs and checks that the numbers match exactly rowwise 
%group_subjects

missing_subjects = cell(size(subject_numbers,2));

%use a sliding window. Compare column1 to column2, then column2 to column3
%etc 
for i = 1:size(subject_numbers, 2)-1
    col1 = subject_numbers(:,i);
    col2 = subject_numbers(:,i+1);
    matching_rows = col1==col2;

    if ~all(matching_rows)
        warning("All subject numbers don't match rowwise for days %d and %d", i, i+1) 
        missing = ismember(col1, col2);
        missing_subjects{i} = col1(~missing);
    end 

    if numel(unique(subject_numbers(:,i))) ~= size(subject_numbers(:, i), 1)
        warning("Not enough subjects in day %d", i)   
    end 
end 