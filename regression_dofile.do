
* Generate interaction term
gen year2023 = (real_tpricefert_cens_mrk !=. & year == 2023)
gen price2023 = real_tpricefert_cens_mrk * year2023
gen mrk_dist_w23 = mrk_dist_w *year2023
gen fert_mrk_23 = mrk_dist_w *real_tpricefert_cens_mrk
gen t23 = real_tpricefert_cens_mrk * mrk_dist_w * year2023


//////////////////////////////////////Regression//////////////////////////////



*-----------------------------
* Triple DID regression without controls
*-----------------------------
* treatment dummy
gen year2023 = (year == 2023 & real_tpricefert_cens_mrk != .)

* two-way interactions
gen price2023   = real_tpricefert_cens_mrk * year2023
gen mrk_dist_w23 = mrk_dist_w * year2023
gen fert_mrk    = mrk_dist_w * real_tpricefert_cens_mrk

* triple interaction
gen t23 = real_tpricefert_cens_mrk * mrk_dist_w * year2023

reg peraeq_cons real_tpricefert_cens_mrk year2023 mrk_dist_w   price2023 mrk_dist_w23 fert_mrk t23, cluster(hhid)
eststo model1

reg peraeq_cons real_tpricefert_cens_mrk year2023 mrk_dist_w price2023 mrk_dist_w23 fert_mrk t23  real_maize_price_mr good fair total_qty real_hhvalue  field_size num_mem hh_headage femhead attend_sch worker, cluster(hhid)
eststo model2


reg peraeq_cons real_tpricefert_cens_mrk year2023 mrk_dist_w price2023 mrk_dist_w23 fert_mrk t23   real_maize_price_mr good fair total_qty real_hhvalue  field_size num_mem hh_headage femhead attend_sch worker i.zone, cluster(hhid)

areg peraeq_cons real_tpricefert_cens_mrk year2023 mrk_dist_w   price2023 mrk_dist_w23 fert_mrk t23  real_maize_price_mr good fair total_qty real_hhvalue  field_size num_mem hh_headage femhead attend_sch worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\Table_triple.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))



reg number_foodgroup real_tpricefert_cens_mrk year2023 mrk_dist_w   price2023 mrk_dist_w23 fert_mrk t23, cluster(hhid)
eststo model1

reg number_foodgroup real_tpricefert_cens_mrk year2023 mrk_dist_w price2023 mrk_dist_w23 fert_mrk t23  real_maize_price_mr good fair total_qty real_hhvalue  field_size num_mem hh_headage femhead attend_sch worker, cluster(hhid)
eststo model2


reg number_foodgroup real_tpricefert_cens_mrk year2023 mrk_dist_w price2023 mrk_dist_w23 fert_mrk t23   real_maize_price_mr good fair total_qty real_hhvalue  field_size num_mem hh_headage femhead attend_sch worker i.zone, cluster(hhid)

areg number_foodgroup real_tpricefert_cens_mrk year2023 mrk_dist_w   price2023 mrk_dist_w23 fert_mrk t23  real_maize_price_mr good fair total_qty real_hhvalue  field_size num_mem hh_headage femhead attend_sch worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\Table_triple2.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))














*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg peraeq_cons price2023 real_tpricefert_cens_mrk year2023  , cluster(hhid)
eststo model1
*no controls
reg peraeq_cons price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker, cluster(hhid)
eststo model2

* DID regression with controls + district fixed effects
reg peraeq_cons price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker i.zone, cluster(hhid)

areg peraeq_cons price2023 real_tpricefert_cens_mrk year2023  mrk_dist_w real_maize_price_mr good fair total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\Table05m.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))



//////////////////////////////////////Regression//////////////////////////////


*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg household_diet_cut_off2 price2023 real_tpricefert_cens_mrk year2023  , cluster(hhid)
eststo model1
*no controls
reg household_diet_cut_off2 price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker, cluster(hhid)
eststo model2

* DID regression with controls + district fixed effects
reg household_diet_cut_off2 price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker i.zone, cluster(hhid)

