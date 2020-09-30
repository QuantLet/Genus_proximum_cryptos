**********************************************
Name of QuantLet : FA_cryptos

Published in : Genus_proximum_cryptos

Description : Performes Factor Analysis on a dataset of 23 variables, describing cryptos, 
stocks, FX and commodities.

Keywords : 
cryptocurrency, genus proximum, classication, multivariate analysis, factor models

Author: Daniel Traian Pele

Submitted : Wed, 20 March 2019

Datafile : 'assets_2020.xlsx'

*************************************************************;

FILENAME REFFILE 'D:/myfolders/assets_2020.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.assets replace;
	GETNAMES=YES;
RUN;




data assets;
set assets;
*if name in ("USDT", "BOX", "HOT", "STOR") then delete;
run;

proc freq data=assets;
table type;
run;

data assets;set assets;
label  Variance='Variance';
label  Skewness='Skewness';
label  Kurtosis='Kurtosis';
label  Stable_alpha='Stable \alpha';
label  Stable_beta='Stable \beta';
label  Stable_gamma='Stable \gamma';
label  Q_5='Q_{5%}';
label  Q_2_5='Q_{2.5%}';
label  Q_1='Q_{1%}';
label  Q_0_5='Q_{0.5%}';
label  CTE_5='CTE_{5%}';
label  CTE_2_5='CTE_{2.5%}';
label  CTE_1='CTE_{1%}';
label  CTE_0_5='CTE_{0.5%}';
label  Q_95='Q_{95%}';
label  Q_97_5='Q_{97.5%}';
label  Q_99='Q_{99%}';
label  Q_99_5='Q_{99.5%}';
label  CTE_95='CTE_{95%}';
label  CTE_97_5='CTE_{97.5%}';
label  CTE_99='CTE_{99%}';
label  CTE_99_5='CTE_{99.5%}';
label  ACF_Lag1='ACF Lag 1';
label  Hurst='Hurst';

label  GARCH_parameter='GARCH parameter';
label  ARCH_parameter='ARCH parameter';

run;


proc sort data=assets; by type;

ods graphics on / width=7in  height=6.5in;
PROC FACTOR DATA=assets outstat=fact nfactors=3 score msa  priors = one ROTATE=varimax 
		plots=pathdiagram ;
		pathdiagram label=[ Factor1="Factor 1 - Tails" Factor2="Factor 2 - Moments" 
		Factor3="Factor 3 - Memory" ] NOERRVAR NOERRORVARIANCE fuzz=0.5 ;
		var Variance		skewness Kurtosis		
			Stable_alpha Stable_gamma Q_5	Q_2_5	Q_1	Q_0_5	CTE_5	
	CTE_2_5	CTE_1	CTE_0_5	CTE_95	
	CTE_97_5	CTE_99	CTE_99_5 Q_95	Q_97_5	Q_99 Q_99_5		
	 ARCH_parameter	GARCH_parameter ;
run;
