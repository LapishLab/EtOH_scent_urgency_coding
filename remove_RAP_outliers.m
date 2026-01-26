%% Remove Outliers from RAP %%
%convert them to 0 in total licks and consumption 

% rat subject IDs with an outlier 
rats = [25 94 86 21 37 56 80 25 84]; 

%days where the outlier is at. The day number aligns with the location of the rat
%IDs in the rats vector
days = [1 8 8 1 10 5 2 4 7];

%vector of the licks and consumption to make sure I am removing the correct
%outlier. The consumption values are only the first 3 integers of the
%consumption 

licks = [2639 0 0 267 357 1436 249 987 2];
cons = [0.08 1.1756 2.325 1.317 1.423 0.947 10.384 33.566 1.980];

for i = 1:numel(rats)
    %find the location of the outlier data in the matrix. Should match
    %between the two matrices since they are the same size
    [licks_row, licks_col] = find(RAP_totalLicks == licks(i));
    [cons_row, cons_col] = find(startsWith(string(table2array(RAP_all)), string(cons(i))));
    row = intersect(licks_row, cons_row);
    col = intersect(licks_col, cons_col);
    %check that the location of the outlier data matches the day and rat
    %number that goes with that location
    if row == find(ratsInfo.ratID == rats(i)) & col == days(i)
        RAP_totalLicks(row, col) = NaN; RAP_all{row, col} = NaN;
    else 
        warning(['Location of outlier data ' num2str(i) ' isnt matching day and rat number'])
    end 
end 

