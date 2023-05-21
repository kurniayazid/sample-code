/*
Name: Final Merge
Date Created: 03/03/2023
Date Last Modified: 03/03/2023
Created by: EKY
Modified By: EKY
Last modified by: EKY
Uses data: data_raw
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
** MERGE ALL DATA *********************************************************
***************************************************************************

* Import Country ID converter
import excel "data_raw/countrycode_converter.xlsx", firstrow clear
rename twodigit countryid // adjust variable name with main dataset


* Merge converter and import main dataset
merge 1:m countryid using "data_raw/official-inflow.dta"
drop if _merge !=3 // drop unmatch (mostly developed countries and small islands)
drop _merge // drop _merge tag
rename threedigit countrycode // adjust variable name with socioeconomic_dataset
rename Country countryname // adjust variable name with socioeconomic_dataset

duplicates report countryid year // check duplicates

* Merge with disaster dataset
mmerge countrycode year using "data_raw/emdat.dta"
duplicates drop countryid year, force // drop duplicates
drop _merge

* Merge with worldrisk dataset

merge 1:1 countrycode year using "data_raw/worldrisk.dta"
drop if _merge < 3 // (mostly developed countries year > 2017)
drop _merge

* Merge with socioeconomic
merge 1:m countrycode year using "data_raw/socioeconomic.dta"

rename _merge disputemerge_1 // unmatched data mostly years are not in IHA
egen id = group(countryid) // generate id
lab var id "Country unique id"

	* Special adjustment to merge
	rename war_scode scode // adjust variable name with polity5 dataset
	replace scode = "SUD" if scode == "SDN" & year < 2011 
	// SUDAN CHANGE FROM SUD TO SDN IN 2011

duplicates tag countryid year, gen(dup)
duplicates drop countryid year, force // drop duplicates

* Merge with global trade
merge 1:1 countrycode year using "data_raw/global_aggregate_trade.dta"
drop if _merge != 3 // Incomplete South Sudan and Aruba
drop _merge

* Merge with energy
merge 1:m countrycode year using "data_raw/energy.dta"
duplicates drop countrycode year, force
drop _merge

* Merge with political variable
merge m:1 scode year using "data_raw/polity5.dta"

// drop if disputemerge_1 != 3
drop if _merge != 3
drop _merge disputemerge_1 dup


***************************************************************************
** FORMATING DATASET ******************************************************
***************************************************************************

* Keep required data
keep countryname countrycode year - iha Region TotalDeaths TotalDeaths TotalAffected TotalDamagesAdjusted000US TotalDamages000US CPI w - ai_04 incomelevel - election
order id

* Labeling variable
lab var year "Year"
lab var oda1_ "Official Development Assistance DAC-ML"
lab var oda2_ "Official Development Assistance Non-DAC"
lab var oof "Other official flows (OOF)"
lab var excred "Officially supported export credits from all donors to all developing countries"
lab var oldebt "Official long-term debt"
lab var iha "International Humanitarian Assitance"
lab var fdi "Foreign Direct Investment"

* Declare panel
xtset id year
tsfill, full // fill the gap

* Label data
lab data "main_dataset"

* Save main_dataset
save "data_cleaned/main_dataset.dta", replace

***************************************************************************
** MERGE ALL DATA v2 ******************************************************
***************************************************************************
// use "data_raw/polity5.dta", clear
// rename scode countrycode
// merge 1:1 countrycode year using "data_raw/socioeconomic.dta"
// drop if _merge !=3
// drop _merge

// tempfile mydata
// save `mydata', replace

// * Import Country ID converter
// import excel "data_raw/countrycode_converter.xlsx", firstrow clear
// rename twodigit countryid // adjust variable name with main dataset


// * Merge converter and import main dataset
// merge 1:m countryid using "data_raw/official-inflow.dta"
// drop if _merge !=3 // drop unmatch (mostly developed countries)
// drop _merge // drop _merge tag
// rename threedigit countrycode // adjust variable name with socioeconomic_dataset

// merge 1:1 countrycode year using `mydata'
// drop if _merge !=3
***************************************************************************
