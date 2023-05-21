/*
Name: Analysis 1
Date Created: 02/23/2023
Date Last Modified: 02/23/2023
Created by: EKY
Modified By: EKY
Last modified by: EKY
Uses data:
Creates data: 
Description:
*/

***************************************************************************
** SYSTEM SETUP ***********************************************************
***************************************************************************

cls
clear
set more off
* set memory // not applicable for version > 12.0


version 16.1


* Set directory [to replicate, CHANGE THIS DIRECTORY]
cd $user_dir

* Check directory
pwd

***************************************************************************
** EDA ********************************************************************
***************************************************************************

* Importing dataset
use "data_cleaned/main_dataset.dta", clear



* Summary statistics
sum

xtdescribe

***************************************************************************
** Variable Specifications ************************************************
***************************************************************************

* Crisis
gen crisis = TotalDeaths + (0.5 * TotalAffected)
gen lcrisis = ln(crisis + 0.01)
gen fcrisis = year==2008

* Rescale main variables
gen ihapc = (iha / total_pop)
gen iharatio = ihapc / gdppc * 100
* gen ihabin = iha > 0
gen gdp = gdppc * total_pop
// gen iharatio = iha / gdp


gen liha = ln(iha + 0.01)
gen lihapc = ln(ihapc + 0.01)
gen ltrade = ln(trade + 0.01)
gen lgdppc = ln(gdppc + 0.01)
gen loda1 = ln(oda1 + 0.1)
gen lpop = ln(total_pop + 0.01)
gen popmil = total_pop/1000000
gen gdppc1000 = gdppc/1000
gen lenergy = ln(energy + 0.01)
gen trade2 = trade*trade
gen trade3 = trade2*trade
xtile tradetile = trade, nq(4)

gen fdiratio = fdi/gdp

	* polity
	replace polity = missing(polity) if polity < -10
	gen democracy = polity > 0

* Factor
egen iclevel = group(incomelevel)
recode iclevel (1 = 4 "High Income") (2 = 1 "Low income") ///
(3 = 2 "Lower middle income") (4 = 3 "Upper middle income"), gen(income_level)


egen regid = group(Region), label

*  Vulnerability
rename s_04 vulnerable 

* Share Export
replace share_export = share_export * 100

// LABELING SPECIFIED VARIABLES
lab var iharatio "IHA/GDP (in percent)"
lab var popmil "Population (in Million)"
lab var vulnerable "Index of people impacted by crises"
lab var gdppc1000 "GDP per capita PPP (constant 2017 in thousand /$)"
lab var lgdppc "ln(GDP per capita)"
lab var lenergy "ln(Energy production)"
lab var lpop "ln(Population)"
lab var loda1 "ln(Official Development Assistance)"
***************************************************************************
***************************************************************************
// TABLE 2. EXPLORING MAIN MODEL

cls
est clear
global FE i.regid
global control_SE lgdppc lpop lenergy i.income_level
global reported trade share_export polity L.vulnerable lgdppc lpop lenergy *.income_level _cons

* Model 1a Bivariate (PCSE-FE) 
eststo: xtpcse iharatio trade $FE, pair corr(ar1)
	estadd local Regional_FE "Yes"	

* Model 2a (PCSE-COVARIATES)
eststo: xtpcse iharatio trade share polity L.vulnerable $FE, pair corr(ar1)
	estadd local Regional_FE  "Yes"

* Model 3a (PCSE-CONTROL-FULL)
eststo: xtpcse iharatio trade share polity L.vulnerable $control_SE $FE, pair corr(ar1)
	estadd local Regional_FE "Yes"

* REPORTING TABLE 2
esttab using "output/tables/regression1.tex", ///
drop(1.income_level *.regid) ///
order($reported) ///
replace b(4) se(4) ///
star(* 0.10 ** 0.05 *** 0.01) ///
label nomtitle booktabs ///
stats(N N_g Regional_FE r2 rho chi2, fmt(%9.0g %9.0g %9.4f %9.4f %9.4f %9.4f) ///
labels("N Obs." "Number of countries" Regional_FE R-squared "Rho" "Wald $\chi2$"))


***************************************************************************
***************************************************************************
// TABLE 1. SUMMARY STATISTICS

// * Statistical summary
eststo: estat sum iharatio trade share_export polity vulnerable gdppc1000 popmil energy
mat stats = r(stats)
esttab matrix(stats, fmt(2)) using "output/tables/summary1.tex", ///
cells("mean(fmt(%.2f)) sd(fmt(%.2f)) min max N") nonumber ///
   nomtitle nonote label booktabs collabels("Mean" "SD" "Min" "Max" "Obs") replace

***************************************************************************
***************************************************************************
// TABLE 3. TESTING MECHANISM

global reported_tbl3 trade c.* loda1 share_export polity vulnerable _cons

