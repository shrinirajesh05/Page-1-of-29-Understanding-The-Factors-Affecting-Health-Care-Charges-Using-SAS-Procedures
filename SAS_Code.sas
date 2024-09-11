/* Code 1: Dataload*/
libname healthin '/home/u62518985/';
filename hidata '/home/u62518985/sas healthinsurance/00healthinsurance.csv';
proc import 
   datafile = hidata
   out = healthin.healthinsurancedata
   dbms = csv 
   replace;
   getnames = yes; 
run;

/* Code 2: Data Labelling*/
title "heath insurance data";
title "heath insurance data";
data healthin.healthinsurancedata;
set healthin.healthinsurancedata;
label 
age ='age beneficiary'
age_group='beneficiary age, 0-><=median age, 1->>median age'
sex ='insurance contractor gender'
sex_status = 'insurance contractor gender - 0=female, 1=male'
bmi = 'body mass index'
children = 'number of children covered by health insurance / number of dependents'
smoker = 'smoking status'
smoker_status = 'smoking status - 0=no,1=yes'
region = 'rhe beneficiarys residential area in the us'
region_value ='residential area in the us seperated from 0 to 3 based on each region'
charges = 'individual medical costs billed by health insurance'
charges_seperation= 'charges seperated based on the median medical costs - <=median=0, >median=1 ';
run;

/* Code 3: If Else Loop*/
data healthin.healthinsurancedata;
   set healthin.healthinsurancedata;
   if sex = 'female' then sex_status = 0;
   else if sex = 'male' then sex_status = 1;
run;
data healthin.healthinsurancedata;
   set healthin.healthinsurancedata;
   if region='northwest' then region_value=0;
   else if region='northeast' then region_value=1;
   else if region='southwest' then region_value=2;
   else if region='southeast' then region_value=3;
run;
data healthin.healthinsurancedata;
   set healthin.healthinsurancedata;
   if smoker = 'no' then smoker_status = 0;
   else if smoker = 'yes' then smoker_status = 1;
run;
data healthin.healthinsurancedata;
   set healthin.healthinsurancedata;
   if age<=39 then age_group = 0;
   else if age>39 then age_group = 1;
run;
data healthin.healthinsurancedata;
   set healthin.healthinsurancedata;
   if charges<=9382.03 then charges_seperation_median = 0;
   else if charges>9382.03 then charges_seperation_median = 1;
run;
data healthin.healthinsurancedata;
   set healthin.healthinsurancedata;
   if charges<=13270.42 then charges_seperation_mean = 0;
   else if charges>13270.42 then charges_seperation_mean = 1;
run;
data healthin.healthinsurancedata;
   set healthin.healthinsurancedata;
   if charges<=16657.72 then charges_seperation = 0;
   else if charges>16657.72 then charges_seperation= 1;
run;

/* Code 4: Finding If There Is Any Missing Value In The Original Data*/
proc means data=healthin.healthinsurancedata nmiss;
var age bmi children charges sex_status region_value smoker_status;
run;

/* Code 5: Performing Descriptive Statistics For Continuous Variables- Age, Bmi, Children And Charges*/
proc means data=healthin.healthinsurancedata mean median skew stddev var maxdec=2 q1 q3;
var age bmi children charges;
run;
title 'means procedure classified by gender';
proc means data=healthin.healthinsurancedata n mean median skew stddev var maxdec=2 kurtosis;
class sex;
var age bmi children charges;
run;
title 'means procedure classified by smoking status';
proc means data=healthin.healthinsurancedata n mean median skew stddev var maxdec=2;
class smoker;
var age bmi children charges;
run;
title 'means procedure classified by region';
proc means data=healthin.healthinsurancedata n mean median skew stddev var maxdec=2;
class region;
var age bmi children charges;
run;

/* code 6: performing descriptive statistics on categorical variables : sex, region and smoking status.*/
proc univariate data=healthin.healthinsurancedata;
var age bmi children charges;
run;
proc univariate data=healthin.healthinsurancedata;
   var age;
   histogram / normal;
run;
proc univariate data=healthin.healthinsurancedata;
   var bmi;
   histogram / normal;
run;
proc univariate data=healthin.healthinsurancedata;
   var children;
   histogram / normal;
run;
proc univariate data=healthin.healthinsurancedata;
   var charges;
   histogram / normal;
