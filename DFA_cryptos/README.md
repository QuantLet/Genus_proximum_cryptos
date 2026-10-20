<div style="margin: 0; padding: 0; text-align: center; border: none;">
<a href="https://quantlet.com" target="_blank" style="text-decoration: none; border: none;">
<img src="https://github.com/StefanGam/test-repo/blob/main/quantlet_design.png?raw=true" alt="Header Image" width="100%" style="margin: 0; padding: 0; display: block; border: none;" />
</a>
</div>

```
Name of Quantlet: DFA_cryptos

Published in: Genus_proximum_cryptos

Description: Dynamic projection of a dataset of 23 variables, describing cryptos, stocks, FX and commodities on a 3D space defined by the three factors extracted using Factor Analysis.

Keywords: cryptocurrency, genus proximum, classiffication, multivariate analysis, factor models

Author: Daniel Traian Pele, Niels Wesselhoft

See also: SFA_cryptos, FA_cryptos

Submitted: 2019-03-21

Datafiles: data_dynamic_jan_2021.mat, dynamic_dataset_2021.csv

Example: Please download and extract the 5 rar volumes in order to get the datafile

Note: These files hold the 24 estimated distributional statistics (quantiles, CTEs, FIGARCH d, stable alpha and gamma, variance, skewness, kurtosis, ACF lag-1, Hurst) per asset per expanding-window wave - the input to the factor analysis, not the returns themselves. data_dynamic_jan_2021.mat (5 rar volumes) was saved from MATLAB

containing table objects and can only be opened in MATLAB; R.matlab: :readMat and scipy.io.loadmat both fail on it. The same data as a plain CSV is in dynamic_dataset_2021.csv (2 rar volumes), which is what DFA_Cryptos.R reads. For the raw daily log-returns (906 assets x 1740 days, 2014-01-03 to 2020-11-30), see RAW_data/ in the repository root.'

```
<div align="center">
<img src="https://raw.githubusercontent.com/QuantLet/Genus_proximum_cryptos/master/DFA_cryptos/class_12_1101.png" alt="Image" />
</div>

<div align="center">
<img src="https://raw.githubusercontent.com/QuantLet/Genus_proximum_cryptos/master/DFA_cryptos/class_12_36.png" alt="Image" />
</div>

<div align="center">
<img src="https://raw.githubusercontent.com/QuantLet/Genus_proximum_cryptos/master/DFA_cryptos/class_12_719.png" alt="Image" />
</div>

<div align="center">
<img src="https://raw.githubusercontent.com/QuantLet/Genus_proximum_cryptos/master/DFA_cryptos/class_12_962.png" alt="Image" />
</div>

