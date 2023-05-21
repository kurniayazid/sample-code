/*
Name: Prelim data cleaning
Date Created: 02/26/2023
Date Last Modified: 04/15/2023
Created by: EKY
Modified By: EKY
Last modified by: EKY
Uses data: iha_inflow.xls AND aid_inflow.xls
Description: Updating IHA dataset and Notes
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

* Import AID dataset

	** OFFICIAL INFLOWS
	
	* oda-dacml-in
	import excel "data_raw/aid_inflow.xlsx", /// 
	sheet("oda-dacml-in") firstrow

	foreach x of varlist C - S{
	local lab: variable label `x'
	rename `x' oda1_`lab'
	}

	drop T // drop extra column
	
	drop in 147/147
	reshape long oda1_, i(country) j(year)

	save "data_raw/oda-dacml-in.dta", replace
	clear

	
	* oda-nondac-in
	import excel "data_raw/aid_inflow.xlsx", /// 
	sheet("oda-nondac-in") firstrow
	
	foreach x of varlist C - S{
	local lab: variable label `x'
	rename `x' oda2_`lab'
	}

	drop T // drop extra column
	
	drop in 147/147
	reshape long oda2_, i(country) j(year)

	save "data_raw/oda-nondac-in.dta", replace
	clear
	
	
	* oof
	import excel "data_raw/aid_inflow.xlsx", /// 
	sheet("oofs-in") firstrow
	
	foreach x of varlist C - S{
	local lab: variable label `x'
	rename `x' oof`lab'
	}
	
	drop T // drop extra column
	
	drop in 147/147
	reshape long oof, i(country) j(year)

	save "data_raw/oofs-in.dta", replace
	clear
	
	
	* export-credits-in
	import excel "data_raw/aid_inflow.xlsx", /// 
	sheet("export-credits-in") firstrow
	
	foreach x of varlist C - S{
	local lab: variable label `x'
	rename `x' excred`lab'
	}
	
	drop T // drop extra column
	
	drop in 147/147
	reshape long excred, i(country) j(year)

	save "data_raw/export-credits-in.dta", replace
	clear
	
	
	* long-debt-net-official-in
	import excel "data_raw/aid_inflow.xlsx", /// 
	sheet("long-debt-net-official-in") firstrow
	
	foreach x of varlist C - S{
	local lab: variable label `x'
	rename `x' oldebt`lab'
	}
	
	drop T // drop extra column
	
	drop in 147/147
	drop if oldebt2000 == .
	reshape long oldebt, i(country) j(year)

	save "data_raw/long-debt-net-official-in.dta", replace
	clear
	
	** PRIVATE INFLOWS
	
	* FDI
	import excel "data_raw/aid_inflow.xlsx", /// 
	sheet("long-debt-net-official-in") firstrow
	
	foreach x of varlist C - S{
	local lab: variable label `x'
	rename `x' fdi`lab'
	}
	
	drop T // drop extra column
	
	drop in 147/147
	drop if fdi2000 == .
	reshape long fdi, i(country) j(year)

	save "data_raw/fdi-in.dta", replace
	
	
***************************************************************************

* INTERNATIONAL HUMANITARIAN ASSISTANCE

* Import dataset
	import excel "data_raw/iha_inflow.xlsx", /// 
	sheet("iha_inflow") firstrow clear

*Rename variable
	foreach x of varlist C - T{
		local lab: variable label `x'
		rename `x' iha`lab'
		}

rename (CountryName ISO2ID) (country countryid)

* Reshape to long 
reshape long iha, i(country) j(year)
drop country

sort countryid year
replace iha = iha * 1000000

* Save dataset
save "data_raw/iha_inflow.dta", replace

***************************************************************************

* Merge official inflow
use "data_raw/oda-dacml-in.dta", clear

merge 1:1 country countryid year using "data_raw/oda-nondac-in.dta"
drop _merge

merge 1:1 country countryid year using "data_raw/oofs-in.dta"
drop _merge

merge 1:1 country countryid year using "data_raw/export-credits-in.dta"
drop _merge

merge 1:1 country countryid year using "data_raw/long-debt-net-official-in.dta"
drop _merge

merge 1:1 country countryid year using "data_raw/fdi-in.dta"
drop _merge

sort countryid year
merge countryid year using "data_raw/iha_inflow.dta"

* Structure the dataset
sort countryid year
drop _merge country

* Save final data
save "data_raw/official-inflow.dta", replace

* Check duplicates
duplicates report countryid year

* Check missing values
//  foreach var of varlist oda1_ - oldebt {
//         display "Checking `var' for missing values..."
//         inspect `var'
//     }

	
***************************************************************************

// NOTES:

* aid_inflow.xlsx using 2016 base prices while iha_inflow.xls using 2017 base
* For intuitive interpretation, it might need to connect the data using OECD deflator


