%brain1
csv_path = "E:\videos.csv";
%import the videos.csv file. Keeps the formatting the same where both
%columns contain strings
opts = detectImportOptions(csv_path, Delimiter=",");
opts = setvartype(opts, opts.SelectedVariableNames, 'string');
t = readtable(csv_path, opts);

