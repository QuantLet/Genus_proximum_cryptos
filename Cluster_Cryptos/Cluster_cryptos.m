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


load clusters_2020.mat;

%% Scores

index_crypto=strcmp(type_assets,'Crypto');

Check = {'BTC','USDT'};  

Match=cellfun(@(x) ismember(x, Check), symb_assets, 'UniformOutput', 0);
index_show=find(cell2mat(Match));
n_assets=679;
%user_factor=2


n_types=11;



%%

%% K-means


rng(1); % For reproducibility
[IDX,C,SUMD,K]=kmeans_opt(F);

[IDX,C, ~, D] = kmeans(F,K); % D is the distance of each datapoint to each of  the clusters
[minD, indMinD] = min(D); % indMinD(i) is the index (in X) of closest point to the i-th centroid
ptsymb = {'bs','r^','md','go','c+', '*','h','o','p','d','ko'};
text_delta=0.03;
h=figure();
%scatter3(F(:,1),F(:,2),F(:,3));

cmap = jet(10);    %or build a custom color map
map = [0 0 0
    1 1 0
    1 0 1
    1 0 0
    0 1 0
    0 0 1
    0 0.5 0
    0.5 0.5 0
    1 0.5 0.5
    0 0.8 0
    0.8 0 0.5];
colormap( map );

 

    %colormap(jet(11));
    scatter3(F(:,1),F(:,2),F(:,3),40,IDX,'filled');
  text(F(index_show,1)+text_delta,F(index_show,2)+text_delta,F(index_show,3)-4*text_delta,symb_assets(index_show));
     hold on




%plot3(cmeans2(:,1),cmeans2(:,2),cmeans2(:,3),'ko');
%plot3(cmeans2(:,1),cmeans2(:,2),cmeans2(:,3),'kx');
hold off
xlabel('Tail Factor');
ylabel('Moment Factor');
zlabel('Memory Factor');
%view(-137,10);
grid on;

Mdl = fitcecoc(F,IDX);
t = templateSVM('Standardize',true);


Mdl = fitcecoc(F,IDX,'Learners',t,...
    'ClassNames',{'1' ,'2', '3' ,'4' ,'5' ,'6', '7' ,'8','9','10','11'});

CVMdl = crossval(Mdl);
genError = kfoldLoss(CVMdl)

 tTree = templateTree('surrogate','on');
tEnsemble = templateEnsemble('GentleBoost',100,tTree);




h=figure();            
CVMdl = crossval(Mdl);
oofLabel = kfoldPredict(CVMdl);
predict= str2double(oofLabel);
C = confusionmat(IDX,predict);
confusionchart(C);

accuracy = sum(diag (C))/sum(C,'all')

