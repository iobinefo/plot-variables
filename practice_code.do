/*********************************************************************************
 * LSMS-ISA Harmonised Panel Analysis Code                                        *
 * Description: Extract data for GHS2          *
 * Date: December 2023                                                            *
 * -------------------------------------------------------------------------------*
*/

**********************************************************
*** Set globals for files
**********************************************************

global country  Nigeria
global wave  GHS 12
global cover1  secta_plantingw2.dta
global cover2  secta_harvestw2.dta
global indiv_roster  sect1_plantingw2.dta
global indiv_roster0  sect1_harvestw2.dta
global indiv_roster1  sect2a_harvestw2.dta
global indiv_roster2  sect2b_harvestw2.dta
global lab_roster1 sect11c1_plantingw2.dta
global lab_roster2 secta2_harvestw2.dta
global shocks sect15a_harvestw2.dta
global housing  sect8_harvestw2.dta
global plot_roster  sect11a1_plantingw2.dta
global plot_inputs sect11f_plantingw2.dta
global ferts sect11d_plantingw2.dta
global csption1 cons_agg_wave2_visit1.dta
global csption2 cons_agg_wave2_visit2.dta
global items secta41_harvestw2.dta
global items_hh sect7_harvestw2.dta
global harvest_rwdta  secta3_harvestw2.dta
global perennial  sect11g_plantingw2.dta
global HDDS sect10b_harvestw2.dta
global livestock sect11i_plantingw2.dta
global conversions w2agnsconversion.dta
global seeds sect11e_plantingw2.dta
global pesticides sect11c2_plantingw2.dta
global tenure sect11b1_plantingw2.dta
global labor_hh sect3a_plantingw2.dta
global nfe sect9_harvestw2.dta
global geovars_hh NGA_HouseholdGeovars_Y2.dta
global geovars NGA_PlotGeovariables_Y2.dta
global anthropo  sect4a_harvestw2.dta
global temppath NGA\GHS12

global temppath 


**********************************************************
**** A) Master frame of crops, plots and households
**********************************************************

// plot-crop frame
use "${Input}\\${country}\\${wave}\\${harvest_rwdta}", clear
rename cropname crop_name
drop if  substr(sa3q4b,1, 2)=="HA"
egen plot_id = concat(hhid plotid), punct("-")

keep hhid plot_id crop_name cropcode 

sort plot_id cropcode, stable
bys plot_id    cropcode  : replace crop_name = crop_name[1]

duplicates drop


duplicates tag plot_id crop_name, gen(tag)
decode cropcode, gen(cropname2)
replace crop_name = cropname2 if tag>0

duplicates report plot_id cropcode crop_name
 
save "${Temp}\\${temppath}\\plot_crop_frame.dta", replace

// household frame
use "${Input}\\${country}\\${wave}\\${cover1}", clear
keep hhid 
duplicates report hhid 
duplicates drop
save "${Temp}\\${temppath}\\hh_frame.dta", replace

// individual frame
use "${Input}\\${country}\\${wave}\\${indiv_roster0}", clear
merge 1:1 hhid indiv using "${Input}\\${country}\\${wave}\\${indiv_roster}", force
drop if s1q14==2
rename indiv id
egen ID= concat (hhid id ), punct("-")
keep hhid ID
duplicates drop
save "${Temp}\\${temppath}\\indiv_frame.dta", replace


**********************************************************
**** B) Variable extraction
**********************************************************

// EA
use "${Nigeria_GHS_W2_raw_data}/Post Planting Wave 2\Household\secta_plantingw2.dta" , clear
*drop ea lga
*merge 1:1 hhid using "${Input}\\${country}\\GHS 10\\secta_plantingw1.dta", keep(master match) nogen
egen ea_id = concat(lga ea), punct("-")
keep hhid ea_id
duplicates drop
save  "${temping}/ea_id.dta", replace

*save "${Temp}\\${temppath}\\ea_id.dta", replace

// strata
*use "${Input}\\${country}\\${wave}\\${cover1}", clear 
/*
rename zone zone_w2
merge 1:1 hhid using "${Input}\\${country}\\GHS 10\\secta_plantingw1.dta", keep(master match)
rename zone strataid
keep hhid strataid  
duplicates drop
save "${Temp}\\${temppath}\\strataid.dta", replace
*/
// admin 1
*use "${Input}\\${country}\\${wave}\\${cover1}", clear 
use "${Nigeria_GHS_W2_raw_data}/Post Planting Wave 2\Household\secta_plantingw2.dta" , clear


rename zone admin_1
keep hhid admin_1  
decode admin_1, gen(admin_1_name)
duplicates drop
*save "${Temp}\\${temppath}\\admin1.dta", replace
save  "${temping}/admin1.dta", replace

// admin 2
*use "${Input}\\${country}\\${wave}\\${cover1}", clear
use "${Nigeria_GHS_W2_raw_data}/Post Planting Wave 2\Household\secta_plantingw2.dta" , clear

rename state admin_2 
keep hhid admin_2
decode admin_2, gen(admin_2_name)
duplicates drop
*save "${Temp}\\${temppath}\\admin2.dta", replace
save  "${temping}/admin2.dta", replace

// admin 3
*use "${Input}\\${country}\\${wave}\\${cover1}", clear
use "${Nigeria_GHS_W2_raw_data}/Post Planting Wave 2\Household\secta_plantingw2.dta" , clear


rename lga admin_3
keep hhid admin_3
duplicates drop
*save "${Temp}\\${temppath}\\admin3.dta", replace
save  "${temping}/admin3.dta", replace

// urban
use "${Input}\\${country}\\${wave}\\${cover1}", clear
recode sector (1 = 1 "Yes") (2 =0 "No"), gen(urban) label(urban)
keep hhid urban
duplicates drop
save "${Temp}\\${temppath}\\urban.dta", replace

// weights
use "${Input}\\${country}\\${wave}\\${csption1}", clear
merge 1:1 hhid using "${Input}\\${country}\\${wave}\\${csption2}", nogen
rename hhweight pw
keep pw hhid
duplicates drop
save "${Temp}\\${temppath}\\weights.dta", replace

// planting month
use "${Input}\\${country}\\${wave}\\${plot_inputs}", clear

egen plot_id = concat( hhid plotid), punct("-")

gen month = s11fq3a
gen year= s11fq3b
replace year=. if s11fq3b>2014 | s11fq3b<1980 

gen planting_month = ym(year, month)
format planting_month %tmCCYYMon
drop month year

collapse (min) planting_month , by(hhid cropcode plot_id)
save "${Temp}\\${temppath}\\planting_month.dta", replace

// harvest end month (absent)

clear

global Nigeria_GHS_W2_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA" 
global Nigeria_GHS_W2_created_data  "C:\Users\obine\Music\Documents\Project\codess\Nigeria_medianc\nga_wave2012"

global temping  "C:\Users\obine\Downloads"







use "${Nigeria_GHS_W2_raw_data}/Post Harvest Wave 2\Household\secta_harvestw2.dta" , clear




// harvest_interview_month 
*use "${Input}\\${country}\\${wave}\\${cover2}", clear
gen month = saq13m
format month %tm 
gen year = saq13y
format year %ty
gen harvest_interview_month = ym( year, month)
format harvest_interview_month %tmCCYYMon
keep hhid harvest_interview_month
duplicates drop
save  "${temping}/harvest_interview_month.dta", replace


// planting_interview_month 
*use "${Input}\\${country}\\${wave}\\${cover1}", clear


use "${Nigeria_GHS_W2_raw_data}/Post Planting Wave 2\Household\secta_plantingw2.dta" , clear
*merge m:1 hhid using "${Nigeria_GHS_W2_created_data}/ag_rainy_12.dta", gen(filter)

*keep if ag_rainy_12==1

gen month = saq13m
format month %tm 
gen year = saq13y
format year %ty
gen planting_interview_month = ym( year, month)
format planting_interview_month %tmCCYYMon
keep hhid planting_interview_month

duplicates drop
 save  "${temping}/planting_interview_month.dta", replace


// harvest_kg 
*use "${Input}\\${country}\\${wave}\\${conversions}", clear

use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\w2agnsconversion.dta" , clear
drop if kg==0
bys nscode: egen mad = mad( conversion)
collapse (mean) conversion (first) mad, by(nscode) 
tempfile Conversions
save "${temping}/conversion.dta", replace

*use "${Input}\\${country}\\${wave}\\${harvest_rwdta}", clear
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Harvest Wave 2\Agriculture\secta3_harvestw2.dta", clear
merge m:1 hhid using "${temping}/admin1.dta", keep(master match) nogen 
merge m:1 hhid using "${temping}/admin2.dta", keep(master match) nogen 
merge m:1 hhid using "${temping}/admin3.dta", keep(master match) nogen 
egen plot_id = concat(hhid plotid), punct("-")
rename ea ea_id
recode sa3q3 (1 = 1 "Yes") (2 =0 "No"), gen(any_harvest) label(any_harvest)
rename sa3q6a2 nscode 
merge m:1  nscode using "${temping}/conversion.dta", keep(master match)
gen harvest_kg= sa3q6a * conversion 
replace harvest_kg = sa3q6a if nscode==1 // KG
replace harvest_kg = sa3q6a * 0.001 if nscode==2 // grams
replace harvest_kg=0 if any_harvest==0 

