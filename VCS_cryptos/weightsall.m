function [cluster1,cluster2,indicat1,indicat2,maxw]=weightsall(X1,truegroups)

K=length(truegroups);
maxvalue=truegroups{K,1}(end);
[x,oo]=sort(X1);
n=length(x);
wn111=[1:(n-1)]*mean(x);
wn112=cumsum(x(1:(n-1)))';
wn1=wn111-wn112;
wn2=diff(x);
wn=wn1.*diff(x)';
wd=(n-1)*var(x);
w=wn/wd;
indicat1=cell(K,1);
indicat2=cell(K,1);
%Note: the commented lines below could be uncommented, if we want to
%further examine the data and the groups created
%         print("TABLE OF ORIGINAL (X,Y) ORDER AND NEW ORDER WITH X INCREASING")
%         print(cbind(x, (1:length(x)), oo))
%         print("TABLE OF WEIGHTS  IN NEW ORDER")
%         print(cbind((1:length(xd)), w))
%         print("SUM OF WEIGHTS IS")
%         print(sum(w))
%         we <- cbind(1:length(xd), w)
%               print(we)      #those below are added
%       print(max(w))  #      print(order(w))
%       print(w[order(w)])
%         print("TOTAL NUMBER OF CASES")
%         print(length(x1))
megw =find(w == max(w));
%Note: the commented lines below could be uncommented, if we want to
%      print("MAXIMUM WEIGHT=")
%     print(max(w))
%print("CORRESPONDS TO WEIGHT=")
% print("NUMBER OF OBSERVATIONS TO THE LEFT OF THE SELECTED GAP")
%         print(megw)
%print("CORRESPONDING SELECTED OBSERVATIONS")
%         print("CORRESPONDING SELECTED ORIGINAL  OBSERVATIONS")
%         print(c(oo[megw], oo[megw + 1]))
% print("DIVIDING OBSERVATIONS")
% print(c(X1[oo[megw]], X1[oo[megw+1]]))
% print("AVERAGE OF DIVIDING OBSERVATIONS")
% print((X1[oo[megw]]+ X1[oo[megw +1]])/2)

%print(oo[1:megw]) #this gves the observations in the 1st group
%print(oo[megw+1:544]) %this gives the observations in the 1st group
maxw=max(w);

cluster1=oo(1:megw);
cluster2=oo((megw+1):maxvalue);

for jj=1:K
    set1=truegroups{jj,1};
    indicat1{jj,1}=intersect(set1,cluster1);
    indicat2{jj,1}=intersect(set1,cluster2);
end

