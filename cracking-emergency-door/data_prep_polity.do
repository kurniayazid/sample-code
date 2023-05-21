/*
Name: Polity data prep
Date Created: 03/03/2023
Date Last Modified: 03/03/2023
Created by: EKY
Modified By: EKY
Last modified by: EKY
Uses data: polity5 (p5v2018.xls)
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

* Import dataset
import excel "data_raw/p5v2018.xls", /// 
	sheet("p5v2018") firstrow

* Binary regime
gen election = xrcomp == 3 // xrcomp = 3 -> election

* Encode durability
destring durable, ignore(",") replace

* Labelling variables
label data polity5 // Labelling dataset

label var cyear "Country Year: A unique identifier for each country year"
label var ccode "Unique Numeric Country Code"
label var scode "Three-letter alpha country code"
label var year "Year coded"
label var democ "The Democracy index is an additive eleven-point scale (0-10)"
label var autoc "Institutionalized Autocracy,is an additive eleven-point scale (0-10)"
label var polity "Combined Polity Score"
label var durable "Regime durability"
label var election "Dummy var =1, if a country implements election"

* Subset dataset based on recent year (after WW-II)
keep if year > 1945

* Retrieve variables of interests
order cyear ccode scode country year democ autoc polity durable election
keep cyear - election

* Save datasets
save "data_raw/polity5.dta", replace