recode sa3q3 (2 = 1 "Yes") (1 = 0 "No"), gen(crop_shock) label(crop_shock)
replace crop_shock = 0 if sa3q4==9 | sa3q4==10 
replace harvest_kg = . if harvest_kg==0 & crop_shock!=1 

collapse (sum) harvest_kg (count) n_harvest_kg = harvest_kg , by(plot_id cropcode admin_1 admin_2 admin_3 hhid)
replace harvest_kg = . if n_harvest_kg==0
save "${temping}/harvest_kg.dta", replace


// crop shock
 use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Harvest Wave 2\Agriculture\secta3_harvestw2.dta", clear
egen plot_id = concat(hhid plotid), punct("-")

recode sa3q3 (2 = 1 "Yes") (1 = 0 "No"), gen(crop_shock) label(crop_shock)
replace crop_shock = 0 if sa3q4==9 | sa3q4==10 
replace crop_shock=0 if  substr(sa3q4b,1, 3)=="NOT" // these are plots with unfinished harvest

recode sa3q4 (1 = 1 "Yes") (2/8 11 = 0 "No") (9 10  = .), gen(drought_shock) label(drought_shock) 
replace drought_shock=0 if sa3q3==1

recode sa3q4 (2 = 1 "Yes") (1 3/8 11 = 0 "No") ( 9 10 = .), gen(flood_shock) label(flood_shock) 
replace flood_shock=0 if sa3q3==1

recode sa3q4 (3 = 1 "Yes") (1 2 4/8 11 = 0 "No") (9 10 = .), gen(pests_shock) label(pests_shock) 
replace pests_shock=0 if sa3q3==1

collapse (max)  crop_shock pests_shock  drought_shock flood_shock    , by(hhid plot_id cropcode)
save "${temping}/crop_shock.dta", replace


// harvest sold amount



*use "${Input}\\${country}\\${wave}\\${harvest_rwdta}", clear


*use "${Input}\\${country}\\${wave}\\${conversions}", clear
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\w2agnsconversion.dta" , clear
drop if kg==0
drop cropname
tempfile Conversions_kg
save "${temping}/Conversions_kg.dta", replace


*use "${Input}\\${country}\\${wave}\\${harvest_rwdta}", clear

use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Harvest Wave 2\Agriculture\secta3_harvestw2.dta", clear
merge m:1 hhid using "${temping}/admin1.dta", keep(master match) nogen 
merge m:1 hhid using "${temping}/admin2.dta", keep(master match) nogen 
merge m:1 hhid using "${temping}/admin3.dta", keep(master match) nogen 
egen plot_id = concat(hhid plotid), punct("-")

rename sa3q11b nscode
count if inlist(., cropcode, nscode) //This command counts the number of observations where either cropcode or nscode is missing
merge m:1  cropcode nscode using "${temping}/Conversions_kg.dta", keep(master match) nogen
gen harvest_sold_kg_unprocessed1 = sa3q11a * conversion
replace harvest_sold_kg_unprocessed1 = sa3q11a if nscode==1 
replace harvest_sold_kg_unprocessed1 = sa3q11a * 0.001 if nscode==2 
replace harvest_sold_kg_unprocessed1 = 0 if sa3q9==2
drop nscode conversion

// other buyers 
rename sa3q16b nscode 
count if inlist(., cropcode, nscode) //This command counts the number of observations where either cropcode or nscode is missing
merge m:1  cropcode nscode using "${temping}/Conversions_kg.dta", keep(master match) nogen
gen harvest_sold_kg_unprocessed2 = sa3q16a * conversion
replace harvest_sold_kg_unprocessed2 = sa3q16a if nscode==1 
replace harvest_sold_kg_unprocessed2 = sa3q16a * 0.001 if nscode==2
replace harvest_sold_kg_unprocessed2 = 0 if sa3q14==2
drop nscode conversion

egen harvest_sold_kg = rowtotal(harvest_sold_kg_unprocessed*), missing

collapse (sum) harvest_sold_kg (count) n_harvest_sold_kg = harvest_sold_kg, by( plot_id cropcode hhid admin_1 admin_2 admin_3) //you want to make sure it is the plotid and for each crop and for individual households
replace harvest_sold_kg = . if n_harvest_sold_kg==0
save "${temping}/harvest_sold_kg.dta", replace

collapse (sum) harvest_sold_kg  (count) n_harvest_sold_kg=harvest_sold_kg , by(hhid)
replace harvest_sold_kg = . if n_harvest_sold_kg==0
merge 1:m hhid using "${temping}/harvest_kg.dta", keep(match)
collapse (sum) harvest_sold_kg harvest_kg (count) n_harvest_sold_kg=harvest_sold_kg n_harvest_kg = harvest_kg, by(hhid)
replace harvest_sold_kg = . if n_harvest_sold_kg==0
replace harvest_kg = . if n_harvest_kg==0
gen share_kg_sold = harvest_sold_kg/harvest_kg
replace share_kg_sold = . if share_kg_sold>1
keep hhid share_kg_sold
duplicates drop
save "${temping}/harvest_sold_kg_hh.dta", replace


// harvest sold value
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Harvest Wave 2\Agriculture\secta3_harvestw2.dta", clear
merge m:1 hhid using "${temping}/admin1.dta", keep(master match) nogen 
merge m:1 hhid using "${temping}/admin2.dta", keep(master match) nogen 
merge m:1 hhid using "${temping}/admin3.dta", keep(master match) nogen 
egen plot_id = concat(hhid plotid), punct("-")

egen harvest_sold_value = rowtotal( sa3q12 sa3q17), missing 
collapse (sum) harvest_sold_value (count) n_harvest_sold_value = harvest_sold_value, by(plot_id cropcode hhid admin_1 admin_2 admin_3)
replace harvest_sold_value = . if n_harvest_sold_value==0
save "${temping}/harvest_sold_value.dta", replace

*/



capture program drop valuation_median_crops_noea
program define valuation_median_crops_noea 
args hhid plotid cropvar 

merge 1:1 `hhid' `plotid' `cropvar' using "${temping}/harvest_sold_value.dta", keep(master match)	nogen
merge 1:1 `hhid' `plotid' `cropvar' using "${temping}/harvest_sold_kg.dta", keep(master match)	nogen


gen crop_price_temp= harvest_sold_value / harvest_sold_kg 
replace crop_price_temp = . if crop_price_temp==0


forvalues n =1/3 {
 merge m:1 `hhid' using "${temping}/admin`n'.dta", keep(master match)	nogen
}

				gen n=1 if !mi(crop_price_temp) & crop_price_temp!=0
				bys admin_3 `cropvar': egen n2= total(n)
				gen ten_obs_admin3=1 if n2>=10 & !mi(n2)
				replace ten_obs_admin3=0 if n2<10 | mi(n2)
				tab ten_obs_admin3
				bys admin_3 `cropvar': egen crop_price_admin3 = median(crop_price_temp) if crop_price_temp!=0
				gen crop_price = crop_price_admin3 if ten_obs_admin3==1
				drop n2 
		
		* 
		bys admin_2 `cropvar': egen n2=total(n)
		gen ten_obs_admin2=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin2=0 if n2<10 | mi(n2)
		tab ten_obs_admin2
		bys admin_2 `cropvar': egen crop_price_admin2 = median(crop_price_temp) if crop_price_temp!=0
		replace crop_price = crop_price_admin2 if ten_obs_admin2==1 & ten_obs_admin3==0 
		drop n2

		* admin_1 level 
		bys admin_1 `cropvar': egen n2=total(n)
		gen ten_obs_admin1=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin1=0 if n2<10 | mi(n2)
		tab ten_obs_admin1
		bys admin_1 `cropvar': egen crop_price_admin_1 = median(crop_price_temp) if crop_price_temp!=0
		replace crop_price = crop_price_admin_1 if ten_obs_admin1==1 & ten_obs_admin2==0 
		drop n2
		
		* 
		bys `cropvar': egen n2=total(n)
		gen ten_obs_n=1 if n2>=10 & !mi(n2)
		replace ten_obs_n=0 if n2<10 | mi(n2)
		tab ten_obs_n
		bys `cropvar': egen crop_price_national = median(crop_price_temp) if crop_price_temp!=0
		replace crop_price = crop_price_national if ten_obs_n==1 & ten_obs_admin1==0 
		drop n2 n
		
		replace crop_price=crop_price_national if ten_obs_n==0
		
	** Collapse to the EA - crop level
	keep admin_1 admin_2 admin_3  `cropvar' crop_price
	duplicates drop
	
	** Generating harvest value, using crop price variable
	merge 1:m admin_1 admin_2 admin_3  `cropvar'  using "${temping}/harvest_kg.dta", keep(match using) nogen
	gen harvest_value = crop_price * harvest_kg
		
end



// program for main crop calculation


capture program drop main_crop_def
program define main_crop_def 
args cropvar 

