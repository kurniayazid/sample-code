/*
Name: Prelim data cleaning - Risk, Disasters, and Humanitarian Crisis
Date Created: 04/16/2023
Date Last Modified: 04/16/2023
Created by: EKY
Modified By: EKY
Last modified by: EKY
Uses data: emdat, worldrisk
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
** DATA_PREP **************************************************************
***************************************************************************

* Import EMDAT dataset
import excel "data_raw/emdat.xlsx", sheet("emdat") firstrow clear

* Collapsing by country and year
collapse (first) Region Country ///
(sum) TotalDeaths TotalAffected TotalDamagesAdjusted000US TotalDamages000US ///
(mean) CPI, by(ISO Year)

* Generate disaster people impact index
* gen disaster_impact = (TotalDeaths + (TotalAffected * 0.5) / total_pop) * 1000

* Rename and relabel variable
rename (ISO Year) (countrycode year)

lab var TotalDeaths "deaths + missing people"
lab var TotalAffected "The total affected is the sum of injured, affected and homeless."

* Fill year-gap
	
	* Generate numeric id
	egen cid = group(countrycode)
	
	* Declare panel
	xtset year cid
	
	* Fill year-country-gap
	tsfill, full
	
	* Replace missing as zero
	foreach x of varlist TotalDeaths - TotalDamages000US {
		replace `x' = 0 if missing(`x')
	}
	
	* Save temporary
	tempfile emdat
	save `emdat', replace
		

* Update countrycode
collapse (mean) cid (first) Country Region, by(countrycode)
drop in 1/1
merge 1:m cid using `emdat'
drop _merge cid

* Sort data
sort countrycode year

* Order dataset
order countrycode year Country Region TotalDeaths TotalAffected TotalDamagesAdjusted000US TotalDamages000US CPI

// * Save to .dta
save "data_raw/emdat.dta", replace
***************************************************************************

* WORLDRISK

import delimited using "data_raw/worldriskindex-trend.csv", clear

* Rename key
rename iso3 countrycode

// * Save to .dta
save "data_raw/worldrisk.dta", replace
