%% Factor modelling of assets

%% Global Commands

clear;clc;

% specify directoy for the files
directory='D:\PROIECTE\berlin_2018\Final_code';
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

load stats_dynamic.mat



%% Expanding window factor model

t_start=ceil(t_max/3);
user_factor=2;


% init
%loadings=[];


for j=[1:971]%(t_max-t_start)
    time(j,1)=datetime(date_unique(j+t_start-1,1),'ConvertFrom','datenum');
    % stats for one point in time
    stats_t=stats(:,:,j);

    % nan assets
    assets_nan=sum(isnan(stats_t),2)>0;
    stats_t(assets_nan,:)=[0];
    
    parms_nan=sum(isnan(stats_t),1)>0;
    stats_t(:,parms_nan)=[0];
    Rho=corr(stats_t);
    n1 = length(stats_t);
    m  = mean(stats_t);
    zz = (stats_t - repmat(m,n1,1))./repmat(sqrt(var(stats_t)), n1, 1);

    F=transpose(f2*transpose(zz));
    F(:,2)=-F(:,2);

type_crypto=strcmp(type_assets,'Crypto');
type_crypto_mod=type_crypto+1;

c=zeros(size(type_crypto_mod));
df=n_assets-2;


for i=1
    [est_reg_para,est_reg_dev,est_reg_stats]=mnrfit(F(:,1),type_crypto_mod);
    [est_reg_dev_null]=mnrfit([],type_crypto_mod);
end
    Dev_F1(j,1)=est_reg_dev;
    Dev_null_F1(j,1)=est_reg_dev_null;
    D1(j,1)=Dev_F1(j,1)- Dev_null_F1(j,1);
    Chi_F1(j,1)=1-chi2cdf(D1(j,1),1);
    
for i=2
    [est_reg_para,est_reg_dev,est_reg_stats]=mnrfit(F(:,2),type_crypto_mod);
    [est_reg_dev_null]=mnrfit([],type_crypto_mod);
end
    Dev_F2(j,1)=est_reg_dev;
    Dev_null_F2(j,1)=est_reg_dev_null;
    D2(j,1)=Dev_F2(j,1)- Dev_null_F2(j,1);
    Chi_F2(j,1)=1-chi2cdf(D2(j,1),1);
 
for i=3
    [est_reg_para,est_reg_dev,est_reg_stats]=mnrfit(F(:,3),type_crypto_mod);
    [est_reg_dev_null]=mnrfit([],type_crypto_mod);
end
    Dev_F3(j,1)=est_reg_dev;
    Dev_null_F3(j,1)=est_reg_dev_null;
    D3(j,1)=Dev_F3(j,1)- Dev_null_F3(j,1);
    Chi_F3(j,1)=1-chi2cdf(D3(j,1),1);
 
   
end
%Conv_index_1=1-(Dev_F1)/max(Dev_F1)
%Conv_index_2=1-(Dev_F2)/max(Dev_F2)
%Conv_index_3=1-(Dev_F3)/max(Dev_F3)
h=figure()
y_lim=[0 140];


ax1 = subplot(3,1,1); % top subplot


plot(time,Dev_F1);
%ylim(y_lim);
ylabel('Likelihood Ratio');
xlabel('Time');
title(ax1,'Tail Factor');

ax2 = subplot(3,1,2); % bottom subplot
plot( time,Dev_F2);
%ylim(y_lim);
ylabel('Likelihood Ratio');
xlabel('Time');

title(ax2,'Moment Factor')

ax3 = subplot(3,1,3); % bottom subplot
plot(time,Dev_F3);
%ylim(y_lim);
ylabel('Likelihood Ratio');
xlabel('Time');

title(ax3,'Memory Factor');

y_lim=[0 0.2];

h=figure()


ax1 = subplot(3,1,1); % top subplot


plot(time,Chi_F1);
ylim(y_lim);
ylabel('P-value');
xlabel('Time');
title(ax1,'Tail Factor');

ax2 = subplot(3,1,2); % bottom subplot
plot( time,Chi_F2);
ylim(y_lim);
ylabel('P-value');
xlabel('Time');

title(ax2,'Moment factor')

ax3 = subplot(3,1,3); % bottom subplot
plot(time,Chi_F3);
ylim(y_lim);
ylabel('P-value');
xlabel('Time');

title(ax3,'Memory Factor');

