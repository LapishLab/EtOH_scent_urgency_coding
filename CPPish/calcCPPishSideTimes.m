function timeOnSides = calcCPPishSideTimes(data)
%% Calculate time on each side for CPPish
% calculates how long the rat in the 2CAP chambers spent on the left or
% right side by subtracting time differences between beam break time stamps
% data:: data file from per each rat with beam break identification and their corresponding time stamps

%variable that contains true for when beam breaks were on the left side (beams 1,2,3) and
%false for when they were on the right side (beams 4,5,6)
side = data(:,1) == 1 | data(:,1) == 2 | data(:,1) == 3;
%initiate the start of the variables that will hold the total time on each
%side
timeLeftSide = 0;
timeRightSide = 0;

%for loop that goes through the total number of beam breaks and calculates
%the time spent on either side 
for i = 1:(length(side)-1)

    %add the time before the first beam break to whichever side the first beam
    %break occurred on. The first time stamp is when i = 1
    if i == 1 && side(i) == 1
        timeLeftSide = timeLeftSide + (data(1,2) - 0);
    elseif i == 1 && side(i) == 0
         timeRightSide = timeRightSide + (data(1,2) - 0);
    end

    %calculate the time between each time stamp and add it to the side the
    %time break was on. 1 means it was on the left side while 0 means it
    %was on the right side. Subtract the time between the present time
    %stamp and the next one farther on in time (the is the time it was at
    %that beam location before breaking the next)
    %time on left side
    if i > 1 && side(i) == 1;
        timeLeftSide = timeLeftSide + (data(i+1,2) - data(i,2));
    %time on right side
    elseif i > 1 && side(i) == 0;
        timeRightSide = timeRightSide + (data(i+1,2) - data(i,2));
    end;
end;

%output variable that will have the total time on the left side in the left
%column and the total time on the rigth side in the right column 
timeOnSides = [timeLeftSide timeRightSide];


