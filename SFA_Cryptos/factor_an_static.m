function [loadings,F,f2] = factor_an_static(stats)
% Factor Model

% standardizing data
Rho=corr(stats);
n1 = length(stats);
m  = mean(stats);
zz = (stats - repmat(m,n1,1))./repmat(sqrt(var(stats)), n1, 1);
Cor=corr(zz);


%% Principal Component Method with varimax rotation
% 
[eigvec,eigval] = eigs(Cor);
E               = ones(size(eigvec(:,1:3)))*eigval(1:3,1:3);

% the estimated factor loadings matrix - the initial factor pattern
Q     =sqrt(E).*eigvec(:,1:3);


%// Rotating loadings
[ld, T] = rotatefactors(Q, 'method','varimax');
% T is the Orthogonal Transformation Matrix;
loadings=ld;
loadings(:,2)=-ld(:,3);
loadings(:,3)=-ld(:,2);
% f2 contains the standardized scoring coefficients;
f2=inv(Rho)*loadings;

% F contains the final scores after the varimax rotation;
F=zz*f2;



end

