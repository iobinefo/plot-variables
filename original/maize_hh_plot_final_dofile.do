



local time_avg "mrk_dist_w23  year2023  mrk_dist_w  real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker real_tpricefert_cens_mrk n_rate_w"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


local time_avg " n_rate_w good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope"

foreach x in `time_avg' {

	bysort hhid : egen TAvg_`x' = mean(`x')

}


************************************************************************************************************************
*Model Specification Using Distance 
************************************************************************************************************************
use "C:\Users\obine\Music\Documents\food_secure\dofile\maize2_farm_dofile.dta", clear

*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg peraeq_cons mrk_dist_w23  year2023 mrk_dist_w TAvg_mrk_dist_w , cluster(hhid)
eststo model1
*no controls
reg peraeq_cons mrk_dist_w23  year2023  mrk_dist_w  real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty TAvg_real_hhvalue TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, cluster(hhid)
eststo model2


areg peraeq_cons mrk_dist_w23  year2023  mrk_dist_w  real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty TAvg_real_hhvalue TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\MarketTable01.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))








*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg number_foodgroup mrk_dist_w23  year2023 mrk_dist_w  TAvg_mrk_dist_w, cluster(hhid)
eststo model1
*no controls
reg number_foodgroup mrk_dist_w23  year2023  mrk_dist_w  real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty TAvg_real_hhvalue TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, cluster(hhid)
eststo model2

areg number_foodgroup mrk_dist_w23  year2023  mrk_dist_w  real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty TAvg_real_hhvalue TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\MarketTable02.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************




************************************************************************************************************************
*Model Specification Using Fertilizer Prices
************************************************************************************************************************
use "C:\Users\obine\Music\Documents\food_secure\dofile\maize_farm_dofile.dta", clear
*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg peraeq_cons price2023 real_tpricefert_cens_mrk year2023 TAvg_real_tpricefert_cens_mrk , cluster(hhid)
eststo model1
*no controls
reg peraeq_cons price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem  hh_headage femhead attend_sch worker TAvg_real_tpricefert_cens_mrk TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty TAvg_real_hhvalue TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, cluster(hhid)
eststo model2

areg peraeq_cons price2023 real_tpricefert_cens_mrk year2023  mrk_dist_w real_maize_price_mr good fair total_qty real_hhvalue field_size num_mem  hh_headage femhead attend_sch worker TAvg_real_tpricefert_cens_mrk TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty TAvg_real_hhvalue TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\fertTable01.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))


//////////////////////////////////////Regression//////////////////////////////


*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg number_foodgroup price2023 real_tpricefert_cens_mrk year2023 TAvg_real_tpricefert_cens_mrk , cluster(hhid)
eststo model1
*no controls
reg number_foodgroup price2023 real_tpricefert_cens_mrk year2023   mrk_dist_w real_maize_price_mr good fair  total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker TAvg_real_tpricefert_cens_mrk TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty TAvg_real_hhvalue TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, cluster(hhid)
eststo model2

areg number_foodgroup price2023 real_tpricefert_cens_mrk year2023  mrk_dist_w real_maize_price_mr good fair total_qty real_hhvalue field_size num_mem hh_headage femhead attend_sch worker TAvg_real_tpricefert_cens_mrk TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty TAvg_real_hhvalue TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\fertTable02.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************







************************************************************************************************************************
*Model Specification Using hhasset_value_w
************************************************************************************************************************

use "C:\Users\obine\Music\Documents\food_secure\dofile\maize2_farm_dofile.dta", clear

*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg peraeq_cons real_hhvalue_23  year2023 real_hhvalue TAvg_real_hhvalue , cluster(hhid)
eststo model1
*no controls
reg peraeq_cons real_hhvalue_23  year2023  real_hhvalue  mrk_dist_w  real_maize_price_mr good fair  total_qty  field_size num_mem hh_headage femhead attend_sch worker TAvg_real_hhvalue  TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty  TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, cluster(hhid)
eststo model2

areg peraeq_cons real_hhvalue_23  year2023 real_hhvalue mrk_dist_w  real_maize_price_mr good fair  total_qty  field_size num_mem hh_headage femhead attend_sch worker TAvg_real_hhvalue  TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty  TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\AssetTable01.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))








*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg number_foodgroup real_hhvalue_23  year2023 real_hhvalue TAvg_real_hhvalue, cluster(hhid)
eststo model1
*no controls
reg number_foodgroup real_hhvalue_23  year2023  real_hhvalue  mrk_dist_w  real_maize_price_mr good fair  total_qty  field_size num_mem hh_headage femhead attend_sch worker TAvg_real_hhvalue  TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty  TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, cluster(hhid)
eststo model2