areg household_diet_cut_off2 price2023 real_tpricefert_cens_mrk year2023  mrk_dist_w real_maize_price_mr good fair total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\Table01m.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))



//////////////////////////////////////Regression//////////////////////////////


*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg number_foodgroup price2023 real_tpricefert_cens_mrk year2023  , cluster(hhid)
eststo model1
*no controls
reg number_foodgroup price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker, cluster(hhid)
eststo model2

* DID regression with controls + district fixed effects
reg number_foodgroup price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker i.zone, cluster(hhid)

areg number_foodgroup price2023 real_tpricefert_cens_mrk year2023  mrk_dist_w real_maize_price_mr good fair total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\Table02m.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))



//////////////////////////////////////Regression//////////////////////////////


*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg yield_plot price2023 real_tpricefert_cens_mrk year2023  , cluster(hhid)
eststo model1
*no controls
reg yield_plot price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker, cluster(hhid)
eststo model2

* DID regression with controls + district fixed effects
reg yield_plot price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker i.zone, cluster(hhid)

areg yield_plot price2023 real_tpricefert_cens_mrk year2023  mrk_dist_w real_maize_price_mr good fair total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\Table03m.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))



//////////////////////////////////////Regression//////////////////////////////


*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg productivity_w price2023 real_tpricefert_cens_mrk year2023  , cluster(hhid)
eststo model1
*no controls
reg productivity_w price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker, cluster(hhid)
eststo model2

* DID regression with controls + district fixed effects
reg productivity_w price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker i.zone, cluster(hhid)

areg productivity_w price2023 real_tpricefert_cens_mrk year2023  mrk_dist_w real_maize_price_mr good fair total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\Table04m.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))




///////////////////////////////////////////////////////Start////////////////////////////////////////////////////////////////////





















































***********************************************************************************************************************************************
*Merging Dataset
***********************************************************************************************************************************************

*******************************
*Household Level Dataset
*******************************
use  "C:\Users\obine\Music\Documents\food\evans/Nigeria_GHS_W4_all_plots.dta",clear

sort hhid plot_id
count
count if cropcode==1080
keep if cropcode==1080

order hhid plot_id cropcode quant_harv_kg value_harvest ha_harvest percent_inputs field_size purestand

collapse (sum) quant_harv_kg value_harvest ha_planted field_size (max) percent_inputs  purestand, by (hhid)
replace ha_planted = 9.5 if ha_planted >= 9.5 
replace field_size = 20 if field_size >= 20
ren value_harvest real_value_harvest
gen value_harvest  = real_value_harvest/0.4574889
tab value_harvest
replace value_harvest=  4695385 if value_harvest>= 4695385


merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/fert_units.dta", gen(fert)
merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/food_prices_2018.dta", gen (food)
merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/household_asset_2018.dta", gen (asset)
merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/weight.dta", nogen
merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/ag_rainy_18.dta", gen(filter)
merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/dieatary_diversity.dta", gen(diet)
merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/Nigeria_GHS_W4_consumption.dta", gen(exp)
merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/Nigeria_GHS_W4_hhsize.dta", gen(hh)
merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/soil_quality_2018.dta", gen(soil)
merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/demographics_2018.dta", gen(house)
merge 1:1 hhid using "C:\Users\obine\Music\Documents\food\evans/laborage_2018.dta", gen(work)


keep if ag_rainy_18==1
***********************Dealing with outliers*************************


gen year = 2018
tabstat ha_planted field_size quant_harv_kg value_harvest maize_price_mr real_maize_price_mr total_qty n_kg  tpricefert_cens_mrk real_tpricefert_cens_mrk  hhasset_value_w real_hhvalue [w=weight], statistics( mean median sd min max ) columns(statistics)
count
misstable summarize ha_planted field_size quant_harv_kg value_harvest maize_price_mr real_maize_price_mr total_qty n_kg  tpricefert_cens_mrk real_tpricefert_cens_mrk  hhasset_value_w real_hhvalue totcons_pc peraeq_cons total_cons mrk_dist_w num_mem hh_headage femhead attend_sch worker zone state lga ea



