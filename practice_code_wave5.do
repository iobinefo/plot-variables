/*********************************************************************************
* LSMS-ISA Harmonised Panel Analysis Code                                        *
* Description: Extract data for GHS4          *
* Date: December 2023                                                            *
* -------------------------------------------------------------------------------*
*/



*encode country, gen (country1)
*keep if wave ==4 & country1==5
**********************************************************
*** Set globals for files
**********************************************************


clear
global country  Nigeria
global wave  GHS 23
global cover  secta_plantingw5.dta
global indiv_roster  sect1_plantingw5.dta
global indiv_roster0  sect1_harvestw5.dta
global indiv_roster1  sect2_harvestw5.dta
global lab_roster11 sect11c1a_plantingw5.dta
global lab_roster12 sect11c1b_plantingw5.dta
global lab_roster21 secta2a_harvestw5.dta
global lab_roster22 secta2b_harvestw5.dta
global shocks sect15a_harvestw5.dta
global housing  sect11_plantingw5.dta
global plot_roster  sect11a1_plantingw5.dta
global ferts secta11c2_harvestw5.dta
global ferts_sold secta11c3_harvestw5.dta
global csption totcons_final.dta
global items secta4_harvestw5.dta
global items_hh sect5_plantingw5.dta
global harvest_rwdta  secta3i_harvestw5.dta
global harvest_sold_rwdta  secta3ii_harvestw5.dta
global perennial  secta3iii_harvestw5.dta
global seeds  sect11f_plantingw5.dta
global seeds_sold1 sect11e1_plantingw5.dta
global seeds_sold2 sect11e2_plantingw5.dta
global geovars_hh nga_householdgeovars_y5.dta
global geovars nga_plotgeovariables_y5.dta
global livestock sect11i_plantingw5.dta
global conversions ag_conv_w5.dta
global tenure sect11b1_plantingw5.dta
global labor_hh1 sect4a_plantingw5.dta
global nfe1 sect8a_harvestw5.dta
global anthropo  sect4a_harvestw5.dta
global meta aux_harvestw5.dta
*global temppath NGA\GHS18
global HDDS sect5b_harvestw5.dta



**********************************************************
**** A) Master frame of crops, plots and households
**********************************************************


**********************************************************
**** B) Variable extraction
**********************************************************







***************************************************
*starting
***************************************************


global Nigeria_GHS_W4_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2023_GHSP-W5_v01_M_Stata (1)"
global temping  "C:\Users\obine\Music\Documents\food_secure"




// plot-crop frame
use "${Nigeria_GHS_W4_raw_data}\\${harvest_rwdta}", clear
merge 1:m hhid plotid cropcode using "${Nigeria_GHS_W4_raw_data}\\${perennial}"
egen plot_id = concat(hhid plotid), punct("-")
decode cropcode, gen(crop_name)
replace crop_name = substr(crop_name, strpos(crop_name,  ".")+2, .)
keep hhid plot_id crop_name cropcode 

duplicates drop


duplicates tag plot_id crop_name, gen(tag)
decode cropcode, gen(cropname2)
replace crop_name = cropname2 if tag>0


duplicates report plot_id cropcode crop_name

save "${temping}/plot_crop_frame.dta", replace

// household frame
use "${Nigeria_GHS_W4_raw_data}\\${cover}", clear
keep hhid 
duplicates report hhid 
duplicates drop
save "${temping}/hh_frame.dta", replace

/*
// planting month
use "${Nigeria_GHS_W4_raw_data}\\${seeds}", clear

egen plot_id = concat( hhid plotid), punct("-")

gen month = s11fq3_1
gen year= s11fq3_2
replace year =s11fq6 if year==. & year!=-99
replace month = 12 if s11fq4aa 	==1


gen planting_month = ym(year, month)
format planting_month %tmCCYYMon
drop month year

collapse (min) planting_month , by(hhid cropcode plot_id)
save "${temping}/planting_month.dta", replace

// harvest end month 
use "${Nigeria_GHS_W4_raw_data}\\${harvest_rwdta}", clear
merge 1:m hhid plotid cropcode using "${Nigeria_GHS_W4_raw_data}\\${perennial}"

egen plot_id = concat( hhid plotid), punct("-")
gen month = sa3iq6c1
gen year = sa3iq6c2
replace month = sa3iiiq12a if _merge==2
replace year = sa3iiiq12b if _merge==2

gen harvest_end_month = ym( year, month)
format harvest_end_month %tmCCYYMon
collapse (max) harvest_end_month, by(plot_id cropcode ) 
save "${temping}/harvest_end_month.dta", replace

// harvest_interview_month 
use "${Nigeria_GHS_W4_raw_data}\\${meta}", clear
gen harvest_interview_month = mofd(dofc(Sec1_StartTime))
format harvest_interview_month %tmCCYYMon
keep hhid harvest_interview_month
duplicates drop
save "${temping}/harvest_interview_month.dta", replace

// planting_interview_month 
use "${Nigeria_GHS_W4_raw_data}\\${meta}", clear
gen planting_interview_month = mofd(dofc(Sec1_StartTime))
format planting_interview_month %tmCCYYMon
keep hhid planting_interview_month
duplicates drop
save "${temping}/planting_interview_month.dta", replace

*/





// EA
use "${Nigeria_GHS_W4_raw_data}\\${cover}" , clear 
egen ea_id_temp = concat(lga ea), punct("-")
drop lga ea
merge 1:1 hhid using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2010_GHSP-W1_v03_M_STATA (1)\Post Planting Wave 1\Household\secta_plantingw1.dta", keep(master match)
egen ea_id = concat(lga ea), punct("-")
replace ea_id = ea_id_temp if _merge==1
keep hhid ea_id
duplicates drop
save  "${temping}/ea_id.dta", replace

// strata
use "${Nigeria_GHS_W4_raw_data}\\${cover}" , clear
rename zone zone_w4
merge 1:1 hhid using "C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2010_GHSP-W1_v03_M_STATA (1)\Post Planting Wave 1\Household\secta_plantingw1.dta", keep(master match)
rename zone strataid
replace strataid = zone_w4 if _merge==1 // refreshed households
keep hhid strataid  
duplicates drop
save "${temping}/strataid.dta", replace

// admin 1
use "${Nigeria_GHS_W4_raw_data}\\${cover}" , clear
rename zone admin_1
keep hhid admin_1  
decode admin_1, gen(admin_1_name)
duplicates drop
save "${temping}/admin1.dta", replace

// admin 2
use "${Nigeria_GHS_W4_raw_data}\\${cover}" , clear
rename state admin_2 
keep hhid admin_2
decode admin_2, gen(admin_2_name)
duplicates drop
save "${temping}/admin2.dta", replace

// admin 3
use "${Nigeria_GHS_W4_raw_data}\\${cover}" , clear
rename lga admin_3
keep hhid admin_3
duplicates drop
save "${temping}/admin3.dta", replace

// urban
use "${Nigeria_GHS_W4_raw_data}\\${cover}" , clear
recode sector (1 = 1 "Yes") (2 =0 "No"), gen(urban) label(urban)
keep hhid urban
duplicates drop
save "${temping}/urban.dta", replace






// weights 
use "${Nigeria_GHS_W4_raw_data}\secta_plantingw5", clear
ren wt_wave5 weight // 
ren wt_longpanel_wave5 weight_longpanel
ren wt_cross_wave5 weight_crosssection
drop if weight==. & weight_longpanel==. & weight_crosssection==.   // 352 hh dropped, household not surveyed will not have weights
count // 4,715 obs 
ren weight pw
keep pw hhid
save "${temping}/weights.dta", replace




// harvest_kg 

use "${Nigeria_GHS_W4_raw_data}\\${harvest_rwdta}", clear
merge 1:m hhid plotid cropcode using "${Nigeria_GHS_W4_raw_data}\\${perennial}"

merge m:1 hhid using "${temping}/admin1.dta", keep(master match) nogen 
merge m:1 hhid using "${temping}/admin2.dta", keep(master match) nogen 
merge m:1 hhid using "${temping}/admin3.dta", keep(master match) nogen 
egen plot_id = concat(hhid plotid), punct("-")

recode sa3iq3 (1 = 1 "Yes") (2 =0 "No"), gen(any_harvest) label(any_harvest) 


gen harvest_kg_temp= sa3iq9a * sa3iq9_conv //if cropcode == 1080
replace harvest_kg_temp=0 if any_harvest==0 
gen harvest_kg_expected = sa3iq15a  * sa3iq15_conv //if cropcode == 1080
*gen harvest_kg_per = sa3iiiq13a * sa3iiiq13d

egen harvest_kg = rowtotal(harvest_kg_temp harvest_kg_expected ), missing // removed this harvest_kg_per

recode sa3iq3 (2 = 1 "Yes") (1 = 0 "No"), gen(crop_shock) label(crop_shock)
replace crop_shock = 0 if sa3iq4_1==22 | sa3iq4_1==23 | sa3iq4_2==22 | sa3iq4_2==23
replace crop_shock = 1 if sa3iiiq19==1 
replace crop_shock = 0 if sa3iiiq19==2 & sa3iiiq17==1 

replace harvest_kg = . if harvest_kg==0 // & //crop_shock!=1 
collapse (sum) harvest_kg (count) n_harvest_kg = harvest_kg , by(plot_id cropcode admin_1 admin_2 admin_3 hhid)
replace harvest_kg = . if n_harvest_kg==0
save "${temping}/harvest_kg.dta", replace

// crop shock
/*
use "${Nigeria_GHS_W4_raw_data}\\${harvest_rwdta}", clear
merge 1:m hhid plotid cropcode using "${Nigeria_GHS_W4_raw_data}\\${perennial}"
egen plot_id = concat(hhid plotid), punct("-")

recode sa3iq3 (2 = 1 "Yes") (1 = 0 "No"), gen(crop_shock) label(crop_shock)
replace crop_shock = 0 if sa3iq4_1==22 | sa3iq4_1==23 | sa3iq4_2==22 | sa3iq4_2==23
replace crop_shock = 1 if sa3iiiq19==1 
replace crop_shock = 0 if sa3iiiq19==2

recode sa3iq7_1   (6 = 1 "Yes") ( 1/5 7/20 96 = 0 "No") (1 = .), gen(drought_shock1) label(drought_shock) 
replace drought_shock1=1 if sa3iq7_2==6
recode sa3iq4_1 (6 = 1 "Yes") (1/5 7/20 96 = 0 "No") ( 9 10 =.), gen(drought_shock2) label(drought_shock) 
replace drought_shock2=1 if sa3iq4_2==6

replace drought_shock1=0 if sa3iq4b==2
replace drought_shock2=0 if sa3iq3==1
gen drought_shock= 1 if drought_shock1==1 | drought_shock2==1
replace drought_shock=0 if (drought_shock1==0 & drought_shock2==0 )
replace drought_shock=1 if sa3iiiq10==1
replace drought_shock=0 if (sa3iiiq10!=1 & sa3iiiq9==1) | sa3iiiq7==1



recode sa3iq4c (3 = 1 "Yes") (2 3/10 = 0 "No")  (1 = .), gen(flood_shock1) label(flood_shock) 
recode sa3iq4 (2 = 1 "Yes") (1 3/8 11 = 0 "No") ( 9 10 =.), gen(flood_shock2) label(flood_shock) 
replace flood_shock1=0 if sa3iq4b==2
replace flood_shock2=0 if sa3iq3==1
gen flood_shock= 1 if flood_shock1==1 | flood_shock2==1
replace flood_shock=0 if (flood_shock1==0 & flood_shock2==0 )
replace flood_shock=1 if sa3iiiq10==2
replace flood_shock=0 if (sa3iiiq10!=2 & sa3iiiq9==1) | sa3iiiq7==1

recode sa3iq4c (4 = 1 "Yes") (2 3 5/10 = 0 "No")  (1 = .), gen(pests_shock1) label(pests_shock) 
recode sa3iq4 (3 = 1 "Yes") (1 2 4/8 11 = 0 "No") ( 9 10 =.), gen(pests_shock2) label(pests_shock) 
replace pests_shock1=0 if sa3iq4b==2
replace pests_shock2=0 if sa3iq3==1
gen pests_shock= 1 if pests_shock1==1 | pests_shock2==1
replace pests_shock=0 if (pests_shock1==0 & pests_shock2==0 )
replace pests_shock=1 if sa3iiiq10==5 | sa3iiiq10==6
replace pests_shock=0 if (sa3iiiq10!=5 & sa3iiiq10!=6  & sa3iiiq9==1) | sa3iiiq7==1

collapse (max)  crop_shock pests_shock  drought_shock flood_shock    , by(hhid plot_id cropcode)

save "${temping}/crop_shock.dta", replace
*/
// harvest sold amount
use "${Nigeria_GHS_W4_raw_data}\\${harvest_sold_rwdta}", clear
gen harvest_sold_kg_temp = sa3iiq6  * sa3iiq1_conv
replace harvest_sold_kg_temp = 0 if sa3iiq4==2
merge 1:m hhid  cropcode using "${Nigeria_GHS_W4_raw_data}\\${perennial}"
gen harvest_sold_per = sa3iiiq23c * sa3iiiq23_conv
replace harvest_sold_per = 0 if _merge==1 
collapse (sum) harvest_sold_per (count) n = harvest_sold_per (max) harvest_sold_kg_temp , by(cropcode hhid)
replace harvest_sold_per = . if n==0
merge m:1 hhid using "${temping}/admin1.dta",  nogen 
merge m:1 hhid using "${temping}/admin2.dta", nogen 
merge m:1 hhid using "${temping}/admin3.dta",  nogen 

egen harvest_sold_kg = rowtotal(harvest_sold_kg_temp harvest_sold_per), missing

