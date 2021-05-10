

%% Global Commands

clear;clc;

% specify directoy for the files
directory='D:\PROIECTE\Cryptos 2019\New_data_2020';
addpath(genpath(directory))
cd(directory)

%set global commands for font size and line width
size_font=9;
size_line=1.5;
set(0,'DefaultAxesFontSize',size_font,'DefaultTextFontSize',size_font);
set(0,'defaultlinelinewidth',size_line)

% figures
set(0, 'defaultFigurePaperType', 'A4')
set(0, 'defaultFigurePaperUnits', 'centimeters')
set(0, 'defaultFigurePaperPositionMode', 'auto')
figure_wide=[680 678 800 420];

% colors
color_blue=[0 102 204]./255;
color_green=[0 204 102]./255;
color_red=[204 0 0]./255;
color_black=[0 0 0];

% reset rngs before running
rng(1)

%% Data

load data_dynamic_jan_2021.mat

%% Portfolio returns
%ret_matrix=ret_matrix(1007:end,:);
Check = {'1.Crypto'};
Match=cellfun(@(x) ismember(x, Check), type_assets, 'UniformOutput', 0);
index_crypto=find(cell2mat(Match));

ret_crypto=mean(ret_matrix(:,index_crypto),2,'omitnan');
ret_classical=mean(ret_matrix(:,(length(index_crypto)+1):n_assets),2,'omitnan');
ret_total=mean(ret_matrix,2,'omitnan');
time(:,1)=datetime(date_unique(:),'ConvertFrom','datenum');
%time=time(1007:end);

%% Log_returns graph

h=figure()
%plot(time,ret_crypto,'LineWidth',1,'color',color_green);

hold on
plot(time,ret_classical,'LineWidth',1 ,'color',color_black);
plot(time,ret_total, '--','LineWidth',1 ,'color',color_red);
% add legend

legend('Classical assets', 'Total portfolio');
Lgnd = legend('show');
Lgnd.Position(1) = 0.4;
Lgnd.Position(2) = 0.12;
hold off

%% Cumulative returns, mean, volatility, SR, Value at Risk
sum_classical=cumsum(ret_classical);
sum_total=cumsum(ret_total);

cumcount = (1:size(ret_classical))';


classical_mean = cumsum(ret_classical)./cumcount;
classical_std = sqrt(bsxfun(@rdivide, cumsum(ret_classical.^2), cumcount) -classical_mean.^2);
classical_SR=classical_mean./classical_std;
cumcount = (1:size(ret_total))';
total_mean = cumsum(ret_total)./ cumcount;
total_std = sqrt(bsxfun(@rdivide, cumsum(ret_total.^2), cumcount) -total_mean.^2);
total_SR=total_mean./total_std;

h=figure()
ax1 = subplot(3,1,1); % top subplot
plot(time,sum_classical,'color',color_black);
hold on;
plot(time,sum_total ,'color',color_red);
ylabel('Cumulative return');
xlabel('Time');


ax3 = subplot(3,1,2); % top subplot

plot(time,classical_std,'color',color_black);
hold on;
plot(time,total_std,'color',color_red);
%ylim(y_lim);
ylabel('Standard deviation');
xlabel('Time');

ax4 = subplot(3,1,3); % top subplot

plot(time,classical_SR,'color',color_black);
hold on;
plot(time,total_SR,'color',color_red);
%ylim(y_lim);
ylabel('Sharpe Ratio');
xlabel('Time');
legend('Classical assets', 'Mixed portfolio');
Lgnd = legend('show');
Lgnd.Position(1) = 0.15;
Lgnd.Position(2) = 0.01;

hold off;


%% VaR

y=ret_total;
T = length(y);    % number of obs for return y
WE = 250;           % estimation window length
time_test=time(WE+1:T);
p = 0.01;  % probability
l1 = ceil(WE*p) ; % HS observation
l5= ceil(WE*0.05);
value = 1;           % portfolio value

