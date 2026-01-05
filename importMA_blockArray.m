function [maData]=importMA_blockArray(pat_File)

% This imports MedAssoc data files where arrays are written in block
% format. I think this will work for both types tho and could replace
% importMA.m

%% To Do: 
% 1. Make header detection dynamic. If header is not 13 lines, I worry arrays might be off. 
% This code is commented poorly. Need to improve.  (ccl 7/26/2024) 

%  pat_File the path and name of your data. 
%  For example patFile = '/Users/clapish/Desktop/MA/!2023-10-09_09h29m.Subject 1'

% Open the file for reading
fileID = fopen(pat_File, 'r');

% Read all elements from the file into a cell array
dataCellArray = textscan(fileID, '%s', 'Delimiter', '\n');

% Close the file
fclose(fileID);

% Extract the cell array from the output of textscan
dataCellArray = dataCellArray{1};
maData.header = dataCellArray(1:13);

k = strmatch('Subject',maData.header);
maData.subjectNumber = str2double(regexp(maData.header{k},'[\d.]+','match'));

j=1;
for i=14:numel(dataCellArray);
    if ~isempty(dataCellArray{i})
        spl = regexp(dataCellArray{i},':','once','split');  % split the text
        spl = strtrim(spl);                                 % get rid of leading white space
        if isempty(str2num(spl{1}));                        % is the first col a letter?
            varIdx(j) = i;
            varCol(j) = spl(1); j=j+1;
        end;
        reData{i,1} = str2num(spl{1});
        reData{i,2} = str2num(spl{2});
    end
end;

%% This section is different than importMA to accomodate the block arrays. 
for i = 1:numel(varIdx);
    if i~=numel(varIdx);
        hld = [];
        for j = varIdx(i):varIdx(i+1)-1;
            hld = [hld cell2mat(reData(j,2))];
        end;
        maData.(varCol{i}) = hld; clear hld;
    else;
        hld = [];
        for j = varIdx(i):size(reData,1);
            hld = [hld cell2mat(reData(j,2))];
        end;
        maData.(varCol{i}) = hld; clear hld;
    end;
end;

clearvars -except maData