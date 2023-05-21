/*
Name: Master Do
Date Created: 02/26/2023
Date Last Modified: 04/25/2023
Created by: EKY
Modified By: EKY
Last modified by: EKY
Uses data: data_raw and data_cleaned
Creates data: 
Description:
*/

********************************************************************************
** MASTER SETUP ****************************************************************
********************************************************************************

/*
REQUIREMENT:
	ssc install outreg2
	ssc install estout
	ssc install mmerge
	ssc install wbopendata
*/

cls
clear
set more off
version 16.1
// set memory 15m // not applicable for version > 12.0 

* Set directory [to replicate, CHANGE THIS DIRECTORY]
global user_dir "/Users/egayazid/QMSS/SPRING23/IPE/cracking-emergency-door"
cd $user_dir

* Check directory
pwd

* Start log session
log using "log/$S_DATE", replace

***************************************************************************
** DO-FILE WORKFLOW *******************************************************
***************************************************************************

**PART 1. Dataset preparation

	* Preliminary data cleaning for prep
	do "script/data_prep.do"
	
	** Crisis data preparation
 	do "script/data_prep_crisis.do"
	
	* Polity5 data preparation
	do "script/data_prep_polity.do"
	
	** Socioeconomic data preparation
 	do "script/data_prep_socioeconomic.do"
	
	** Final dataset merge
	do "script/merge.do"

**PART 2. Analysis

	** Descriptive analysis and EDA
// 	do "script/EDA.do"
	
	** Regression test
// 	do "script/regression.do"

**PART 3. Figures

// 	do "script/reporting.do"

***************************************************************************

* LOG NOTES ***************************************************************
/*
***** UPDATE *****
- Updating ISSO-war_scode connecting id
- simple bivariate test

***** TO DO *****
1. Consider to remove transitional period because the polity score is undefined
2. Prep socioeconomic dataset:
	[x] GDPpc (constant rate) or growth
	[x] Trade (% of GDP) DONE
	- Population (nominal or growth)
	- School participation (avg. education)
	- HDI
	- Geographical aspect: Continent or climate
	- Culture
3. Finished the bivariate test:
	- rescale logarithmic transformation for international aid and economic variables
*/

* End log session
capture log close

translate "log/$S_DATE.smcl" "log/$S_DATE.pdf", replace