collapse (sum) harvest_sold_kg (count) n_harvest_sold_kg = harvest_sold_kg, by( cropcode hhid admin_1 admin_2 admin_3)
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
use "${Nigeria_GHS_W4_raw_data}\\${harvest_sold_rwdta}", clear
gen harvest_sold_value_temp = sa3iiq7 
merge 1:m hhid  cropcode using "${Nigeria_GHS_W4_raw_data}\\${perennial}"
gen harvest_sold_value_per = sa3iiiq24
collapse (sum) harvest_sold_value_per (count) n = harvest_sold_value_per (max) harvest_sold_value_temp , by(cropcode hhid)
replace harvest_sold_value_per = . if n==0
merge m:1 hhid using "${temping}/admin1.dta",  nogen 
merge m:1 hhid using "${temping}/admin2.dta", nogen 
merge m:1 hhid using "${temping}/admin3.dta",  nogen 

egen harvest_sold_value = rowtotal(harvest_sold_value_temp harvest_sold_value_per), missing

collapse (sum) harvest_sold_value (count) n_harvest_sold_value = harvest_sold_value, by( cropcode hhid admin_1 admin_2 admin_3)
replace harvest_sold_value = . if n_harvest_sold_value==0
save "${temping}/harvest_sold_value.dta", replace





capture program drop valuation_median_crops_noea
program define valuation_median_crops_noea 
args hhid plotid cropvar 

merge 1:1 `hhid'  `cropvar' using "${temping}/harvest_sold_value.dta", keep(master match)	nogen
merge 1:1 `hhid'  `cropvar' using "${temping}/harvest_sold_kg.dta", keep(master match)	nogen


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


*
// harvest_value & main crop
use "${Nigeria_GHS_W4_raw_data}\\${harvest_sold_rwdta}", clear

merge 1:m hhid  cropcode using "${Nigeria_GHS_W4_raw_data}\\${perennial}"
keep hhid  cropcode 
duplicates drop

valuation_median_crops_noea hhid hhid cropcode

main_crop_def cropcode


keep plot_id harvest_value cropcode main_crop 
save "${temping}/harvest_value.dta", replace


// intercropped
use "${Nigeria_GHS_W4_raw_data}\\${seeds}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11fq4 (1= 0 "No") (2 = 1 "Yes"), gen(intercropped) label(intercropped)
keep cropcode plot_id intercropped
collapse (max) intercropped, by(plot_id)
save "${temping}/intercropped.dta", replace

// nb_seasonal_crop
use "${Nigeria_GHS_W4_raw_data}\\${harvest_rwdta}", clear

egen plot_id = concat( hhid plotid), punct("-")
bys  plot_id : egen nb_seasonal_crop = count(cropcode)
keep plot_id nb_seasonal_crop
duplicates drop
save "${temping}/nb_seasonal_crop.dta", replace
/*
// main crop
use "${Nigeria_GHS_W4_raw_data}\\${seeds}", clear

drop if s11fq2==2 // drop permanent crops
gen count_temporary=1
collapse (sum) count_temporary, by(cropcode)
tempfile Perennial_crops_temp
save `Perennial_crops_temp', replace

use "${Nigeria_GHS_W4_raw_data}\\${seeds}", clear
drop if s11fq2==1 // drop seasonal crops
gen count_permanent=1
collapse (sum) count_permanent, by(cropcode)
merge 1:1 cropcode using `Perennial_crops_temp' // There is no overlap 
gen permanent_crop=0 
replace permanent_crop=1 if _merge==1 
drop if permanent_crop==0 
drop permanent_crop count_permanent count_temporary _merge
tempfile Perennial_crops_list 
save `Perennial_crops_list', replace
rename cropcode main_crop
tempfile Perennial_crops_list_MC 
save `Perennial_crops_list_MC', replace

use "${Nigeria_GHS_W4_raw_data}\\${harvest_rwdta}", clear
merge 1:m hhid plotid cropcode using "${Nigeria_GHS_W4_raw_data}\\${perennial}"
rename _merge _mergeper
egen plot_id = concat( hhid plotid), punct("-")
merge m:1 cropcode using  `Perennial_crops_list', keep(master match) 
rename _merge _mergecropcode

merge m:1 cropcode plot_id  using "${temping}/harvest_value.dta", keep(match using) nogen
merge m:1 main_crop using  `Perennial_crops_list_MC', keep(master match) 
rename _merge _mergemain_crop

bys plot_id: egen total_value_plot= total(harvest_value), missing
gen maincrop_valueshare_temp = harvest_value/ total_value_plot if cropcode==main_crop
bys plot_id: egen maincrop_valueshare = max(maincrop_valueshare_temp)

foreach c in main_crop cropcode {
lab val `c' crop
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

 
foreach n in 8 7 6 5 4 {
	local i = `n' + 2
	rename contains_crop_`n' contains_crop_`i'
} 

foreach n in 3 2 1 {
	local i = `n' + 1
	rename contains_crop_`n' contains_crop_`i'
} 

gen contains_crop_1=0
gen contains_crop_5=0
gen contains_crop_11=0

//share of each crop category

forvalues n = 1/11 {
gen share_crop`n' = harvest_value/ total_value_plot if contains_crop_`n'==1
replace share_crop`n' = 0 if contains_crop_`n'==0
}

collapse (sum)   share_crop* (max) contains_crop_*, by(plot_id main_crop maincrop_valueshare ) 
save "${temping}/main_crop.dta", replace
*/
// share of plot area planted by crop 


// land area
use "${Nigeria_GHS_W4_raw_data}\\${plot_roster}", clear
rename (zone state lga) (admin_1 admin_2 admin_3)
egen plot_id = concat( hhid plotid), punct("-") 

gen area_self_reported= s11aq3_number  
replace area_self_reported = area_self_reported * 0.0667 if s11aq3_unit==4 
replace area_self_reported = area_self_reported * 0.4 if s11aq3_unit==5
replace area_self_reported = area_self_reported * 0.0001 if s11aq3_unit==7

// heaps
replace area_self_reported = area_self_reported * 0.00012 if s11aq3_unit==1 & admin_1==1
replace area_self_reported = area_self_reported * 0.00016 if s11aq3_unit==1 & admin_1==2
replace area_self_reported = area_self_reported * 0.00011 if s11aq3_unit==1 & admin_1==3
replace area_self_reported = area_self_reported * 0.00019 if s11aq3_unit==1 & admin_1==4
replace area_self_reported = area_self_reported * 0.00021 if s11aq3_unit==1 & admin_1==5
replace area_self_reported = area_self_reported * 0.00012 if s11aq3_unit==1 & admin_1==6

// ridges 
replace area_self_reported = area_self_reported * 0.0027 if s11aq3_unit==2 & admin_1==1
replace area_self_reported = area_self_reported * 0.004 if s11aq3_unit==2 & admin_1==2
replace area_self_reported = area_self_reported * 0.00494 if s11aq3_unit==2 & admin_1==3
replace area_self_reported = area_self_reported * 0.0023 if s11aq3_unit==2 & admin_1==4
replace area_self_reported = area_self_reported * 0.0023 if s11aq3_unit==2 & admin_1==5
replace area_self_reported = area_self_reported * 0.00001 if s11aq3_unit==2 & admin_1==6

// stands
replace area_self_reported = area_self_reported * 0.00006 if s11aq3_unit==3 & admin_1==1
replace area_self_reported = area_self_reported * 0.00016 if s11aq3_unit==3 & admin_1==2
replace area_self_reported = area_self_reported * 0.00004 if s11aq3_unit==3 & admin_1==3
replace area_self_reported = area_self_reported * 0.00004 if s11aq3_unit==3 & admin_1==4
replace area_self_reported = area_self_reported * 0.00013 if s11aq3_unit==3 & admin_1==5
replace area_self_reported = area_self_reported * 0.00041 if s11aq3_unit==3 & admin_1==6


gen plot_area_GPS= s11mq3  
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

*replace plot_area_GPS = plot_area_GPS_1_ if mi(plot_area_GPS) & cropcode == 1080

bys hhid: egen farm_size = total(plot_area_GPS), missing

keep hhid plot_id   plot_area_GPS farm_size
duplicates drop
save "${temping}/plot_area.dta", replace





// improved
use "${Nigeria_GHS_W4_raw_data}\sect11f_plantingw5.dta", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11fq7 (2=0 "No") (1 =1 "Yes"), gen(improved)
collapse (max) improved, by(hhid plot_id cropcode)
save "${temping}/improved.dta", replace

// seed kg
use "${Nigeria_GHS_W4_raw_data}\secta3i_harvestw5.dta", clear
keep cropcode sa3iq9b sa3iq9c sa3iq9d sa3iq9_conv zone 
drop if sa3iq9d==1 // we drop unshelled observations: assuming all expected harvest are shelled estimates
rename sa3iq9b unit 
rename sa3iq9c size
collapse (median) sa3iq9_conv, by(zone cropcode unit size)
drop if inlist(., sa3iq9_conv, size, unit, zone)
save "${temping}/Conversions.dta", replace

use "${Nigeria_GHS_W4_raw_data}\secta3i_harvestw5.dta", clear
keep cropcode sa3iq9b sa3iq9c sa3iq9d sa3iq9_conv zone 
drop if sa3iq9d==1 // we drop unshelled observations: assuming all expected harvest are shelled estimates
rename sa3iq9b unit 
rename sa3iq9c size
collapse (median) sa3iq9_conv, by( cropcode unit size)
drop if inlist(., sa3iq9_conv, unit)
save "${temping}/Conversions_nozone.dta", replace

use "${Nigeria_GHS_W4_raw_data}\secta3i_harvestw5.dta", clear
keep cropcode sa3iq9b sa3iq9c sa3iq9d sa3iq9_conv zone 
drop if sa3iq9d==1 // we drop unshelled observations: assuming all expected harvest are shelled estimates
rename sa3iq9b unit 
rename sa3iq9c size
collapse (median) sa3iq9_conv , by( unit size)
drop if inlist(., sa3iq9_conv, size, unit)
save "${temping}/Conversions_nozonecrop.dta", replace

use "${Nigeria_GHS_W4_raw_data}\secta3i_harvestw5.dta", clear
keep cropcode sa3iq9b sa3iq9c sa3iq9d sa3iq9_conv zone 
drop if sa3iq9d==1 // we drop unshelled observations: assuming all expected harvest are shelled estimates
rename sa3iq9b unit 
rename sa3iq9c size
collapse (median) sa3iq9_conv , by( unit)
drop if inlist(., sa3iq9_conv, unit)
save "${temping}/Conversions_nozonenocropnosize.dta", replace

use "${Nigeria_GHS_W4_raw_data}\sect11f_plantingw5.dta" , clear
egen plot_id = concat( hhid plotid), punct("-") // This creates a unique plot id.

recode s11fq7 (2=0 "No") (1 =1 "Yes"), gen(improved)

gen seed_kg_preconv = s11fq5a 
rename s11fq5b  unit
rename s11fq5c size
merge m:1 zone cropcode unit size using  "${temping}/Conversions.dta", keep(master match)  
gen seed_kg= seed_kg_preconv * sa3iq9_conv 
drop sa3iq9_conv  
merge m:1 cropcode unit size using "${temping}/Conversions_nozone.dta", keep(master match) nogen
replace seed_kg= seed_kg_preconv * sa3iq9_conv  if seed_kg==.
drop sa3iq9_conv 
merge m:1  unit size using "${temping}/Conversions_nozonecrop.dta", keep(master match) nogen
replace seed_kg= seed_kg_preconv * sa3iq9_conv  if seed_kg==.
drop sa3iq9_conv 

merge m:1 unit using "${temping}/Conversions_nozonenocropnosize.dta", keep(master match) nogen
replace seed_kg= seed_kg_preconv * sa3iq9_conv  if seed_kg==.

replace seed_kg = seed_kg_preconv if unit==1
replace seed_kg = seed_kg_preconv * 0.001 if unit==2

rename (zone state lga) (admin_1 admin_2 admin_3)
collapse (sum)  seed_kg (count) n_seed_kg = seed_kg , by( cropcode hhid plot_id admin_1 admin_2 admin_3 improved)
replace seed_kg = . if n_seed_kg==0
save "${temping}/seed_kg.dta", replace
collapse (sum)  seed_kg (count) n_seed_kg = seed_kg , by( cropcode hhid plot_id admin_1 admin_2 admin_3)
replace seed_kg = . if n_seed_kg==0
save "${temping}/seed_kg_merge.dta", replace


// seed_kg_sold 
use "${Nigeria_GHS_W4_raw_data}\sect11e1_plantingw5.dta", clear
merge m:1 hhid using "${Nigeria_GHS_W4_raw_data}\\${seeds_sold2}", nogen

merge m:1 hhid using "${temping}/admin1.dta", nogen 
merge m:1 hhid using "${temping}/admin2.dta", nogen 
merge m:1 hhid using "${temping}/admin3.dta",  nogen 

decode seedid, gen(seed_id)
egen improved_string= ends(seed_id), head
gen improved= 1 if improved_string=="IMPROVED" 
replace improved=0 if improved_string=="TRADITIONAL"

** Price of seeds per observation
rename s11eq9b unit
rename s11eq9c size
merge m:1 zone cropcode unit size using "${temping}/Conversions.dta", keep(master match) nogen 
gen seeds_amount_purchased_kg= sa3iq9_conv * s11eq9a
drop sa3iq9_conv 
merge m:1 cropcode unit size using  "${temping}/Conversions_nozone.dta", keep(master match) nogen 
replace seeds_amount_purchased_kg= sa3iq9_conv * s11eq9a if mi(seeds_amount_purchased_kg)
drop sa3iq9_conv 
merge m:1  unit size using  "${temping}/Conversions_nozonecrop.dta", keep(master match) nogen 
replace seeds_amount_purchased_kg= sa3iq9_conv * s11eq9a if mi(seeds_amount_purchased_kg)
drop sa3iq9_conv 
merge m:1  unit  using  "${temping}/Conversions_nozonenocropnosize.dta", keep(master match) nogen 
replace seeds_amount_purchased_kg= sa3iq9_conv * s11eq9a if mi(seeds_amount_purchased_kg)