areg number_foodgroup real_hhvalue_23  year2023 real_hhvalue mrk_dist_w  real_maize_price_mr good fair  total_qty  field_size num_mem hh_headage femhead attend_sch worker TAvg_real_hhvalue  TAvg_mrk_dist_w  TAvg_real_maize_price_mr TAvg_good TAvg_fair  TAvg_total_qty  TAvg_field_size TAvg_num_mem TAvg_hh_headage TAvg_femhead TAvg_attend_sch TAvg_worker, absorb(zone) cluster(hhid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\AssetTable02.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))

*********************************************************************************************************************************************************
*********************************************************************************************************************************************************





************************************************************************************************************************
*Model Specification Using Nitrogen
************************************************************************************************************************
use "C:\Users\obine\Music\Documents\food_secure\dofile\maize_plot_dofile.dta", clear



*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg yield_plot n_rate_w year2023 nitrogen2  TAvg_n_rate_w , cluster(plotid)
eststo model1
*no controls
reg yield_plot n_rate_w year2023 nitrogen2  good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope TAvg_n_rate_w TAvg_good TAvg_fair  TAvg_ha_planted TAvg_herbicide TAvg_pesticide TAvg_org_fert TAvg_irrigation TAvg_flat_slope TAvg_slope_slope, cluster(plotid)
eststo model2

* DID regression with controls + district fixed effects
areg yield_plot n_rate_w nitrogen2 year2023 good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope TAvg_n_rate_w TAvg_good TAvg_fair  TAvg_ha_planted TAvg_herbicide TAvg_pesticide TAvg_org_fert TAvg_irrigation TAvg_flat_slope TAvg_slope_slope, absorb(zone) cluster(plotid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\NitrogenTable01.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))






*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg productivity_w n_rate_w nitrogen2 year2023  , cluster(plotid)
eststo model1
*no controls
reg productivity_w n_rate_w nitrogen2 year2023 good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope, cluster(plotid)
eststo model2

* DID regression with controls + district fixed effects
areg productivity_w n_rate_w nitrogen2 year2023 good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope , absorb(zone) cluster(plotid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\NitrogenTable02.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))










*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg lproductivity_w n_rate_w nitrogen2 year2023  , cluster(plotid)
eststo model1
*no controls
reg lproductivity_w n_rate_w nitrogen2 year2023 good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope, cluster(plotid)
eststo model2

* DID regression with controls + district fixed effects
areg lproductivity_w n_rate_w nitrogen2 year2023 good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope , absorb(zone) cluster(plotid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\NitrogenTable03.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))



**************************************************************************************************************************************************************************************************************************************************************************************************************************







************************************************************************************************************************
*Model Specification Using Nitrogen Interaction
************************************************************************************************************************
use "C:\Users\obine\Music\Documents\food_secure\dofile\maize_plot_dofile.dta", clear



*-----------------------------
* DID regression without controls
*-----------------------------
eststo clear
reg yield_plot n_rate_w nitrogen2  year2023 nitrogen223 nitrogen23, cluster(plotid)
eststo model1
*no controls
reg yield_plot n_rate_w nitrogen2  year2023 nitrogen223 nitrogen23 good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope, cluster(plotid)
eststo model2

* DID regression with controls + district fixed effects
areg yield_plot n_rate_w nitrogen2  year2023 nitrogen223 nitrogen23 good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope , absorb(zone) cluster(plotid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\NitrogenTable05.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))



*-----------------------------
* Interaction
*-----------------------------
eststo clear
reg productivity_w n_rate_w nitrogen2  year2023 nitrogen223 nitrogen23, cluster(plotid)
eststo model1
*no controls
reg productivity_w n_rate_w nitrogen2  year2023 nitrogen223 nitrogen23 good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope, cluster(plotid)
eststo model2

* DID regression with controls + district fixed effects
areg productivity_w n_rate_w nitrogen2  year2023 nitrogen223 nitrogen23 good fair  ha_planted herbicide pesticide org_fert irrigation flat_slope slope_slope , absorb(zone) cluster(plotid)
eststo model3
*-----------------------------
* Export all results into one DOCX file
*-----------------------------
esttab m* using "C:\Users\obine\Music\Documents\Project_25\NitrogenTable06.regression.rtf", label replace cells(b(star fmt(%9.2f)) se(par fmt(%9.2f)))






**************************************************************************************************************************************************************************************************************************************************************************************************************************







