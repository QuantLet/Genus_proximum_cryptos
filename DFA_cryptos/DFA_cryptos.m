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
h=figure();

% init
%loadings=[];



for j=[1:100:901 971]%(t_max-t_start)
    
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


    % colors
    n_assets_t=length(stats_t);
    type_assets_t=type_assets;


    %type_assets_t(assets_nan,:)=[0];
    color_assets=nan(n_assets_t,3);
    color_crypto=nan(n_assets_t,3);
    [~,index_type_raw]=unique(type_assets_t,'stable');
    index_type=[index_type_raw; n_assets_t];
    n_types=length(index_type(1:end-1));

    
    
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
    scatter(F(:,1),F(:,user_factor),[],color_assets,'filled')
    text_delta=0.3;
    index_crypto=strcmp(type_assets_t,'Crypto');
    text(F(index_crypto,1)+text_delta,F(index_crypto,user_factor),...
    asset_unique(index_crypto));

    xlabel('Tail Factor')
    if user_factor==2
        ylim([-6 12])
        xlim([-5 18])
        ylabel('Moment factor')
    elseif user_factor==3
        ylim([-6 8])
        xlim([-4 12])
        ylabel('Memory Factor')
    end
    progress=(j+t_start-1)/t_max*100;
    title(['Data:',' ',datestr(date_unique(1)),' - ',...
        datestr(date_unique(j+t_start-1)),' (',mat2str(round(progress,1)),'%)'])

    hold on

    for i=1:n_types
        if i==1
            user_color=color_green;
        elseif i==2
            user_color=color_black;
        elseif i==3
            user_color=color_blue;
        elseif i==4
            user_color=color_red;
        end
    x=[F(index_type(i):index_type(i+1)-1,1),...
        F(index_type(i):index_type(i+1)-1,user_factor)];

    grid_add=3;
    grid_x=min(x(:,1))-grid_add:0.1:max(x(:,1)+grid_add);
    grid_y=min(x(:,2))-grid_add:0.05:max(x(:,2)+grid_add);
    [x1_raw,x2_raw] = meshgrid(grid_x, grid_y);
    x1 = x1_raw(:);
    x2 = x2_raw(:);
    xi=[x1,x2];
    fd=ksdensity(x,xi,'PlotFcn','contour');

    user_level=0.015;
    [C,~]=contour(grid_x,grid_y,reshape(fd,length(grid_y),length(grid_x)),[user_level,user_level],...
        'color',user_color,'linewidth',1.5);
    end

    print(h,'-dpng','-r300',strcat('class_1',mat2str(user_factor),'_',mat2str(j))) %-depsc

    hold off
   % close(h)
 
end
    


