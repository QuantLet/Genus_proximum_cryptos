%% Clustering assets

%% Global Commands


clear;clc;

% specify directoy for the files
directory='D:\PROIECTE\Cryptos 2019\Data';
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
color_blue=[0 102 204]./255;
color_green=[0 204 102]./255;
color_red=[204 0 0]./255;
color_black=[0 0 0];

% reset rngs before running
rng(1)

%% Data


load clusters.mat;

%% Scores

index_crypto=strcmp(type_assets,'Crypto');

Check = {'BTC','USDT','XRP','BCH','KMD','ETH','EOS'};  

Match=cellfun(@(x) ismember(x, Check), symbol, 'UniformOutput', 0);
index_show=find(cell2mat(Match));
n_assets=679;
%user_factor=2

color_assets=repmat(0,n_assets,1);
color_crypto=nan(n_assets,1);
[~,index_type_raw]=unique(cluster_new,'stable');
index_type=[index_type_raw; n_assets];
n_types=6;
index_type_raw(3,1)=610;
index_type_raw(4,1)=620;
index_type_raw(5,1)=656;

h=figure();

text_delta=0.1;
scatter3(F1,F3,F2,30,cluster_new,'filled');
cmap = jet(10);    %or build a custom color map
map = [0 0 0
    1 1 0
    1 0 1
    1 0 0
    0 1 0
    0 0 1];
colormap( map );
text(F1(index_show)-4*text_delta,F3(index_show)-3*text_delta,F2(index_show)+2*text_delta,symbol(index_show));
text(F1(index_type_raw)+text_delta,F3(index_type_raw),F2(index_type_raw), num2str(cluster_new(index_type_raw)));

xlabel('Tail factor');

    ylabel('GARCH factor');
zlabel('Moment factor');
axis tight; box on; 
%print(h,'-depsc','-r300','['class_scat1' mat2str(user_factor)]) %-depsc
%view(5,3);
hold off
F=[F1(:), F2(:),F3(:)];
Mdl = fitcecoc(F,cluster_new);
t = templateSVM('Standardize',true);


Mdl = fitcecoc(F,cluster_new,'Learners',t,...
    'ClassNames',{'1' ,'2', '3' ,'4' ,'5' ,'6'});

CVMdl = crossval(Mdl);
genError = kfoldLoss(CVMdl)

 tTree = templateTree('surrogate','on');
tEnsemble = templateEnsemble('GentleBoost',100,tTree);




h=figure();            
CVMdl = crossval(Mdl);
oofLabel = kfoldPredict(CVMdl);
predict= str2double(oofLabel);
C = confusionmat(cluster_new,predict);
confusionchart(C);

accuracy = sum(diag (C))/sum(C,'all');