vol_classical=NaN(T,5);
vol_total=NaN(T,5);
%% Rolling mean and volatility

for t = WE+1:T
    t1 = t-WE;       % start of the data window
    t2 = t-1;        % end of data window
    window = ret_classical(t1:t2) ;        % data for estimation
    vol_classical(t,1)=mean(window,'omitnan');
    vol_classical(t,2)=std(window,'omitnan');
    vol_classical(t,3)=mean(window,'omitnan')/std(window,'omitnan');
    ys=sort(window);
    vol_classical(t,4)=-ys(l1);
    vol_classical(t,5)=-ys(l5);
    window = ret_total(t1:t2) ;        % data for estimation
    vol_total(t,1)=mean(window,'omitnan');
    vol_total(t,2)=std(window,'omitnan');
    vol_total(t,3)=mean(window,'omitnan')/std(window,'omitnan');
    ys=sort(window);
    vol_total(t,4)=-ys(l1);
    vol_total(t,5)=-ys(l5);
end


%% Plot volatility, mean and Sharpe Ratio
h=figure()


ax1 = subplot(3,1,1); % top subplot

plot(time,vol_classical(:,2),'color',color_black);
hold on;
plot(time,vol_total(:,2),'color',color_red);
%ylim(y_lim);
ylabel('Standard Deviation');
xlabel('Time');

ax2 = subplot(3,1,2); % top subplot

plot(time,vol_classical(:,3),'color',color_black);
hold on;
plot(time,vol_total(:,3),'color',color_red);
%ylim(y_lim);
ylabel('Sharpe Ratio');
xlabel('Time');

ax3 = subplot(3,1,3); % top subplot

plot(time,vol_classical(:,4),'color',color_black);
hold on;
plot(time,vol_total(:,4),'color',color_red);
%ylim(y_lim);
ylabel('1% VaR');
xlabel('Time');

legend('Classical assets', 'Mixed portfolio');
Lgnd = legend('show');
Lgnd.Position(1) = 0.15;
Lgnd.Position(2) = 0.01;

%% Best VaR model
WE=250;
p=0.01;
y=ret_classical;
[results_classical,VaR_test_classical,VaR_classical]=VaR_function(y,WE,time,p);
y=ret_total;
[results_total,VaR_test_total,VaR_total]=VaR_function(y,WE,time,p);
y=ret_crypto;
[results_crypto,VaR_test_crypto,VaR_crypto]=VaR_function(y,WE,time,p);
%% VaR
h=figure()

plot(time(WE+1:end),y(WE+1:end,1),'color',color_black);
hold on;
plot(time(WE+1:end),-VaR_crypto(WE+1:end,6),'--','color',color_red);
hold off;

%%
VaR=NaN(T,6);
for t = WE+1:T
    t1 = t-WE;       % start of the data window
    t2 = t-1;        % end of data window
    y=ret_crypto;
    window = y(t1:t2) ;        % data for estimation
    % Student GARCH(1,1)
    [par,ll,ht]=tarch(window-mean(window),1,1,1,'STUDENTST');
    h=par(1)+par(2)*window(end)^2+par(3)*window(end)^2*(window(end)<0)+par(4)*ht(end);
    VaR(t,1)=h;
    nu=par(5);
    VaR(t,4) =-tinv(p,nu)*sqrt((nu-2)/nu)*sqrt(h)*value+mean(window); 
    y=ret_classical;
    window = y(t1:t2) ;        % data for estimation
    % Student GARCH(1,1)
    [par,ll,ht]=tarch(window-mean(window),1,1,1,'STUDENTST');
    h=par(1)+par(2)*window(end)^2+par(3)*window(end)^2*(window(end)<0)+par(4)*ht(end);
    nu=par(5);
    VaR(t,5) = -tinv(p,nu)*sqrt((nu-2)/nu)*sqrt(h)*value+mean(window); 
    VaR(t,2)=h;
    y=ret_total;
    window = y(t1:t2) ;        % data for estimation
    % Student GJR-GARCH(1,1)
    [par,ll,ht]=tarch(window-mean(window),1,1,1,'STUDENTST');
    h=par(1)+par(2)*window(end)^2+par(3)*window(end)^2*(window(end)<0)+par(4)*ht(end);
    VaR(t,3)=h;
    nu=par(5);
    VaR(t,6) =-tinv(p,nu)*sqrt((nu-2)/nu)*sqrt(h)*value+mean(window); 