run;
proc corr data=healthin.healthinsurancedata;
var age	sex_status bmi children smoker_status region_value charges;
run;
/*correlation*/
proc corr data=healthin.healthinsurancedata;
var charges age bmi children smoker_status sex_status region_value;
run;
proc freq data=healthin.healthinsurancedata;
   table smoker;
run;
proc freq data=healthin.healthinsurancedata;
   table sex;
run;
proc freq data=healthin.healthinsurancedata;
   table region;
run;
proc univariate data=healthin.healthinsurancedata;
   var age bmi children	charges;
   qqplot / normal;
run;
proc univariate data=healthin.healthinsurancedata;
   var age;
   qqplot / normal;
run;
proc univariate data=healthin.healthinsurancedata;
   var bmi;
   qqplot / normal;
run;
proc univariate data=healthin.healthinsurancedata;
   var children	;
   qqplot / normal;
run;
proc univariate data=healthin.healthinsurancedata;
   var charges;
   qqplot / normal;
run;
proc freq data=healthin.healthinsurancedata;
tables sex region smoker;
run;
proc gchart data=healthin.healthinsurancedata;
vbar age;
run;
proc gchart data=healthin.healthinsurancedata;
vbar bmi;
run;
proc gchart data=healthin.healthinsurancedata;
vbar children;
run;
proc gchart data=healthin.healthinsurancedata;
vbar charges;
run;
proc sgplot data=healthin.healthinsurancedata;
vbox age;
run;
proc sgplot data=healthin.healthinsurancedata;
vbox bmi;
run;
proc sgplot data=healthin.healthinsurancedata;
vbox children;
run;
proc sgplot data=healthin.healthinsurancedata;
vbox charges/ fill;
run;

/* Code 7: Performing Anova/Ttest/Wilcocon/Kruskal And The Assumption Of Normality And Homogeneity.*/

data healthin.healthinsurancedata;
set healthin.healthinsurancedata;
charges_log=log10(charges);
run;
proc print data=healthin.healthinsurancedata;
var charges charges_log;
run;
/*------------------------------------main code------------------------------------*/
proc univariate data=healthin.healthinsurancedata normal;
  var charges;
  class region;
  histogram /normal;
run;
proc univariate data=healthin.healthinsurancedata normal;
  var charges_log;
  class region;
  histogram /normal;
run;
/* check homogeneity of variances assumption */
proc glm data=healthin.healthinsurancedata;
  class region;
  model charges_log = region;
  means region / hovtest=levene;
run;
/*levene's test for equality of variances is significant (i.e. p-value < 0.05), it suggests that the assumption of homogeneity of variances has been violated. 
in such a case, the results of the anova may not be reliable.
*assumption of homogenerity fails*/
proc npar1way data=healthin.healthinsurancedata;
   class region;
   var charges_log;
   run;
proc npar1way data=healthin.healthinsurancedata;
   class region;
   var charges;
   run;
/*for children*/
proc univariate data=healthin.healthinsurancedata normal;
  var charges_log;
  class children;
  histogram /normal;
run;
proc glm data=healthin.healthinsurancedata;
  class children;
  model charges_log = children;
  means children / hovtest=levene scheffe;
run;
proc glm data=healthin.healthinsurancedata;
  class children;
  model charges = children;
  means children / hovtest=levene;
run;
proc npar1way data=healthin.healthinsurancedata;
   class children;
   var charges_log;
   run;
/*----------------------------------------------------------------------------------*/

/* check normality assumption */
proc univariate data=healthin.healthinsurancedata normal;
  var charges_log;
  class smoker;
  histogram/normal;
run;
/* check homogeneity of variances assumption */
proc glm data=healthin.healthinsurancedata;
  class smoker;
  model charges_log = smoker;
  means smoker / hovtest=levene;
run;
/*test for homogenity fails*/
proc npar1way data=healthin.healthinsurancedata wilcoxon;
   class smoker;
   var charges_log;
run;
proc npar1way data=healthin.healthinsurancedata wilcoxon;
   class smoker;
   var charges;
run;
/*ttest assumption failed
proc ttest data=healthin.healthinsurancedata;
  class smoker;
  var charges;
run;
-----------------------------------------------------------------------------------------------*/

/* check normality assumption */
proc univariate data=healthin.healthinsurancedata normal;
  var charges_log;
  class sex;
  histogram/ normal;
run;
/* check homogeneity of variances assumption */
proc glm data=healthin.healthinsurancedata;
  class sex;
  model charges_log = sex;
  means sex / hovtest=levene;
  output out=healthin.asst residual=residual p=predicted;
