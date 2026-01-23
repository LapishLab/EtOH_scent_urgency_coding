function g_cons = convert_gkg_g(RAP_weights, RAP_all, ratsInfo, constant)

arguments 
    RAP_weights {mustBeInteger} %weights of all the rats 
    RAP_all %table of g/kg consumption in RAP
    ratsInfo %table of rat specific information 
    constant %constant value use to find g/kg when consuming ethanol to accuont for metabolism differences. 0.0789 for 10%, 0.1578 for 20%
end 

%determine size of table
[row, col] = size(RAP_all);

%premake matrix
g_cons = zeros(row, col);

%check if the rat is an ethanol or water consumer and then calculate their
%g consumption from their weight, g/kg consumption, and constant if ethanol
%consumers. Add to new g_cons matrix
for day = 1:size(g_cons, 2)
    for rat = 1:size(g_cons, 1)
        if ratsInfo.treatment(rat) == "Control"
            g_cons(rat, day) = RAP_all{rat, day} * RAP_weights(rat, day) / 1000;
        elseif ratsInfo.treatment(rat) == "EtOH" & ismember(day, [1 3 5 6 8 10 11 13])
            g_cons(rat, day) = RAP_all{rat, day} * RAP_weights(rat, day) / 1000 / constant;
        elseif ratsInfo.treatment(rat) == "EtOH" & ismember(day, [2 4 7 9 12 14])
            g_cons(rat, day) = RAP_all{rat, day} * RAP_weights(rat, day) / 1000;
        end 
    end
end