bys plot_id (harvest_value): gen n=_n if !mi(plot_id) & !mi(`cropvar') & !mi(harvest_value) // This ranks crops by harvest value within a plot 
bys plot_id: egen nMax= max(n)  
gen main_crop_obs = `cropvar' if n==nMax
bys plot_id: egen main_crop = max(main_crop_obs) // this is the variable of interest. It is now at the plot level.
*drop n nMax


end



// harvest_value & main crop
 use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Harvest Wave 2\Agriculture\secta3_harvestw2.dta", clear
egen plot_id = concat(hhid plotid), punct("-")
keep hhid plot_id cropcode 
duplicates drop

valuation_median_crops_noea hhid  plot_id  cropcode  

main_crop_def cropcode  //shouldn't the main crop be based on the total plot allocated to the particular crop?


keep plot_id harvest_value cropcode main_crop 
save "${temping}/harvest_value.dta", replace






// intercropped
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Planting Wave 2\Agriculture\sect11f_plantingw2.dta", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11fq2 (1= 0 "No") (2/7 = 1 "Yes"), gen(intercropped) label(intercropped)
keep cropcode plot_id intercropped
collapse (max) intercropped, by(plot_id)
save "${temping}/intercropped.dta", replace


// nb_seasonal_crop
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Harvest Wave 2\Agriculture\secta3_harvestw2.dta", clear
egen plot_id = concat( hhid plotid), punct("-")
bys  plot_id : egen nb_seasonal_crop = count(cropcode)
keep plot_id nb_seasonal_crop
duplicates drop
save "${temping}/nb_seasonal_crop.dta", replace


// main crop

use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Planting Wave 2\Agriculture\sect11f_plantingw2.dta", clear
gen count_temporary=1
collapse (sum) count_temporary, by(cropcode)
*tempfile Perennial_crops_temp
save "${temping}/Perennial_crops_temp.dta", replace
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Planting Wave 2\Agriculture\sect11g_plantingw2.dta", clear
gen count_permanent=1
collapse (sum) count_permanent, by(cropcode)
merge 1:1 cropcode using  "${temping}/Perennial_crops_temp.dta" // There is overlap
gen permanent_crop=0 
replace permanent_crop=1 if _merge==1 
replace permanent_crop=1 if _merge==3 & count_permanent>count_temporary // if crops appear in the "permanent" list more * frequently, they are counted as permanent crops. 
replace permanent_crop=1 if cropcode==3230 // rubber was misscoded
drop if permanent_crop==0 // this results in a list of crop codes which are permanent
drop permanent_crop count_permanent count_temporary _merge
*tempfile Perennial_crops_list 
save "${temping}/Perennial_crops_list.dta", replace
rename cropcode main_crop
*tempfile Perennial_crops_list_MC 
save "${temping}/Perennial_crops_list_MC.dta", replace

use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Harvest Wave 2\Agriculture\secta3_harvestw2.dta", clear
egen plot_id = concat( hhid plotid), punct("-")
merge m:1 cropcode using  "${temping}/Perennial_crops_list.dta", keep(master match) 
rename _merge _mergecropcode

merge m:1 cropcode plot_id  using "${temping}/harvest_value.dta", keep(match using) nogen
merge m:1 main_crop using  "${temping}/Perennial_crops_list_MC.dta", keep(master match) 
rename _merge _mergemain_crop

bys plot_id: egen total_value_plot= total(harvest_value), missing
gen maincrop_valueshare_temp = harvest_value/ total_value_plot if cropcode==main_crop
bys plot_id: egen maincrop_valueshare = max(maincrop_valueshare_temp)

foreach c in main_crop cropcode {
lab val `c' SECTA3_Q2
rename `c' `c'2
decode `c'2, gen(`c')
drop `c'2
replace `c' = strupper(`c')
local dot strpos(`c', ".")
replace `c' = trim(cond(`dot', substr(`c',`dot' + 1, .), `c'))
replace `c' = "SUGARCANE" if `c' =="SUGAR CANE"
replace `c' = "PUMPKINS" if `c' =="PUMPKIN"
replace `c' = "OKRA" if `c' =="OKRO"
replace `c' = "BANANAS" if `c' =="BANANA"
replace `c' = "TOMATOES" if `c' =="TOMATO"

gen `c'2 = "BEANS AND OTHER LEGUMES" if inlist(`c',"COWPEA", "GROUNDNUTS", "SOY", "SOYA BEANS",  "BEANS") | strpos(`c', "COWPEA") | strpos(`c', "PEANUT") | strpos(`c' , "GROUND NUTS")
replace `c'2 = "BEANS AND OTHER LEGUMES" if inlist(`c',"PEA", "PEANUTS", "VOANDZOU", "BAMBARA NUT", "PIGEON PEA")
replace `c'2 = "TUBERS / ROOT CROPS" if inlist(`c',"POTATO", "SWEET POTATO", "CASSAVA", "YAMS", "CARROT") | strpos(`c', "CASSAVA") | strpos(`c', "POTATO")
replace `c'2 = "TUBERS / ROOT CROPS" if strpos(`c', "YAM")
replace `c'2 = "TUBERS / ROOT CROPS" if inlist(`c',"BEETS", "TARO", "SOUCHET", "COCOYAM", "RIZGA")
replace `c'2 = "RICE" if `c'=="PADDY RICE" | `c'=="RICE" | strpos(`c', "RICE")
replace `c'2 = "WHEAT" if `c'=="WHEAT"
replace `c'2 = "MAIZE" if `c'=="MAIZE"| strpos(`c', "MAIZE")
replace `c'2 = "BARLEY" if `c'=="BARLEY"
replace `c'2 = "SORGHUM" if `c'=="SORGHUM"
replace `c'2 = "SORGHUM" if strpos(`c', "SORGHUM")
replace `c'2 = "MILLET" if `c'=="MILLET" | `c'=="ACHA" |  `c'=="FONIO" | strpos(`c', "MILLET")
replace `c'2 = "NUTS" if `c'=="NUTS" | `c'=="SHEA NUTS" | `c'=="CASHEW NUT"
replace `c'2 = "" if `c'=="."
tab `c' if `c'2==""
replace `c'2 = "OTHER" if `c'2==""
replace `c'2 = "PERENNIAL/FRUIT" if  _merge`c' == 3
drop `c'
rename `c'2 `c'
}
tab cropcode, gen(contains_crop_)
foreach n in 9 8 7 6 5 4 {
	local i = `n' + 2
	rename contains_crop_`n' contains_crop_`i'
} 
	
foreach n in 3 2 1 {
	local i = `n' + 1
	rename contains_crop_`n' contains_crop_`i'
} 
gen contains_crop_1=0
gen contains_crop_5=0


//share of each crop category

forvalues n = 1/11 {
gen share_crop`n' = harvest_value/ total_value_plot if contains_crop_`n'==1
replace share_crop`n' = 0 if contains_crop_`n'==0
}

collapse (sum)   share_crop* (max) contains_crop_*, by(plot_id main_crop maincrop_valueshare ) 
save "${temping}/main_crop.dta", replace


// share of plot area planted by crop 
*use "${Input}\\${country}\\${wave}\\${plot_inputs}", clear


// land area
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Planting Wave 2\Agriculture\sect11a1_plantingw2.dta" , clear
rename (zone state lga) (admin_1 admin_2 admin_3)
egen plot_id = concat( hhid plotid), punct("-") 

gen area_self_reported= s11aq4a
replace area_self_reported = area_self_reported * 0.0667 if s11aq4b==4 
replace area_self_reported = area_self_reported * 0.4 if s11aq4b==5
replace area_self_reported = area_self_reported * 0.0001 if s11aq4b==7

// heaps
replace area_self_reported = area_self_reported * 0.00012 if s11aq4b==1 & admin_1==1
replace area_self_reported = area_self_reported * 0.00016 if s11aq4b==1 & admin_1==2
replace area_self_reported = area_self_reported * 0.00011 if s11aq4b==1 & admin_1==3
replace area_self_reported = area_self_reported * 0.00019 if s11aq4b==1 & admin_1==4
replace area_self_reported = area_self_reported * 0.00021 if s11aq4b==1 & admin_1==5
replace area_self_reported = area_self_reported * 0.00012 if s11aq4b==1 & admin_1==6

// ridges 
replace area_self_reported = area_self_reported * 0.0027 if s11aq4b==2 & admin_1==1
replace area_self_reported = area_self_reported * 0.004 if s11aq4b==2 & admin_1==2
replace area_self_reported = area_self_reported * 0.00494 if s11aq4b==2 & admin_1==3
replace area_self_reported = area_self_reported * 0.0023 if s11aq4b==2 & admin_1==4
replace area_self_reported = area_self_reported * 0.0023 if s11aq4b==2 & admin_1==5
replace area_self_reported = area_self_reported * 0.00001 if s11aq4b==2 & admin_1==6

// stands
replace area_self_reported = area_self_reported * 0.00006 if s11aq4b==3 & admin_1==1
replace area_self_reported = area_self_reported * 0.00016 if s11aq4b==3 & admin_1==2
replace area_self_reported = area_self_reported * 0.00004 if s11aq4b==3 & admin_1==3
replace area_self_reported = area_self_reported * 0.00004 if s11aq4b==3 & admin_1==4
replace area_self_reported = area_self_reported * 0.00013 if s11aq4b==3 & admin_1==5
replace area_self_reported = area_self_reported * 0.00041 if s11aq4b==3 & admin_1==6


gen plot_area_GPS= s11aq4c
replace plot_area_GPS = plot_area * 0.0001 // converting to hectare

merge m:1 hhid using "${temping}/admin3.dta", keep(master match) nogen

isid hhid plot_id
sort hhid plot_id