cls
est clear
* Model Dependency
eststo: xtpcse iharatio c.trade##c.share_export polity L.vulnerable $control_SE $FE, pair corr(ar1)
	estadd local Regional_FE  "Yes"

* Model Conditionality
eststo: xtpcse iharatio c.trade##c.polity share_export L.vulnerable $control_SE $FE, pair corr(ar1)
	estadd local Regional_FE  "Yes"

* Model Altruism
eststo: xtpcse iharatio c.trade##c.L.vulnerable share_export polity $control_SE $FE, pair corr(ar1)
	estadd local Regional_FE  "Yes"

* Model Complementary
eststo: xtpcse iharatio loda1 polity L.vulnerable $control_SE $FE, pair corr(ar1)
	estadd local Regional_FE  "Yes"

esttab using "output/tables/regression2.tex", ///
drop(*.income_level *.regid lgdppc lpop lenergy) ///
order($reported_tbl3) ///
replace b(4) se(4) ///
star(* 0.10 ** 0.05 *** 0.01) ///
label nomtitle booktabs ///
stats(N N_g Regional_FE r2 rho chi2, fmt(%9.0g %9.0g %9.4f %9.4f %9.4f %9.4f) ///
labels("N Obs." "Number of countries" Regional_FE R-squared "Rho" "Wald $\chi2$"))


// cls
// est clear

// * Dependency:
// eststo: xtpcse iharatio trade polity vulnerable $control_SE $FE, pair corr(ar1)
// 	estadd local Regional_FE  "Yes"

// * Political:
// eststo: xtpcse iharatio trade share vulnerable $control_SE $FE, pair corr(ar1)
// 	estadd local Regional_FE  "Yes"

// * Altruism
// eststo: xtpcse iharatio trade share polity $control_SE $FE, pair corr(ar1)
// 	estadd local Regional_FE  "Yes"
	
// * Complementary
// eststo: xtpcse iharatio oda1 share polity vulnerable $control_SE $FE, pair corr(ar1)
// 	estadd local Regional_FE  "Yes"
	
* Complementary A:
// eststo: xtpcse iharatio share vulnerable polity $control_SE $FE, pair corr(ar1)
// 	estadd local Regional_FE "Yes"

// * Complementary B:	
// eststo: xtpcse iharatio share vulnerable polity $control_SE $FE, pair corr(ar1)
// 	estadd local Regional_FE "Yes"

// * REPORTING TABLE 3
// esttab using "output/tables/regression2.csv", ///
// drop(1.income_level *.regid) ///
// order($reported) ///
// replace b(4) se(4) ///
// star(* 0.10 ** 0.05 *** 0.01) ///
// label nomtitle  ///
// stats(N N_g Regional_FE r2 rho chi2, fmt(%9.0g %9.4f) ///
// labels("N Obs." "Number of countries" Regional_FE R-squared "Rho" "Wald Chi2"))
	
// * Baseline
// eststo: xtpcse iharatio trade share polity vulnerable $control_SE $FE, pair corr(ar1)
// 	estadd local Regional_FE  "Yes"


***************************************************************************
***************************************************************************
// TABLE 5. HETEROGENEITY ANALYSIS

global reported_tbl4 trade c.* share_export polity L.vulnerable _cons

cls
est clear

// B. BY INCOME
eststo: xtpcse iharatio c.trade##c.lgdppc share polity L.vulnerable $control_SE $FE, pair corr(ar1)
	estadd local Regional_FE "Yes"
	
eststo: xtpcse iharatio c.trade##income_level share polity L.vulnerable $control_SE $FE, pair corr(ar1)
	estadd local Regional_FE "Yes"

// B. BY CRISIS
eststo: xtpcse iharatio c.trade##c.L.vulnerable share polity $control_SE $FE, pair corr(ar1)
	estadd local Regional_FE "Yes"
	
// C. BY ECONOMIC OPENNESS (NON-LINEARITY)
eststo: xtpcse iharatio trade trade2 trade3 share polity L.vulnerable $control_SE $FE, pair corr(ar1)
	estadd local Regional_FE "Yes"

esttab using "output/tables/regression3.tex", ///
drop(*.regid $Control_SE) ///
order($reported_tbl4) ///
replace b(4) se(4) ///
star(* 0.10 ** 0.05 *** 0.01) ///
label nomtitle booktabs ///
stats(N N_g Regional_FE r2 rho chi2, fmt(%9.0g %9.4f) ///
labels("N Obs." "Number of countries" Regional_FE R-squared "Rho" "Wald Chi2"))

***************************************************************************
***************************************************************************
***************************************************************************

/*
NOTES:

1. Bivariate
2. Bivariate + Control
3. Bivariate + Control + Democracy
4. Bivariate + Control + Competitiveness

1. Bivariate (dummy)
2. Bivariate (dummy) + Control
3. Bivariate (dummy) + Control + Democracy
4. Bivariate (dummy) + Control + Competitiveness


Check baseline for regid
*/