collapse (sum) seeds_amount_purchased_kg (count) n_seeds_amount_purchased_kg = seeds_amount_purchased_kg, by(cropcode hhid  admin_1 admin_2 admin_3 improved)
replace seeds_amount_purchased_kg = . if n_seeds_amount_purchased_kg==0
save "${temping}/seeds_amount_purchased_kg.dta", replace

// seed_value_sold
use "${Nigeria_GHS_W4_raw_data}\sect11e1_plantingw5.dta", clear
merge m:1 hhid using "${Nigeria_GHS_W4_raw_data}\sect11e2_plantingw5.dta", nogen
merge m:1 hhid using "${temping}/admin1.dta", nogen 
merge m:1 hhid using "${temping}/admin2.dta", nogen 
merge m:1 hhid using "${temping}/admin3.dta",  nogen 


decode seedid, gen(seed_id)
egen improved_string= ends(seed_id), head
gen improved= 1 if improved_string=="IMPROVED" 
replace improved=0 if improved_string=="TRADITIONAL"


gen seed_value_temp = s11eq11 

collapse  (sum) seed_value_temp (count) n_seed_value_temp = seed_value_temp , by(cropcode hhid  admin_1 admin_2 admin_3 improved )
replace seed_value_temp = . if n_seed_value_temp==0
save "${temping}/seed_value_temp.dta", replace




capture program drop valuation_median_seeds_noea
program define valuation_median_seeds_noea 
args hhid id_link_seeds cropvar 


merge 1:1 `hhid' `id_link_seeds' `cropvar' using "${temping}/seed_value_temp.dta", keep(master match)	nogen
merge 1:1 `hhid' `id_link_seeds' `cropvar' using "${temping}/seeds_amount_purchased_kg.dta", keep(master match)	nogen
	
gen seed_price_temp = seed_value_temp / seeds_amount_purchased_kg
replace seed_price_temp = . if seed_price_temp==0


forvalues n =1/4 {
capture merge m:1 `hhid' using "${temping}/admin`n'.dta", keep(master match)	nogen
if !_rc {
 merge m:1 `hhid' using "${temping}/admin`n'.dta", keep(master match)	nogen
}
}

			capture confirm variable admin_4
		if !_rc {
				gen n=1 if !mi(seed_price_temp) & seed_price_temp!=0
				bys admin_4 `cropvar' improved : egen n2= total(n)
				gen ten_obs_admin4=1 if n2>=10 & !mi(n2)
				replace ten_obs_admin4=0 if n2<10 | mi(n2)
				tab ten_obs_admin4
				bys admin_4 `cropvar' improved : egen seed_price_admin4 = median(seed_price_temp) if seed_price_temp!=0
				gen seed_price = seed_price_admin4 if ten_obs_admin4==1
				drop n2 

				bys admin_3 `cropvar' improved : egen n2=total(n)
				gen ten_obs_admin3=1 if n2>=10 & !mi(n2)
				replace ten_obs_admin3=0 if n2<10 | mi(n2)
				tab ten_obs_admin3
				bys admin_3 `cropvar' improved : egen seed_price_admin3 = median(seed_price_temp) if seed_price_temp!=0
				replace seed_price = seed_price_admin3 if ten_obs_admin3==1 & ten_obs_admin4==0 
				drop n2 
				}
			else {
				gen n=1 if !mi(seed_price_temp) & seed_price_temp!=0
				bys admin_3 `cropvar' improved : egen n2=total(n)
				gen ten_obs_admin3=1 if n2>=10 & !mi(n2)
				replace ten_obs_admin3=0 if n2<10 | mi(n2)
				tab ten_obs_admin3
				bys admin_3 `cropvar' improved : egen seed_price_admin3 = median(seed_price_temp) if seed_price_temp!=0
				gen seed_price = seed_price_admin3 if ten_obs_admin3==1 
				drop n2 
				} 	
		
		* 
		bys admin_2 `cropvar' improved : egen n2=total(n)
		gen ten_obs_admin2=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin2=0 if n2<10 | mi(n2)
		tab ten_obs_admin2
		bys admin_2 `cropvar' improved : egen seed_price_admin2 = median(seed_price_temp) if seed_price_temp!=0
		replace seed_price = seed_price_admin2 if ten_obs_admin2==1 & ten_obs_admin3==0 
		drop n2

		* admin_1 level 
		bys admin_1 `cropvar' improved : egen n2=total(n)
		gen ten_obs_admin1=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin1=0 if n2<10 | mi(n2)
		tab ten_obs_admin1
		bys admin_1 `cropvar' improved : egen seed_price_admin_1 = median(seed_price_temp) if seed_price_temp!=0
		replace seed_price = seed_price_admin_1 if ten_obs_admin1==1 & ten_obs_admin2==0 
		drop n2
		
		* 
		bys `cropvar' improved : egen n2=total(n)
		gen ten_obs_n=1 if n2>=10 & !mi(n2)
		replace ten_obs_n=0 if n2<10 | mi(n2)
		tab ten_obs_n
		bys `cropvar' improved : egen seed_price_national = median(seed_price_temp) if seed_price_temp!=0
		replace seed_price = seed_price_national if ten_obs_n==1 & ten_obs_admin1==0 
		drop n2 n
		
		replace seed_price=seed_price_national if ten_obs_n==0
		
	
	** Collapse to the EA - crop level
	keep admin_1 admin_2 admin_3 `cropvar' improved seed_price 
	duplicates drop
	
	** Generating harvest value, using crop price variable
	merge 1:m admin_1 admin_2 admin_3 `cropvar' improved  using "${temping}/seed_kg.dta", keep(match using) nogen
	gen seed_value = seed_price * seed_kg
		
		
end


// seed value 
use "${Nigeria_GHS_W4_raw_data}\\${seeds_sold1}", clear
rename (zone state lga) (admin_1 admin_2 admin_3)
merge m:1 hhid using "${temping}/admin1.dta", nogen 
merge m:1 hhid using "${temping}/admin2.dta", nogen 
merge m:1 hhid using "${temping}/admin3.dta",  nogen 

decode seedid, gen(seed_id)
egen improved_string= ends(seed_id), head
gen improved= 1 if improved_string=="IMPROVED" 
replace improved=0 if improved_string=="TRADITIONAL"


keep cropcode  hhid  improved
duplicates drop

valuation_median_seeds_noea hhid improved cropcode 

keep  plot_id cropcode seed_value
duplicates drop
save "${temping}/seed_value.dta", replace

// labor days

capture program drop valuation_median_wages
program define valuation_median_wages 
args hhid hired_man_wage hired_woman_wage hired_child_wage