mi set wide 					//	declare the data to be wide. 
mi register imputed plot_area_GPS	//	identify plotsize as the variable being imputed 
mi tsset, clear 
mi impute pmm plot_area_GPS area_self_reported i.admin_3, add(1) rseed(12345) noisily dots /*
*/	force knn(5) bootstrap 
mi unset
replace plot_area_GPS = plot_area_GPS_1_ if mi(plot_area_GPS)

bys hhid: egen farm_size = total(plot_area_GPS), missing

keep hhid plot_id   plot_area_GPS farm_size
duplicates drop
save "${temping}/plot_area.dta", replace

// improved (absent)
*use "${Input}\\${country}\\${wave}\\${plot_inputs}", clear

// seed kg
use "${Input}\\${country}\\${wave}\\${conversions}", clear
drop if kg==0
drop kg cropname
tempfile Conversions
save `Conversions', replace
use "${Input}\\${country}\\${wave}\\${conversions}", clear
drop if kg==0
drop kg cropname
collapse (mean) conversion , by(nscode) 
tempfile Conversions_nocrop
save `Conversions_nocrop', replace

use "${Input}\\${country}\\${wave}\\${seeds}", clear
egen plot_id = concat( hhid plotid), punct("-") // This creates a unique plot id.
rename (zone state lga) (admin_1 admin_2 admin_3)

foreach var of varlist s11eq5 s11eq9 s11eq17 s11eq29 {
replace `var'=. if `var'< cropcode | `var'> cropcode + 9 & !mi(`var')
assert `var' >= cropcode | mi(`var') | mi(cropcode) & `var' <= cropcode + 9 | mi(`var') | mi(cropcode)
}

gen seed_kg_preconv = s11eq6a 
rename s11eq6b nscode
count if nscode==. | seed_kg_preconv==. | cropcode ==.  // many missing
merge m:1  cropcode  nscode using `Conversions', keep(master match)  // this is a terrible match rate, but mostly because many are in kg
gen seed_kg1= seed_kg_preconv * conversion
replace seed_kg1= seed_kg_preconv if nscode==1 
replace seed_kg1 = seed_kg_preconv * 0.001 if nscode==2
drop conversion  
merge m:1  nscode using  `Conversions_nocrop', keep(master match) nogen 
replace seed_kg1= seed_kg_preconv * conversion if  seed_kg1==.
drop conversion seed_kg_preconv nscode 

// free seeds  
gen seed_kg_preconv = s11eq10a 
rename s11eq10b nscode
count if nscode==. | seed_kg_preconv==. | cropcode ==.  // many missing
merge m:1  cropcode  nscode  using `Conversions', keep(master match) nogen 
gen seed_kg2= seed_kg_preconv * conversion
replace seed_kg2= seed_kg_preconv if nscode==1 
replace seed_kg2 = seed_kg_preconv * 0.001 if nscode==2
drop conversion  
merge m:1  nscode using `Conversions_nocrop', keep(master match)  nogen
replace seed_kg2= seed_kg_preconv * conversion if  seed_kg2==.
drop conversion seed_kg_preconv nscode

// 1st source commercial 
gen seed_kg_preconv = s11eq18a 
rename s11eq18b nscode
count if nscode==. | seed_kg_preconv==. | cropcode ==.  // many missing
merge m:1  cropcode  nscode  using `Conversions', keep(master match) nogen 
gen seed_kg3= seed_kg_preconv * conversion
replace seed_kg3= seed_kg_preconv if nscode==1 
replace seed_kg3 = seed_kg_preconv * 0.001 if nscode==2
drop conversion  
merge m:1  nscode using `Conversions_nocrop', keep(master match)  nogen
replace seed_kg3= seed_kg_preconv * conversion if  seed_kg3==.
drop conversion seed_kg_preconv nscode

// 2nd source commercial 
gen seed_kg_preconv = s11eq30a 
rename s11eq30b nscode
count if nscode==. | seed_kg_preconv==. | cropcode ==.  // many missing
merge m:1  cropcode  nscode  using `Conversions', keep(master match) nogen 
gen seed_kg4= seed_kg_preconv * conversion
replace seed_kg4= seed_kg_preconv if nscode==1 
replace seed_kg4 = seed_kg_preconv * 0.001 if nscode==2
drop conversion  
merge m:1  nscode using `Conversions_nocrop', keep(master match) nogen
replace seed_kg4= seed_kg_preconv * conversion if  seed_kg4==.
drop conversion seed_kg_preconv nscode


egen seed_kg = rowtotal(seed_kg*), missing
replace seed_kg=0 if s11eq3==2
collapse (sum)  seed_kg (count) n_seed_kg = seed_kg , by( cropcode hhid plot_id admin_1 admin_2 admin_3)
replace seed_kg = . if n_seed_kg==0
save "${Temp}\\${temppath}\\seed_kg.dta", replace
save "${Temp}\\${temppath}\\seed_kg_merge.dta", replace


// seed_kg_sold 
use "${Input}\\${country}\\${wave}\\${conversions}", clear
drop if kg==0
drop kg cropname
tempfile Conversions
save `Conversions', replace
use "${Input}\\${country}\\${wave}\\${seeds}", clear
egen plot_id = concat( hhid plotid), punct("-") // This creates a unique plot id.
rename (zone state lga) (admin_1 admin_2 admin_3)

gen seed_kg_preconv = s11eq18a 
rename s11eq18b nscode // to merge
count if cropcode==. | nscode==. 
merge m:1  cropcode nscode  using  `Conversions', keep(master match) nogen 
gen seed_kg_purch1= seed_kg_preconv * conversion
replace seed_kg_purch1 = seed_kg_preconv if nscode ==1
replace seed_kg_purch1 = seed_kg_preconv * 0.001 if nscode ==2

drop conversion seed_kg_preconv nscode

// 2nd source commercial 
gen seed_kg_preconv = s11eq30a 
rename s11eq30b nscode
count if cropcode==. | nscode==. 
merge m:1  cropcode nscode  using  `Conversions', keep(master match) nogen 
gen seed_kg_purch2= seed_kg_preconv * conversion
replace seed_kg_purch2 = seed_kg_preconv if nscode ==1
replace seed_kg_purch2 = seed_kg_preconv * 0.001 if nscode ==2
drop conversion seed_kg_preconv nscode

egen seeds_amount_purchased_kg= rowtotal(seed_kg_purch1 seed_kg_purch2), missing
collapse (sum) seeds_amount_purchased_kg (count) n_seeds_amount_purchased_kg = seeds_amount_purchased_kg, by(cropcode hhid plot_id)
replace seeds_amount_purchased_kg = . if n_seeds_amount_purchased_kg==0
save "${Temp}\\${temppath}\\seeds_amount_purchased_kg.dta", replace

// seed_value_sold
use "${Input}\\${country}\\${wave}\\${seeds}", clear
egen plot_id = concat( hhid plotid), punct("-") // This creates a unique plot id.
rename (zone state lga) (admin_1 admin_2 admin_3)

egen seed_value_temp = rowtotal(s11eq21 s11eq33), missing 

collapse  (sum) seed_value_temp (count) n_seed_value_temp = seed_value_temp , by(cropcode hhid plot_id )
replace seed_value_temp = . if n_seed_value_temp==0
save "${Temp}\\${temppath}\\seed_value_temp.dta", replace

// seed value 
use "${Input}\\${country}\\${wave}\\${seeds}", clear
egen plot_id = concat( hhid plotid), punct("-") // This creates a unique plot id.
rename (zone state lga) (admin_1 admin_2 admin_3)

keep cropcode plot_id hhid plot_id
duplicates drop

val_median_seeds_noimp_noea hhid plot_id cropcode 

keep  plot_id cropcode seed_value
duplicates drop
save "${Temp}\\${temppath}\\seed_value.dta", replace

// labor days
use "${Input}\\${country}\\${wave}\\${lab_roster1}", clear
egen plot_id = concat( hhid plotid), punct("-")
egen PPmean_fam_hr_per_day = rowmean(s11c1q1*4)

* 1) Family labor

gen hh_labordays1 = s11c1q1a2 * s11c1q1a3
gen hh_labordays2 = s11c1q1b2 * s11c1q1b3
gen hh_labordays3 = s11c1q1c2 * s11c1q1c3
gen hh_labordays4 = s11c1q1d2 * s11c1q1d3
    egen PPtotal_family_labor_days = rowtotal(hh_labordays*), missing 


* 2) Hired labor

gen PPhired_man_days = s11c1q2 * s11c1q3
replace PPhired_man_days = 0 if s11c1q2 == 0

gen PPhired_woman_days = s11c1q5 *s11c1q6
replace PPhired_woman_days = 0 if s11c1q5 == 0

gen PPhired_child_days = s11c1q8 *s11c1q9
replace PPhired_child_days = 0 if s11c1q8 == 0

egen PPtotal_hired_labor_days= rowtotal(PPhired_man_days PPhired_woman_days PPhired_child_days), missing

gen PPhired_man_wage= s11c1q4

gen PPhired_woman_wage= s11c1q7

gen PPhired_child_wage = s11c1q10

valuation_median_wages hhid PPhired_man_wage PPhired_woman_wage PPhired_child_wage

gen man_labor_value = man_wage * PPhired_man_wage
gen woman_labor_value = woman_wage * PPhired_woman_wage
gen child_labor_value = child_wage * PPhired_child_wage
egen PPhired_labor_value = rowtotal (*_labor_value), missing


* ID code of workers

local let "a b c d"
forvalues n = 1/4 {
local a: word `n' of `let'
egen ID`a' = concat(hhid s11c1q1`a'1 ), punct("-")
gen ID_worker`n'_PP = ID`a' if  s11c1q1`a'1 !=.
}


