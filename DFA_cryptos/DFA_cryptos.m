%{
Name of QuantLet : DFA_cryptos
Published in : Genus_proximum_cryptos
Description : Dynamic projection of a dataset of 24 variables, describing cryptos, 
stocks, FX, bonds, real estates and commodities on a 3D space defined by the three factors
extracted using Factor Analysis.
Keywords : 
cryptocurrency, genus proximum, classiffication, multivariate analysis, factor models
Authors: Daniel Traian Pele, Niels Wesselhoft
Submitted : Thu, 21 March 2021
Datafiles : 'data_dynamic_2021.mat'; 
Note: Please download and extract the 5 rar volumes in order to get the datfile.
*************************************************************;
%}

%% Factor modelling of assets

%% Global Commands

clear;clc;

% specify directoy for the files
directory='D:\PROIECTE\Cryptos 2019\New_data_2020';
addpath(genpath(directory));
cd(directory);



%set global commands for font size and line width
size_font=9;
size_line=1.5;
set(0,'DefaultAxesFontSize',size_font,'DefaultTextFontSize',size_font);
set(0,'defaultlinelinewidth',size_line)

% figures
set(0, 'defaultFigurePapertype', 'A4');
set(0, 'defaultFigurePaperUnits', 'centimeters');
set(0, 'defaultFigurePaperPositionMode', 'auto');
figure_wide=[680 678 800 420];

% colors
% colors
color_blue=[0 102 204]./255;
color_green=[0 204 102]./255;
color_red=[204 0 0]./255;
color_black=[0 0 0];

color_purple= [0.75 0 0.75];
color_yellow=  [1 1 0];
% reset rngs before running
rng(1)

%% Data

load data_dynamic_jan_2021.mat







%%% Subset

subset=[1:18 20 24:28];
     stats_s=stats_raw(:,subset);

est_labels_raw={'Q_{0.5%}';'Q_{1%}';'Q_{2.5%}';'Q_{5%}';...
     'CTE_{0.5%}';'CTE_{1%}';'CTE_{2.5%}';'CTE_{5%}';...
      'Q_{95%}';'Q_{97.5%}';'Q_{99%}';'Q_{99.5%}';...
      'CTE_{95%}';'CTE_{97.5%}';'CTE_{99%}';'CTE_{99.5%}';...
       'FIGARCH d'; ...
    'Stable \alpha';'Stable \beta';'Stable \gamma';...
    'Stable \delta';...
  'GARCH parameter';'ARCH parameter';...
'Variance';'Skewness';'Kurtosis';'ACF Lag 1'; 'Hurst'};
est_labels=est_labels_raw(subset,1);



%% Factor model

%%
[loadings,F,f2] = factor_an_static(stats_s);



%% Expanding window factor model

t_start=ceil(t_max/3);
user_factor=2;


% init
%loadings=[];



for j=1:(t_max-t_start+1)
    
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

    index_crypto=strcmp(type_assets_t,'1.Crypto');

    symb_assets(symb_assets(:,1)=='#IBBEU00')='.IBBEU003D';
    symb_assets(symb_assets(:,1)=='#IBLUS00')='.IBLUS0004';
% Check = {'BTC','ETH','XRP','BCH','LTC','USDT',	'BNB','LINK','ADA','DOT','PAX',...
   % 'TUSD','USDC','EURS','GUSD','XAU','CHF','GBP','.IBLUS0004','.IBBEU003D',...
	
  % 'SUSD'	,'ZB','HT', 'ZT', 'BHP',	'BNT',	'KAN',	'C20',...
   % 'VET',	'ELA',	'BTG',	'QKC',	'INO'};  
    Check = {'BTC','ETH','XRP','BCH','LTC','USDT',	'CHF','.IBLUS0004','.IBBEU003D'};
    Match=cellfun(@(x) ismember(x, Check), symb_assets, 'UniformOutput', 0);
    index_show=find(cell2mat(Match));
    
    for i=1:n_assets_t
                        
     if strcmp(type_assets_t{i},'1.Crypto')==1
        color_assets(i,:)=color_green;
        color_crypto(i,:)=color_green;
    elseif strcmp(type_assets_t{i},'2.Stock')==1
        color_assets(i,:)=color_black;
        color_crypto(i,:)=color_black;
    elseif strcmp(type_assets_t{i},'4.Exchange Rate')==1
        color_assets(i,:)=color_blue;
        color_crypto(i,:)=color_blue;
    elseif strcmp(type_assets_t{i},'5.Commodity')==1
        color_assets(i,:)=color_red;
        color_crypto(i,:)=color_red;
    elseif strcmp(type_assets_t{i},'3.Bond')==1
        color_assets(i,:)=color_purple;
        color_crypto(i,:)=color_purple;
    elseif strcmp(type_assets_t{i},'6.Real Estate')==1
        color_assets(i,:)=color_yellow;
        color_crypto(i,:)=color_yellow;
        end
    end

    
    % plot
   h=figure();
scatter(F(:,1),F(:,user_factor),[],color_assets,'filled')
text_delta=0.03;

text(F(index_show,1)+text_delta,F(index_show,user_factor),...
   symb_assets(index_show));


    ylabel('Memory factor');
    xlabel('Tail factor');

    ylim([-4 8])
    xlim([-1 9])

    progress=(j+t_start-1)/t_max*100;
    title(['Data:',' ',datestr(date_unique(1)),' - ',...
        datestr(date_unique(j+t_start-1)),' (',mat2str(round(progress,1)),'%)'])

hold on

for i=1

    if i==1
        user_color=color_green;

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