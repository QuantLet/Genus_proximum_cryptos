%{
Name of QuantLet : DFA_cryptos
Published in : Genus_proximum_cryptos
Description : Dybnamic projection of a dataset of 23 variables, describing cryptos, 
stocks, FX and commodities on a 3D space defined by the three factors
extracted using Factor Analysis.
Keywords : 
cryptocurrency, genus proximum, classiffication, multivariate analysis, factor models
Authors: Daniel Traian Pele, Niels Wesselhoft
Submitted : Thu, 21 March 2019
Datafiles : 'stats_dynamic.mat'; 
Note: Please download and extract the 5 rar volumes in order to get the datfile.
*************************************************************;
%}

%% Factor modelling of assets

%% Global Commands

clear;clc;

% specify directory for the files
directory='D:\PROIECTE\Cryptos 2019\Data';
addpath(genpath(directory));
cd(directory);

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

load data_dynamic.mat







%% Subset

subset=[1:3 4 6   8:23 26:27];
%subset=[1:27];
 stats_s=stats_raw(:,subset);

est_labels_raw={'Variance'; 'Skewness';'Kurtosis';...
    'Stable \alpha';'Stable \beta';'Stable \gamma';...
    'Stable \delta';'Q_{5%}';'Q_{2.5%}';'Q_{1%}';'Q_{0.5%}';...
    'CTE_{5%}';'CTE_{2.5%}';'CTE_{1%}';'CTE_{0.5%}';...
    'Q_{95%}';'Q_{97.5%}';'Q_{99%}';'Q_{99.5%}';...
    'CTE_{95%}';'CTE_{97.5%}';'CTE_{99%}';'CTE_{99.5%}';...
    'ACF Lag 1'; 'Hurst';'GARCH parameter';'ARCH parameter'};
est_labels=est_labels_raw(subset,1);






%% Factor model

[loadings,F,f2] = factor_an_static(stats_s);



%% Expanding window factor model

t_start=ceil(t_max/2);
user_factor=2;


% init
%loadings=[];



for j=1:740%(t_max-t_start)
    
    % stats for one point in time
    stats_t=stats(:,:,j);

    % nan assets
    assets_nan=sum(isnan(stats_t),2)>0;
    stats_t(assets_nan,:)=[0];
    
    parms_nan=sum(isnan(stats_t),1)>0;
    stats_t(:,parms_nan)=[0];
    Rho=corr(stats_t);
    Rho(isnan(Rho))=0;
    n1 = length(stats_t);
    m  = mean(stats_t);
    zz = (stats_t - repmat(m,n1,1))./repmat(sqrt(var(stats_t)), n1, 1);
   zz(isnan(zz))=0;
    %f2=inv(Rho)*loadings;

    % F contains the final scores after the varimax rotation;
    F=zz*f2;
    
     
   
    % colors
    n_assets_t=length(stats_t);
    type_assets_t=type_assets;


    %type_assets_t(assets_nan,:)=[0];
    color_assets=nan(n_assets_t,3);
    color_crypto=nan(n_assets_t,3);
    [~,index_type_raw]=unique(type_assets_t,'stable');
    index_type=[index_type_raw; n_assets_t];
    n_types=length(index_type(1:end-1));

    index_crypto=strcmp(type_assets_t,'Crypto');

    Check = {'BTC','ETH','XRP','BCH','LTC','USDT',	'BNB','EOS','BSV','XMR'}';  

    Match=cellfun(@(x) ismember(x, Check), symb_assets, 'UniformOutput', 0);
    index_show=find(cell2mat(Match));
    
    for i=1:n_assets_t
        if strcmp(type_assets_t{i},'Crypto')==1
            color_assets(i,:)=color_green;
            color_crypto(i,:)=color_green;
        elseif strcmp(type_assets_t{i},'Stock')==1
            color_assets(i,:)=color_black;
            color_crypto(i,:)=color_black;
        elseif strcmp(type_assets_t{i},'Exchange rate')==1
            color_assets(i,:)=color_blue;
            color_crypto(i,:)=color_black;
        elseif strcmp(type_assets_t{i},'Commodity')==1
            color_assets(i,:)=color_red;
            color_crypto(i,:)=color_black;
        end
    end

    
    % plot
   h=figure();
scatter(F(:,1),F(:,user_factor),[],color_assets,'filled')
text_delta=0.03;

text(F(index_show,1)+text_delta,F(index_show,user_factor),...
   symb_assets(index_show));


    ylabel('Moment factor');
    xlabel('Tail Factor');

    ylim([-3 6])
    xlim([-5 2])

    progress=(j+t_start-1)/t_max*100;
    title(['Data:',' ',datestr(date_unique(1)),' - ',...
        datestr(date_unique(j+t_start-1)),' (',mat2str(round(progress,1)),'%)'])

hold on

for i=1:n_types

    if i==1
        user_color=color_red;
    elseif i==2
        user_color=color_green;
    elseif i==3
        user_color=color_blue;
    elseif i==4
        user_color=color_black;
    end
x=[F(index_type(i):index_type(i+1)-1,1),...
    F(index_type(i):index_type(i+1)-1,user_factor)];

grid_add=1.15;
grid_x=min(x(:,1))-grid_add:0.05:max(x(:,1)+grid_add);
grid_y=min(x(:,2))-grid_add:0.05:max(x(:,2)+grid_add);
[x1_raw,x2_raw] = meshgrid(grid_x, grid_y);
x1 = x1_raw(:);
x2 = x2_raw(:);
xi=[x1 x2];


fd=mvksdensity(x,xi,'PlotFcn','contour');

user_level=0.05;
[C,~]=contour(grid_x,grid_y,reshape(fd,length(grid_y),length(grid_x)),[user_level,user_level],...
    'color',user_color,'linewidth',1.5);
    end

   print(h,'-dpng','-r300',strcat('class_1',mat2str(user_factor),'_',mat2str(j))) %-depsc

    hold off
   close(h)
 
end