tempfile PPtotal_labor_days 
save `PPtotal_labor_days', replace 

use "${Input}\\${country}\\${wave}\\${lab_roster2}", clear
egen plot_id = concat( hhid plotid), punct("-") 
egen PHmean_fam_hr_per_day = rowmean(sa2q1*4)

* 1) Family labor 

local a "a b c d"

forvalues x =1/4 {
    local let: word `x' of `a'
   gen hh_labordays`x' = sa2q1`let'2 * sa2q1`let'3
}

egen PHtotal_family_labor_days = rowtotal(hh_labordays*), missing 
replace PHtotal_family_labor_days= 0 if  sa2q1a1==. & sa2q1b1==. & sa2q1c1==. & sa2q1d1==.
 replace PHtotal_family_labor_days= 0 if  sa2q1a1==0 & sa2q1b1==0 & sa2q1c1==0 & sa2q1d1==0
 

* 2) Hired labor days
 
gen PHhired_man_days = sa2q2 * sa2q3  
replace PHhired_man_days = 0 if sa2q2==0

gen PHhired_woman_days = sa2q5 * sa2q6  
replace PHhired_woman_days = 0 if sa2q5==0

gen PHhired_child_days = sa2q8 * sa2q9 
replace PHhired_child_days = 0 if sa2q8==0

egen PHtotal_hired_labor_days= rowtotal(PHhired_man_days PHhired_woman_days PHhired_child_days), missing

gen PHhired_man_wage= sa2q4
  
gen PHhired_woman_wage= sa2q7

gen PHhired_child_wage = sa2q10

valuation_median_wages hhid PHhired_man_wage PHhired_woman_wage PHhired_child_wage

gen man_labor_value = man_wage * PHhired_man_days
gen woman_labor_value = woman_wage * PHhired_woman_days
gen child_labor_value = child_wage * PHhired_child_days
egen PHhired_labor_value = rowtotal (*_labor_value), missing


* 3) Other (free) labor

gen PHother_man_days = sa2q12a   

gen PHother_woman_days = sa2q12b

gen PHother_child_days = sa2q12c

egen PHtotal_other_labor_days= rowtotal(PHother_man_days PHother_woman_days PHother_child_days), missing

* 4) Total labor days

egen PHtotal_labor_days = rowtotal(PHtotal_hired_labor_days PHtotal_family_labor_days PHtotal_other_labor_days), missing

* ID code of workers

local let "a b c d"
forvalues n = 1/4 {
local a: word `n' of `let'
egen ID`a' = concat(hhid sa2q1`a'1), punct("-")
gen ID_worker`n'_PH = ID`a' if  sa2q1`a'1 !=.
}


tempfile PHtotal_labor_days 
save `PHtotal_labor_days', replace 

// PH labor

// put all together
use `PHtotal_labor_days', clear
merge 1:1 plot_id  using `PPtotal_labor_days', nogen

egen total_labor_days = rowtotal(PHtotal_hired_labor_days PHtotal_family_labor_days PHtotal_other_labor_days PPtotal_hired_labor_days PPtotal_family_labor_days ), missing

egen total_hired_labor_days = rowtotal(PHtotal_hired_labor_days PPtotal_hired_labor_days ), missing

egen total_family_labor_days = rowtotal(PHtotal_family_labor_days PPtotal_family_labor_days)

egen hired_labor_value = rowtotal(PHhired_labor_value PPhired_labor_value), missing
replace hired_labor_value = 0 if total_hired_labor_days==0

keep total_labor_days plot_id total_family_labor_days total_hired_labor_days hired_labor_value ID_worker1_PH ID_worker2_PH ID_worker3_PH ID_worker4_PH ID_worker1_PP ID_worker2_PP ID_worker3_PP ID_worker4_PP
duplicates drop
save "${Temp}\\${temppath}\\labor_days.dta", replace

// inorganic fertilizer
use "${Input}\\${country}\\${wave}\\${ferts}", clear

egen plot_id = concat( hhid plotid), punct("-")
gen inorganic_fertilizer=0 if s11dq1!=. // if any fertilizer was known to be used
replace inorganic_fertilizer=1 if inlist(1,s11dq3, s11dq7, s11dq15, s11dq27) | inlist(2,s11dq3, s11dq7, s11dq15, s11dq27)
keep plot_id inorganic_fertilizer
duplicates drop
save "${Temp}\\${temppath}\\inorganic_fertilizer.dta", replace

// nitrogen equivalent
use "${Input}\\${country}\\${wave}\\${conversions}", clear
bys nscode: egen mad = mad( conversion)
collapse (median) conversion (first) mad, by(nscode)
tempfile Conversions
save `Conversions', replace

use "${Input}\\${country}\\${wave}\\${ferts}", clear

egen plot_id = concat( hhid plotid), punct("-") 
*UREA

//left over 
gen UREA_kg1= s11dq4 if s11dq3==2

// free
gen UREA_kg2= s11dq8 if s11dq7==2
  
// commercial 1  
gen UREA_kg3= s11dq16 if s11dq15==2

// commercial 2 
gen UREA_kg4 = s11dq28 if s11dq27==2

egen UREA_kg = rowtotal (UREA_kg*), missing
replace UREA_kg = 0 if s11dq1==2 | !inlist(2,s11dq3, s11dq7, s11dq15, s11dq27)

** NPK

// left over
gen NPK_kg1= s11dq4 if s11dq3==1

// free
gen NPK_kg2= s11dq8 if s11dq7==1
  
// commercial 1  
gen NPK_kg3= s11dq16 if s11dq15==1

// commercial 2 
gen NPK_kg4 = s11dq28 if s11dq27==1

egen NPK_kg = rowtotal (NPK_kg*), missing
replace NPK_kg = 0 if s11dq1==2 | !inlist(1,s11dq3, s11dq7, s11dq15, s11dq27)

** other 

// left over
gen other_kg1= s11dq4 if s11dq3==4

// free
gen other_kg2= s11dq8 if s11dq7==4
  
// commercial 1  
gen other_kg3= s11dq16 if s11dq15==4

// commercial 2 
gen other_kg4 = s11dq28 if s11dq27==4

egen other_kg = rowtotal (other_kg*), missing
replace other_kg = 0 if s11dq1==2 | !inlist(1,s11dq3, s11dq7, s11dq15, s11dq27)

* B/ Nitrogen equalivents

gen UREA_N_kg = UREA_kg*0.46
gen NPK_N_kg = NPK_kg*0.2
egen nitrogen_kg = rowtotal(UREA_N_kg NPK_N_kg), missing


collapse (sum) nitrogen_kg  UREA_kg  NPK_kg other_kg  (count) n_nitrogen_kg = nitrogen_kg n_NPK_kg = NPK_kg  n_UREA_kg = UREA_kg n_other_kg = other_kg , by(plot_id hhid)
foreach var in nitrogen_kg NPK_kg  UREA_kg  other_kg  {
replace `var' = . if n_`var'==0
}
save "${Temp}\\${temppath}\\nitrogen_kg.dta", replace
save  "${temping}/admin1.dta", replace

// inorganic fertilizer value 
use "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2012_GHSP-W2_v02_M_STATA\Post Planting Wave 2\Agriculture\sect11d_plantingw2.dta", clear
*use "${Input}\\${country}\\${wave}\\${ferts}", clear
egen plot_id = concat( hhid plotid), punct("-") 

gen UREA_purchased_p1 = s11dq19 if s11dq15==2 
gen UREA_purchased_p2 = s11dq29 if s11dq27==2 
egen UREA_purchased_value = rowtotal(UREA_purchased_p* ), missing 

gen NPK_purchased_p1 = s11dq19 if s11dq15==1
gen NPK_purchased_p2 = s11dq29 if s11dq27==1 
egen NPK_purchased_value = rowtotal(NPK_purchased_p* ), missing 

gen other_purchased_p1 = s11dq19 if s11dq15==4
gen other_purchased_p2 = s11dq29 if s11dq27==4
egen other_purchased_value = rowtotal(other_purchased_p* ), missing 

** quantity 

* UREA

// commercial 1
gen UREA_purchased_kg1= s11dq16 if s11dq15==2

// commercial 2
gen UREA_purchased_kg2= s11dq28 if s11dq27==2

egen UREA_purchased_kg = rowtotal(UREA_purchased_kg*), missing

* NPK 

// commercial 1
gen NPK_purchased_kg1= s11dq16  if s11dq15==1

// commercial 2
gen NPK_purchased_kg2= s11dq28 if s11dq27==1

egen NPK_purchased_kg = rowtotal(NPK_purchased_kg*), missing

* Other 
gen other_purchased_kg1= s11dq16  if s11dq15==4

// commercial 2
gen other_purchased_kg2= s11dq28  if s11dq27==4

egen other_purchased_kg = rowtotal(other_purchased_kg*), missing

collapse (max) UREA_purchased_kg  NPK_purchased_kg other_purchased_kg  UREA_purchased_value NPK_purchased_value  other_purchased_value  , by(hhid)

valuation_median_fert_price hhid UREA

valuation_median_fert_price hhid NPK

valuation_median_fert_price hhid other


