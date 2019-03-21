function [loadings,F] = factor_an_static(stats)
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
Q      = sqrt(E).*((eigvec(:,1:3)));
Q(:,3)=-Q(:,3);
%// Extracting the eigenvectors/eigenvalues
[V,D] = eig(corr(zz));

%// Sorting the eigenvectors/eigenvalues
[~, ind] = sort(diag(D), 'descend');
D = D(ind, ind);
V = V(:, ind);

%// Keeping only the first three factors
D = D(1:3,1:3);
V = V(:,1:3);

%// Computing loadings
L = V*sqrt(D);

%// Rotating loadings
[loadings, T] = rotatefactors(L, 'method','varimax');
% T is the Orthogonal Transformation Matrix;

f1=transpose(Q)*inv(Cor);

% f2 contains the standardized scoring coefficients;
f2=transpose(T)*f1;

% F contains the final scores after the varimax rotation;
F=transpose(f2*transpose(zz));
F(:,2)=-F(:,2);

end