replace total_qty = 0 if total_qty==.
replace n_kg = 0 if n_kg ==.

/*
replace ha_planted = 0 if ha_planted==.
replace field_size = 0 if field_size ==.
replace value_harvest = 0 if value_harvest==.
replace quant_harv_kg = 0 if quant_harv_kg ==.
*/
egen medianfert_pr = median(real_tpricefert_cens_mrk)
egen medianfert_ = median(tpricefert_cens_mrk)
replace real_tpricefert_cens_mrk = medianfert_pr if real_tpricefert_cens_mrk ==. 

replace tpricefert_cens_mrk = medianfert_ if tpricefert_cens_mrk ==. 


egen medianmaize_pr = median(real_maize_price_mr)
egen medianmaize_ = median(maize_price_mr)

replace real_maize_price_mr = medianmaize_pr if real_maize_price_mr ==. 

replace maize_price_mr = medianmaize_ if maize_price_mr ==. 



egen medianfert_dist_ea = median(mrk_dist_w), by (ea)
egen medianfert_dist_lga = median(mrk_dist_w), by (lga)
egen medianfert_dist_state = median(mrk_dist_w), by (state)
egen medianfert_dist_zone = median(mrk_dist_w), by (zone)


replace mrk_dist_w = medianfert_dist_ea if mrk_dist_w ==. 
replace mrk_dist_w = medianfert_dist_lga if mrk_dist_w ==. 
replace mrk_dist_w = medianfert_dist_state if mrk_dist_w ==.

replace mrk_dist_w = medianfert_dist_zone if mrk_dist_w ==. 

misstable summarize ha_planted field_size quant_harv_kg value_harvest maize_price_mr real_maize_price_mr total_qty n_kg  tpricefert_cens_mrk real_tpricefert_cens_mrk  hhasset_value_w real_hhvalue totcons_pc peraeq_cons total_cons number_foodgroup mrk_dist_w num_mem hh_headage femhead attend_sch worker 



save "C:\Users\obine\Music\Documents\food\evans/checking.dta", replace



global Nigeria_GHS_W5_created_data  "C:\Users\obine\Music\Documents\food_secure\evans"

use "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_all_plots.dta",clear

sort hhid 
count
count if cropcode==1080
keep if cropcode==1080

order hhid plot_id cropcode quant_harv_kg value_harvest ha_harvest percent_inputs field_size purestand

collapse (sum) quant_harv_kg value_harvest ha_planted field_size (max) percent_inputs  purestand, by (hhid)
replace ha_planted = 9 if ha_planted >= 9 
replace field_size = 22 if field_size >= 22
replace value_harvest=  4695385 if value_harvest>= 4695385

merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/fert_units.dta", gen(fert)
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/food_prices_2023.dta", gen(food)
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}\household_asset_2023.dta", gen(asset)
merge 1:1 hhid using  "${Nigeria_GHS_W5_created_data}/hhids.dta", nogen
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/ag_rainy_18.dta", gen(filter)
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/dieatary_diversity.dta", gen(diet)
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_consumption.dta", gen(exp)
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_hhsize.dta", gen(hh)
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/soil_quality_2023.dta", gen(soil)
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/demographics_2023.dta", gen(house)
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/laborage_2023.dta", gen(work)



keep if ag_rainy_23==1
gen year =2023
***********************Dealing with outliers*************************

tabstat ha_planted field_size quant_harv_kg value_harvest maize_price_mr real_maize_price_mr total_qty n_kg  tpricefert_cens_mrk real_tpricefert_cens_mrk  hhasset_value_w real_hhvalue number_foodgroup soil_qty_rev2 [w=weight], statistics( mean median sd min max ) columns(statistics)
count
misstable summarize ha_planted field_size quant_harv_kg value_harvest maize_price_mr real_maize_price_mr total_qty n_kg  tpricefert_cens_mrk real_tpricefert_cens_mrk  hhasset_value_w real_hhvalue totcons_pc peraeq_cons total_cons hh_members number_foodgroup soil_qty_rev2 mrk_dist_w num_mem hh_headage femhead attend_sch worker zone state lga ea


