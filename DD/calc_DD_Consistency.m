function [consistMtx, planningMtx, matchMtx] = calc_DD_Consistency(initialLevers, choiceLevers)
%% Calculate Consistency and Planning Index
% Calculate how often the intiate lever matches what they then choose for
% a delay/immediate choice. 
% input: initialLevers, choiceLevers
    % initialLevers: matrix of what initial lever was pressed on each
    % choice trial 
    % choiceLevers: matrix of what choice lever was pressed on each choice
    % trail 
    % both need to be a cell with the data for each day contained in a single cell 
% output: consistMtx, planningMtx, matchMtx
    % matrix showing the percent consistency of matched initiate and choice
    % lever. rows are rats and columns are days 
    % matrix 
    % matchMtx: true if the initial and choice levers matched or false if
    % not. 

%create matrix that will hold final consistency data
consistMtx = [];
%create matrix that will hold final planning scores
planningMtx = [];
%create matrix that holds when the levers were a match 
matchMtx = {};

for i = 1:numel(initialLevers);
    %reinitialize each rat loop 
    consistDayMtx = [];
    planningDayMtx = [];
    matchDayMtx = [];
    %use another for loop to import the data from each rat 
    for rat = 1:size(initialLevers{i}, 1);
        %pull out the initial lever response response (A) and choice types
        %(H) for a single rat
        Atypes = initialLevers{i}(rat, :);
        Htypes = choiceLevers{i}(rat, :);
        % % find choice trials;
        % choiceTrls = Htypes == 3 | Htypes == 4;
        % % remove anything from the vectors except for the choice trials
        % Atypes = Atypes(choiceTrls); Htypes = Htypes(choiceTrls); 
        %calculate the number of times where the initial lever matched the
        %then chosen lever. (A1 with H3 or A2 with H4). 
        matchedLevers = (Atypes == 1 & Htypes == 3) | (Atypes == 2 & Htypes == 4);
        %store trials with matched initial and choice levers 
        matchDayMtx = [matchDayMtx; matchedLevers];
        %calculate the percent consistency for each rat
        percentConsist = (sum(matchedLevers)/size(Htypes,2));
        %calculate the planning index?
        idx = 2*abs(percentConsist - 0.5);
        %add both calculations to the matrix 
        consistDayMtx = [consistDayMtx; percentConsist];
        planningDayMtx = [planningDayMtx; idx];
    end;
    %Combining all animal's percentages into one variable 
    consistMtx = [consistMtx consistDayMtx];
    planningMtx = [planningMtx planningDayMtx];
    matchMtx{i} = matchDayMtx; 
end;

