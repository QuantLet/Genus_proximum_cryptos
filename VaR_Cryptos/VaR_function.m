
function [results,VaR_test,VaR]=VaR_function(y,WE,time,p)
% colors
color_blue=[0 102 204]./255;
color_green=[0 204 102]./255;
color_red=[204 0 0]./255;
color_black=[0 0 0];

%% VaR


T = length(y);    % number of obs for return y
% WE estimation window length
time_test=time(WE+1:T);
%p = 0.01;  % probability
l1 = ceil(WE*0.01) ; % HS observation
l5= ceil(WE*0.05);
value = 1;           % portfolio value
VaR= NaN(T,5);   % matrix for forecasts

vol=NaN(T,5);

%% Rolling mean and volatility

for t = WE+1:T
    t1 = t-WE;       % start of the data window
    t2 = t-1;        % end of data window
    window = y(t1:t2) ;        % data for estimation
    vol(t,1)=mean(window,'omitnan');
    vol(t,2)=std(window,'omitnan');
    vol(t,3)=mean(window,'omitnan')/std(window,'omitnan');
    ys=sort(window);
    vol(t,4)=-ys(l1);
    vol(t,5)=-ys(l5);
end






%% GARCH models
for t = WE+1:T
    t1 = t-WE;       % start of the data window
    t2 = t-1;        % end of data window
    
    window = y(t1:t2) ;        % data for estimation
    
    VaR(t,1) = mean(window)- std(window)*value*(norminv(p)+1/6*(norminv(p)^2-1)* skewness(window)+1/24*(norminv(p)^3-3*norminv(p))*kurtosis(window)-1/36*(2*norminv(p)^3-5*norminv(p))*skewness(window)^2); % four moments VaR
    %VaR(t,2) = -std(window)*norminv(p)*value++mean(window);   % MA
    
    ys = sort(window);
    VaR(t,2) = -ys(l1)*value;  % HS
    %%%Normal GARCH;
    [par,ll,ht]=tarch(window,1,0,1);
    h=par(1)+par(2)*window(end)^2+par(3)*ht(end);

     VaR(t,3) = -norminv(p)*sqrt(h)*value+mean(window);  
    %%%Student GARCH;
    [par,ll,ht]=tarch(window,1,0,1,'STUDENTST');
    h=par(1)+par(2)*window(end)^2+par(3)*ht(end);
    nu=par(4);
    VaR(t,4) = -tinv(p,nu)*sqrt((nu-2)/nu)*sqrt(h)*value+mean(window);  
    % GJR GARCH Normal
    [par,ll,ht]=tarch(window,1,1,1);
    h=par(1)+par(2)*window(end)^2+par(3)*window(end)^2*(window(end)<0)+par(4)*ht(end);
    %h=par(1)+par(2)*window(end)^2+par(3)*window(end)^2*(window(end)<0)+par(4)*ht(end);
    VaR(t,5) = -norminv(p)*sqrt(h)*value+mean(window);          
    % Student GJR-GARCH(1,1)
    [par,ll,ht]=tarch(window,1,1,1,'STUDENTST');
    h=par(1)+par(2)*window(end)^2+par(3)*window(end)^2*(window(end)<0)+par(4)*ht(end);
    %h=par(1)+par(2)*window(end)^2+par(3)*window(end)^2*(window(end)<0)+par(4)*ht(end);
    nu=par(5);
    VaR(t,6) = -tinv(p,nu)*sqrt((nu-2)/nu)*sqrt(h)*value+mean(window);          % t-GJR-GARCH(1,1)
end




%% Backtesting tests
names = ["four moment VaR", "Historical Simulation", "N-GARCH(1,1)", "t-GARCH(1,1)", "N-GJR-GARCH(1,1)", "t-GJR-GARCH(1,1)"];
results=cell(6,4);
for i=1:6
    VR = length(find(y(WE+1:T)<-VaR(WE+1:T,i)))/((T-WE));
    s = std(VaR(WE+1:T,i));
    disp([names(i), "Violation Ratio:", VR, "Volatility:", s])
    results{i,1}=names(i);
    results{i,2}=VR;
    results{i,3}=s;
    results{i,4}=mean(VaR(WE+1:T,i));
end


%% Christopherssen Test
names = ["four moment VaR", "Historical Simulation", "N-GARCH(1,1)", "t-GARCH(1,1)", "N-GJR-GARCH(1,1,1)", "t-GJR-GARCH(1,1,1)"];
VaR_test=cell(6,7);
ya=y(WE+1:T);
VaRa=VaR(WE+1:T,:);
for i=1:6
	q=find(y(WE+1:T)<-VaR(WE+1:T,i));
	v=VaRa*0;
	v(q,i)=1;
	ber=bern_test(p,v(:,i));
	in=ind_test(v(:,i));
    full=ber+in;
    VaR_test{i,1}=names(i);
    VaR_test{i,2}=ber;
    VaR_test{i,3}=1-chi2cdf(ber,1);
    VaR_test{i,4}=in;
    VaR_test{i,5}= 1-chi2cdf(in,1);
    VaR_test{i,6}=full;
    VaR_test{i,7}=1-chi2cdf(full,2);
    
	disp([names(i), "Bernoulli Statistic:", ber, "P-value:", 1-chi2cdf(ber,1),...
    "Independence Statistic:", in, "P-value:", 1-chi2cdf(in,1),...
     "Full Statistic:", full, "P-value:", 1-chi2cdf(full,2)])
end


end	