collapse (sum) UREA_value  NPK_value  other_value , by(hhid) 
merge 1:m hhid using "${Temp}\\${temppath}\\nitrogen_kg.dta",  nogen

foreach n in NPK UREA other  {
    gen value_`n' = `n'_value * `n'_kg
}

egen inorganic_fertilizer_value = rowtotal(value_*), missing

keep plot_id  inorganic_fertilizer_value
duplicates drop
save "${Temp}\\${temppath}\\inorganic_fertilizer_value.dta", replace

// organic fert
use "${Input}\\${country}\\${wave}\\${ferts}", clear
egen plot_id = concat( hhid plotid), punct("-") 

gen organic_fertilizer=0 if s11dq1!=. // if any fertilizer was known to be used
replace organic_fertilizer=1 if inlist(3,s11dq3, s11dq7, s11dq15, s11dq27) 
collapse (max)  organic_fertilizer, by(plot_id)
save "${Temp}\\${temppath}\\organic_fertilizer.dta", replace

// pesticides
use "${Input}\\${country}\\${wave}\\${pesticides}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11c2q1 (1 = 1 "Yes") (2 = 0 "No") , gen(used_pesticides) label(used_pesticides)
collapse (max) used_pesticides, by(plot_id)
save "${Temp}\\${temppath}\\used_pesticides.dta", replace

// plot owned
use "${Input}\\${country}\\${wave}\\${tenure}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11b1q4 ( 1 4   = 1 "Yes") (2 3 = 0 "No") , gen(plot_owned) 
recode s11b1q7 (1 = 1 "Yes") (2= 0 "No") (3=.), gen(plot_certificate) label(plot_certificate)
replace plot_certificate=0 if plot_owned==0 | s11b1q4==4
keep plot_id plot_owned plot_certificate
duplicates drop
save "${Temp}\\${temppath}\\plot_owned.dta", replace

// irrigated
use "${Input}\\${country}\\${wave}\\${tenure}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11b1q39 (1 = 1 "Yes") (2 = 0 "No"), gen(irrigated) label(irrigated)
keep plot_id irrigated
duplicates drop
save "${Temp}\\${temppath}\\irrigated.dta", replace

// erosion protection (absent)


// tractor
use "${Input}\\${country}\\${wave}\\${pesticides}", clear
egen plot_id = concat( hhid plotid), punct("-") 
gen tractor= 0 if  s11c2q28b!=. | s11c2q28d!=. | s11c2q28f!=. | s11c2q30b!=. | s11c2q30d!=. | s11c2q30f!=. 
replace tractor= 1 if inlist(1, s11c2q28b, s11c2q28d, s11c2q28f, s11c2q30b, s11c2q30d, s11c2q30f)
replace tractor= 1 if inlist(2, s11c2q28b, s11c2q28d, s11c2q28f, s11c2q30b, s11c2q30d, s11c2q30f) // ridger 
replace tractor= 1 if inlist(3, s11c2q28b, s11c2q28d, s11c2q28f, s11c2q30b, s11c2q30d, s11c2q30f) // harvester
replace tractor= 1 if inlist(4, s11c2q28b, s11c2q28d, s11c2q28f, s11c2q30b, s11c2q30d, s11c2q30f) // planter

replace tractor = 0 if s11c2q27==2
collapse (max) tractor , by(hhid)
save "${Temp}\\${temppath}\\tractor.dta", replace

// nb fallow
use "${Input}\\${country}\\${wave}\\${tenure}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11b1q28 (1 = 1) (. = . ) (* = 0), gen(fallow_plot)
replace fallow_plot= 0 if s11b1q27==1
bys hhid: egen nb_fallow_plots = total(fallow_plot), missing
merge m:1 hhid using "${Input}\\${country}\\${wave}\\${cover1}", 
replace nb_fallow_plots= 0 if _merge ==2		
keep hhid nb_fallow_plots
duplicates drop
save "${Temp}\\${temppath}\\nb_fallow_plots.dta", replace

// nb plots
use "${Input}\\${country}\\${wave}\\${tenure}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11b1q28 (1 = 1) (. = . ) (* = 0), gen(fallow_plot)
replace fallow_plot= 0 if s11b1q27==1
bys hhid: egen nb_plots = count(fallow_plot)
merge m:1 hhid using "${Input}\\${country}\\${wave}\\${cover1}", 
replace nb_plots= 0 if _merge ==2	
keep hhid nb_plots
duplicates drop
save "${Temp}\\${temppath}\\nb_plots.dta", replace

// education hh
use "${Input}\\${country}\\${wave}\\${indiv_roster1}", clear
merge 1:1 hhid indiv using "${Input}\\${country}\\${wave}\\${indiv_roster2}", nogen

//new members
recode s2aq6 ( 1 = 1 "Yes") ( 2 = 0 "No"), gen(formal_education_hh1) label(formal_education_hh1)
recode s2aq9 (  0/15 51/52 = 0 "No" ) (16/43  = 1 "Yes"), gen(primary_education_hh1) label(primary_education_hh1)
replace primary_education_hh1 = 0 if s2aq6==2

// old members
recode s2bq1a ( 1 = 1 "Yes") ( 2 = 0 "No" ), gen(formal_education_hh2) label(formal_education_hh2)
replace formal_education_hh2 = 1 if s2bq2==1
recode s2bq3 (  0/16 51/61 = 0 "No" ) (17/43  = 1 "Yes"), gen(primary_education_hh2) label(primary_education_hh2)

egen formal_education_hh = rowmax(formal_education_hh1 formal_education_hh2)
egen primary_education_hh = rowmax(primary_education_hh2 primary_education_hh1)
bys hhid: egen hh_primary_education= max(primary_education_hh) 
bys hhid: egen hh_formal_education = max(formal_education_hh)

collapse (max) hh_formal_education hh_primary_education, by(hhid)
keep hhid hh_formal_education hh_primary_education
duplicates drop
save "${Temp}\\${temppath}\\hh_primary_education.dta", replace

// electricity access
use "${Input}\\${country}\\${wave}\\${housing}", clear
recode s8q17 (1 = 1 "Yes") ( 2 = 0 "No"),  gen(hh_electricity_access) label(hh_electricity_access) 
keep hhid hh_electricity_access
duplicates drop
save "${Temp}\\${temppath}\\hh_electricity_access.dta", replace

// dependency ratio
use "${Input}\\${country}\\${wave}\\${indiv_roster}", clear

rename s1q6 age 
replace age=. if age==999
gen dep_temp= !inrange(age,15,65) & !mi(age) // dummy for dependents
gen nondep_temp= inrange(age,15,65) & !mi(age) // dummy for non-dependents

bysort hhid: egen dep=total(dep_temp)
bysort hhid: egen nondep=total(nondep_temp)

gen hh_dependency_ratio = (dep/nondep) 
replace hh_dependency_ratio = dep if nondep==0
collapse (max) hh_dependency_ratio, by(hhid)
keep hhid hh_dependency_ratio
duplicates drop
save "${Temp}\\${temppath}\\hh_dependency_ratio.dta", replace

// livestock
use "${Input}\\${country}\\${wave}\\${livestock}", clear
recode s11iq1  (1 = 1 "Yes") (2 = 0 "No"), gen(livestock) label(livestock)
collapse (max) livestock, by(hhid) 
save "${Temp}\\${temppath}\\livestock.dta", replace

// consumption quint
use "${Input}\\${country}\\${wave}\\${csption1}", clear
merge 1:1 hhid using "${Input}\\${country}\\${wave}\\${csption2}", nogen

xtile cons_quint= totcons, n(5)  
keep hhid cons_quint 
duplicates drop
save "${Temp}\\${temppath}\\cons_quint.dta", replace

// consumption aggregate (unprcoessed)
use "${Input}\\${country}\\${wave}\\${csption1}", clear
merge 1:1 hhid using "${Input}\\${country}\\${wave}\\${csption2}", nogen
keep hhid totcons 
duplicates drop
save "${Temp}\\${temppath}\\totcons.dta", replace

// manager chars
use "${Input}\\${country}\\${wave}\\${plot_roster}", clear
egen plot_id = concat( hhid plotid), punct("-")
gen  manager_id = s11aq6a
replace manager_id =  s11aq6b if s11aq6a==.
sort  hhid (manager_id)
collapse (first) manager_id  , by(hhid plot_id)
tempfile ID_list
save `ID_list', replace

use "${Input}\\${country}\\${wave}\\${indiv_roster0}", clear
gen manager_id = indiv  // this is the HH member id 
merge 1:m  hhid manager_id using `ID_list', keep(match ) nogen
rename manager_id id
egen manager_id = concat (hhid id ), punct("-")
recode  s1q2 (2=1 "Yes") (1=0 "No"), gen(female_manager) 
rename s1q4 age_manager
replace age_manager=. if age_manager==999
recode s1q7 ( 1 2 = 1 "Yes") (3/7 = 0 "No"), gen(married_manager) 
keep plot_id female_manager age_manager married_manager manager_id
duplicates drop
save "${Temp}\\${temppath}\\Manager_characteristics1.dta", replace

