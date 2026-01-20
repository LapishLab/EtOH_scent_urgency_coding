function b=getKvalue(x,y)

%% Gets k value from x(delay) and y(indifference at delay)
%% y must be a vector or matrix arranged with delay on columns 
%% and observations (delays) on rows

modelfun='6./(1+(k.*x))'
for i=1:size(y,1);
 b(i,1)=nlinfit(x,y(i,:),modelfun,0);
end;