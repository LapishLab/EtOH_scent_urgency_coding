%brain1
csv_path = "E:\072125_121225_Prat_urgency\DD\Prat_Urgency_audioSubjectInfo.csv";
%import the videos.csv file. Keeps the formatting the same where both
%columns contain strings
opts = detectImportOptions(csv_path, Delimiter=",");
opts = setvartype(opts, opts.SelectedVariableNames, 'string');
P_info = readtable(csv_path, opts);