use "${Input}\\${country}\\${wave}\\${indiv_roster1}", clear
merge 1:1 hhid indiv using "${Input}\\${country}\\${wave}\\${indiv_roster2}" , nogen
gen manager_id =  indiv  // this is the HH member id 
merge 1:m  hhid manager_id using `ID_list', keep(match) nogen
rename manager_id id
egen manager_id = concat (hhid id ), punct("-")
recode s2aq6 ( 1 = 1 "Yes") ( 2 = 0 "No" ), gen(formal_education_manager1) label(formal_education_manager1)
recode s2aq9 (  0/15 51/52 = 0 "No" ) (16/43  = 1 "Yes"), gen(primary_education_manager1) label(primary_education_manager1)
replace primary_education_manager1 = 0 if s2aq6==2
recode s2bq1a ( 1 = 1 "Yes") ( 2 = 0 "No"), gen(formal_education_manager2) label(formal_education_manager2)
replace formal_education_manager2 = 1 if s2bq2==1
recode s2bq3 (  0/16 51/61 = 0 "No" ) (17/43  = 1 "Yes"), gen(primary_education_manager2) label(primary_education_manager2)

egen formal_education_manager = rowmax(formal_education_manager1 formal_education_manager2)
egen primary_education_manager = rowmax(primary_education_manager2 primary_education_manager1)
keep plot_id primary_education_manager formal_education_manager
duplicates drop
save "${Temp}\\${temppath}\\Manager_characteristics2.dta", replace

// respondent chars
use "${Input}\\${country}\\${wave}\\${tenure}", clear 
merge 1:1 hhid plotid using "${Input}\\${country}\\${wave}\\${plot_roster}", nogen 
duplicates report hhid // one duplicate
gen respondent_id = s11b1q2 
replace respondent_id  = s11aq6a if s11b1q1==1
replace respondent_id =  s11aq6b if s11aq6a==.
sort  hhid (respondent_id)
collapse (first) respondent_id, by(hhid)
tempfile ID_list
save `ID_list', replace

use "${Input}\\${country}\\${wave}\\${indiv_roster0}", clear
rename indiv respondent_id // this is the HH member id 
merge 1:m  hhid respondent_id using `ID_list', keep(match) nogen
rename respondent_id id
egen respondent_id = concat (hhid id ), punct("-")
recode  s1q2 (2=1 "Yes") (1=0 "No"), gen(female_respondent) 
rename s1q4 age_respondent
replace age_respondent=. if age_respondent==999
recode s1q7 ( 1 2 = 1 "Yes") (3/7 = 0 "No"), gen(married_respondent) 
keep hhid female_respondent age_respondent married_respondent respondent_id
duplicates drop
save "${Temp}\\${temppath}\\respondent_characteristics1.dta", replace

use "${Input}\\${country}\\${wave}\\${indiv_roster1}", clear
merge 1:1 hhid indiv using "${Input}\\${country}\\${wave}\\${indiv_roster2}", nogen
gen respondent_id = indiv  // this is the HH member id 
merge 1:m  hhid respondent_id using `ID_list', keep(match) nogen
rename respondent_id id
egen respondent_id = concat (hhid id ), punct("-")
//new members
recode s2aq6 ( 1 = 1 "Yes") ( 2 = 0 "No"), gen(formal_education_respondent1) label(formal_education_respondent1)
recode s2aq9 (  0/15 51/52 = 0 "No" ) (16/43  = 1 "Yes"), gen(primary_education_respondent1) label(primary_education_respondent1)
replace primary_education_respondent1 = 0 if s2aq6==2

// old members
recode s2bq1a ( 1 = 1 "Yes") ( 2 =  0 "No" ), gen(formal_education_respondent2) label(formal_education_respondent2) // Cannot be positive that the individual has no formal education
replace formal_education_respondent2 = 1 if s2bq2==1
recode s2bq3 (  0/16 51/61 = 0 "No" ) (17/43  = 1 "Yes"), gen(primary_education_respondent2) label(primary_education_respondent2)

egen formal_education_respondent = rowmax(formal_education_respondent1 formal_education_respondent2)
egen primary_education_respondent = rowmax(primary_education_respondent2 primary_education_respondent1)
keep hhid primary_education_respondent formal_education_respondent
duplicates drop
save "${Temp}\\${temppath}\\Resp_characteristics2.dta", replace

// hh shock
use "${Input}\\${country}\\${wave}\\${shocks}", clear
replace s15aq1=0 if !inlist(., s15aq3a,  s15aq3b, s15aq3c)
recode s15aq1 (1 = 1 "Yes") (2 = 0 "No"), gen(hh_shock) label(hh_shock)
collapse (max) hh_shock, by(hhid) 
save "${Temp}\\${temppath}\\shock.dta", replace

// hh size
use "${Input}\\${country}\\${wave}\\${labor_hh}", clear
bys hhid: egen hh_size = count(indiv)
keep hhid hh_size
duplicates drop
isid hhid
save "${Temp}\\${temppath}\\size.dta", replace

// ag assets
use "${Input}\\${country}\\${wave}\\${items}", clear

drop if inlist(item_cd, 313, 314, 315, 316, 317,  322, 323, 324, 325 )
duplicates report hhid item_cd // a few duplicates 
duplicates drop hhid item_cd, force

gen hh_owns_= 0 if !mi(sa4q1)
replace hh_owns= 1 if !mi(sa4q1) & sa4q1!= 0


keep hhid item_cd hh_owns_
reshape wide hh_owns_ , i(hhid) j(item_cd)
foreach var of varlist hh_owns_* {
replace `var'=0 if `var'==.
}
factor hh_owns_*, pcf 
predict ag_asset_index
drop hh_owns*
keep hhid ag_asset_index
duplicates drop
save "${Temp}\\${temppath}\\ag_asset_index.dta", replace

// hh assets
use "${Input}\\${country}\\${wave}\\${items_hh}", clear

drop if item_cd>331
recode s7 (0 = 0) (.=.) (else = 1), gen(hh_owns) label(hh_owns) 
keep hh_owns hhid item_cd
reshape wide hh_owns , i(hhid) j(item_cd)
foreach var of varlist hh_owns* {
replace `var'=0 if `var'==.
}
factor hh_owns*, pcf 
predict hh_asset_index
keep hhid hh_asset_index
duplicates drop
save "${Temp}\\${temppath}\\hh_asset_index.dta", replace

// non farm enterprise
use "${Input}\\${country}\\${wave}\\${nfe}", clear
merge m:1 hhid using "${Input}\\${country}\\${wave}\\${cover1}",
recode _merge ( 2 = 0 "No") (3 = 1 "Yes"), gen(nonfarm_enterprise) label(nonfarm_enterprise)
keep hhid nonfarm_enterprise
duplicates drop
save "${Temp}\\${temppath}\\nfe.dta", replace

// latitude 
use "${Input}\\${country}\\${wave}\\${geovars_hh}", clear
rename ( LAT_DD_MOD LON_DD_MOD) ( lat_modified lon_modified)
keep hhid lat_modified lon_modified
duplicates drop
save "${Temp}\\${temppath}\\Coords.dta", replace

// agro ecological zone
use "${Input}\\${country}\\${wave}\\${geovars_hh}", clear
rename ea ea_id

rename ssa_aez09 agro_ecological_zone
keep hhid agro_ecological_zone
duplicates drop
save "${Temp}\\${temppath}\\aez.dta", replace

// distance to nearest road
use "${Input}\\${country}\\${wave}\\${geovars_hh}", clear
rename dist_road2 dist_road
keep hhid dist_road
duplicates drop
save "${Temp}\\${temppath}\\dist_road.dta", replace

// distance to nearest population center
use "${Input}\\${country}\\${wave}\\${geovars_hh}", clear
rename dist_popcenter2 dist_popcenter
keep hhid dist_popcenter
duplicates drop
save "${Temp}\\${temppath}\\dist_popcenter.dta", replace
 
// distance to nearest market (none)
use "${Input}\\${country}\\${wave}\\${geovars_hh}", clear
rename ea ea_id
keep hhid dist_market
duplicates drop
save "${Temp}\\${temppath}\\dist_market.dta", replace
 

// plot slope
use "${Input}\\${country}\\${wave}\\${geovars}", clear
egen plot_id = concat( hhid plotid), punct("-")
rename srtmslp_nga plot_slope
keep plot_id plot_slope
duplicates drop
save "${Temp}\\${temppath}\\plot_slope.dta", replace

// plot elevation
use "${Input}\\${country}\\${wave}\\${geovars}", clear
egen plot_id = concat( hhid plotid), punct("-")
rename srtm_nga elevation 
keep plot_id elevation
duplicates drop
save "${Temp}\\${temppath}\\elevation.dta", replace

// total wetness index
use "${Input}\\${country}\\${wave}\\${geovars}", clear 
egen plot_id = concat( hhid plotid), punct("-")
rename twi_nga twi 
keep plot_id twi
duplicates drop
save "${Temp}\\${temppath}\\twi.dta", replace

// soil variables
use "${Input}\\${country}\\${wave}\\${geovars_hh}", clear
rename ea ea_id
forvalues i=1/7{
recode sq`i' (1=1) (2/7=0), gen(sq`i'_d)
}
factor sq1_d-sq7_d, pcf 
predict soil_fertility_index

local names "nutrient_availability nutrient_retention rooting_conditions oxygen_availability excess_salts toxicity workability"
forvalues n =1/7 {
local lab: word `n' of `names'
rename sq`n'_d `lab'
}