replace total_qty = 0 if total_qty==.
replace n_kg = 0 if n_kg ==.

/*
replace ha_planted = 0 if ha_planted==.
replace field_size = 0 if field_size ==.
replace value_harvest = 0 if value_harvest==.
replace quant_harv_kg = 0 if quant_harv_kg ==.
*/
egen medianfert_pr = median(real_tpricefert_cens_mrk)
egen medianfert_ = median(tpricefert_cens_mrk)

replace real_tpricefert_cens_mrk = medianfert_pr if real_tpricefert_cens_mrk ==. 

replace tpricefert_cens_mrk = medianfert_ if tpricefert_cens_mrk ==. 

egen medianmaize_pr = median(real_maize_price_mr)
egen medianmaize_ = median(maize_price_mr)

replace real_maize_price_mr = medianmaize_pr if real_maize_price_mr ==. 

replace maize_price_mr = medianmaize_ if maize_price_mr ==. 


egen medianfert_dist_ea = median(mrk_dist_w), by (ea)
egen medianfert_dist_lga = median(mrk_dist_w), by (lga)
egen medianfert_dist_state = median(mrk_dist_w), by (state)
egen medianfert_dist_zone = median(mrk_dist_w), by (zone)


replace mrk_dist_w = medianfert_dist_ea if mrk_dist_w ==. 
replace mrk_dist_w = medianfert_dist_lga if mrk_dist_w ==. 
replace mrk_dist_w = medianfert_dist_state if mrk_dist_w ==.

replace mrk_dist_w = medianfert_dist_zone if mrk_dist_w ==. 


misstable summarize ha_planted field_size quant_harv_kg value_harvest maize_price_mr real_maize_price_mr total_qty n_kg  tpricefert_cens_mrk real_tpricefert_cens_mrk  hhasset_value_w real_hhvalue totcons_pc peraeq_cons total_cons hh_members number_foodgroup soil_qty_rev2 mrk_dist_w num_mem hh_headage femhead attend_sch worker

append using "C:\Users\obine\Music\Documents\food\evans/checking.dta"


save "C:\Users\obine\Music\Documents\food\evans/apppend.dta", replace


use "C:\Users\obine\Music\Documents\food\evans/apppend.dta", clear

order year


gen dummy = 1

collapse (sum) dummy, by (hhid)
tab dummy
keep if dummy==2


merge 1:m hhid  using "C:\Users\obine\Music\Documents\food\evans/apppend.dta", gen(fil)

drop if fil==2

order year

sort hhid  year

misstable summarize ha_planted field_size quant_harv_kg value_harvest maize_price_mr real_maize_price_mr total_qty n_kg  tpricefert_cens_mrk real_tpricefert_cens_mrk  hhasset_value_w real_hhvalue totcons_pc peraeq_cons total_cons hh_members number_foodgroup soil_qty_rev2 mrk_dist_w num_mem hh_headage femhead attend_sch worker zone state lga ea


*tab if ha_planted == 0 | ha_planted == .
drop if ha_planted == 0 | ha_planted == .

