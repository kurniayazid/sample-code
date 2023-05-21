/*
Name: Socioeconomic data prep
Date Created: 03/03/2023
Date Last Modified: 03/03/2023
Created by: EKY
Modified By: EKY
Last modified by: EKY
Data Source: World Bank
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
** GDP Per Capita *********************************************************
***************************************************************************

* Import dataset
wbopendata, language(en - English) country() topics() ///
indicator(NY.GDP.PCAP.PP.KD) clear long

* Relabelling variable and data
rename ny_gdp_pcap_pp_kd gdppc
lab data GDPpc
lab var gdppc "Annual GDP per capita PPP (constant 2017 international $)"
lab var year "Year"

* Description Summary
des

* Save Dataset
save "data_raw/socioeconomic/gdppc.dta", replace

***************************************************************************
** Trade ******************************************************************
***************************************************************************

wbopendata, language(en - English) country() topics() ///
indicator(NE.TRD.GNFS.ZS) clear long

* Relabelling variable and data
rename ne_trd_gnfs_zs trade
lab data percent_trade
lab var trade "Trade (\% of GDP)"
lab var year "Year"

* Description Summary
des

* Save Dataset
save "data_raw/socioeconomic/trade.dta", replace

***************************************************************************
** SCHOOL PARTICIPATION  **************************************************
***************************************************************************

wbopendata, language(en - English) country() topics() ///
indicator(SE.SEC.ENRR) clear long

* Rename variable
rename se_sec_enrr educ
lab var educ "Gross enrollment ratio is the ratio of total secondary education enrollment"

* Save Population
save "data_raw/socioeconomic/educ.dta", replace


***************************************************************************
** POPULATION  ************************************************************
***************************************************************************

* Import population database from world bank
wbopendata, language(en - English) country() topics() ///
indicator(SP.POP.TOTL) clear long

* Rename variable
rename sp_pop_totl total_pop
lab var total_pop "Total Population"

* Save Population
save "data_raw/socioeconomic/total_pop.dta", replace

***************************************************************************
** MERGE SOCIOECONOMIC ****************************************************
***************************************************************************
use "data_raw/socioeconomic/trade.dta", replace

merge 1:1 countryname countrycode year using "data_raw/socioeconomic/gdppc.dta"
drop _merge

merge 1:1 countryname countrycode year using "data_raw/socioeconomic/educ.dta"
drop _merge

merge 1:1 countryname countrycode year using "data_raw/socioeconomic/total_pop.dta"
drop _merge

* Save Dataset
lab data socioeconomic_dataset
save "data_raw/socioeconomic.dta", replace

***************************************************************************
** COMPETITIVENESS / GLOBAL TRADE *****************************************
***************************************************************************

* Import Global Trade Data
use data_raw/global_trade.dta, clear

* Aggregating by country-year
collapse (sum) export_value (mean) pci, by(location_code year)

* Generate global export share
egen world_export = total(export_value)
gen share_export = export_value / world_export

* Renaming and relabelling variables
rename location_code countrycode
lab var export_value "Total annual export value"
lab var pci "Country annual average Product Complexity Index"
lab var world_export "Annual global export value"
lab var share_export "Global export share"

save data_raw/global_aggregate_trade.dta, replace


***************************************************************************
** OIL & GAS  *************************************************************
***************************************************************************

* Total Energy Production

	* Import dataset
	import excel "data_raw/energy_production.xlsx", sheet("TotalEnergy") firstrow clear

	* Rename variable as year
	foreach x of varlist C - AR{
		local lab: variable label `x'
		rename `x' energy`lab'
	}
	
	* Reshape to long
	reshape long energy, i(countryname) j(year)

	* Relabelling
	lab var energy "Country annual energy production (in BTU)"

	* Save energy
	order countrycode countryname year energy
	save "data_raw/energy_production.csv", replace

* Energy production from coal

	* Import dataset
	import excel "data_raw/energy_production.xlsx", sheet("Coal") firstrow clear

	* Rename variable as year
	foreach x of varlist C - AR{
		local lab: variable label `x'
		rename `x' coal`lab'
	}

	* Reshape to long
	reshape long coal, i(countryname) j(year)

	* Relabelling
	lab var coal "Country annual energy production from coal (in BTU)"

	* Save energy
	order countrycode countryname year coal
	save "data_raw/coal_production.csv", replace

* Energy production from natural gas

	* Import dataset
	import excel "data_raw/energy_production.xlsx", sheet("NaturalGas") firstrow clear

	* Rename variable as year
	foreach x of varlist C - AR{
		local lab: variable label `x'
		rename `x' gas`lab'
	}

	* Reshape to long
	reshape long gas, i(countryname) j(year)

	* Relabelling
	lab var gas "Country annual energy production from natural gas (in BTU)"

	* Save energy
	order countrycode countryname year gas
	save "data_raw/gas_production.csv", replace
	
* Energy production from petroleum and other liquids

	* Import dataset
	import excel "data_raw/energy_production.xlsx", sheet("PetroleumOther") firstrow clear

	* Rename variable as year
	foreach x of varlist C - AR{
		local lab: variable label `x'
		rename `x' petro`lab'
	}

	* Reshape to long
	reshape long petro, i(countryname) j(year)

	* Relabelling
	lab var petro "Country annual energy production from petroleum and other liquids (in BTU)"

	* Save energy
	order countrycode countryname year petro
	save "data_raw/petro_production.csv", replace
	
* Merge Energy production
	
merge 1:1 countrycode countryname year using "data_raw/energy_production.csv"
drop _merge
merge 1:1 countrycode countryname year using "data_raw/coal_production.csv"
drop _merge
merge 1:1 countrycode countryname year using "data_raw/gas_production.csv"
drop _merge

* Format data as number
destring(petro energy coal gas), ignore("--" "ie") replace

lab data "Energy Production"
save "data_raw/energy.dta", replace

***************************************************************************
// NOTES

* Need to carryover or extrapolate the education