end


%% GARCH volatility
VaR=NaN(T,6);
for t = WE+1:T
    t1 = t-WE;       % start of the data window
    t2 = t-1;        % end of data window
    y=ret_crypto;
    window = y(t1:t2) ;        % data for estimation
    % Student GARCH(1,1)
    [par,ll,ht]=tarch(window-mean(window),1,1,1,'STUDENTST');
    h=par(1)+par(2)*window(end)^2+par(3)*window(end)^2*(window(end)<0)+par(4)*ht(end);
    VaR(t,1)=h;
    nu=par(5);
    VaR(t,4) =-tinv(p,nu)*sqrt((nu-2)/nu)*sqrt(h)*value+mean(window); 
    y=ret_classical;
    window = y(t1:t2) ;        % data for estimation
    % Student GARCH(1,1)
    [par,ll,ht]=tarch(window-mean(window),1,1,1,'STUDENTST');
    h=par(1)+par(2)*window(end)^2+par(3)*window(end)^2*(window(end)<0)+par(4)*ht(end);
    nu=par(5);
    VaR(t,5) = -tinv(p,nu)*sqrt((nu-2)/nu)*sqrt(h)*value+mean(window); 
    VaR(t,2)=h;
    y=ret_total;
    window = y(t1:t2) ;        % data for estimation
    % Student GJR-GARCH(1,1)
    [par,ll,ht]=tarch(window-mean(window),1,1,1,'STUDENTST');
    h=par(1)+par(2)*window(end)^2+par(3)*window(end)^2*(window(end)<0)+par(4)*ht(end);
    VaR(t,3)=h;
    nu=par(5);
    VaR(t,6) =-tinv(p,nu)*sqrt((nu-2)/nu)*sqrt(h)*value+mean(window); 
end



%% %% Plot VaR
h=figure()
ax1 = subplot(3,1,1); % top subplot
plot(time((WE+1):end),-VaR((WE+1):end,4),'--','color',color_blue);
hold on;
plot(time((WE+1):end),ret_classical((WE+1):end),'color',color_black);
hold off;
ylabel('1% VaR');
xlabel('Time');
title('Classical assets');
ax2 = subplot(3,1,2); % top subplot
plot(time((WE+1):end),-VaR((WE+1):end,5),'--','color',color_blue);
hold on;
plot(time((WE+1):end),ret_crypto((WE+1):end),'color',color_green);
ylabel('1% VaR');
xlabel('Time');
title('Cryptos');
ax3 = subplot(3,1,3); % top subplot
plot(time((WE+1):end),-VaR((WE+1):end,6),'--','color',color_blue);
hold on;
plot(time((WE+1):end),ret_total((WE+1):end),'color',color_red);
ylabel('1% VaR');
title('Mixed portfolio');
xlabel('Time');
hold off;
%}
%% Plot GARCH volatility
h=figure()
ax1 = subplot(3,1,1); % top subplot
plot(time,VaR(:,2),'color',color_black);
ylabel('Volatility');
xlabel('Time');
title('Classical assets');
ax2 = subplot(3,1,2); % top subplot
plot(time,VaR(:,1),'color',color_green);
ylabel('Volatility');
xlabel('Time');
title('Cryptos');
ax3 = subplot(3,1,3); % top subplot
plot(time,VaR(:,3),'color',color_red);
ylabel('Volatility');
title('Mixed portfolio');
xlabel('Time');
hold off;