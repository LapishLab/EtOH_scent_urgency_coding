function [orgData, totalBreaks] = orgCPPishRats(data)
%% Organize beam break information for each rat from CPPish
%input: medPC file containing beam break information 
%orgData: vector with beam break location in column 1 and the corresponding
%time stamp in column 2. in order of increasing time stamps
%total breaks: total number of beam breaks for each beam for each rat 

% P: beam 1 break
% Q: beam 2 break
% R: beam 3 break
% S: beam 4 break
% U: beam 5 break
% v: beam 6 break

%vector of beam break letters
beamLetters = ["P" "Q" "R" "S" "U" "V"];
%vector of beam break numbers
beamNums = [1 2 3 4 5 6];
%vector of data that holds all of the data from the different beam types
orgData = [];
totalBreaks = [];

%for loop that moves through each beam type and collects the data 
for i = 1:length(beamLetters);
    %variable that pulls out the time breaks for the specific beam 
    beamInfo = data.(beamLetters(i));
    %remove the 0s at the end and remove the -1 at the beginning
    beamInfo = beamInfo(beamInfo ~= 0 & beamInfo ~= -1);
    %calculate the total number of beam breaks for each beam and add the information to the totalBreaks vector that will have all of
    %the number of beam breaks for each beam. Total beam breaks ordered
    %from left to right in order of beam location. 
    totalBreaks = [totalBreaks length(beamInfo)];
    %create a new vector with the beam location repeating as many times as
    %there were beam breaks in that specific beam 
    orgData = [orgData; [repmat(beamNums(i), length(beamInfo), 1) beamInfo]];
end; 

%organize the beam break data in order of increasing time stamps
[order, index] = sort(orgData(:,2));
orgData = orgData(index,:);