run;
proc gplot data=healthin.asst;
plot predicted*residual;
run;
proc sgplot data=healthin.asst;
scatter x=predicted y=residual;
run;
/* assumption of homogenity failed
proc ttest data=healthin.healthinsurancedata;
  class sex;
  var charges;
run;
*/
proc npar1way data=healthin.healthinsurancedata wilcoxon;
   class sex;
   var charges_log;
run;
proc npar1way data=healthin.healthinsurancedata wilcoxon;
   class sex;
   var charges;
run;
/*no relation btwn sex and charges*/
/*-----------------------------------------------------------------------------------------------*/

proc univariate data=healthin.healthinsurancedata normal;
  var charges_log;
  class age_group;
  histogram/normal;
run;
proc univariate data=healthin.healthinsurancedata normal;
  var charges;
  class age_group;
  histogram/normal;
run;
/* check homogeneity of variances assumption */
proc glm data=healthin.healthinsurancedata;
  class age_group;
  model charges_log = age_group;
  means age_group / hovtest=levene;
run;
/*assumption of homogenity did not fail*/
proc ttest data=healthin.healthinsurancedata;
  class age_group;
  var charges_log;
run;
proc ttest data=healthin.healthinsurancedata;
  class age_group;
  var charges;
run;

/* Code 8: Performing Logistic Regression and its assumptions
proc logistic data=healthin.healthinsurancedata ;
model age_group= bmi children sex_status smoker_status region_value charges/ corrb ;
output out=healthin.logisticoutput resdev=resdev;
run;
proc autoreg data=healthin.healthinsurancedata;
   model age_group= bmi children sex_status smoker_status region_value charges / dw=4 dwprob;
run;
assumption of independence

proc sgplot data=healthin.logisticoutput;
scatter x=age_group y=resdev;
xaxis label='age group';
yaxis label='residuals';
run; 
------------------------------------------------------------------------------------------------*/

proc logistic data=healthin.healthinsurancedata descending;
model charges_seperation= age bmi children sex_status region_value smoker_status/selection=stepwise;
output out=healthin.logisticoutput resdev=resdev predicted=predicted;
run;
/*independence*/
data healthin.logisticoutput;
set healthin.logisticoutput;
obs=_n_;
run;
proc sgplot data=healthin.logisticoutput;
scatter x=resdev y=obs;
yaxis label='observation';
xaxis label='residuals' ;
run; 
/*correlation*/
proc corr data=healthin.healthinsurancedata;
var age bmi children sex_status region_value smoker_status;
run;
proc logistic data=healthin.healthinsurancedata descending;
model charges_seperation_median= age bmi children sex_status region_value / selection=stepwise;
output out=healthin.logisticoutputmedian resdev=resdev predicted=predicted;
run;
/*independence*/
data healthin.logisticoutputmedian;
set healthin.logisticoutputmedian;
obs=_n_;
run;
proc sgplot data=healthin.logisticoutputmedian;
scatter x=resdev y=obs;
yaxis label='observation';
xaxis label='residuals' ;
run; 
/*correlation*/
proc corr data=healthin.healthinsurancedata;
var age bmi children sex_status region_value smoker_status;
run;
/*quasi complete seperation
proc logistic data=healthin.healthinsurancedata ;
model charges_seperation_median=smoker_status;
run;
proc autoreg data=healthin.healthinsurancedata;
   model charges_seperation= age bmi children sex_status smoker_status region_value / dw=4 dwprob;
run;*/
proc logistic data=healthin.healthinsurancedata descending;
model charges_seperation= age bmi children sex_status region_value smoker_status/selection=stepwise;
output out=healthin.logisticoutput resdev=resdev predicted=predicted;
run;
/*linearity*/
proc sgplot data=healthin.logisticoutput;
scatter x=predicted y=resdev;
xaxis label='predicted';
yaxis label='residuals' ;
run; 
/*independence*/
data healthin.logisticoutput;
set healthin.logisticoutput;
obs=_n_;
run;
proc sgplot data=healthin.logisticoutput;
scatter x=resdev y=obs;
yaxis label='observation';
xaxis label='residuals' ;
run; 
/*correlation*/
proc corr data=healthin.healthinsurancedata;
var age bmi children sex_status region_value smoker_status;
run;
proc logistic data=healthin.healthinsurancedata descending;
model charges_seperation_median= age bmi children sex_status region_value / selection=stepwise;
output out=healthin.logisticoutputmedian resdev=resdev predicted=predicted;
run;
/*linearity*/
proc sgplot data=healthin.logisticoutputmedian;
scatter x=predicted y=resdev;
xaxis label='predicted';
yaxis label='residuals' ;
run; 
/*independence*/
data healthin.logisticoutputmedian;
set healthin.logisticoutputmedian;
obs=_n_;
run;
proc sgplot data=healthin.logisticoutputmedian;
scatter x=resdev y=obs;
yaxis label='observation';
xaxis label='residuals' ;
run; 
/*correlation*/
proc corr data=healthin.healthinsurancedata;
var age bmi children sex_status region_value smoker_status;
run;
/*quasi complete seperation
proc logistic data=healthin.healthinsurancedata ;
model charges_seperation_median=smoker_status;
run;
proc autoreg data=healthin.healthinsurancedata;
   model charges_seperation= age bmi children sex_status smoker_status region_value / dw=4 dwprob;
run;*/

