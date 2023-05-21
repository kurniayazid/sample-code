/*
Name: Reporting
Date Created: 04/19/2023
Date Last Modified: 04/19/2023
Created by: EKY
Modified By: EKY
Last modified by: EKY
Uses data: main_dataset.dta
Creates data: 
Description:
*/

***************************************************************************
** SYSTEM SETUP ***********************************************************
***************************************************************************

cls
clear
set more off
set graphics off
* set memory // not applicable for version > 12.0


version 16.1


* Set directory [to replicate, CHANGE THIS DIRECTORY]
cd $user_dir

* Check directory
pwd

***************************************************************************
** INTRODUCTION ***********************************************************
***************************************************************************

use "data_cleaned/main_dataset.dta", clear
collapse (sum) iha (mean) trade s_04 w e v, by(year incomelevel)
label var iha "Sum of IHA"
label var w "WorldRisk"
label var s_04 " Vulnerability to Violence, Conflicts And Disaster"
lab var incomelevel "Income Level Group"

twoway (tsline iha, yaxis(1) lc(orange)) (tsline s_04, yaxis(2) lc(blue)), by(incomelevel)
graph export "/Users/egayazid/QMSS/SPRING23/IPE/cracking-emergency-door/output/Images/fig1.png", as(png) replace
0


* Importing dataset
use "data_raw/worldrisk.dta", clear
0
use "data_raw/iha_inflow.dta", clear
collapse iha, by(year)

* Aggregate worldrisk by year
// collapse w - a s_04 s_05, by(year)
tsset year
// tsline s_04 s_05

use "data_raw/socioeconomic.dta", clear
collapse trade, by(year)
tsset year