keep hhid  nutrient_availability nutrient_retention rooting_conditions oxygen_availability excess_salts toxicity workability soil_fertility_index
duplicates drop
save "${Temp}\\${temppath}\\soil.dta", replace


// popdensity (absent)

// indiv chars 
use "${Input}\\${country}\\${wave}\\${indiv_roster0}", clear
egen ID = concat (hhid indiv), punct("-")
recode  s1q2 (2=1 "Yes") (1=0 "No"), gen(female)
rename s1q4 age
recode s1q7 ( 1 2 = 1 "Yes") (3/7 = 0 "No"), gen(married) 
rename s1q3 relationship_head_temp
decode relationship_head_temp, gen(relationship_head)
replace relationship_head = proper(relationship_head)
replace relationship_head = "Father-in-law/Mother-in-law" if relationship_head== "Parent In Law"
replace relationship_head = "Son-in-law/Daughter-in-law" if relationship_head== "Son/Daughter-In-Law"
replace relationship_head = "Brother-in-law/Sister-in-law" if relationship_head== "Brother/Sister Inlaw"
replace relationship_head = "Sister/Brother" if relationship_head== "Brother/Sister"
replace relationship_head = "Non Relative" if relationship_head== "Other Non-Relative"
replace relationship_head = "Non Relative" if relationship_head== "Other (Specify)"
replace relationship_head = "Other Relative" if relationship_head== "Other Relative"
replace relationship_head = "Servant" if relationship_head== "Domestic Help (Resident)"
replace relationship_head = "Servant" if relationship_head== "Domestic Help (Non Resident)"
replace relationship_head = "Grandparent" if relationship_head== "Grandfather/Mother"
replace relationship_head = "Son/Daughter" if relationship_head== "Adopted Child"
replace relationship_head = "Son/Daughter" if relationship_head== "Own Child"
replace relationship_head = "Son/Daughter" if relationship_head== "Step Child"
replace relationship_head = "Other Relative" if relationship_head== "Other Relation (Specify)"
replace relationship_head = "Non Relative" if relationship_head== "Other Non Relation (Specify)"

// month of birth
gen birth_month= ym(s1q6_year, s1q6_month)
format birth_month %tm 

keep hhid ID married female age relationship_head  birth_month
duplicates drop
save "${Temp}\\${temppath}\\indiv_chars.dta", replace


// wasting
use "${Input}\\${country}\\${wave}\\${anthropo}", clear
egen ID = concat (hhid indiv ), punct("-")
merge 1:1 hhid ID using "${Temp}\\${temppath}\\indiv_chars.dta",  keep(master match) nogen
merge m:1 hhid  using "${Temp}\\${temppath}\\harvest_interview_month.dta",  keep(master match) nogen

// age in months
gen age_months = harvest_interview_month - birth_month

*Main anthropometric variables
gen weight=s4aq52
gen height=s4aq53 // height missing 

gen cage=age*12
replace cage = age_months if age==0| age==.
format %5.0g cage
zscore06, a(cage) s(female) h(height) w(weight) male(0) female(1)

gen wasting=whz06<-2 if whz06<.

keep haz06 waz06 whz06 bmiz06 wasting  hhid ID weight height
duplicates drop
save "${Temp}\\${temppath}\\wasting.dta", replace


// labor 
use "${Input}\\${country}\\${wave}\\${labor_hh}", clear
egen ID = concat (hhid indiv), punct("-")

recode s3aq5 (1 = 1) (2= 0) (9 . = .), gen( farm_work)
recode s3aq6 (1 = 1) (2= 0) (9 . = .), gen( SOB_work)
recode s3aq4 (1 = 1) (2= 0) (9 . = .), gen( wage_work)

// industry:
gen ind_ag = s3aq14 == 1  // Agriculture 
gen ind_fish = . // none?
gen ind_mining = s3aq14 == 2 // mining
gen ind_manuf = s3aq14 >= 3 & s3aq14<=5 // manuf
gen ind_const = s3aq14 == 6 // construc
gen ind_serv = s3aq14 >= 7 & s3aq14<= 14 // services
foreach var in ind_ag ind_const ind_fish ind_manuf ind_mining ind_serv {
replace `var' = 0 if s3aq4==2 | s3aq15==10 | s3aq15==11  // remove self employment, most of "other"
replace `var' = 0 if s3aq7==2 // did not work
}
  
gen working_age = s3aq1 == 1

gen hour_job1 = s3aq18 // hours asked for last 7 days
replace hour_job1 = 0 if s3aq7==2 | s3aq9==7 | s3aq9==8 //answered "no" to filter questions = unemployed
gen hour_job2 = s3aq31
replace hour_job2 = 0 if s3aq7==2 | s3aq9==7 | s3aq9==8 //answered "no" to filter questions = unemployed


recode s3aq13b (6111 6112 6113 6114 6121 6122 6123 6130 6141 6142 6151 6152 6153 6164 6210 9211 = 1) (. =.) (else = 0) , gen(farm_job1)
recode s3aq26b (6111 6112 6113 6114 6121 6122 6123 6130 6141 6142 6151 6152 6153 6164 6210 9211 = 1) (. =.) (else = 0) , gen(farm_job2)
replace farm_job1 = 0 if farm_job1==1 & inlist(s3aq15, 1, 2, 3, 4, 5, 6, 7, 8, 9)
replace farm_job2 = 0 if farm_job2==1 & inlist(s3aq28, 1, 2, 3, 4, 5, 6, 7, 8, 9)
recode s3aq15 (10 = 1) (.=.) (else = 0), gen(SB_job1) 
replace SB_job1 = 0 if farm_job1==1
recode s3aq28 (10 = 1) (.=.) (else = 0), gen(SB_job2) 
replace SB_job2 = 0 if farm_job2==1

recode SB_job1 (1= 0) (0 = 1) , gen(wage_job1)
replace wage_job1 = 0 if farm_job1==1
recode SB_job2 (1= 0) (0 = 1) , gen(wage_job2)
replace wage_job2 = 0 if farm_job2==1

rename SOB_work SB_work
foreach act in farm SB wage {
gen `act'_hrs1 = hour_job1 if `act'_job1 == 1
replace `act'_hrs1 = 0 if `act'_job1 == 0
replace `act'_hrs1 = 0 if `act'_work == 0
gen `act'_hrs2 = hour_job2 if `act'_job2 == 1
replace `act'_hrs2 = 0 if `act'_job2 == 0
replace `act'_hrs2 = 0 if `act'_work == 0
egen `act'_hrs = rowtotal(`act'_hrs1 `act'_hrs2), missing
}
rename SB_work SOB_work


foreach var in farm_work SOB_work wage_work farm_hrs SB_hrs wage_hrs ind_ag ind_const ind_fish ind_manuf ind_mining ind_serv {
replace `var' = 0 if working_age==0
}


keep ID hhid  farm_work SOB_work wage_work farm_hrs SB_hrs wage_hrs ind_ag ind_const ind_fish ind_manuf ind_mining ind_serv working_age
duplicates drop
save "${Temp}\\${temppath}\\labor.dta", replace

// education
use "${Input}\\${country}\\${wave}\\${indiv_roster1}", clear
merge 1:1 hhid indiv using "${Input}\\${country}\\${wave}\\${indiv_roster2}", nogen

egen ID = concat (hhid indiv), punct("-")
//new members
recode s2aq6 ( 1 = 1 "Yes") ( 2 = 0 "No"), gen(formal_education1) label(formal_education1)
recode s2aq9 (  0/15 51/52 = 0 "No" ) (16/43  = 1 "Yes"), gen(primary_education1) label(primary_education1)
replace primary_education1 = 0 if s2aq6==2

// old members
recode s2bq1a ( 1 = 1 "Yes") ( 2 =  0 "No" ), gen(formal_education2) label(formal_education2) // Cannot be positive that the individual has no formal education
replace formal_education2 = 1 if s2bq2==1
recode s2bq3 (  0/16 51/61 = 0 "No" ) (17/43  = 1 "Yes"), gen(primary_education2) label(primary_education2)

egen formal_education = rowmax(formal_education1 formal_education2)
egen primary_education = rowmax(primary_education2 primary_education1)
keep ID hhid formal_education primary_education
duplicates drop
save "${Temp}\\${temppath}\\educ_indiv.dta", replace


// HDDS 
use "${Input}\\${country}\\${wave}\\${HDDS}", clear

keep if s10bq1 ==1 // keep if consumed
rename item_cd food_id

gen A = food_id>=10 & food_id<=29
gen B = food_id>=30 & food_id<=38
gen C = food_id>=70 & food_id<=79
gen D = food_id>=60 & food_id<=66
gen E = food_id>=80 & food_id<=82 | food_id>=90 & food_id<=96
gen F = food_id>=83 & food_id<=85
gen G = food_id>=100 & food_id<=107
gen H = food_id>=40 & food_id<=48
gen I = food_id>=110 & food_id<=114
gen J = food_id>=50 & food_id<=53
gen K = food_id>=130 & food_id<=133
gen L = food_id>=120 & food_id<=122

collapse (max) A B C D E F G H I J K L, by(hhid)
egen HDDS = rowtotal(A B C D E F G H I J K L), missing 

merge 1:m hhid  using "${Input}\\${country}\\${wave}\\${HDDS}", 
collapse (max) HDDS, by(hhid)
replace HDDS = 0 if HDDS==.
save "${Temp}\\${temppath}\\HDDS.dta", replace