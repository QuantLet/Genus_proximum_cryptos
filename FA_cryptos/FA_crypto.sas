**********************************************
Name of QuantLet : FA_crypto

Published in : Genus_proximum_cryptos

Description : Performes Factor Analysis on a dataset of 23 variables, describing cryptos, 
stocks, FX and commodities.

Keywords : 
cryptocurrency, genus proximum, classication, multivariate analysis, factor models

Author: Daniel Traian Pele

Submitted : Wed, 20 March 2019

Datafile : 'dataset_crypto.xlsx'

*************************************************************;

FILENAME REFFILE '/folders/myfolders/dataset_crypto.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.assets replace;
	GETNAMES=YES ;
RUN;


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
label  Hurst_2='Hurst 2';
label  ACF_Lag_1_absolute='ACF Lag 1 (absolute)';
label  ACF_Lag_1_squared='ACF Lag 1 (squared)';
label  GARCH_parameter='GARCH parameter';
label  ARCH_parameter='ARCH parameter';
label  Exponential_fit='Exponential fit';
label  Correlation_to_market='Correlation to market';

run;

proc template;
	define statgraph corrHeatmap;
		dynamic _Title;
		begingraph;
		entrytitle _Title;
		rangeattrmap name='map';

		/* select a series of colors that represent a "diverging"  */
		/* range of values: stronger on the ends, weaker in middle */
		/* Get ideas from http://colorbrewer.org                   */
		range -1 - 1 / rangecolormodel=(blue white red);
		endrangeattrmap;
		rangeattrvar var=r attrvar=r attrmap='map';
		layout overlay / xaxisopts=(display=(line ticks tickvalues)) 
			yaxisopts=(display=(line ticks tickvalues));
		heatmapparm x=x y=y colorresponse=r / xbinaxis=false ybinaxis=false 
			colormodel=THREECOLORRAMP name="heatmap" display=all;
		continuouslegend "heatmap" / orient=vertical location=outside 
			title="Pearson Correlation";
		endlayout;
		endgraph;
	end;
run;

proc corr data=assets noprint pearson outp=corr;
	var 	Variance		skewness Kurtosis		
		Stable_gamma	Stable_alpha  Q_5	Q_2_5	Q_1	Q_0_5	CTE_5	
	CTE_2_5	CTE_1	CTE_0_5	CTE_95	
	CTE_97_5	CTE_99	CTE_99_5 Q_95	Q_97_5	Q_99 Q_99_5	ACF_Lag1	Hurst		 ;
run;

/* prep data for heatmap */
data corr;
	keep x y r;
	set Corr(where=(_TYPE_="CORR"));
	array v{*} _numeric_;
	x=_NAME_;

	do i=dim(v) to 1 by -1;
		y=vname(v(i));
		r=v(i);

		/* creates a diagonally sparse matrix */
		if (i<_n_) then
			r=.;
		output;
	end;
run;

/* Build the graphs */
proc sgrender data=corr template=corrHeatmap;
	dynamic _title="Correlation matrix for taxonomy parameters";
run;

ods graphics on / width=7in  height=6.5in;
PROC FACTOR DATA=assets outstat=fact nfactors=3 score msa  priors = one ROTATE=varimax 
		plots=pathdiagram ;
		pathdiagram label=[ Factor1="Factor 1 - Tails" Factor2="Factor 2 - Moments" 
		Factor3="Factor 3 - Memory" ] NOERRVAR
NOERRORVARIANCE fuzz=0.4  ;
	var  Variance		skewness Kurtosis		
		Stable_gamma	Stable_alpha  Q_5	Q_2_5	Q_1	Q_0_5	CTE_5	
	CTE_2_5	CTE_1	CTE_0_5	CTE_95	
	CTE_97_5	CTE_99	CTE_99_5 Q_95	Q_97_5	Q_99 Q_99_5	ACF_Lag1	Hurst	;
run;

PROC SCORE DATA=assets SCORE=fact OUT=scores;
	var  Variance		skewness Kurtosis		
		Stable_gamma	Stable_alpha  Q_5	Q_2_5	Q_1	Q_0_5	CTE_5	
	CTE_2_5	CTE_1	CTE_0_5	CTE_95	
	CTE_97_5	CTE_99	CTE_99_5 Q_95	Q_97_5	Q_99 Q_99_5	ACF_Lag1	Hurst		;
run;

 


data scores;
	set scores;

	if type="Crypto" then
		new_name=name;

data scores;
	set scores;
	label factor1="Factor 1 - Tails";
	label factor2="Factor 2 - Moments";
	label factor3="Factor 3 - Memory";




proc sgplot data=scores;
	styleattrs datacontrastcolors=(green black  blue red);
	scatter x=factor1 y=factor2 /group=type markerattrs=(symbol=CircleFilled 
		size=12) /* big filled markers */
		datalabel=new_Name;

	/* add labels to markers */
run;

proc sgplot data=scores;
	styleattrs datacontrastcolors=(green black  blue red);
	scatter x=factor1 y=factor3 /group=type markerattrs=(symbol=CircleFilled 
		size=12) /* big filled markers */
		datalabel=new_Name;

	/* add labels to markers */
run;

proc sgplot data=scores;
	styleattrs datacontrastcolors=(green black  blue red);
	scatter x=factor2 y=factor3 /group=type markerattrs=(symbol=CircleFilled 
		size=12) /* big filled markers */
		datalabel=new_Name;

	/* add labels to markers */
run;

data scores;
	set scores;

	if type='Crypto' then
		tip='Crypto';
	else
		tip='Other';

proc logistic data=scores plots=none outest=betas;
	model tip(event='CRYPTO')=factor1 /rsq lackfit;
run;

proc logistic data=scores plots=none outest=betas;
	model tip(event='CRYPTO')=factor2 /rsq lackfit;
run;

proc logistic data=scores plots=none outest=betas;
	model tip(event='CRYPTO')=factor3 /rsq lackfit;
run;