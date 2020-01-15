function [minpropB,kkk,matrixminpropB]=MVCS_allinone_withdiscrproj(w1,M,componentsizes)
% %w1: the data set
%M: the number of angles used for projection directions, as in in equation (11) of Yatrakos (2013)
%componentsizes: the number of data points in each component

%We have K components in the data (for example, the data correspond to
%assets and we have K=4 components, in particular cryptos, stocks, exchange, commodities)
%This program uses the MVCS clustering method of Yaracos (2013). In
%particular, this code is used is to find how many of the projection directions used will give perfect
%classification for each component, in one run.
%As projection directions, we use the discretized projection directions of equation (11) of Yatrakos (2013)
%This code was created bu Michalis Kolossiatis and Yannis Yatracos.

[n,d]=size(w1); %n is the data size, d is the data dimension
K=length(componentsizes); %the number of components
niter=M^(d-1); %the number of projection directions examined
maxmaxw=zeros(K,1); %the maximum index value, among those that  give perfect classification.
minpropB=ones(K,1); %the minimum misclassification proportions
bestproj=zeros(K,d);  %the projection direction that corresponds to the minimum misclassification proportion
kkk=ones(K,1); %the number of projection directions that give perfect classification
truegroups=cell(K,1); %the data indices for each component
truegroups{1,1}=1:componentsizes(1);
ind=componentsizes(1);
for jj=2:K
    truegroups{jj,1}=(ind+1):(ind+componentsizes(jj));
    ind=ind+componentsizes(jj);
end
matrixminpropB=zeros(K,d+1);

a=0.95;
xa=-log(-log(a));
signif=(log(n)+xa)/n;
signifindex=zeros(K,1); %the number of maximum index values that are statistically not significant, among those that give perfect classification.

flip=zeros(d-1,1)';
k=zeros(d-1,1)';
for i=1:niter
    ucoeff=ones(1,d); %the discretized projection directions
    k(d-1)=k(d-1)+1;
    for j=(d-2):(-1):1
        flip(j+1)=((mod(k(j+1),M)-1)==0);
        flipsum=sum(flip((j+1):(d-1)));
        chk=ones(d-1-j,1)';
        chksum=sum(chk);
        if flipsum==chksum
            k(j)=k(j)+1;
            k(j+1)=1;
        end
    end
    for jjj=1:(d-1)
        ucoeff(1)=ucoeff(1)*cos(pi*k(jjj)/M);
    end
    ucoeff(d)=ucoeff(d)*sin(pi*k(d-1)/M);
    if d>2
        for n1=2:(d-1)
            ucoeff(n1)=ucoeff(n1)*sin(pi*k(n1-1)/M);
            for n2=n1:(d-1)
                ucoeff(n1)=ucoeff(n1)*cos(pi*k(n2)/M);
            end
        end
    end
    w2=w1*ucoeff'; %the projected data
    [cluster1,cluster2,indicat1,indicat2,maxw]=weightsall(w2,truegroups); %cluster1,cluster2 are the clusters generated
    %idicat1, indicat2 are the indicators to which cluster each data point is allocated
    %maxw is the maximum index value
    
    
    for jj=1:K
        propcl1=1-length(indicat1{jj,1})/componentsizes(jj);
        propcl2=1-length(indicat2{jj,1})/componentsizes(jj);
        prop=min(propcl1,propcl2);
        propcl1A=1-length(indicat1{jj,1})/length(cluster1);
        propcl2A=1-length(indicat2{jj,1})/length(cluster2);
        propA=min(propcl1A,propcl2A) ;
        propB=max(propA,prop);
        
        if propB<minpropB(jj)
            minpropB(jj)=propB;
            bestproj(jj,:)=ucoeff; %We store the projection direction that corresponds to the best classification (in terms of smallest misclassification proportion)
        end
        if propB==0
            kkk(jj)=kkk(jj)+1;
            if maxw>maxmaxw(jj)
                matrixminpropB(jj,:)=[maxw ucoeff]; %We store the projection direction that corresponds to the maximum index value, among those
                %that  give perfect classification. We also keep that maximum index value
                maxmaxw(jj)=maxw;
            end
            if maxw<signif
                signifindex(jj,1)=signifindex(jj,1)+1;
            end
        end
    end