gen yield_plot =  quant_harv_kg/ ha_planted
gen fert_rate = total_qty/ ha_planted
gen n_rate = n_kg/ field_size
gen productivity = value_harvest/ ha_planted
foreach v of varlist  productivity  {
	_pctile `v' , p(5 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}
/////real variables

gen input_ratio =  real_tpricefert_cens_mrk/real_maize_price_mr
gen output_ratio =  real_maize_price_mr/ real_tpricefert_cens_mrk
gen good = (soil_qty_rev2 ==1)
gen fair = (soil_qty_rev2==2)
gen poor = (soil_qty_rev2==3)
gen good_soil_plant = ha_planted if ha_planted !=. & good==1
gen fair_soil_plant = ha_planted if ha_planted !=. & fair==1
gen poor_soil_plant = ha_planted if ha_planted !=. & poor==1



misstable summarize ha_planted field_size quant_harv_kg yield_plot value_harvest maize_price_mr real_maize_price_mr total_qty n_kg n_rate tpricefert_cens_mrk real_tpricefert_cens_mrk  hhasset_value_w real_hhvalue productivity productivity_w household_diet_cut_off1 household_diet_cut_off2 totcons_pc peraeq_cons total_cons hh_members number_foodgroup input_ratio output_ratio soil_qty_rev2 good fair poor mrk_dist_w num_mem hh_headage femhead attend_sch worker
preserve

keep if year ==2018
tabstat ha_planted field_size quant_harv_kg yield_plot value_harvest maize_price_mr real_maize_price_mr total_qty n_kg n_rate tpricefert_cens_mrk real_tpricefert_cens_mrk  hhasset_value_w real_hhvalue productivity productivity_w household_diet_cut_off1 household_diet_cut_off2 totcons_pc peraeq_cons total_cons hh_members number_foodgroup input_ratio output_ratio soil_qty_rev2 good fair poor good_soil_plant fair_soil_plant poor_soil_plant mrk_dist_w num_mem hh_headage femhead attend_sch worker [w=weight], statistics( mean median sd min max ) columns(statistics)
count
restore


preserve

keep if year ==2023
tabstat ha_planted field_size quant_harv_kg yield_plot value_harvest maize_price_mr real_maize_price_mr total_qty n_kg n_rate tpricefert_cens_mrk real_tpricefert_cens_mrk  hhasset_value_w real_hhvalue productivity productivity_w household_diet_cut_off1 household_diet_cut_off2 totcons_pc peraeq_cons total_cons hh_members number_foodgroup input_ratio output_ratio soil_qty_rev2 good fair poor good_soil_plant fair_soil_plant poor_soil_plant mrk_dist_w num_mem hh_headage femhead attend_sch worker [w=weight], statistics( mean median sd min max ) columns(statistics)
count
restore

gen commercial_dummy = (total_qty >0)
//% of HHs that bought commercial fertilizer by each survey wave
bysort year : tabstat commercial_dummy [w=weight], stat(mean sem) //

// By HH, sum the binary variable of commerical fert market particapation for all waves
bysort hhid : egen sum_4waves_com_fer_bin = sum(commercial_dummy) 


**********************************
ttest household_diet_cut_off2, by(year) unequal
ttest number_foodgroup, by(year) unequal
ttest totcons_pc, by(year) unequal
ttest peraeq_cons, by(year) unequal
ttest ha_planted, by(year) unequal
ttest field_size, by(year) unequal
ttest quant_harv_kg, by(year) unequal
ttest yield_plot, by(year) unequal
ttest value_harvest, by(year) unequal
ttest productivity_w, by(year) unequal
ttest maize_price_mr, by(year) unequal
ttest real_maize_price_mr, by(year) unequal
ttest input_ratio, by(year) unequal
ttest total_qty, by(year) unequal
ttest n_kg, by(year) unequal
ttest n_rate, by(year) unequal
ttest tpricefert_cens_mrk, by(year) unequal
ttest real_tpricefert_cens_mrk, by(year) unequal
ttest good, by(year) unequal
ttest fair, by(year) unequal
ttest poor, by(year) unequal
ttest good_soil_plant, by(year) unequal
ttest fair_soil_plant, by(year) unequal
ttest poor_soil_plant, by(year) unequal
ttest hh_members, by(year) unequal
ttest hhasset_value_w, by(year) unequal



//yield_plot  quant_harv_kg productivity_w household_diet_cut_off2 peraeq_cons number_foodgroup
 


* Generate interaction term
gen year2023 = (real_tpricefert_cens_mrk !=. & year == 2023)
gen price2023 = real_tpricefert_cens_mrk * year2023
gen mrk_dist_w23 = mrk_dist_w *year2023
gen fert_mrk_23 = mrk_dist_w *real_tpricefert_cens_mrk
gen t23 = real_tpricefert_cens_mrk * mrk_dist_w * year2023


//////////////////////////////////////Regression//////////////////////////////


