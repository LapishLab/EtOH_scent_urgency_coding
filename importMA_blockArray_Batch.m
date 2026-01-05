function [allData] = importMA_blockArray_Batch(pat);

%% importMA_Batch
%% This code will detect the Med Associates files in a directory and import them all
%  pat the path and the directory to your data. 
%  For example pat = '/Users/clapish/Desktop/MA'

d = dir([pat]);                           % Find the contents of the directory 
fileList  = extractfield(d,'name');
k = startsWith(fileList,["2024","2025"]);           % Remove the operating system garabage 
fileList = fileList(k);

for i = 1:length(fileList);             % Iterate over fileList and import data
    getFile = fullfile(pat, fileList{i});
    %disp(['Importing: ' getFile])
    [maData] = importMA_blockArray(getFile);
    allData{i} = maData;
end;

%% Organize allData Files in Order
%create the subject numbers matrix
SubNums = [];
%set up a for loop to loop through all the allData options and pull out the
%subject numbers
for i = 1 : length(allData);
    %logical index of the line that has the subject number 
    WhereSNum = contains(string(allData{i}.header), "Subject:");
    %use logical index to pull out the data in the subject line
    Subject = allData{i}.header(WhereSNum);
    %erase the "subject" part of the subject line so you are left with just
    %the number. Convert the string number to double data type
    SNumber = str2double(erase(Subject, "Subject: "));
    SubNums = [SubNums SNumber];
end

%Sort the numbers in order and find the logcial indexing of how they were sorted
[IOrder, OIndx] = sort(SubNums);
%use OIndx to sort the allData files in order
allData = allData(OIndx);

%%% ccl 07/29/2024 
% New MA computers. No leading '!' in file name, will use the year