end
kkk=kkk-1;

%==========================================================================
%Output

a=0.95;
xa=-log(-log(a));
signif=(log(n)+xa)/n;
%Output
disp('=========================================================================')
disp('Results:')
fprintf('\n')
disp(['Data dimension: ' num2str(d)])
disp(['Number of data components: ' num2str(K)])
disp(['Data components sizes: ' num2str(componentsizes')])
%disp(['Number of angles used for projection directions: ' num2str(M)])
angles=1:M;
angles=(180/M*angles);
disp(['The angles (in degrees) used in projection directions were from the set: {' num2str(angles) '}'])
disp(['Critical value for 5% significance of the index value is ' num2str(signif)])
fprintf('\n')
disp(['Number of projection directions examined: ' num2str(niter)])
fprintf('\n')
disp('Component  Minimum misclassification proportion     Number of projection directions that give perfect classification')
for jj=1:K
    disp([num2str(jj) '                            ' num2str(minpropB(jj)) '                                            ' num2str(kkk(jj))])
end
fprintf('\n')
fprintf('\n')

disp('Results for each component:')
for jj=1:K
    fprintf('\n')
    if kkk(jj)==0
        w2=w1*bestproj(jj,:)';
        [cluster1,cluster2,indicat1,indicat2,maxw]=weightsall(w2,truegroups);
        propcl1=1-length(indicat1{jj,1})/componentsizes(jj);
        propcl2=1-length(indicat2{jj,1})/componentsizes(jj);
        prop=min(propcl1,propcl2);
        propcl1A=1-length(indicat1{jj,1})/length(cluster1);
        propcl2A=1-length(indicat2{jj,1})/length(cluster2);
        propA=min(propcl1A,propcl2A) ;
        %propB=max(propA,prop);
        set1=truegroups{jj,1};
        set0=1:n;
        set2=setdiff(set0,set1);
        if propA>prop %this means that propB=propA
            if propcl1A>propcl2A %this means that propA=propcl2A and the selected cluster is cluster2
                extraobs=intersect(cluster2,set2);  %those from outside the component that are in the selected cluster;
                leftoutobs=intersect(cluster1,set1); %those from the component that are in the other cluster
            else %this means that propA=propcl1A and the selected cluster is cluster1
                extraobs=intersect(cluster1,set2);  %those from outside the component that are in the selected cluster;
                leftoutobs=intersect(cluster2,set1); %those from the component that are in the other cluster
            end
        else %this means that propB=prop
            if propcl1>propcl2 %this means that prop=propcl2 and the selected cluster is cluster2
                extraobs=intersect(cluster2,set2);  %those from outside the component that are in the selected cluster;
                leftoutobs=intersect(cluster1,set1); %those from the component that are in the other cluster
            else %this means that prop=propcl1 and the selected cluster is cluster1
                extraobs=intersect(cluster1,set2);  %those from outside the component that are in the selected cluster;
                leftoutobs=intersect(cluster2,set1); %those from the component that are in the other cluster
            end
        end
        disp(['No perfect classification for component ' num2str(jj)])  % isos look episis: fprintf anti tou disp??
        disp('The best classification of the elements of this component, corresponding to the minimum misclassification proportion above, is as follows:')
        disp([num2str(length(leftoutobs)) ' observations from component ' num2str(jj) ' are misclassified, i.e clustered with the observations from all other categories.'])
        disp([num2str(length(extraobs)) ' observations from other categories are misclassified, i.e. clustered together with the observations of component ' num2str(jj) '.'])
    else
        disp(['The maximum index value that provided perfect classification for component '  num2str(jj) ' was ' num2str(maxmaxw(jj))])
        disp('and the corresponding projection direction was')
        disp(num2str(matrixminpropB(jj,2:end)))
        if signifindex(jj)==0
            disp(['All projection directions that provided perfect classification had index values that were statistically significant.'])
        else
            disp(['The number of projection directions that provided perfect classification, and whose index value was statistically significant, was ' num2str(kkk(jj)-signifindex(jj)) '.'])
        end
    end
end