merge m:1 `hhid'  using "${temping}/ea_id.dta", keep(master match)	nogen

forvalues n =1/4 {
capture merge m:1 `hhid' using "${temping}/admin`n'.dta", keep(master match)	nogen
if !_rc {
 merge m:1 `hhid' using "${temping}/admin`n'.dta", keep(master match)	nogen
}
}

	* EA level
	
		// Men
		gen x1=1 if !mi(`hired_man_wage') & `hired_man_wage'>0
		bys ea_id: egen n2= total(x1), missing
		gen ten_obs_EA_man=1 if n2>=10 & !mi(n2)
		replace ten_obs_EA_man=0 if n2<10 |mi(n2)
		tab ten_obs_EA_man
		bys ea_id: egen man_wage = median(`hired_man_wage') if `hired_man_wage'>0
		bys ea_id (man_wage): replace man_wage = man_wage[1] // in case wage==0
		drop n2
		
		//Women
		gen x2=1 if !mi(`hired_woman_wage') & `hired_woman_wage'>0
		bys ea_id: egen n2= total(x2), missing
		gen ten_obs_EA_woman=1 if n2>=10 & !mi(n2)
		replace ten_obs_EA_woman=0 if n2<10 |mi(n2)
		tab ten_obs_EA_woman
		bys ea_id: egen woman_wage = median(`hired_woman_wage') if `hired_woman_wage'>0
		bys ea_id (woman_wage): replace woman_wage = woman_wage[1] // in case wage==0
		drop n2
		
		// Children
		gen x3=1 if !mi(`hired_child_wage') & `hired_child_wage'>0
		bys ea_id: egen n2= total(x3), missing
		gen ten_obs_EA_child=1 if n2>=10 & !mi(n2)
		replace ten_obs_EA_child=0 if n2<10 |mi(n2)
		tab ten_obs_EA_child
		bys ea_id: egen child_wage = median(`hired_child_wage') if `hired_child_wage'>0
		bys ea_id (child_wage): replace child_wage = child_wage[1] // in case wage==0
		drop n2
		
	* admin 4 level
		capture confirm variable admin_4
		if !_rc {
		bys admin_4 : egen n2=total(x1)
		gen ten_obs_admin4_man=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin4_man=0 if n2<10 |mi(n2)
		tab ten_obs_admin4_man
		bys admin_4 : egen  man_wage_kebele = median(`hired_man_wage') if `hired_man_wage'>0
		bys admin_4 (man_wage_kebele): replace man_wage_kebele = man_wage_kebele[1] // in case wage==0
		replace man_wage=  man_wage_kebele if ten_obs_admin4_man==1 & ten_obs_EA_man==0 
		drop n2 
		
		bys admin_4 : egen n2=total(x2), missing
		gen ten_obs_admin4_woman=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin4_woman=0 if n2<10 |mi(n2)
		tab ten_obs_admin4_woman
		bys admin_4 : egen  woman_wage_kebele = median(`hired_woman_wage') if `hired_woman_wage'>0
		bys admin_4 (woman_wage_kebele): replace woman_wage_kebele = woman_wage_kebele[1] // in case wage==0
		replace woman_wage=  woman_wage_kebele if ten_obs_admin4_woman==1 & ten_obs_EA_woman==0 
		drop n2
		
		bys admin_4 : egen n2=total(x3), missing
		gen ten_obs_admin4_child=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin4_child=0 if n2<10 |mi(n2)
		tab ten_obs_admin4_child
		bys admin_4 : egen  child_wage_kebele = median(`hired_child_wage')  if `hired_child_wage'>0
		bys admin_4 (child_wage_kebele): replace child_wage_kebele = child_wage_kebele[1] // in case wage==0
		replace child_wage=  child_wage_kebele if ten_obs_admin4_child==1 & ten_obs_EA_child==0 
		drop n2
		
	* admin 3 level
		bys admin_3 : egen n2=total(x1), missing
		gen ten_obs_admin3_man=1 if n2>=10 & !mi(n2) 
		replace ten_obs_admin3_man=0 if n2<10 |mi(n2)
		tab ten_obs_admin3_man
		bys admin_3 : egen  man_wage_woreda = median(`hired_man_wage') if `hired_man_wage'>0
		bys admin_3 (man_wage_woreda): replace man_wage_woreda = man_wage_woreda[1] // in case wage==0
		replace man_wage=  man_wage_woreda if ten_obs_admin3_man==1 & ten_obs_admin4_man==0 
		drop n2 
		
		bys admin_3 : egen n2=total(x2), missing
		gen ten_obs_admin3_woman=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin3_woman=0 if n2<10 |mi(n2)
		tab ten_obs_admin3_woman
		bys admin_3 : egen  woman_wage_woreda = median(`hired_woman_wage') if `hired_woman_wage'>0
		bys admin_3 (woman_wage_woreda): replace woman_wage_woreda = woman_wage_woreda[1] // in case wage==0
		replace woman_wage=  woman_wage_woreda if ten_obs_admin3_woman==1 & ten_obs_admin4_woman==0 
		drop n2
		
		bys admin_3 : egen n2=total(x3), missing
		gen ten_obs_admin3_child=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin3_child=0 if n2<10 |mi(n2)
		tab ten_obs_admin3_child
		bys admin_3 : egen  child_wage_woreda = median(`hired_child_wage') if `hired_child_wage'>0
		bys admin_3 (child_wage_woreda): replace child_wage_woreda = child_wage_woreda[1] // in case wage==0
		replace child_wage=  child_wage_woreda if ten_obs_admin3_child==1 & ten_obs_admin4_child==0 
		drop n2
		}
		else {
		bys admin_3 : egen n2=total(x1), missing
		gen ten_obs_admin3_man=1 if n2>=10 & !mi(n2) 
		replace ten_obs_admin3_man=0 if n2<10 |mi(n2)
		tab ten_obs_admin3_man
		bys admin_3 : egen  man_wage_woreda = median(`hired_man_wage') if `hired_man_wage'>0
		bys admin_3 (man_wage_woreda): replace man_wage_woreda = man_wage_woreda[1] // in case wage==0
		replace man_wage=  man_wage_woreda if ten_obs_admin3_man==1 & ten_obs_EA_man==0 
		drop n2 
		
		bys admin_3 : egen n2=total(x2), missing
		gen ten_obs_admin3_woman=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin3_woman=0 if n2<10 |mi(n2)
		tab ten_obs_admin3_woman
		bys admin_3 : egen  woman_wage_woreda = median(`hired_woman_wage') if `hired_woman_wage'>0
		bys admin_3 (woman_wage_woreda): replace woman_wage_woreda = woman_wage_woreda[1] // in case wage==0
		replace woman_wage=  woman_wage_woreda if ten_obs_admin3_woman==1 & ten_obs_EA_woman==0 
		drop n2
		
		bys admin_3 : egen n2=total(x3), missing
		gen ten_obs_admin3_child=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin3_child=0 if n2<10 |mi(n2)
		tab ten_obs_admin3_child
		bys admin_3 : egen  child_wage_woreda = median(`hired_child_wage') if `hired_child_wage'>0
		bys admin_3 (child_wage_woreda): replace child_wage_woreda = child_wage_woreda[1] // in case wage==0
		replace child_wage=  child_wage_woreda if ten_obs_admin3_child==1 & ten_obs_EA_child==0 
		drop n2
		}
		
	* admin 2 level
		bys admin_2: egen n2=total(x1), missing
		gen ten_obs_admin2_man=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin2_man=0 if n2<10 |mi(n2)
		tab ten_obs_admin2_man
		bys admin_2: egen  man_wage_zone = median(`hired_man_wage') if `hired_man_wage'>0
		bys admin_2 (man_wage_zone): replace man_wage_zone = man_wage_zone[1] // in case wage==0
		replace man_wage =  man_wage_zone if ten_obs_admin2_man==1 &ten_obs_admin3_man==0 
		drop n2
		
		bys admin_2: egen n2=total(x2), missing
		gen ten_obs_admin2_woman=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin2_woman=0 if n2<10 |mi(n2)
		tab ten_obs_admin2_woman
		bys admin_2: egen  woman_wage_zone = median(`hired_woman_wage') if `hired_woman_wage'>0
		bys admin_2 (woman_wage_zone): replace woman_wage_zone = woman_wage_zone[1] // in case wage==0
		replace woman_wage =  woman_wage_zone if ten_obs_admin2_woman==1 &ten_obs_admin3_woman==0 
		drop n2
		
		bys admin_2: egen n2=total(x3), missing
		gen ten_obs_admin2_child=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin2_child=0 if n2<10 |mi(n2)
		tab ten_obs_admin2_child
		bys admin_2: egen  child_wage_zone = median(`hired_child_wage') if `hired_child_wage'>0
		bys admin_2 (child_wage_zone): replace child_wage_zone = child_wage_zone[1] // in case wage==0
		replace child_wage =  child_wage_zone if ten_obs_admin2_child==1 &ten_obs_admin3_child==0 
		drop n2

		bys admin_1: egen n2=total(x1), missing
		gen ten_obs_admin1_man=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin1_man=0 if n2<10 |mi(n2)
		tab ten_obs_admin1_man
		bys admin_1: egen  man_wage_region = median(`hired_man_wage') if `hired_man_wage'>0
		bys admin_1 (man_wage_region): replace man_wage_region = man_wage_region[1] // in case wage==0
		replace  man_wage =  man_wage_region if ten_obs_admin1_man==1 &ten_obs_admin2_man==0 
		drop n2
		
		bys admin_1: egen n2=total(x2), missing
		gen ten_obs_admin1_woman=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin1_woman=0 if n2<10 |mi(n2)
		tab ten_obs_admin1_woman
		bys admin_1: egen  woman_wage_region = median(`hired_woman_wage') if `hired_woman_wage'>0
		bys admin_1 (woman_wage_region): replace woman_wage_region = woman_wage_region[1] // in case wage==0
		replace  woman_wage =  woman_wage_region if ten_obs_admin1_woman==1 &ten_obs_admin2_woman==0 
		drop n2
		
		bys admin_1: egen n2=total(x3), missing
		gen ten_obs_admin1_child=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin1_child=0 if n2<10 |mi(n2)
		tab ten_obs_admin1_child
		bys admin_1: egen  child_wage_region = median(`hired_child_wage') if `hired_child_wage'>0
		bys admin_1 (child_wage_region): replace child_wage_region = child_wage_region[1] // in case wage==0
		replace  child_wage =  child_wage_region if ten_obs_admin1_child==1 &ten_obs_admin2_child==0 
		drop n2
		
	* 
		egen n2=total(x1), missing
		gen ten_obs_n_man=1 if n2>=10 & !mi(n2)
		replace ten_obs_n_man=0 if n2<10 |mi(n2)
		tab ten_obs_n_man
		egen  man_wage_national = median(`hired_man_wage') if `hired_man_wage'>0
		bys man_wage_national: replace man_wage_national = man_wage_national[1] // in case wage==0
		replace  man_wage =  man_wage_national if ten_obs_n_man==1 &ten_obs_admin1_man==0 
		drop n2 x1
		
		egen n2=total(x2), missing
		gen ten_obs_n_woman=1 if n2>=10 & !mi(n2)
		replace ten_obs_n_woman=0 if n2<10 |mi(n2)
		tab ten_obs_n_woman
		egen  woman_wage_national = median(`hired_woman_wage') if `hired_woman_wage'>0
		bys woman_wage_national: replace woman_wage_national = woman_wage_national[1] // in case wage==0
		replace  woman_wage =  woman_wage_national if ten_obs_n_woman==1 &ten_obs_admin1_woman==0 
		drop n2 x2
		
		egen n2=total(x3), missing
		gen ten_obs_n_child=1 if n2>=10 & !mi(n2)
		replace ten_obs_n_child=0 if n2<10 |mi(n2)
		tab ten_obs_n_child
		egen  child_wage_national = median(`hired_child_wage') if `hired_child_wage'>0
		bys child_wage_national: replace child_wage_national = child_wage_national[1] // in case wage==0
		replace  child_wage =  child_wage_national if ten_obs_n_child==1 &ten_obs_admin1_child==0 
		drop n2 x3
		
		replace man_wage=man_wage_national if ten_obs_n_man==0
		replace woman_wage=woman_wage_national if ten_obs_n_woman==0
		replace child_wage=child_wage_national if ten_obs_n_child==0
		
		
end





use "${Nigeria_GHS_W4_raw_data}\\${lab_roster11}", clear
merge m:1 hhid plotid using "${Nigeria_GHS_W4_raw_data}\\${lab_roster12}", 
egen plot_id = concat( hhid plotid), punct("-")
drop if indiv==.

* 1) Family labor

replace s11c1q1b = 0 if s11c1q1a==2
bys plot_id: egen PPtotal_family_labor_days = total(s11c1q1b), missing 
replace PPtotal_family_labor_days = 0 if _merge==2


* 2) Hired labor
gen PPhired_man_days = s11c1q3_1 *s11c1q4_1
replace PPhired_man_days = 0 if s11c1q2_1 ==2 // these plots did not hire men

gen PPhired_woman_days = s11c1q3_2 *s11c1q4_2
replace PPhired_woman_days = 0 if s11c1q2_2==2 // these plots did not hire women

gen PPhired_child_days = s11c1q3_3 *s11c1q4_3
replace PPhired_child_days = 0 if s11c1q2_3==2 // these plots did not hire children

egen PPtotal_hired_labor_days= rowtotal(PPhired_man_days PPhired_woman_days PPhired_child_days), missing

replace PPtotal_hired_labor_days = 0 if _merge==1

gen PPhired_man_wage= s11c1q6_1

gen PPhired_woman_wage= s11c1q6_2

gen PPhired_child_wage = s11c1q6_3



* 3) other labor

gen PPother_man_days = s11c1q9_1  *s11c1q10_1
replace PPhired_man_days = 0 if s11c1q8_1==2 // these plots did not hire men

gen PPother_woman_days = s11c1q9_2 *s11c1q10_2
replace PPhired_woman_days = 0 if s11c1q8_2==2 // these plots did not hire women

gen PPother_child_days = s11c1q9_3 *s11c1q10_3
replace PPhired_child_days = 0 if s11c1q8_3==2 // these plots did not hire children


egen PPtotal_other_labor_days= rowtotal(PPother_man_days PPother_woman_days PPother_child_days), missing
replace PPtotal_other_labor_days = 0 if _merge==1
* ID code of workers

keep PPtotal_other_labor_days PPhired_man_wage PPhired_woman_wage PPhired_child_wage PPtotal_hired_labor_days PPtotal_family_labor_days plot_id hhid indiv

gen ID_worker = indiv
reshape wide PPtotal_other_labor_days PPhired_man_wage PPhired_woman_wage PPhired_child_wage PPtotal_hired_labor_days PPtotal_family_labor_days ID_worker, i(plot_id hhid) j(indiv)

foreach var in PPtotal_other_labor_days  PPtotal_hired_labor_days PPtotal_family_labor_days {
egen `var' =  rowtotal(`var'*), missing
}

foreach var in PPhired_man_wage PPhired_woman_wage PPhired_child_wage {
egen `var' =  rowmean(`var'*)
}

drop PPtotal_family_labor_days1 PPtotal_hired_labor_days1 PPhired_man_wage1 PPhired_woman_wage1 PPhired_child_wage1 PPtotal_other_labor_days1 PPtotal_family_labor_days2 PPtotal_hired_labor_days2 PPhired_man_wage2 PPhired_woman_wage2 PPhired_child_wage2 PPtotal_other_labor_days2 PPtotal_family_labor_days3 PPtotal_hired_labor_days3 PPhired_man_wage3 PPhired_woman_wage3 PPhired_child_wage3 PPtotal_other_labor_days3 PPtotal_family_labor_days4 PPtotal_hired_labor_days4 PPhired_man_wage4 PPhired_woman_wage4 PPhired_child_wage4 PPtotal_other_labor_days4 PPtotal_family_labor_days5 PPtotal_hired_labor_days5 PPhired_man_wage5 PPhired_woman_wage5 PPhired_child_wage5 PPtotal_other_labor_days5 PPtotal_family_labor_days6 PPtotal_hired_labor_days6 PPhired_man_wage6 PPhired_woman_wage6 PPhired_child_wage6 PPtotal_other_labor_days6 PPtotal_family_labor_days7 PPtotal_hired_labor_days7 PPhired_man_wage7 PPhired_woman_wage7 PPhired_child_wage7 PPtotal_other_labor_days7 PPtotal_family_labor_days8 PPtotal_hired_labor_days8 PPhired_man_wage8 PPhired_woman_wage8 PPhired_child_wage8 PPtotal_other_labor_days8 PPtotal_family_labor_days9 PPtotal_hired_labor_days9 PPhired_man_wage9 PPhired_woman_wage9 PPhired_child_wage9 PPtotal_other_labor_days9 PPtotal_family_labor_days10 PPtotal_hired_labor_days10 PPhired_man_wage10 PPhired_woman_wage10 PPhired_child_wage10 PPtotal_other_labor_days10 PPtotal_family_labor_days11 PPtotal_hired_labor_days11 PPhired_man_wage11 PPhired_woman_wage11 PPhired_child_wage11 PPtotal_other_labor_days11 PPtotal_family_labor_days12 PPtotal_hired_labor_days12 PPhired_man_wage12 PPhired_woman_wage12 PPhired_child_wage12 PPtotal_other_labor_days12 PPtotal_family_labor_days13 PPtotal_hired_labor_days13 PPhired_man_wage13 PPhired_woman_wage13 PPhired_child_wage13 PPtotal_other_labor_days13 PPtotal_family_labor_days14 PPtotal_hired_labor_days14 PPhired_man_wage14 PPhired_woman_wage14 PPhired_child_wage14 PPtotal_other_labor_days14 PPtotal_family_labor_days15 PPtotal_hired_labor_days15 PPhired_man_wage15 PPhired_woman_wage15 PPhired_child_wage15 PPtotal_other_labor_days15 PPtotal_family_labor_days16 PPtotal_hired_labor_days16 PPhired_man_wage16 PPhired_woman_wage16 PPhired_child_wage16 PPtotal_other_labor_days16 PPtotal_family_labor_days17 PPtotal_hired_labor_days17 PPhired_man_wage17 PPhired_woman_wage17 PPhired_child_wage17 PPtotal_other_labor_days17 PPtotal_family_labor_days18 PPtotal_hired_labor_days18 PPhired_man_wage18 PPhired_woman_wage18 PPhired_child_wage18 PPtotal_other_labor_days18 PPtotal_family_labor_days19 PPtotal_hired_labor_days19 PPhired_man_wage19 PPhired_woman_wage19 PPhired_child_wage19 PPtotal_other_labor_days19 PPtotal_family_labor_days20 PPtotal_hired_labor_days20 PPhired_man_wage20 PPhired_woman_wage20 PPhired_child_wage20 PPtotal_other_labor_days20 PPtotal_family_labor_days21 PPtotal_hired_labor_days21 PPhired_man_wage21 PPhired_woman_wage21 PPhired_child_wage21 PPtotal_other_labor_days21 PPtotal_family_labor_days22 PPtotal_hired_labor_days22 PPhired_man_wage22 PPhired_woman_wage22 PPhired_child_wage22 PPtotal_other_labor_days22 PPtotal_family_labor_days23 PPtotal_hired_labor_days23 PPhired_man_wage23 PPhired_woman_wage23 PPhired_child_wage23 PPtotal_other_labor_days23 PPtotal_family_labor_days24 PPtotal_hired_labor_days24 PPhired_man_wage24 PPhired_woman_wage24 PPhired_child_wage24 PPtotal_other_labor_days24 PPtotal_family_labor_days25 PPtotal_hired_labor_days25 PPhired_man_wage25 PPhired_woman_wage25 PPhired_child_wage25 PPtotal_other_labor_days25 PPtotal_family_labor_days26 PPtotal_hired_labor_days26 PPhired_man_wage26 PPhired_woman_wage26 PPhired_child_wage26 PPtotal_other_labor_days26 PPtotal_family_labor_days27 PPtotal_hired_labor_days27 PPhired_man_wage27 PPhired_woman_wage27 PPhired_child_wage27 PPtotal_other_labor_days27 PPtotal_family_labor_days33 PPtotal_hired_labor_days33 PPhired_man_wage33 PPhired_woman_wage33 PPhired_child_wage33 PPtotal_other_labor_days33

foreach var in ID_worker* {
rename `var' `var'_PP
}

valuation_median_wages hhid PPhired_man_wage PPhired_woman_wage PPhired_child_wage

gen man_labor_value = man_wage * PPhired_man_wage
gen woman_labor_value = woman_wage * PPhired_woman_wage
gen child_labor_value = child_wage * PPhired_child_wage
egen PPhired_labor_value = rowtotal (*_labor_value), missing


save "${temping}/PPtotal_labor_days.dta", replace



use "${Nigeria_GHS_W4_raw_data}\\${lab_roster21}", clear
merge m:1 hhid plotid using "${Nigeria_GHS_W4_raw_data}\\${lab_roster22}"
egen plot_id = concat( hhid plotid), punct("-") 
drop if indiv==.

* 1) Family labor 

bys plot_id: egen PHtotal_family_labor_days = total(sa2aq2), missing 
replace PHtotal_family_labor_days = 0 if _merge==2

* 2) Hired labor days

gen PHhired_man_days = sa2bq2_1 *sa2bq3_1
replace PHhired_man_days = 0 if sa2bq1_1==0 

gen PHhired_woman_days = sa2bq2_2 *sa2bq3_2
replace PHhired_woman_days = 0 if sa2bq1_2==0 

gen PHhired_child_days = sa2bq2_3 *sa2bq3_3
replace PHhired_child_days = 0 if sa2bq1_3 ==0 

egen PHtotal_hired_labor_days= rowtotal(PHhired_man_days PHhired_woman_days PHhired_child_days), missing
replace PHtotal_hired_labor_days = 0 if _merge==1

gen PHhired_man_wage= sa2bq5_1
	
gen PHhired_woman_wage= sa2bq5_2
	
gen PHhired_child_wage = sa2bq5_3	

valuation_median_wages hhid PHhired_man_wage PHhired_woman_wage PHhired_child_wage

gen man_labor_value = man_wage * PHhired_man_days
gen woman_labor_value = woman_wage * PHhired_woman_days
gen child_labor_value = child_wage * PHhired_child_days
egen PHhired_labor_value = rowtotal (*_labor_value), missing


* 3) Other (free) labor

gen PHother_man_days =  sa2bq8_1 * sa2bq9_1
replace PHhired_man_days = 0 if sa2bq7_1==0 // these plots did not hire men
  
gen PHother_woman_days = sa2bq8_2 * sa2bq9_2
replace PHhired_woman_days = 0 if sa2bq7_2==0 // these plots did not hire women

gen PHother_child_days =  sa2bq8_3 * sa2bq9_3
replace PHhired_child_days = 0 if sa2bq7_3==2 // these plots did not hire children

egen PHtotal_other_labor_days= rowtotal(PHother_man_days PHother_woman_days PHother_child_days), missing
replace PHtotal_other_labor_days = 0 if _merge==1

* 4) Total labor days

egen PHtotal_labor_days = rowtotal(PHtotal_hired_labor_days PHtotal_family_labor_days PHtotal_other_labor_days), missing

* ID code of workers

keep PHtotal_other_labor_days PHhired_man_wage PHhired_woman_wage PHhired_child_wage PHtotal_hired_labor_days PHtotal_family_labor_days plot_id hhid indiv

gen ID_worker = indiv
reshape wide PHtotal_other_labor_days PHhired_man_wage PHhired_woman_wage PHhired_child_wage PHtotal_hired_labor_days PHtotal_family_labor_days ID_worker, i(plot_id hhid) j(indiv)

foreach var in PHtotal_other_labor_days  PHtotal_hired_labor_days PHtotal_family_labor_days {
egen `var' =  rowtotal(`var'*), missing
}

foreach var in PHhired_man_wage PHhired_woman_wage PHhired_child_wage {
egen `var' =  rowmean(`var'*)
}

drop PHtotal_family_labor_days1 PHtotal_hired_labor_days1 PHhired_man_wage1 PHhired_woman_wage1 PHhired_child_wage1 PHtotal_other_labor_days1 PHtotal_family_labor_days2 PHtotal_hired_labor_days2 PHhired_man_wage2 PHhired_woman_wage2 PHhired_child_wage2 PHtotal_other_labor_days2 PHtotal_family_labor_days3 PHtotal_hired_labor_days3 PHhired_man_wage3 PHhired_woman_wage3 PHhired_child_wage3 PHtotal_other_labor_days3 PHtotal_family_labor_days4 PHtotal_hired_labor_days4 PHhired_man_wage4 PHhired_woman_wage4 PHhired_child_wage4 PHtotal_other_labor_days4 PHtotal_family_labor_days5 PHtotal_hired_labor_days5 PHhired_man_wage5 PHhired_woman_wage5 PHhired_child_wage5 PHtotal_other_labor_days5 PHtotal_family_labor_days6 PHtotal_hired_labor_days6 PHhired_man_wage6 PHhired_woman_wage6 PHhired_child_wage6 PHtotal_other_labor_days6 PHtotal_family_labor_days7 PHtotal_hired_labor_days7 PHhired_man_wage7 PHhired_woman_wage7 PHhired_child_wage7 PHtotal_other_labor_days7 PHtotal_family_labor_days8 PHtotal_hired_labor_days8 PHhired_man_wage8 PHhired_woman_wage8 PHhired_child_wage8 PHtotal_other_labor_days8 PHtotal_family_labor_days9 PHtotal_hired_labor_days9 PHhired_man_wage9 PHhired_woman_wage9 PHhired_child_wage9 PHtotal_other_labor_days9 PHtotal_family_labor_days10 PHtotal_hired_labor_days10 PHhired_man_wage10 PHhired_woman_wage10 PHhired_child_wage10 PHtotal_other_labor_days10 PHtotal_family_labor_days11 PHtotal_hired_labor_days11 PHhired_man_wage11 PHhired_woman_wage11 PHhired_child_wage11 PHtotal_other_labor_days11 PHtotal_family_labor_days12 PHtotal_hired_labor_days12 PHhired_man_wage12 PHhired_woman_wage12 PHhired_child_wage12 PHtotal_other_labor_days12 PHtotal_family_labor_days13 PHtotal_hired_labor_days13 PHhired_man_wage13 PHhired_woman_wage13 PHhired_child_wage13 PHtotal_other_labor_days13 PHtotal_family_labor_days14 PHtotal_hired_labor_days14 PHhired_man_wage14 PHhired_woman_wage14 PHhired_child_wage14 PHtotal_other_labor_days14 PHtotal_family_labor_days15 PHtotal_hired_labor_days15 PHhired_man_wage15 PHhired_woman_wage15 PHhired_child_wage15 PHtotal_other_labor_days15 PHtotal_family_labor_days16 PHtotal_hired_labor_days16 PHhired_man_wage16 PHhired_woman_wage16 PHhired_child_wage16 PHtotal_other_labor_days16 PHtotal_family_labor_days17 PHtotal_hired_labor_days17 PHhired_man_wage17 PHhired_woman_wage17 PHhired_child_wage17 PHtotal_other_labor_days17 PHtotal_family_labor_days18 PHtotal_hired_labor_days18 PHhired_man_wage18 PHhired_woman_wage18 PHhired_child_wage18 PHtotal_other_labor_days18 PHtotal_family_labor_days19 PHtotal_hired_labor_days19 PHhired_man_wage19 PHhired_woman_wage19 PHhired_child_wage19 PHtotal_other_labor_days19 PHtotal_family_labor_days20 PHtotal_hired_labor_days20 PHhired_man_wage20 PHhired_woman_wage20 PHhired_child_wage20 PHtotal_other_labor_days20 PHtotal_family_labor_days22 PHtotal_hired_labor_days22 PHhired_man_wage22 PHhired_woman_wage22 PHhired_child_wage22 PHtotal_other_labor_days22 PHtotal_family_labor_days23 PHtotal_hired_labor_days23 PHhired_man_wage23 PHhired_woman_wage23 PHhired_child_wage23 PHtotal_other_labor_days23 PHtotal_family_labor_days25 PHtotal_hired_labor_days25 PHhired_man_wage25 PHhired_woman_wage25 PHhired_child_wage25 PHtotal_other_labor_days25 PHtotal_family_labor_days26 PHtotal_hired_labor_days26 PHhired_man_wage26 PHhired_woman_wage26 PHhired_child_wage26 PHtotal_other_labor_days26 PHtotal_family_labor_days31 PHtotal_hired_labor_days31 PHhired_man_wage31 PHhired_woman_wage31 PHhired_child_wage31 PHtotal_other_labor_days31 PHtotal_family_labor_days32 PHtotal_hired_labor_days32 PHhired_man_wage32 PHhired_woman_wage32 PHhired_child_wage32 PHtotal_other_labor_days32 

*PHtotal_family_labor_days36 PHtotal_hired_labor_days36 PHhired_man_wage36 PHhired_woman_wage36 PHhired_child_wage36 PHtotal_other_labor_days36


foreach var in ID_worker* {
rename `var' `var'_PH
}
valuation_median_wages hhid PHhired_man_wage PHhired_woman_wage PHhired_child_wage

gen man_labor_value = man_wage * PHhired_man_wage
gen woman_labor_value = woman_wage * PHhired_woman_wage
gen child_labor_value = child_wage * PHhired_child_wage
egen PHhired_labor_value = rowtotal (*_labor_value), missing

save "${temping}/PHtotal_labor_days.dta", replace 



// PH labor

// put all together
use "${temping}/PHtotal_labor_days.dta", clear
merge 1:1 plot_id  using "${temping}/PPtotal_labor_days.dta", nogen

egen total_labor_days = rowtotal(PHtotal_hired_labor_days PHtotal_family_labor_days PHtotal_other_labor_days PPtotal_hired_labor_days PPtotal_family_labor_days ), missing

egen total_hired_labor_days = rowtotal(PHtotal_hired_labor_days PPtotal_hired_labor_days ), missing

egen total_family_labor_days = rowtotal(PHtotal_family_labor_days PPtotal_family_labor_days)

egen hired_labor_value = rowtotal(PHhired_labor_value PPhired_labor_value), missing
replace hired_labor_value = 0 if total_hired_labor_days==0

keep total_labor_days plot_id total_family_labor_days total_hired_labor_days hired_labor_value ID_worker*
duplicates drop
save "${temping}/labor_days.dta", replace









// inorganic fertilizer
use "${Nigeria_GHS_W4_raw_data}\\${ferts}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11c2q5 (1 =1 "Yes") (2 = 0 "No"), gen(inorganic_fertilizer) label(inorganic_fertilizer)
replace inorganic_fertilizer=0 if s11c2q5==2
keep plot_id inorganic_fertilizer
duplicates drop
save "${temping}/inorganic_fertilizer.dta", replace

// nitrogen equivalent

use "${Nigeria_GHS_W4_raw_data}\\${ferts}", clear

merge m:1 hhid  using "${temping}/ea_id.dta", keep(master match)	nogen

forvalues n =1/4 {
capture merge m:1 hhid using "${temping}/admin`n'.dta", keep(master match)	nogen
if !_rc {
 merge m:1 hhid using "${temping}/admin`n'.dta", keep(master match)	nogen
}
}

egen plot_id = concat( hhid plotid), punct("-") 
recode s11c2q5 (1 =1 "Yes") (2 = 0 "No"), gen(inorganic_fertilizer) label(inorganic_fertilizer)

*UREA
gen UREA_kg = s11c2q11am * s11c2q11am_conv
replace UREA_kg= 0 if inorganic_fertilizer==0

* NPK
gen NPK_kg=  s11c2q7am * s11c2q7am_conv
replace NPK_kg=0 if inorganic_fertilizer==0

* other
gen other_kg=  s11c2q9am * s11c2q9am_conv
replace other_kg=0 if inorganic_fertilizer==0

* Nitrogen equalivent 

gen UREA_N_kg = UREA_kg*0.46
gen NPK_N_kg = NPK_kg*0.2
egen nitrogen_kg = rowtotal(UREA_N_kg NPK_N_kg), missing


collapse (sum) nitrogen_kg  UREA_kg  NPK_kg other_kg  (count) n_nitrogen_kg = nitrogen_kg n_NPK_kg = NPK_kg  n_UREA_kg = UREA_kg n_other_kg = other_kg , by(plot_id hhid ea_id admin_1 admin_2 admin_3)
foreach var in nitrogen_kg NPK_kg  UREA_kg  other_kg  {
replace `var' = . if n_`var'==0
}
save "${temping}/nitrogen_kg.dta", replace

// inorganic fertilizer value 

use "${Nigeria_GHS_W4_raw_data}\\${ferts_sold}", clear
rename (zone state lga) (admin_1 admin_2 admin_3)
gen input_purchase_kg = s11c3q4a * s11c3q4_conv if !inlist(s11c3q4b, 3, 4) // if not converted to liters 
gen input_purchase_l = s11c3q4a * s11c3q4_conv if inlist(s11c3q4b, 3, 4)
drop if ea==. | ea==0
keep s11c3q5 input_purchase_kg input_purchase_l hhid inputid admin_1 admin_2 admin_3 ea // I keep quantity sold and value to reshape
reshape wide admin_1 admin_2 admin_3 ea s11c3q5 input_purchase_kg input_purchase_l , i(hhid) j(inputid) // inputs types are not variables
foreach var in  admin_1 admin_2 admin_3 ea {
drop `var'2 `var'3 `var'4 `var'5 `var'6 `var'7 `var'8
rename `var'1 `var'
}
gen UREA_purchased_kg = input_purchase_kg3
gen UREA_purchased_value = s11c3q53

gen NPK_purchased_kg = input_purchase_kg2
gen NPK_purchased_value = s11c3q52

gen other_purchased_kg = input_purchase_kg4
gen other_purchased_value = s11c3q54


collapse (max) UREA_purchased_kg  NPK_purchased_kg other_purchased_kg  UREA_purchased_value NPK_purchased_value  other_purchased_value  , by(hhid)

// program to calculate inorganic fertilizer value


capture program drop valuation_median_fert_price
program define valuation_median_fert_price 
args hhid name

merge m:1 `hhid'  using "${temping}/ea_id.dta", keep(master match)	nogen

forvalues n =1/4 {
capture merge m:1 `hhid' using "${temping}/admin`n'.dta", keep(master match)	nogen
if !_rc {
 merge m:1 `hhid' using "${temping}/admin`n'.dta", keep(master match)	nogen
}
}

	gen `name'price = `name'_purchased_value/ `name'_purchased_kg


	** `name'
		gen x1=1 if !mi(`name'price) & `name'price!=0
		bys ea_id: egen n2= total(x1), missing
		gen ten_obs_EA_`name'=1 if n2>=10 & !mi(n2)
		replace ten_obs_EA_`name'=0 if n2<10 |mi(n2)
		tab ten_obs_EA_`name'
		bys ea_id: egen `name'_value_EA = median(`name'price) if `name'price>0
		gen `name'_value = `name'_value_EA if ten_obs_EA_`name'==1
		drop n2
		
		
	** Kebele
		capture variable admin_4 
		if !_rc {
		bys admin_4 : egen n2=total(x1), missing
		gen ten_obs_admin4_`name'=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin4_`name'=0 if n2<10 |mi(n2)
		tab ten_obs_admin4_`name'
		bys admin_4 : egen  `name'_value_admin4 = median(`name'price) if `name'price>0 
		replace `name'_value=  `name'_value_admin4 if ten_obs_admin4_`name'==1 & ten_obs_EA_`name'==0 
		drop n2 
		
		bys admin_3 : egen n2=total(x1), missing
		gen ten_obs_admin3_`name'=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin3_`name'=0 if n2<10 |mi(n2)
		tab ten_obs_admin3_`name'
		bys admin_3 : egen  `name'_value_admin3 = median(`name'price) if `name'price>0 
		replace `name'_value=  `name'_value_admin3 if ten_obs_admin3_`name'==1 & ten_obs_admin4_`name'==0 
		drop n2 
		} 
		else {
		bys admin_3 : egen n2=total(x1), missing
		gen ten_obs_admin3_`name'=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin3_`name'=0 if n2<10 |mi(n2)
		tab ten_obs_admin3_`name'
		bys admin_3 : egen  `name'_value_admin3 = median(`name'price) if `name'price>0 
		replace `name'_value=  `name'_value_admin3 if ten_obs_admin3_`name'==1 & ten_obs_EA_`name'==0 
		drop n2
		}
	
		
	***  
		bys admin_2 : egen n2=total(x1), missing
		gen ten_obs_admin2_`name'=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin2_`name'=0 if n2<10 |mi(n2)
		tab ten_obs_admin2_`name'
		bys admin_2 : egen  `name'_value_admin2 = median(`name'price) if `name'price>0 
		replace `name'_value=  `name'_value_admin2 if ten_obs_admin2_`name'==1 & ten_obs_admin3_`name'==0 
		drop n2 
		
	***  
		
		bys admin_1 : egen n2=total(x1), missing
		gen ten_obs_admin1_`name'=1 if n2>=10 & !mi(n2)
		replace ten_obs_admin1_`name'=0 if n2<10 |mi(n2)
		tab ten_obs_admin1_`name'
		bys admin_1 : egen  `name'_value_admin1 = median(`name'price) if `name'price>0
		replace `name'_value=  `name'_value_admin1 if ten_obs_admin1_`name'==1 & ten_obs_admin2_`name'==0 
		drop n2 
		
	***  
		egen n2=total(x1), missing
		gen ten_obs_n_`name'=1 if n2>=10 & !mi(n2)
		replace ten_obs_n_`name'=0 if n2<10 |mi(n2)
		tab ten_obs_n_`name'
		egen  `name'_value_national = median(`name'price) if `name'price>0
		replace `name'_value=  `name'_value_national if ten_obs_n_`name'==1 & ten_obs_admin1_`name'==0 
		drop n2  x1
		

	//gen value_`name'_total = `name'_value * `name'_kg

end 







valuation_median_fert_price hhid UREA

valuation_median_fert_price hhid NPK

valuation_median_fert_price hhid other

bys ea_id admin_1 admin_2 admin_3: assert UREA_value==UREA_value[1]

collapse (mean) UREA_value  NPK_value  other_value , by(ea_id admin_1 admin_2 admin_3) 
merge 1:m ea_id admin_1 admin_2 admin_3 using "${temping}/nitrogen_kg.dta", nogen // some unmatched regions

foreach n in NPK UREA other  {
gen value_`n' = `n'_value * `n'_kg
}

egen inorganic_fertilizer_value = rowtotal(value_*), missing

keep plot_id  inorganic_fertilizer_value
duplicates drop
save "${temping}/inorganic_fertilizer_value.dta", replace

// organic fert
use "${Nigeria_GHS_W4_raw_data}\\${ferts}", clear
egen plot_id = concat( hhid plotid), punct("-") 
recode s11c2q11 (1 = 1 "Yes") (2 = 0 "No"), gen(organic_fertilizer) label(organic_fertilizer)
*replace organic_fertilizer= 0 if s11dq1==2
collapse (max)  organic_fertilizer, by(plot_id)
save "${temping}/organic_fertilizer.dta", replace

// pesticides
use "${Nigeria_GHS_W4_raw_data}\\${ferts}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11c2q3 (1 = 1 "Yes") (2 = 0 "No") , gen(used_pesticides) label(used_pesticides)
collapse (max) used_pesticides, by(plot_id)
save "${temping}/used_pesticides.dta", replace

// plot owned
use "${Nigeria_GHS_W4_raw_data}\\${tenure}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11b1q4 ( 1 4 5  = 1 "Yes") (2 3 6 7 = 0 "No") , gen(plot_owned) 
recode s11b1q8 (1 = 1 "Yes") (2= 0 "No") (3=.), gen(plot_certificate) label(plot_certificate)
replace plot_certificate=0 if plot_owned==0 
keep plot_id plot_owned plot_certificate
duplicates drop
save "${temping}/plot_owned.dta", replace

// irrigated
use "${Nigeria_GHS_W4_raw_data}\\${tenure}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11b1q56 (1 = 1 "Yes") (2 = 0 "No"), gen(irrigated) label(irrigated)
keep plot_id irrigated
duplicates drop
save "${temping}/irrigated.dta", replace

// erosion protection
use "${Nigeria_GHS_W4_raw_data}\\${tenure}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11b1q66 ( 2 = 0 "No" ) (1 = 1 "Yes"), gen(erosion_protection) label(erosion_protection)
keep plot_id erosion_protection
duplicates drop
save "${temping}/erosion_protection.dta", replace

// tractor
use "${Nigeria_GHS_W4_raw_data}\\${tenure}", clear
egen plot_id = concat( hhid plotid), punct("-") 
recode s11b1q69 (1 = 1 "Yes") (2 = 0 "No"), gen(tractor) label(tractor)
collapse (max) tractor , by(hhid)
save "${temping}/tractor.dta", replace

// nb fallow
use "${Nigeria_GHS_W4_raw_data}\\${tenure}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11b1q44 (1 = 1) (. = . ) (* = 0), gen(fallow_plot)
replace fallow_plot= 0 if s11b1q68==1
bys hhid: egen nb_fallow_plots = total(fallow_plot), missing
merge m:1 hhid using "${Nigeria_GHS_W4_raw_data}\\${cover}", 
replace nb_fallow_plots= 0 if _merge ==2		
keep hhid nb_fallow_plots
duplicates drop
save "${temping}/nb_fallow_plots.dta", replace

// nb plots
use "${Nigeria_GHS_W4_raw_data}\\${tenure}", clear
egen plot_id = concat( hhid plotid), punct("-")
recode s11b1q44 (1 = 1) (. = . ) (* = 0), gen(fallow_plot)
replace fallow_plot= 0 if s11b1q68==1
bys hhid: egen nb_plots = count(fallow_plot)
merge m:1 hhid using "${Nigeria_GHS_W4_raw_data}\\${cover}", 
replace nb_plots= 0 if _merge ==2	
keep hhid nb_plots
duplicates drop
save "${temping}/nb_plots.dta", replace

// education hh
use "${Nigeria_GHS_W4_raw_data}\\${indiv_roster1}", clear

recode s2q6 ( 1 = 1 "Yes") ( 2 = 0 "No"), gen(formal_education_hh1) label(formal_education_hh1)
recode s2q9 (0/15 51/61 98 99 = 0 "No" ) (16/43 321/424 = 1 "Yes"), gen(primary_education_hh1) label(primary_education_hh1)
replace primary_education_hh1 = 0 if formal_education_hh1==0

egen formal_education_hh = rowmax(formal_education_hh1 )
egen primary_education_hh = rowmax( primary_education_hh1)
bys hhid: egen hh_primary_education= max(primary_education_hh) 
bys hhid: egen hh_formal_education = max(formal_education_hh)

collapse (max) hh_formal_education hh_primary_education, by(hhid)
keep hhid hh_formal_education hh_primary_education
duplicates drop
save "${temping}/hh_primary_education.dta", replace

/*
// electricity access
use "${Nigeria_GHS_W4_raw_data}\\${housing}", clear
recode s11q47 (1 = 1 "Yes") (2 = 0 "No"), gen(hh_electricity_access) label(hh_electricity_access)
keep hhid hh_electricity_access
duplicates drop
save "${temping}/hh_electricity_access.dta", replace
*/


// dependency ratio
use "${Nigeria_GHS_W4_raw_data}\\${indiv_roster}", clear

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
save "${temping}/hh_dependency_ratio.dta", replace

// livestock
use "${Nigeria_GHS_W4_raw_data}\\${livestock}", clear
merge m:1 hhid using "${Nigeria_GHS_W4_raw_data}\\${cover}"
recode s11iq1  (1 = 1 "Yes") (2 . = 0 "No"), gen(livestock) label(livestock)
collapse (max) livestock, by(hhid) 
save "${temping}/livestock.dta", replace







/*
// consumption quint
use "${Nigeria_GHS_W4_raw_data}\\\${csption}", clear
xtile cons_quint= totcons_pc
keep hhid cons_quint 
duplicates drop
save "${temping}/cons_quint.dta", replace

// consumption aggregate (unprcoessed)
use "${Nigeria_GHS_W4_raw_data}\\${csption}", clear
keep hhid totcons_pc
rename totcons_pc totcons 
duplicates drop
save "${temping}/totcons.dta", replace

*/








// manager chars
use "${Nigeria_GHS_W4_raw_data}\\${plot_roster}", clear
egen plot_id = concat( hhid plotid), punct("-")
rename s11aq5a manager_id
sort  hhid (manager_id)
collapse (first) manager_id  , by(hhid plot_id)
save "${temping}/ID_list.dta", replace


use "${Nigeria_GHS_W4_raw_data}\\${indiv_roster0}", clear
gen manager_id = indiv  // this is the HH member id 
merge 1:m  hhid manager_id using "${temping}/ID_list.dta", keep(match ) nogen
rename manager_id id
egen manager_id = concat (hhid id ), punct("-")
recode  s1q2 (2=1 "Yes") (1=0 "No"), gen(female_manager) 
rename s1q6 age_manager
replace age_manager=. if age_manager==999
recode s1q16 ( 1 2 = 1 "Yes") (3/7 = 0 "No"), gen(married_manager) 
keep plot_id female_manager age_manager married_manager manager_id
duplicates drop
save "${temping}/Manager_characteristics1.dta", replace

use "${Nigeria_GHS_W4_raw_data}\\${indiv_roster1}", clear
gen manager_id =  indiv  // this is the HH member id 
merge 1:m  hhid manager_id using "${temping}/ID_list.dta", keep(match) nogen
rename manager_id id
egen manager_id = concat (hhid id ), punct("-")
recode s2q6 ( 1 = 1 "Yes") ( 2 = 0 "No" ), gen(formal_education_manager1) label(formal_education_manager1)
recode s2q9 (0/15 51/61 98 99 = 0 "No" ) (16/43 321/424 = 1 "Yes"), gen(primary_education_manager1) label(primary_education_manager1)
replace primary_education_manager1 = 0 if formal_education_manager1==0

egen formal_education_manager = rowmax(formal_education_manager1)
egen primary_education_manager = rowmax( primary_education_manager1)
keep plot_id primary_education_manager formal_education_manager
duplicates drop
save "${temping}/Manager_characteristics2.dta", replace

// respondent chars
use "${Nigeria_GHS_W4_raw_data}\\${tenure}", clear 
merge 1:1 hhid plotid using "${Nigeria_GHS_W4_raw_data}\\${plot_roster}", nogen 
duplicates report hhid // one duplicate
gen respondent_id = s11b1q2  

sort  hhid (respondent_id)
collapse (first) respondent_id, by(hhid)
tempfile ID_list
save "${temping}/ID_list.dta", replace

use "${Nigeria_GHS_W4_raw_data}\\${indiv_roster0}", clear
rename indiv respondent_id // this is the HH member id 
merge 1:m  hhid respondent_id using "${temping}/ID_list.dta", keep(match) nogen
rename respondent_id id
egen respondent_id = concat (hhid id ), punct("-")
recode  s1q2 (2=1 "Yes") (1=0 "No"), gen(female_respondent) 
rename s1q6 age_respondent
replace age_respondent=. if age_respondent==999
recode s1q16 ( 1 2 = 1 "Yes") (3/7 = 0 "No"), gen(married_respondent) 
keep hhid female_respondent age_respondent married_respondent respondent_id
duplicates drop
save "${temping}/respondent_characteristics1.dta", replace

use "${Nigeria_GHS_W4_raw_data}\\${indiv_roster1}", clear
gen respondent_id = indiv  // this is the HH member id 
merge 1:m  hhid respondent_id using "${temping}/ID_list.dta", keep(match) nogen
rename respondent_id id
egen respondent_id = concat (hhid id ), punct("-")

recode s2q6 ( 1 = 1 "Yes") ( 2 = 0 "No"), gen(formal_education_respondent1) label(formal_education_respondent1)
recode s2q9 (0/15 51/61 98 99 = 0 "No" ) (16/43 321/424 = 1 "Yes"), gen(primary_education_respondent1) label(primary_education_respondent1)
replace primary_education_respondent1 = 0 if formal_education_respondent1==0

egen formal_education_respondent = rowmax(formal_education_respondent1 )
egen primary_education_respondent = rowmax( primary_education_respondent1)
keep hhid primary_education_respondent formal_education_respondent
duplicates drop
save "${temping}/Resp_characteristics2.dta", replace


/*
// hh shock
use "${Nigeria_GHS_W4_raw_data}\\${shocks}", clear
replace s15aq1=0 if s15aq3a==1 
recode s15aq1 (1 = 1 "Yes") (2 0 = 0 "No"), gen(hh_shock) label(hh_shock)
collapse (max) hh_shock, by(hhid) 
save "${temping}/shock.dta", replace
*/
// hh size
use "${Nigeria_GHS_W4_raw_data}\\${labor_hh}", clear
bys hhid: egen hh_size = count(indiv)
keep hhid hh_size
duplicates drop
isid hhid
save "${temping}/size.dta", replace

// ag assets
use "${Nigeria_GHS_W4_raw_data}\\${items}", clear

drop if inlist(item_cd, 313, 314, 315, 316 )
duplicates report hhid item_cd // a few duplicates 
duplicates drop hhid item_cd, force

gen hh_owns_= 0
foreach var of varlist sa4q4_1 sa4q4_2 sa4q4_3 sa4q4_4 sa4q4_5 { 
replace hh_owns_=1 if !mi(`var') & `var'!=0
replace hh_owns_=1 if sa4q3==1
}


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
save "${temping}/ag_asset_index.dta", replace
/*
// hh assets
use "${Nigeria_GHS_W4_raw_data}\\${items_hh}", clear

drop if item_cd>331
recode s5q1a (1 = 1) (2=0), gen(hh_owns) label(hh_owns) 
keep hh_owns hhid item_cd
reshape wide hh_owns , i(hhid) j(item_cd)
foreach var of varlist hh_owns* {
replace `var'=0 if `var'==.
}
factor hh_owns*, pcf 
predict hh_asset_index
keep hhid hh_asset_index
duplicates drop
save "${temping}/hh_asset_index.dta", replace
*/
// non farm enterprise
use "${Nigeria_GHS_W4_raw_data}\\${nfe1}", clear
merge m:1 hhid using "${Nigeria_GHS_W4_raw_data}\\${cover}",
recode s8q1a ( 2 = 0 "No") (3 = 1 "Yes"), gen(nonfarm_enterprise) label(nonfarm_enterprise)
keep hhid nonfarm_enterprise
duplicates drop
save "${temping}/nfe.dta", replace
/*
// latitude 
use "${Nigeria_GHS_W4_raw_data}\\${geovars_hh}", clear
rename (lat_dd_mod lon_dd_mod) ( lat_modified lon_modified)
keep hhid lat_modified lon_modified
duplicates drop
save "${temping}/Coords.dta", replace

// agro ecological zone
use "${Nigeria_GHS_W4_raw_data}\\${geovars_hh}", clear

rename ssa_aez09 agro_ecological_zone
keep hhid agro_ecological_zone
duplicates drop
save "${temping}/aez.dta", replace

// distance to nearest road
use "${Nigeria_GHS_W4_raw_data}\\${geovars_hh}", clear
rename dist_road2 dist_road
keep hhid dist_road
duplicates drop
save "${temping}/dist_road.dta", replace

// distance to nearest population center
use "${Nigeria_GHS_W4_raw_data}\\${geovars_hh}", clear
rename dist_popcenter2 dist_popcenter
keep hhid dist_popcenter
duplicates drop
save "${temping}/dist_popcenter.dta", replace

// distance to nearest market 
use "${Nigeria_GHS_W4_raw_data}\\${geovars_hh}", clear
keep hhid dist_market
duplicates drop
save "${temping}/dist_market.dta", replace

// plot slope
use "${Nigeria_GHS_W4_raw_data}\\${geovars}", clear
egen plot_id = concat( hhid plotid), punct("-")
replace srtmslp_nga="" if srtmslp_nga=="NA"
destring srtmslp_nga, replace
rename srtmslp_nga plot_slope
keep plot_id plot_slope
duplicates drop
save "${temping}/plot_slope.dta", replace

// plot elevation
use "${Nigeria_GHS_W4_raw_data}\\${geovars}", clear
egen plot_id = concat( hhid plotid), punct("-")
rename srtm_nga elevation 
keep plot_id elevation
duplicates drop
save "${temping}/elevation.dta", replace

// total wetness index
use "${Nigeria_GHS_W4_raw_data}\\${geovars}", clear 
egen plot_id = concat( hhid plotid), punct("-")
rename twi_nw twi 
keep plot_id twi
duplicates drop
save "${temping}/twi.dta", replace

// soil variables
use "${Nigeria_GHS_W4_raw_data}\\${geovars_hh}", clear
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
save "${temping}/soil.dta", replace


// popdensity
use "${Nigeria_GHS_W4_raw_data}\\${geovars_hh}", clear 
keep hhid popdensity
tostring popdensity, replace 
duplicates drop
save "${temping}/popdensity.dta", replace
*/
// indiv chars 
use "${Nigeria_GHS_W4_raw_data}\\${indiv_roster0}", clear
egen ID = concat (hhid indiv), punct("-")
drop if s1q4==2
recode  s1q2 (2=1 "Yes") (1=0 "No"), gen(female)
rename s1q6 age
recode s1q16 ( 1 2 = 1 "Yes") (3/7 = 0 "No"), gen(married) 
rename s1q3 relationship_head_temp
decode relationship_head_temp, gen(relationship_head)
replace relationship_head = proper(relationship_head)
replace relationship_head = substr(relationship_head,strpos(relationship_head, " " ) + 1, .)
replace relationship_head = "Father-in-law/Mother-in-law" if relationship_head== "Parent-In-Law"
replace relationship_head = "Son-in-law/Daughter-in-law" if relationship_head== "Son/Daughter-In-Law"
replace relationship_head = "Brother-in-law/Sister-in-law" if relationship_head== "Brother/Sister-In-Law"
replace relationship_head = "Sister/Brother" if relationship_head== "Brother/Sister"
replace relationship_head = "Non Relative" if relationship_head== "Other Non-Relative"
replace relationship_head = "Non Relative" if relationship_head== "Other (Specify)"
replace relationship_head = "Other Relative" if relationship_head== "Other Relative"
replace relationship_head = "Servant" if relationship_head== "Domestic Help"
replace relationship_head = "Grandparent" if relationship_head== "Grandfather/Mother"
replace relationship_head = "Son/Daughter" if relationship_head== "Adopted Child"
replace relationship_head = "Son/Daughter" if relationship_head== "Own Child"
replace relationship_head = "Son/Daughter" if relationship_head== "Step Child"
replace relationship_head = "Other Relative" if relationship_head== "Other Relation (Specify)"
replace relationship_head = "Non Relative" if relationship_head== "Other Non-Relation (Specify)" 

// month of birth
gen birth_month= ym(s1q11, s1q10)
format birth_month %tm 

keep hhid ID married female age relationship_head  birth_month
duplicates drop
save "${temping}/indiv_chars.dta", replace

/*
// wasting
use "${Nigeria_GHS_W4_raw_data}\\${anthropo}", clear
egen ID = concat (hhid indiv ), punct("-")
merge 1:1 hhid ID using "${temping}/indiv_chars.dta",  keep(master match) nogen
merge m:1 hhid  using "${temping}/harvest_interview_month.dta",  keep(master match) nogen

// age in months
gen age_months = harvest_interview_month - birth_month

*Main anthropometric variables
egen weight=rowtotal(s4aq52_1 s4aq52_2 s4aq52_3), missing
egen height=rowtotal(s4aq53_1 s4aq53_2 s4aq53_3), missing // height missing 

gen cage=age*12
replace cage = age_months if age==0| age==.
format %5.0g cage
zscore06, a(cage) s(female) h(height) w(weight) male(0) female(1)

gen wasting=whz06<-2 if whz06<.

keep haz06 waz06 whz06 bmiz06 wasting  hhid ID weight height
duplicates drop
save "${temping}/wasting.dta", replace
*/
/*
// labor 
use "${Nigeria_GHS_W4_raw_data}\\${labor_hh1}", clear
egen ID = concat (hhid indiv), punct("-")

recode s3q5b (0 = 0) (.=.) (else = 1), gen( farm_work)
replace farm_work= 0 if s3q5==2
recode s3q6b (0 = 0) (.=.) (else = 1), gen( SOB_work)
replace SOB_work= 0 if s3q6==2
recode s3q4b (0 = 0) (.=.) (else = 1), gen( wage_work)
replace wage_work= 0 if s3q4==2

gen working_age = s3q1 == 1

// industry:
gen ind_ag = s3q14 == 1  // Agriculture 
gen ind_fish = . // none?
gen ind_mining = s3q14 == 2 // mining
gen ind_manuf = s3q14 >= 3 & s3q14<=5 // manuf
gen ind_const = s3q14 == 6 // construc
gen ind_serv = s3q14 >= 7 & s3q14<= 14 // services
foreach var in ind_ag ind_const ind_fish ind_manuf ind_mining ind_serv {
replace `var' = 0 if s3q4==2   // remove self employment, did not need to use s3q15
replace `var' = 0 if s3q7==2 // did not work
}
rename (s3q5b s3q6b s3q4b ) (farm_hrs SB_hrs wage_hrs )
replace farm_hrs= 0 if s3q5==2
replace SB_hrs= 0 if s3q6==2
replace wage_hrs= 0 if s3q4==2



foreach var in farm_work SOB_work wage_work farm_hrs SB_hrs wage_hrs ind_ag ind_const ind_fish ind_manuf ind_mining ind_serv {
replace `var' = 0 if working_age==0
}


keep ID hhid  farm_work SOB_work wage_work farm_hrs SB_hrs wage_hrs ind_ag ind_const ind_fish ind_manuf ind_mining ind_serv working_age
duplicates drop
save "${temping}/labor.dta", replace
*/
// education

use "${Nigeria_GHS_W4_raw_data}\\${indiv_roster1}", clear

egen ID = concat (hhid indiv), punct("-")

recode s2q6 ( 1 = 1 "Yes") ( 2 = 0 "No"), gen(formal_education1) label(formal_education1)
recode s2q9 (0/15 51/61 98 99 = 0 "No" ) (16/43 321/424 = 1 "Yes"), gen(primary_education1) label(primary_education1)
replace primary_education1 = 0 if formal_education1==0

egen formal_education = rowmax(formal_education1 )
egen primary_education = rowmax( primary_education1)
keep ID hhid formal_education primary_education
duplicates drop
save "${temping}/educ_indiv.dta", replace



// HDDS 
use "${Nigeria_GHS_W4_raw_data}\\${HDDS}", clear

keep if s5bq1 ==1 // keep if consumed
rename item_cd food_id

gen A = food_id>=10 & food_id<=29
gen B = food_id>=30 & food_id<=38
gen C = food_id>=70 & food_id<=79
gen D = food_id>=60 & food_id<=69
gen E = food_id>=80 & food_id<=82 | food_id>=90 & food_id<=96
gen F = food_id>=83 & food_id<=85
gen G = food_id>=100 & food_id<=107
gen H = food_id>=40 & food_id<=48
gen I = food_id>=110 & food_id<=115
gen J = food_id>=50 & food_id<=56
gen K = food_id>=130 & food_id<=133
gen L = food_id>=120 & food_id<=122 | food_id>=141 & food_id<=148

collapse (max) A B C D E F G H I J K L, by(hhid)
egen HDDS = rowtotal(A B C D E F G H I J K L), missing 

merge 1:m hhid  using "${Nigeria_GHS_W4_raw_data}\\${HDDS}", 
collapse (max) HDDS, by(hhid)
replace HDDS = 0 if HDDS==.
save "${temping}/HDDS.dta", replace








*********************************************************************************
*Merging Datasets
*********************************************************************************


**********************************************************
**** B) Create plot-crop datasets
**********************************************************


use "${temping}/plot_crop_frame.dta", clear
duplicates drop
merge m:1 hhid using "${temping}/strataid.dta", keep(master match) nogen
merge m:1 hhid using "${temping}/weights.dta", keep(master match) nogen
merge m:1 hhid using "${temping}/admin1.dta", keep(master match) nogen
merge m:1 hhid using "${temping}/admin2.dta", keep(master match) nogen
merge m:1 hhid using "${temping}/admin3.dta", keep(master match) nogen
merge m:1 hhid  using "${temping}/urban.dta", keep(master match) nogen
*merge m:1 hhid  using "${temping}/Coords.dta", keep(master match) nogen
*merge m:1 lat_modified lon_modified  using "${temping}/geocoords_id.dta", keep(master match) nogen
merge 1:1 plot_id cropcode using "${temping}/harvest_kg.dta", keep(master match) nogen
merge 1:1 plot_id cropcode using "${temping}/harvest_value.dta", keep(master match) nogen
drop main_crop // added later
*merge 1:1 plot_id cropcode using "${temping}/harvest_end_month.dta", keep(master match) nogen
*merge 1:1 plot_id cropcode using "${temping}/planting_month.dta", keep(master match) nogen
merge 1:1 plot_id cropcode using "${temping}/seed_kg_merge.dta", keep(master match) nogen
merge 1:1 plot_id cropcode using "${temping}/seed_value.dta" , keep(master match) nogen
merge 1:1 plot_id cropcode using "${temping}/improved.dta" , keep(master match) nogen
merge m:1 plot_id  using "${temping}/used_pesticides.dta", keep(master match) nogen
*merge 1:1 plot_id cropcode using "${temping}/crop_shock.dta", keep(master match) nogen


rename cropcode crop_code

preserve
foreach var in  harvest_sold_kg  {
capture drop `var'
}  

gen year = 2023
sort plot_id crop_code
*tostring hh_id_merge, replace
save "${temping}/NGA_FINAL_plotcrop5.dta", replace
restore


**********************************************************
**** C) Create plot datasets
**********************************************************

*ea_id
	local improved improved


collapse (sum) harvest_kg harvest_value  seed_kg  seed_value (count) n_harvest_kg = harvest_kg n_harvest_value=harvest_value n_seed_kg = seed_kg  n_seed_value =seed_value (max) `improved' used_pesticides , by(plot_id   pw strataid admin_1 admin_1_name admin_2  admin_3 hhid )

foreach var in  harvest_kg harvest_value seed_kg  seed_value {
	replace `var' = . if n_`var'==0
}



merge 1:1 plot_id  using "${temping}/intercropped.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/nb_seasonal_crop.dta", keep(master match) nogen
*merge 1:1 plot_id  using "${temping}/main_crop.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/plot_area.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/labor_days.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/inorganic_fertilizer.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/nitrogen_kg.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/inorganic_fertilizer_value.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/organic_fertilizer.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/Manager_characteristics1.dta", keep(master match) nogen
*merge 1:1 plot_id  using "${temping}/Manager_characteristics1_ID.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/Manager_characteristics2.dta", keep(master match) nogen
merge m:1 hhid  using "${temping}/Respondent_characteristics1.dta", keep(master match) nogen
*merge m:1 hhid  using "${temping}/Respondent_characteristics1_ID.dta", keep(master match) nogen
merge m:1 hhid  using "${temping}/Resp_characteristics2.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/irrigated.dta", keep(master match) nogen
merge 1:1 plot_id  using "${temping}/erosion_protection.dta", keep(master match) nogen

merge m:1 hhid  using "${temping}/tractor.dta", keep(master match) nogen
merge m:1 plot_id   using "${temping}/plot_owned.dta", keep(master match) nogen
merge m:1 hhid  using "${temping}/livestock.dta", keep(master match) nogen
*merge m:1 hhid  using "${temping}/harvest_interview_month.dta", keep(master match) nogen
*merge m:1 hhid  using "${temping}/planting_interview_month.dta", keep(master match) nogen
merge m:1 hhid  using "${temping}/urban.dta", keep(master match) nogen
merge m:1 hhid  using "${temping}/ag_asset_index.dta", keep(master match) nogen
/*merge m:1 hhid  using "${temping}/aez.dta", keep(master match) nogen
merge m:1 hhid  using "${temping}/dist_popcenter.dta", keep(master match) nogen
merge m:1 hhid  using "${temping}/dist_market.dta", keep(master match) nogen
merge m:1 plot_id  using "${temping}/elevation.dta", keep(master match) nogen
merge m:1 plot_id  using "${temping}/twi.dta", keep(master match) nogen
merge m:1 hhid  using "${temping}/soil.dta", keep(master match) nogen
merge m:1 hhid  using "${temping}/Coords.dta", keep(master match) nogen
*merge m:1 lat_modified lon_modified  using "${temping}/geocoords_id.dta", keep(master match) nogen
merge m:1 plot_id  using "${temping}/plot_slope.dta", keep(master match) nogen

merge m:1 hhid  using "${temping}/popdensity.dta", keep(master match) nogen	
*/
// calculate yields
gen yield_kg = harvest_kg/plot_area_GPS
gen yield_value = harvest_value/plot_area_GPS

// harmonise IDS
*tostring hh_id_merge, replace
foreach var in  UREA_kg NPK_kg other_kg n_nitrogen_kg n_NPK_kg n_UREA_kg n_other_kg    harvest_sold_kg  n_harvest_kg n_harvest_value n_seed_value n_seed_kg manager_id respondent_id ID_worker* {
capture drop `var'
}  
order hhid plot_id

gen year = 2023
sort hhid plot_id

*define_labels

save "${temping}/NGA_FINAL_plot5.dta", replace


**********************************************************
**** D) Create household datasets
**********************************************************



use "${temping}/hh_frame.dta", clear

merge 1:1 hhid using "${temping}/strataid.dta", keep(master match) nogen
merge 1:1 hhid using "${temping}/admin1.dta", keep(master match) nogen
merge 1:1 hhid using "${temping}/admin2.dta", keep(master match) nogen
merge 1:1 hhid using "${temping}/admin3.dta", keep(master match) nogen
merge 1:1 hhid using "${temping}/urban.dta", keep(master match) nogen
merge 1:1 hhid using "${temping}/weights.dta", keep(master match) nogen
*merge 1:1 hhid using "${temping}/Coords.dta", keep(master match) nogen
*merge m:1 lat_modified lon_modified  using "${temping}/geocoords_id.dta", keep(master match) nogen
merge 1:1 hhid using "${temping}/hh_primary_education.dta", keep(master match) nogen
*merge 1:1 hhid using "${temping}/hh_electricity_access.dta", keep(master match) nogen
merge 1:1 hhid using "${temping}/hh_dependency_ratio.dta", keep(master match) nogen
*merge 1:1 hhid using "${temping}/cons_quint.dta", keep(master match) nogen
*merge 1:1 hhid using "${temping}/totcons.dta", keep(master match) nogen			
*merge 1:1 hhid using "${temping}/shock.dta", keep(master match) nogen
*merge 1:1 hhid using "${temping}/hh_asset_index.dta", keep(master match) nogen
merge 1:1 hhid using "${temping}/size.dta", keep(master match) nogen
*merge 1:1 hhid  using "${temping}/hh_asset_index.dta", keep(master match) nogen
merge 1:1 hhid  using "${temping}/nfe.dta", keep(master match) nogen
merge 1:1 hhid  using "${temping}/HDDS.dta", keep(master match) nogen
merge 1:1 hhid  using "${temping}/nb_fallow_plots.dta", keep(master match) nogen
merge 1:1 hhid   using "${temping}/nb_plots.dta", keep(master match) nogen
merge 1:1 hhid  using "${temping}/harvest_sold_kg_hh.dta", keep(master match) nogen

gen year = 2023
sort hhid
save "${temping}/NGA_FINAL_hh5.dta", replace

/*
// harmonise IDS
gen hh_id_merge = hhid

merge m:1 hh_id_merge wave using "${Temp}\\NGA\\Frame_hhIDs.dta", keep(master match) nogen
merge m:1 hh_id_merge wave using "${Temp}\\NGA\\ea_id_obs.dta", keep(master match) nogen
foreach var in hhid {
capture drop `var'
} 
define_labels
tostring hh_id_merge, replace
order hh_id_merge hh_id_obs 

}
*/


 


*****************Appending all Nigeria Datasets*****************
use "C:\Users\obine\Music\Documents\food_secure\NGA_FINAL_hh5.dta" ,clear
append using "C:\Users\obine\Music\Documents\food\NGA_FINAL_hh.dta"
order year

tabstat hhid strataid admin_1 hh_formal_education hh_primary_education hh_dependency_ratio hh_size nonfarm_enterprise HDDS nb_fallow_plots nb_plots share_kg_sold  [aweight = pw], statistics( mean median sd min max ) columns(statistics)

misstable summarize hhid strataid admin_1 hh_formal_education hh_primary_education hh_dependency_ratio hh_size nonfarm_enterprise HDDS nb_fallow_plots nb_plots share_kg_sold 

save "C:\Users\obine\Music\Documents\food_secure/Household", replace


gen dummy = 1

collapse (sum) dummy, by (hhid)
tab dummy
keep if dummy==2
sort hhid


merge 1:m hhid using "C:\Users\obine\Music\Documents\food_secure/Household"

drop if _merge==2



gen year_2018 = (year==2018)
gen year_2023 = (year==2023)



tabstat hhid strataid admin_1 hh_formal_education hh_primary_education hh_dependency_ratio hh_size nonfarm_enterprise HDDS nb_fallow_plots nb_plots share_kg_sold  [aweight = pw], statistics( mean median sd min max ) columns(statistics)

misstable summarize hhid strataid admin_1 hh_formal_education hh_primary_education hh_dependency_ratio hh_size nonfarm_enterprise HDDS nb_fallow_plots nb_plots share_kg_sold 
save "C:\Users\obine\Music\Documents\food_secure/complete/Household23", replace







************************
*Plot Level
************************



*****************Appending all Nigeria Datasets*****************
use "C:\Users\obine\Music\Documents\food_secure\NGA_FINAL_plot5.dta" ,clear
append using "C:\Users\obine\Music\Documents\food\NGA_FINAL_plot.dta"
order year

tabstat harvest_kg harvest_value seed_kg seed_value improved used_pesticides intercropped nb_seasonal_crop plot_area_GPS farm_size total_labor_days total_hired_labor_days total_family_labor_days hired_labor_value inorganic_fertilizer nitrogen_kg inorganic_fertilizer_value organic_fertilizer age_manager female_manager married_manager formal_education_manager primary_education_manager age_respondent female_respondent married_respondent formal_education_respondent primary_education_respondent irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index yield_kg yield_value   [aweight = pw], statistics( mean median sd min max ) columns(statistics)

misstable summarize harvest_kg harvest_value seed_kg seed_value improved used_pesticides intercropped nb_seasonal_crop plot_area_GPS farm_size total_labor_days total_hired_labor_days total_family_labor_days hired_labor_value inorganic_fertilizer nitrogen_kg inorganic_fertilizer_value organic_fertilizer age_manager female_manager married_manager formal_education_manager primary_education_manager age_respondent female_respondent married_respondent formal_education_respondent primary_education_respondent irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index yield_kg yield_value  


save "C:\Users\obine\Music\Documents\food_secure/Plot", replace


gen dummy = 1

collapse (sum) dummy, by (plot_id)
tab dummy
keep if dummy==2
sort plot_id


merge 1:m plot_id using "C:\Users\obine\Music\Documents\food_secure/Plot"

drop if _merge==2



gen year_2018 = (year==2018)
gen year_2023 = (year==2023)




misstable summarize harvest_kg harvest_value seed_kg seed_value improved used_pesticides intercropped nb_seasonal_crop plot_area_GPS farm_size total_labor_days total_hired_labor_days total_family_labor_days hired_labor_value inorganic_fertilizer nitrogen_kg inorganic_fertilizer_value organic_fertilizer age_manager female_manager married_manager formal_education_manager primary_education_manager age_respondent female_respondent married_respondent formal_education_respondent primary_education_respondent irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index yield_kg yield_value 

save "C:\Users\obine\Music\Documents\food_secure/complete/Plot23", replace





*use "C:\Users\obine\Music\Documents\food_secure/Household23", clear
*tabstat hhid strataid admin_1 hh_formal_education hh_primary_education hh_dependency_ratio hh_size nonfarm_enterprise HDDS nb_fallow_plots nb_plots share_kg_sold  [aweight = pw], statistics( mean median sd min max ) columns(statistics)





use "C:\Users\obine\Music\Documents\food_secure/Plot23", clear


tabstat harvest_kg harvest_value seed_kg seed_value improved used_pesticides intercropped nb_seasonal_crop plot_area_GPS farm_size total_labor_days total_hired_labor_days total_family_labor_days hired_labor_value inorganic_fertilizer nitrogen_kg inorganic_fertilizer_value organic_fertilizer age_manager female_manager married_manager formal_education_manager primary_education_manager age_respondent female_respondent married_respondent formal_education_respondent primary_education_respondent irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index yield_kg yield_value   [aweight = pw], statistics( mean median sd min max ) columns(statistics)



gen nitrogen_rate = nitrogen_kg/plot_area_GPS
gen seed_rate = seed_kg/plot_area_GPS
gen inorganic_fertilizer_rate = inorganic_fertilizer/plot_area_GPS




keep yield_kg  nitrogen_rate   seed_rate  inorganic_fertilizer_rate  farm_size  improved used_pesticides intercropped organic_fertilizer age_manager female_manager married_manager formal_education_manager irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index plot_id pw hhid plot_area_GPS year

tabstat  yield_kg  nitrogen_rate   seed_rate  inorganic_fertilizer_rate  farm_size  improved used_pesticides intercropped organic_fertilizer age_manager female_manager married_manager formal_education_manager irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index [aweight = pw], statistics( mean median sd min max ) columns(statistics)


preserve

keep if year ==2018
tabstat  yield_kg  nitrogen_rate   seed_rate  inorganic_fertilizer_rate  farm_size  improved used_pesticides intercropped organic_fertilizer age_manager female_manager married_manager formal_education_manager irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index [aweight = pw], statistics( mean median sd min max ) columns(statistics)


restore


preserve

keep if year ==2023
tabstat  yield_kg  nitrogen_rate   seed_rate  inorganic_fertilizer_rate  farm_size  improved used_pesticides intercropped organic_fertilizer age_manager female_manager married_manager formal_education_manager irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index [aweight = pw], statistics( mean median sd min max ) columns(statistics)

restore


collapse (sum) yield_kg  nitrogen_rate   seed_rate  inorganic_fertilizer_rate plot_area_GPS (max) farm_size improved used_pesticides intercropped organic_fertilizer age_manager female_manager married_manager formal_education_manager irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index pw, by (hhid)

tabstat  yield_kg  nitrogen_rate   seed_rate  inorganic_fertilizer_rate  farm_size  improved used_pesticides intercropped organic_fertilizer age_manager female_manager married_manager formal_education_manager irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index [aweight = pw], statistics( mean median sd min max ) columns(statistics)


preserve

keep if year ==2018
tabstat  yield_kg  nitrogen_rate   seed_rate  inorganic_fertilizer_rate  farm_size  improved used_pesticides intercropped organic_fertilizer age_manager female_manager married_manager formal_education_manager irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index [aweight = pw], statistics( mean median sd min max ) columns(statistics)


restore


preserve

keep if year ==2023
tabstat  yield_kg  nitrogen_rate   seed_rate  inorganic_fertilizer_rate  farm_size  improved used_pesticides intercropped organic_fertilizer age_manager female_manager married_manager formal_education_manager irrigated erosion_protection tractor plot_owned plot_certificate livestock ag_asset_index [aweight = pw], statistics( mean median sd min max ) columns(statistics)

restore


save "C:\Users\obine\Music\Documents\food_secure/Household_refined23", replace
















