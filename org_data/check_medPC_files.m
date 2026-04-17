%% Check medPC files %%
% Check that medPC files within each datastar folder are all from the same
% date and not duplicated in other folders. Do this by checking that the
% dates on all the text files and folders match

csv_file = readtable("C:\Users\annar\OneDrive\Documents\IUSM\Dr. Lapish Lab\EtOH_scent_Urgency\audioFiles_subjectInfo.csv", 'Delimiter', ',');

%pull out all dates in each path 
newPath = regexprep(path, '\d{4}-\d{2}-\d{2}', '');

%save all files where the dates across the whole path don't match up 
incorrect_dates
for i = 1:size(csv_file,1);

end 