/*Code 9: Performing Multiple Regression And Its Assumptions*/

proc reg data=healthin.healthinsurancedata;
model charges = age bmi children smoker_status sex_status region_value / vif ;
output out=healthin.residuals residual=residual predicted=predicted cookd=cookd  ;
run;
proc autoreg data=healthin.healthinsurancedata;
   model charges = age bmi children smoker_status sex_status region_value / dw=4 dwprob;
run;
data healthin.residuals;
set healthin.residuals;
order = _n_;
run;
/*assumption of independence order vs residuals*/
title 'assumption of independence';
proc sgplot data=healthin.residuals;
scatter x=order y=residual;
xaxis label='observation';
yaxis label='residuals';
run;
/*assumption of variance*/
title 'assumption of variance';
proc sgplot data=healthin.residuals;
scatter x=predicted y=residual;
xaxis label='observation';
yaxis label='residuals';
run;
/*assumption of normality*/
title 'assumption of normality';
proc univariate data=healthin.healthinsurancedata;
var charges;
histogram /normal;
run;
/*assumption of linearity*/
title'assumption of linearity';
proc sgplot data=healthin.gammaresiduals;
scatter x=charges y=predicted / markerattrs=(symbol=circlefilled);
lineparm x=0 y=0 slope=1;
xaxis label='charges';
yaxis label='predicted charges';
run;
/*assumption of linearity
proc sgplot data=healthin.residuals;
scatter x=predicted y=charges;
lineparm x=0 y=0 slope=1;
xaxis label='predicted values';
yaxis label='actual values';
run;
*/

/*Code 10: Performing Gamma Regression and its assumption*/
/*---------------------------------Gamma----------------------------------------------------------*/
proc genmod data=healthin.healthinsurancedata;
model charges = age bmi children smoker_status sex_status region_value / dist=gamma  link=log  ;
output out=healthin.gammaresiduals resdev=resdev predicted=predicted ;
run;
data healthin.healthinsurancedata;
set healthin.healthinsurancedata;
agelog=log(age);
run;
/*assumption of independence
title 'assumption of independence';
proc sgplot data=healthin.gammaresiduals;
scatter x=resdev y=charges;
xaxis label='observation';
yaxis label='residuals';
run;*/
data healthin.gammaresiduals;
set healthin.gammaresiduals;
order = _n_;
age=log(age);
run;
proc sgplot data=healthin.healthinsurancedata;
scatter x=charges y=agelog;
run;
/*assumption of independence order vs residuals*/
title 'assumption of independence';
proc sgplot data=healthin.gammaresiduals;
scatter x=order y=resdev;
xaxis label='observation';
yaxis label='residuals' min=-2 max=3 values=(-0.75 to .10 by 0.05);
run;
data healthin.gammaresiduals;
set healthin.gammaresiduals;
logpred=log(predicted);
run;
proc sgplot data=healthin.gammaresiduals;
scatter x=resdev y=predicted;
run;
/*assumption of linearity*/
title'assumption of linearity';
proc sgplot data=healthin.gammaresiduals;
scatter y=resdev x=logpred / markerattrs=(symbol=circlefilled);
  refline 0 / lineattrs=(color=black);
xaxis label='log of predicted values' values=(8 to 9.5 by .25);
yaxis label='residual deviance' min=-5 max=1 values=(-1 to 2 by 0.05) ;
run;
quit;
