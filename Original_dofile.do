/*********************************************************************************
* LSMS-ISA Harmonised Panel Analysis Code                                        *
* Description: Extract data for GHS4          *
* Date: December 2023                                                            *
* -------------------------------------------------------------------------------*
*/

***************************************************
*starting
***************************************************


global Nigeria_GHS_W5_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2023_GHSP-W5_v01_M_Stata (1)"
global Nigeria_GHS_W5_created_data  "C:\Users\obine\Music\Documents\food_secure\evans"





********************************************************************************
* AG FILTER *
********************************************************************************

use  "${Nigeria_GHS_W5_raw_data}/secta_plantingw5.dta", clear

keep hhid ag1
rename (ag1) (ag_rainy_18)
save  "${Nigeria_GHS_W5_created_data}/ag_rainy_18.dta", replace


********************************************************************************
* WEIGHTS *
********************************************************************************

use "${Nigeria_GHS_W5_raw_data}/secta_plantingw5.dta" , clear

gen rural = (sector==2)
lab var rural "1= Rural"
keep hhid zone state lga ea wt_wave5 rural
ren wt_wave5 weight
duplicates report hhid

save  "${Nigeria_GHS_W5_created_data}/hhids.dta", replace




********************************************************************************
* PLOT AREAS *
********************************************************************************
*starting with planting
//ALT IMPORTANT NOTE: As of w5, the implied area conversions for farmer estimated units (including hectares) are markedly different from previous waves. I recommend excluding plots that do not have GPS measured areas from any area-based productivity estimates.
use "${Nigeria_GHS_W5_raw_data}/sect11a1_plantingw5.dta", clear
*merging in planting section to get cultivated status
merge 1:1 hhid plotid using "${Nigeria_GHS_W5_raw_data}/sect11b1_plantingw5.dta", nogen
*merging in harvest section to get areas for new plots
merge 1:1 hhid plotid using "${Nigeria_GHS_W5_raw_data}/secta1_harvestw5.dta", gen(plot_merge)
merge m:1 hhid using "${Nigeria_GHS_W5_created_data}/hhids.dta", nogen keep( 3)
ren s11aq3_number area_size
ren s11aq3_unit area_unit
ren sa1q1c area_size2 //GPS measurement, no units in file
//ren sa1q9b area_unit2 //Not in file
ren s11mq3 area_meas_sqm
//ren sa1q9c area_meas_sqm2
gen cultivate = sa1q1a ==1 
*assuming new plots are cultivated
//replace cultivate = 1 if sa1q1aa==1
//replace cultivate = 1 if sa1q3==1 //ALT: This has changed to respondent ID for w5
*using conversion factors from LSMS-ISA Nigeria Wave 2 Basic Information Document (Wave 3 unavailable, but Waves 1 & 2 are identical) 
*found at http://econ.worldbank.org/WBSITE/EXTERNAL/EXTDEC/EXTRESEARCH/EXTLSMS/0,,contentMDK:23635560~pagePK:64168445~piPK:64168309~theSitePK:3358997,00.html
*General Conversion Factors to Hectares
//		Zone   Unit         Conversion Factor
//		All    Plots        0.0667
//		All    Acres        0.4
//		All    Hectares     1
//		All    Sq Meters    0.0001
// 	    All	   100x100 sq ft 0.09290304
//      All    100x50 sq ft  0.04645152
//      All    Football field 0.721159848  //According to FIFA, a standard football field is 110-120 yards long and 70-80 yards wide (roughly 8625 sq yd)

*Zone Specific Conversion Factors to Hectares
//		Zone           Conversion Factor
//				 Heaps      Ridges      Stands
//		1 		 0.00012 	0.0027 		0.00006
//		2 		 0.00016 	0.004 		0.00016
//		3 		 0.00011 	0.00494 	0.00004
//		4 		 0.00019 	0.0023 		0.00004
//		5 		 0.00021 	0.0023 		0.00013
//		6  		 0.00012 	0.00001 	0.00041


*farmer reported field size for post-planting
gen field_size= area_size if area_unit==6
replace field_size = area_size*0.0667 if area_unit==4									//reported in plots
replace field_size = area_size*0.404686 if area_unit==5		    						//reported in acres
replace field_size = area_size*0.0001 if area_unit==7									//reported in square meters
replace field_size = area_size*0.09290304 if area_unit==8
replace field_size = area_size*0.04645152 if area_unit==9
replace field_size = area_size*0.721159848 if area_unit==10

replace field_size = area_size*0.00012 if area_unit==1 & zone==1						//reported in heaps
replace field_size = area_size*0.00016 if area_unit==1 & zone==2
replace field_size = area_size*0.00011 if area_unit==1 & zone==3
replace field_size = area_size*0.00019 if area_unit==1 & zone==4
replace field_size = area_size*0.00021 if area_unit==1 & zone==5
replace field_size = area_size*0.00012 if area_unit==1 & zone==6

replace field_size = area_size*0.0027 if area_unit==2 & zone==1							//reported in ridges
replace field_size = area_size*0.004 if area_unit==2 & zone==2
replace field_size = area_size*0.00494 if area_unit==2 & zone==3
replace field_size = area_size*0.0023 if area_unit==2 & zone==4
replace field_size = area_size*0.0023 if area_unit==2 & zone==5
replace field_size = area_size*0.00001 if area_unit==2 & zone==6

replace field_size = area_size*0.00006 if area_unit==3 & zone==1						//reported in stands
replace field_size = area_size*0.00016 if area_unit==3 & zone==2
replace field_size = area_size*0.00004 if area_unit==3 & zone==3
replace field_size = area_size*0.00004 if area_unit==3 & zone==4
replace field_size = area_size*0.00013 if area_unit==3 & zone==5
replace field_size = area_size*0.00041 if area_unit==3 & zone==6

/*ALT 02.23.23*/ gen area_est = field_size
*replacing farmer reported with GPS if available
gen area_meas_hectares =  area_meas_sqm*0.0001 if area_meas_sqm!=.  & area_meas_sqm!=0
replace field_size=area_meas_hectares if area_meas_hectares!=.
        				
gen gps_meas = (area_meas_sqm!=. & area_meas_sqm !=0)
la var gps_meas "Plot was measured with GPS, 1=Yes"
ren plotid plot_id
/*
if $drop_unmeas_plots !=0 {
	drop if gps_meas == 0
}
*/

ren s11aq5a indiv1
ren s11aq5b indiv2
ren s11aq5c indiv3
ren s11aq5d indiv4

replace indiv1 = sa1q11_1 if indiv1==. //Post-Harvest (only reported for "new" plot)
replace indiv2 = sa1q11_2 if indiv2==.
replace indiv3 = sa1q11_3 if indiv3==. //The ph questionnaire goes up to six for ph but we'll stick to the first four for consistency with the pp questionnaire 
replace indiv4 = sa1q11_4 if indiv4==.
replace indiv1 = s11b1q7_1 if indiv1==. & indiv2==. & indiv3==. & indiv4==. //plot owner if dm is empty

la var indiv1 "Primary plot manager (indiv id)"
la var indiv2 "First Secondary plot manager (indiv id)"
la var indiv3 "Second secondary plot manager (indiv id)"
la var indiv4 "Third secondary plot manager (indiv id)"

drop s11* sa1*
save "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_plot_areas.dta", replace




********************************************************************************
*crop unit conversion factors
********************************************************************************
/*ALT: Theoretically this should be unnecessary because conversion factors are now
included in their respective files. However, in practice there is a lot of missing info
and so we need to construct a central conversion factors file like the one provided in W3.
Issues this section is used to address:
	*Known but missing conversion factors
	*Calculating conversion factors for seed (see seed section for why we need this)
	*Units that had conversion factors in previous waves that were not used in w5
	*Conversion factors for units that weren't included but which can be inferred from the literature
*/
use "${Nigeria_GHS_W5_raw_data}/secta3i_harvestw5.dta", clear
append using "${Nigeria_GHS_W5_raw_data}/secta3ii_harvestw5.dta"
append using "${Nigeria_GHS_W5_raw_data}/secta3iii_harvestw5.dta"
replace cropcode=1120 if inrange(cropcode, 1121,1124)
label define CROPCODE 1120 "1120. YAM" , add //all yam cfs are the same
//recode cropcode (2170=2030) //Bananas=plaintains ALT 06.23.2020: Bad idea, because the conversion factors vary a bunch (har har)

ren sa3iq9b unit
ren sa3iq9c size
ren sa3iq9d condition
ren sa3iq9_conv conv_fact

replace unit=sa3iq15b if unit==.
replace size=sa3iq15c if size==.
replace condition=sa3iq15d if condition==.  //ALT 02.01.21 Typo; fixed //DYA.11.21.2020  I am not sure why this? sa3iiq1d is "What was the total harvest of [CROP] from all HH's plots? (Size)". Should be sa3iiq1b but this is used below
replace conv_fact=sa3iq15_conv if conv_fact==.

replace unit=sa3iiiq23b if unit==.
replace size=sa3iiiq23c if size==.
replace condition=sa3iiiq23d if condition==.
replace conv_fact=sa3iiiq23_conv if conv_fact==.

/*
replace unit=sa3iq6d2 if unit==.
replace size=sa3iq6d4 if size==.
//ALT 09.25.20: something weird is happening here
replace condition=sa3iq6d2a if condition==.
replace conv_fact=sa3iq6d_conv if conv_fact==.
//drop if sa3iq3==2 | sa3iq3==. //drop if no harvest //ALT 02.03.21: I was mistakenly dropping things needed for conversion factors here
drop if unit==.  //DYA.11.21.2020 So all the missing units are instances where there was no harvest during the season
//At this point we have all cropcode/size/unit/condition combinations that show up in the survey.
//Ordinarily, we'd collapse by state/zone/country to get median values most representative of a hh's area.
//However, here the values are the same across geographies so we don't need to do it - we just need to add in our imputed values.
*/
//ALT 06.23.2020: Code added for bananas/plantains, oil palm, other missing conversions. Turns out conversions are missing from the tree crop harvest in the next section, and so tree crops are being underreported in the final data.
replace conv_fact=1 if unit==1 //kg
replace conv_fact=0.001 if unit==2 //g

replace conv_fact=25 if size==10 //25kg bag
replace conv_fact=50 if size==11 //50kg bag
replace conv_fact=100 if size==12 //100kg bag

replace conv_fact = 21.3 if unit==160 & cropcode==2230 //Conversion factors for sugar cane, because they are not in the files or basic info doc
replace conv_fact = 2.13 if unit==80 & cropcode==2230
replace conv_fact = 53.905 if unit==170 & cropcode==2230
replace conv_fact = 1957.58 if unit==180 //Estimated weight for a pick-up 
//Banana/Plantain & oil palm conversions from W3
replace conv_fact=0.5 if unit==80 & size==0 & cropcode==2030
replace conv_fact=0.6 if unit==80 & (size==1 | size==.) & cropcode==2030
replace conv_fact=0.7 if unit==80 & size==2 & cropcode==2030
replace conv_fact=0.445 if unit==100 & size==0 & cropcode==2030
replace conv_fact=1.345 if unit==100 & (size==1 | size==.) & cropcode==2030
replace conv_fact=2.12 if unit==100 & size==2 & cropcode==2030
replace conv_fact=5.07 if unit==110 & size==0 & cropcode==2030
replace conv_fact=7.14 if unit==110 & (size==1 | size==.) & cropcode==2030
replace conv_fact=21.62 if unit==110 & size==2 & cropcode==2030

replace conv_fact=0.135 if unit==80 & size==0 & cropcode==2170
replace conv_fact=0.23 if unit==80 & (size==1 | size==.) & cropcode==2170
replace conv_fact=0.34 if unit==80 & size==2 & cropcode==2170
replace conv_fact=0.615 if unit==100 & size==0 & cropcode==2170
replace conv_fact=1.06 if unit==100 & (size==1 | size==.) & cropcode==2170
replace conv_fact=2.1 if unit==100 & size==2 & cropcode==2170
replace conv_fact=3.51 if unit==110 & size==0 & cropcode==2170
replace conv_fact=5.14 if unit==110 & (size==1 | size==.) & cropcode==2170
replace conv_fact=7.965 if unit==110 & size==2 & cropcode==2170

replace conv_fact=5.235 if unit==140 & size==0 & cropcode==2170
replace conv_fact=13.285 if unit==140 & (size==1 | size==.) & cropcode==2170
replace conv_fact=15.972 if unit==140 & size==2 & cropcode==2170
replace conv_fact=3.001 if unit==150 & size==0 & cropcode==2170
replace conv_fact=6.959 if unit==150 & (size==1 | size==.) & cropcode==2170
replace conv_fact=16.11 if unit==150 & size==2 & cropcode==2170

//Oil palm bunch data. Lots of papers report weights, but none report variances, so asessing small/med/large is difficult.
//The lit cites bunch weights anywhere from 15-40 kg, but Nigeria-specific research exclusively cites lower values. Here,
//I use the range from Genotype and genotype by environment (GGE) biplot analysis of fresh fruit bunch yield and yield components of oil palm (Elaeis guineensis Jacq.).
//by Okoye et al (2008) to approximate the field variation.

replace conv_fact=9.5 if unit==100 & size==0 & cropcode==3180
replace conv_fact=14.5 if unit==100 & size==2 & cropcode==3180
replace conv_fact=12 if unit==100 & (size==1 | size==.) & cropcode==3180

//Now one-size-fits-all estimates from WB and external sources to get stragglers 
//These from Local weights and measures in Nigeria: a handbook of conversion factors by Kormawa and Ogundapo
//paint rubber - 2.49 //LSMS says about 2.9
replace conv_fact=2.49 if unit==11 & conv_fact==.
replace conv_fact = 1.36 if (unit==20 | unit==30) & size==0 & conv_fact==. //Lower estimate given by Kormawa and Ogundapo
replace conv_fact = 1.5 if (unit==20 | unit==30) & (size==1 | size==.) & conv_fact==. //congo/mudu value from LSMS W1, assuming medium if left blank
replace conv_fact = 1.74 if (unit==20 | unit==30) & size==2 & conv_fact==. //Upper estimate by K&O
replace conv_fact = 2.72 if unit==50 & size==0 & conv_fact==. //1 tiya=2 mudu
replace conv_fact = 3 if unit==50 & (size==1 | size==.) & conv_fact==. //2x med mudu
replace conv_fact = 3.48 if unit==50 & size==2 & conv_fact==. //2x lg mudu
replace conv_fact = 0.35 if unit==40 & size==0  & conv_fact==. //Small derica from W1
replace conv_fact = 0.525 if unit==40 & (size==1 | size==.) & conv_fact==. //central value
replace conv_fact = 0.7 if unit==40 & size==2 & conv_fact==. & conv_fact==. //large derica from W1
replace conv_fact = 15 if unit==140 & size==0 & conv_fact==. //Small basket from W1
replace conv_fact = 30 if unit==140 & (size==1 | size==.) & conv_fact==. //Med basket W1
replace conv_fact = 50 if unit==140 & size==2 & conv_fact==. //Lg basket W1
replace conv_fact = 85 if unit==170 & size==. & conv_fact==. //Med wheelbarrow w1 

drop if conv_fact==.

collapse (median) conv_fact, by(unit size cropcode condition)
ren conv_fact conv_fact_median
save "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_cf.dta", replace










***************************
	*Crop Values
	***************************
	//Nonstandard unit values
use "${Nigeria_GHS_W5_raw_data}/secta3ii_harvestw5.dta", clear
	//Fstat highly insignificant for yam on price, so we'll lump here.
	replace cropcode=1120 if inrange(cropcode, 1121,1124)
	label define CROPCODE 1120 "1120. YAM", add
	keep if sa3iiq4==1
	ren sa3iiq6 qty
	ren sa3iiq3d condition
	ren sa3iiq3b unit
	ren sa3iiq3c size
	ren sa3iiq7 value
	merge m:1 hhid using "${Nigeria_GHS_W5_created_data}/hhids.dta", nogen keepusing(weight) keep(3)
	//ren cropcode crop_code
	gen price_unit = value/qty
	gen obs=price_unit!=.
	keep if obs==1
	foreach i in zone state lga ea hhid {
		preserve
		bys `i' cropcode unit size condition : egen obs_`i'_price = sum(obs)
		collapse (median) price_unit_`i'=price_unit [aw=weight], by (`i' unit size condition cropcode obs_`i'_price)
		tempfile price_unit_`i'_median
		save `price_unit_`i'_median'
		restore
	}
	bys cropcode unit size condition : egen obs_country_price = sum(obs)
	collapse (median) price_unit_country = price_unit [aw=weight], by(cropcode unit size condition obs_country_price)
	
	save "${Nigeria_GHS_W5_created_data}/price_unit_country_median.dta", replace

	//Because we have several qualifiers now (size and condition), using kg as an alternative for pricing. Results from experimentation suggests that the kg method is less accurate than using original units, so original units should be preferred.
	
use "${Nigeria_GHS_W5_raw_data}/secta3ii_harvestw5.dta", clear
	keep if sa3iiq4==1
	replace cropcode=1120 if inrange(cropcode, 1121,1124)
	label define CROPCODE 1120 "1120. YAM", add
	ren sa3iiq6 qty
	ren sa3iiq3d condition
	ren sa3iiq3b unit
	ren sa3iiq3c size
	ren sa3iiq7 value
	merge m:1 hhid using "${Nigeria_GHS_W5_created_data}/hhids.dta", nogen keepusing(weight) keep(1 3)
	merge m:1 cropcode unit size condition using "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_cf.dta", nogen keep(1 3)
	//ren cropcode crop_code
	gen qty_kg = qty*conv_fact 
	drop if qty_kg==. //34 dropped; largely basin and bowl.
	gen price_kg = value/qty_kg
	gen obs=price_kg !=.
	keep if obs == 1
	foreach i in zone state lga ea hhid {
		preserve
		bys `i' cropcode : egen obs_`i'_pkg = sum(obs)
		collapse (median) price_kg_`i'=price_kg [aw=weight], by (`i' cropcode obs_`i'_pkg)
		tempfile price_kg_`i'_median
		save `price_kg_`i'_median'
		restore
	}
	bys cropcode : egen obs_country_pkg = sum(obs)
	collapse (median) price_kg_country = price_kg [aw=weight], by(cropcode obs_country_pkg)
	save "${Nigeria_GHS_W5_created_data}/price_kg_country_median.dta" , replace







***************************
	*Plot variables
	***************************
use "${Nigeria_GHS_W5_raw_data}/sect11f_plantingw5.dta", clear
	merge 1:1 hhid plotid cropcode using "${Nigeria_GHS_W5_raw_data}/secta3i_harvestw5.dta", nogen
	merge 1:1 hhid plotid cropcode using "${Nigeria_GHS_W5_raw_data}/secta3iii_harvestw5.dta", nogen
	gen use_imprv_seed=s11fq7==1
	replace use_imprv_seed = s11fq18==1 if s11fq7==.
	gen crop_code_long = cropcode
	//ren cropcode crop_code_a3i 
	ren plotid plot_id
	ren s11fq15 number_trees_planted
	//replace crop_code_11f=crop_code_a3i if crop_code_11f==.
	//replace crop_code_a3i = crop_code_11f if crop_code_a3i==.
	//gen cropcode =crop_code_11f //Generic level
	//replace cropcode = crop_code_11f if cropcode==.
	drop if strpos(sa3iq4_os, "WRONGLY") | strpos(sa3iq4_os, "MISTAKEN") | strpos(sa3iq4_os, "DIDN'T") | strpos(sa3iq4_os, "did not") | strpos(sa3iq4_os, "DID NOT") //Reported as mistaken entries in sa3iq4_os
	recode cropcode (2170=2030) (2142 = 2141) (1121 1122 1123=1120) //Only things that carry over from W3 are bananas/plantains, yams, and peppers. The generic pepper category 2040 in W3 is missing from this wave. //Okay to lump yams for price and unit conversions, not for other things. 
	//replace cropcode = 4010 if strpos(sa3iq4_os, "FEED") | regexm(sa3iq4_os, "CONSUMP*TION") | regexm(sa3iq4_os, "ONLY.+LEAVES") //no one reported fodder in this question for w5.
	label def Sec11f_crops__id 1120 "1120. YAM" 4010 "4010. FODDER", modify
	la values cropcode Sec11f_crops__id
	merge m:1 hhid plot_id using "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_plot_areas.dta", nogen keep(3) //ALT 05.03.23
	gen percent_field = s11fq3/100
	replace percent_field = s11fq14/100 if percent_field==. 
	recode percent_field field_size (0=.)

	//for tree crops not part of an orchard, the area planted is not recorded; this divides the missing area by the number of tree crops on the plot 
	bys hhid plot_id : egen tot_pct_planted = sum(percent_field)
	gen miss_pct = percent_field==. 
	bys hhid plot_id : egen tot_miss = sum(miss_pct)
	gen underplant_pct = 1-tot_pct_planted 
	replace percent_field = underplant_pct/tot_miss if miss_pct & underplant_pct > 0 //175/241 fixed, remainder are overplanted. 
	replace percent_field=percent_field/tot_pct_planted if tot_pct_planted > 1
	gen ha_planted = percent_field*field_size
	
	gen pct_harvest=1 if sa3iq6 ==2 | sa3iiiq17==1 //Was area planted less than area harvested? 2=No / In the last 12 months, has your household harvested any <Tree Crop>? They don't ask for area harvested, so I assume that the whole area is harvested (not true for some crops)
	replace pct_harvest = sa3iq8/100 if sa3iq8!=. //1075 obs
	replace pct_harvest = 0 if pct_harvest==. & sa3iq4_1 <= 18  
	replace pct_harvest = . if pct_harvest==0 & sa3iq4_1 > 18 & sa3iq4_1 < 96
	gen ha_harvest=pct_harvest*ha_planted
	//replace pct_harvest = 1 if cropcode==4010 //Assuming fodder crops were fully "harvested"
	preserve
		gen obs=1
		//replace obs=0 if inrange(sa3iq3,1,5) & sa3iq3==1// Question changed to sa3iq4_1/2, no entries for either. Only 1 hh reports harvesting 0% of the plot.
		collapse (sum) obs, by(hhid plot_id cropcode)
		replace obs = 1 if obs > 1
		collapse (sum) crops_plot=obs, by(hhid plot_id)
		save "${Nigeria_GHS_W5_created_data}/ncrops.dta", replace
	restore //14 plots have >1 crop but list monocropping; meanwhile 289 list intercropping or mixed cropping but only report one crop
	merge m:1 hhid plot_id using "${Nigeria_GHS_W5_created_data}/ncrops.dta", nogen
	
	/*
	gen lost_crop=inrange(sa3iq3,1,5) & s11fq2==1
	bys hhid plot_id : egen max_lost = max(lost_crop)
	gen replanted = (max_lost==1 & crops_plot>0)
	drop if replanted==1 & lost_crop==1 //Crop expenses should count toward the crop that was kept, probably.
	*/
	//bys hhid plot_id : egen crops_avg = mean(cropcode) //Checks for different versions of the same crop in the same plot
	gen purestand = crops_plot==1 //This includes replanted crops 
	
	gen perm_crop=(s11fq2==2)
	replace perm_crop = 1 if cropcode==1020 //I don't see any indication that cassava is grown as a seasonal crop in Nigeria
	bys hhid plot_id : egen permax = max(perm_crop)
	
	//bys hhid plot_id s11fq3a s11fq3b : gen plant_date_unique=_n
	gen planting_year = s11fq11_year
	gen planting_month = s11fq11_month
	gen harvest_month_begin = sa3iq5a
	gen harvest_year_begin = s11fq20b
	replace harvest_year_begin = planting_year if sa3iq3==1 & harvest_year_begin==.
	replace harvest_year_begin = harvest_year_begin+1 if harvest_year_begin==planting_year & harvest_month_begin <= planting_month
	gen harvest_year_end = s11fq20d
	replace harvest_year_end = harvest_year_begin if harvest_year_end==.
	gen harvest_month_end = s11fq20c
	replace harvest_month_end =harvest_month_begin if harvest_month_end==.
	replace harvest_year_end = harvest_year_begin if harvest_year_end < harvest_year_begin
	replace harvest_year_end = harvest_year_end+1 if harvest_year_end == planting_year & harvest_month_end <= planting_month
	
/* Most crops are planted and/or harvested within a month of each other, so there's little evidence of relay cropping in the dataset.
	preserve
	keep hhid plot_id planting_year planting_month perm_crop
	duplicates drop
	gen obs = planting_year!=. & planting_month!=. 
	collapse (sum) plant_dates=obs, by(hhid plot_id perm_crop)
	tempfile plant_dates 
	save `plant_dates'
	restore
	
	preserve
	keep hhid plot_id harvest_year_begin harvest_month_begin perm_crop
	duplicates drop 
	gen obs = harvest_year_begin!=. & harvest_month_begin!=.
	collapse (sum) harv_dates=obs, by(hhid plot_id perm_crop)
	tempfile harvest_dates 
	save `harvest_dates'
	restore
	
	merge m:1 hhid plot_id perm_crop using `plant_dates', nogen
	merge m:1 hhid plot_id perm_crop using `harvest_dates', nogen
	replace purestand=0 if (crops_plot>1 & (plant_dates==1 | harv_dates==1))  | (crops_plot>1 & permax==1)  //Multiple crops planted or harvested in the same month are not relayed; may omit some crops that were purestands that preceded or followed a mixed crop.
	*gen any_mixed = !(s11fq4==1 | s11fq4==3)
	gen any_mixed =(s11fq4==2) if s11fq4!=. // PA 12.24 updated definition
	
	
	bys hhid plot_id : egen any_mixed_max = max(any_mixed)
	replace purestand=1 if crops_plot>1 & plant_dates==1 & harv_dates==1 & permax==0 & any_mixed_max==0 
	gen relay=crops_plot>1 & plant_dates>1 & harv_dates>1 & perm_crop==0 & any_mixed_max==0 //No relay cropping to report. 
	*/
	
	//replace purestand=1 if crop_code_11f==crops_avg


	

	*renaming unit code for merge
	//ALT 10.14.21: Tree crop harvests are recorded in both s11f (planting) and sa3iii (harvest); thus, it's likely that s11f has a lot of old harvests (range 2010-2018; mean 2017.365) that we wouldn't want to consider here. However, 465 obs note 2018 (vs 300 in harvest questionnaire), so I replace with sa3iii except when sa3iii is empty and the harvest year is 2018
	ren sa3iq9b unit
	replace unit = s11fq24c if unit==.
	replace unit = s11fq23c if unit==. & s11fq20b==2018 
	ren sa3iq9c size
	replace size = sa3iiiq23c if size==.
	replace size = s11fq23d if size==. & s11fq20b==2018
	ren sa3iq9d condition
	replace condition = sa3iiiq23b if condition==.
	replace condition = s11fq23a if condition==. & s11fq20b==2018
	ren sa3iq9a quantity_harvested
	replace quantity_harvested = sa3iiiq23a if quantity_harvested==.
	*replace quantity_harvested = s11fq23a if quantity_harvested==. & s11fq20b==2018
	*merging in conversion factors
	merge m:1 cropcode unit size condition using "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_cf.dta", keep(1 3) nogen 
	replace conv_fact=1 if conv_fact==. & unit==1
	gen quant_harv_kg = quantity_harvested * sa3iq9_conv
	replace quant_harv_kg = quantity_harvested * sa3iq15_conv if quant_harv_kg == .
	replace quant_harv_kg = quantity_harvested * sa3iiiq23_conv if quant_harv_kg == .
	replace quant_harv_kg = quantity_harvested * conv_fact if quant_harv_kg == .
	replace quant_harv_kg = . if harvest_year_end < 2023 //Tracking only the most recent production period. 
	replace ha_harvest = . if harvest_year_end < 2023
	//gen quant_harv_kg= quantity_harvested*conv_fact
	ren sa3iq10 val_harvest_est
	replace val_harvest_est = sa3iiiq24 if val_harvest_est==.
	//ALT 09.28.22: I'm going to keep the grower-estimated valuation in here even though it's likely inaccurate for comparison purposes.
	gen val_unit_est = val_harvest_est/quantity_harvested
	gen val_kg_est = val_harvest_est/quant_harv_kg
	merge m:1 hhid using "${Nigeria_GHS_W5_created_data}/hhids.dta", nogen keep(1 3)
	gen plotweight = ha_planted*weight
	//IMPLAUSIBLE ENTRIES - at least 100x the typical yield
	gen obs=quantity_harvested>0 & quantity_harvested!=.

foreach i in zone state lga ea hhid {
	merge m:1 `i' unit size condition cropcode using `price_unit_`i'_median', nogen keep(1 3)
	merge m:1 `i' cropcode using `price_kg_`i'_median', nogen keep(1 3)
}
merge m:1 unit size condition cropcode using "${Nigeria_GHS_W5_created_data}/price_unit_country_median.dta", nogen keep(1 3)
*merge m:1 unit size condition cropcode using `val_unit_country_median', nogen keep(1 3)
merge m:1 cropcode using "${Nigeria_GHS_W5_created_data}/price_kg_country_median.dta", nogen keep(1 3)
*merge m:1 cropcode using `val_kg_country_median', nogen keep(1 3)

//We're going to prefer observed prices first
gen price_unit = . 
gen price_kg = .
recode obs_* (.=0)
foreach i in country zone state lga ea {
	replace price_unit = price_unit_`i' if obs_`i'_price>9 & price_unit_`i'!=.
	replace price_kg = price_kg_`i' if obs_`i'_pkg>9 & price_kg_`i'!=. 
}
	ren price_unit_hhid price_unit_hh 
	ren price_kg_hhid price_kg_hh 
	
	gen value_harvest = price_unit * quantity_harvested	 
	replace value_harvest = price_kg * quant_harv_kg if value_harvest == .
	replace value_harvest = val_harvest_est if value_harvest == .
	
	gen value_harvest_hh=price_unit_hh*quantity_harvested 
	replace value_harvest=price_kg_hh * quant_harv_kg if value_harvest_hh==.
	replace value_harvest_hh = value_harvest if value_harvest_hh==.

	//Replacing conversions for unknown units
	replace val_unit_est = value_harvest/quantity_harvested if val_unit_est==.
	replace val_kg_est = value_harvest/quant_harv_kg if val_kg_est == .

preserve
//ALT note to double check and see if the changes to valuation mess this up.
	replace val_kg = val_kg_est if val_kg==.
	collapse (mean) val_kg=price_kg conv_fact, by(hhid cropcode)
	save "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_hh_crop_prices_kg.dta", replace //Backup for s-e income.
restore
preserve
	//ALT 02.10.22: NOTE: This should be changed to ensure we get all household values rather than just ones with recorded harvests (although I imagine the number of households that paid in a crop they did not harvest is small)
	replace val_unit = val_unit_est if val_unit==.
	collapse (mean) val_unit=price_unit, by (hhid cropcode unit size condition)
	drop if unit == .
	ren val_unit hh_price_mean
	lab var hh_price_mean "Average price reported for this crop-unit in the household"
	save "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_hh_crop_prices_for_wages.dta", replace //This gets used for self-employment income
restore
	//still-to-harvest value
	gen same_unit=unit==sa3iq15b & size==sa3iq15c & condition==sa3iq15d & unit!=.
	replace price_unit = value_harvest/quantity_harvested if same_unit==1 & price_unit==.
	//ALT 05.12.21: I feel like we should include the expected harvest.
	//Addendum 10.14: Unfortunately we can only reliably do this for annual crops because the question for tree crops was asked in the planting survey; estimates are probably not reliable.
	//Addendum to addendum 9.28.22: The plant survey also asks about temporary crops, not just tree crops. This was causing estimated harvests to be far too high.
	//Addendum to addendum 9.30.24: Adding an additional criterion to only include harvests that had been started, some long-haul crops like cassava and yam were probably not intended for harvest this year.
	replace sa3iq15a = . if sa3iq15a > 19000 //Retaining this threshold from W4; two plots are affected, one 
	drop unit size condition quantity_harvested
	ren sa3iq15b unit
	ren sa3iq15c size
	ren sa3iq15d condition
	ren sa3iq15a quantity_harvested
	//replace quantity_harvested = . if hhid == 220016 & plot_id==2 & cropcode==1121 //One obs of 2000 pickups on a quarter of a hectare. Planting estimate was 1 pickup; likely a unit typo. //ALT: Excluded by the 9.30.24 update
	gen quant_harv_kg2 = quantity_harvested * sa3iq9_conv 
	replace quant_harv_kg2 = quantity_harvested * conv_fact if same_unit == 1
	drop conv_fact
	merge m:1 cropcode unit size condition using "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_cf.dta", nogen keep(1 3)
	replace quant_harv_kg2= quantity_harvested*conv_fact if quant_harv_kg2 == .
	gen val_harv2 = 0
	gen val_harv2_hh=0
	recode quant_harv_kg2 quantity_harvested value_harvest (.=0) //ALT 02.10.22: This is causing people with "still to harvest" values getting missing where they should have something.
	replace val_harv2=quantity_harvested*price_kg if unit==1 
	replace val_harv2=quantity_harvested*price_unit if val_harv2==0 & same_unit==1  //Use household price for consistency. (see line 959)

//The few that don't have the same units are in somewhat suspicious units. (I'm pretty sure you can't measure bananas in liters)
	replace quant_harv_kg = quant_harv_kg+quant_harv_kg2 if sa3iq3==1   //Counting only crops that have begun harvest; only 44 obs 
	replace quant_harv_kg = quant_harv_kg2 if sa3iq3==1 & quant_harv_kg==. //this annoying two-step here to deal with how stata processes missing values and the desire to avoid introducing spurious 0s.
	replace value_harvest = value_harvest+val_harv2 if sa3iq3==1 
	replace value_harvest = val_harv2 if sa3iq3==1 & value_harvest==.
	replace ha_harvest = ha_planted if sa3iq3==1 & !inlist(quant_harv_kg2,0,.) & !inlist(sa3iq7_1, 1, .)
	gen lost_drought = sa3iq4_1==6 | sa3iq4_2==6 | s11fq22==1 | sa3iq7_1==6 | sa3iq7_2==6 
	gen lost_flood = sa3iq4_1==5 | sa3iq4_2==5 | s11fq22==2 | sa3iq7_1==5 | sa3iq7_2==5
	gen lost_pest = sa3iq4_1==12 | sa3iq4_2==12 | s11fq22==5 | sa3iq7_1==12 | sa3iq7_2==12
	replace cropcode = 1124 if crop_code_long==1124 //Removing three-leaved yams from yams. 
	//ren cropcode crop_code 
	replace ha_harvest = . if ha_harvest==0 & (quant_harv_kg !=. & quant_harv_kg !=0)
	gen no_harvest = ha_harvest==. 
	collapse (sum) quant_harv_kg value_harvest* /*val_harvest_est*/ ha_planted ha_harvest number_trees_planted percent_field (max) no_harvest lost_pest lost_flood lost_drought use_imprv_seed, by(zone state lga sector ea hhid plot_id cropcode purestand field_size gps_meas area_est)
	recode ha_planted (0=.)
replace ha_harvest=. if (ha_harvest==0 & no_harvest==1) | (ha_harvest==0 & quant_harv_kg>0 & quant_harv_kg!=.)
   replace quant_harv_kg = . if quant_harv_kg==0 & no_harvest==1
   drop no_harvest
	bys hhid plot_id : gen count_crops = _N
	replace purestand = 0 if count_crops > 1 & purestand==1 //Three plots no longer considered monocropped after the disaggregation.
	bys hhid plot_id : egen percent_area = sum(percent_field)
	bys hhid plot_id : gen percent_inputs = percent_field/percent_area
	drop percent_area //Assumes that inputs are +/- distributed by the area planted. Probably not true for mixed tree/field crops, but reasonable for plots that are all field crops
	//Labor should be weighted by growing season length, though. 
	//Small gardens may distort yield by being undermeasured/under-reported given the quantities harvested. We exclude them from the yield analysis.
	gen ha_harv_yld = ha_harvest if ha_planted >=0.05
	gen ha_plan_yld = ha_planted if ha_planted >=0.05
	*merge m:1 hhid plot_id using "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm_gender)
	save "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_all_plots.dta",replace




********************************************************************************************************************************************************
*New Day
********************************************************************************************************************************************************

*******************************************************************

*******************************************************************

global Nigeria_GHS_W5_pop_tot 227882945
global Nigeria_GHS_W5_pop_rur 104181246
global Nigeria_GHS_W5_pop_urb 123701699
*************
* HOUSEHOLD IDS *
********************************************************************************
use "${Nigeria_GHS_W5_raw_data}/secta_plantingw5.dta", clear
keep if interview_result==1
gen rural = (sector==2)
lab var rural "1= Rural"
keep hhid zone state lga ea wt_wave5 wt_longpanel_wave5 wt_cross_wave5 rural
ren wt_wave5 weight // 
ren wt_longpanel_wave5 weight_longpanel
ren wt_cross_wave5 weight_crosssection
drop if weight==. & weight_longpanel==. & weight_crosssection==.
duplicates report hhid
save  "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_hhids.dta", replace











********************************************************************************
* INDIVIDUAL IDS *
********************************************************************************
use "${Nigeria_GHS_W5_raw_data}/sect1_plantingw5.dta", clear
gen season="plan"
append using "${Nigeria_GHS_W5_raw_data}/sect1_harvestw5.dta"
replace season="harv" if season==""
*keep if s1q4==1 //Drop individuals who've left household   // AYW_3.5.20 This question wasn't asked of all individuals. 
gen member = s1q4
replace member = 1 if s1q3 != . 
drop if member!=1
gen female= s1q2==2
gen fhh = s1q3==1 & female
recode fhh (.=0)
preserve 
collapse (max) fhh, by(hhid)
tempfile fhh
save `fhh'
restore 
la var female "1= individual is female"
ren s1q6 age
la var age "Individual age"
keep hhid indiv female age season
ren female female_
ren age age_ 
reshape wide female_ age_, i(hhid indiv) j(season) string
gen age = age_plan 
replace age=age_harv if age==.
gen female=female_plan 
replace female=female_harv if female==.
drop *harv *plan
merge m:1 hhid using `fhh'
merge m:1 hhid using  "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_hhids.dta", keep(2 3) nogen  // keeping hh surveyed
save "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_person_ids.dta", replace





*************
* HOUSEHOLD SIZE *
********************************************************************************
use "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_person_ids.dta", clear
gen member=1
collapse (max) fhh (sum) hh_members=member, by (hhid)
lab var hh_members "Number of household members"
lab var fhh "1= Female-headed household"
*DYA.11.1.2020 Re-scaling survey weights to match population estimates
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_hhids.dta", nogen keep(2 3)
*Adjust to match total population
total hh_members [pweight=weight]
matrix temp =e(b)
gen weight_pop_tot=weight*${Nigeria_GHS_W5_pop_tot}/el(temp,1,1)
total hh_members [pweight=weight_pop_tot]
lab var weight_pop_tot "Survey weight - adjusted to match total population"
*Adjust to match total population but also rural and urban
total hh_members [pweight=weight] if rural==1
matrix temp =e(b)
gen weight_pop_rur=weight* ${Nigeria_GHS_W5_pop_rur}/el(temp,1,1) if rural==1
total hh_members [pweight=weight_pop_tot]  if rural==1

total hh_members [pweight=weight] if rural==0
matrix temp =e(b)
gen weight_pop_urb=weight*${Nigeria_GHS_W5_pop_urb}/el(temp,1,1) if rural==0
total hh_members [pweight=weight_pop_urb]  if rural==0

egen weight_pop_rururb=rowtotal(weight_pop_rur weight_pop_urb)
total hh_members [pweight=weight_pop_rururb]  
lab var weight_pop_rururb "Survey weight - adjusted to match rural and urban population"
drop weight_pop_rur weight_pop_urb
save "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_hhsize.dta", replace
keep hhid zone state lga ea weight* rural
save "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_weights.dta", replace








use "${Nigeria_GHS_W5_raw_data}/secta11c3_harvestw5.dta", clear
gen qty=s11c3q4a*s11c3q4_conv
ren s11c3q5 val
ren s11c3q4b unit
recode unit (4=3) (2 10 11 12 13 30 31 50 51 52=1) //Everything has been converted to kg/L
replace val=s11c3q11 if inputid==7 | inputid==8 //Equipment rental costs 
//Now we have all hhs for the value calculations and can keep track of implicit/explicit costs later. This'll partially correct for the fact that
//the enumerators stopped asking about free inputs in W3.
keep zone state lga sector ea hhid inputid qty val unit
/*merge 1:1 hhid inputid using `impl_inputs'
replace cost_implicit=0 if _merge!=2
drop _merge
gen exp="exp" if cost_implicit==0
replace exp="imp" if cost_implicit==1 */
//ALT 07.03.20 Note, if _merge==1, this implies that the hh bought inputs but didn't use them. 
gen input = "orgfert" if inputid==1
replace input = "npk_fert" if inputid==2
replace input = "urea" if inputid==3
replace input = "other_fert" if inputid==4
replace input = "pest" if inputid==5
replace input = "herb" if inputid==6
replace input = "mech" if inputid==7 | inputid==8
replace qty = 0 if inputid==7 | inputid==8
replace unit = 0 if inputid==7 | inputid==8
drop inputid
preserve
	keep if strmatch(input,"mech") //We'll add these back in after we do prices
	collapse (sum) val, by(hhid input qty unit)
	tempfile mechrenttemp
	save `mechrenttemp'
	use "${Nigeria_GHS_W5_raw_data}/secta11c2_harvestw5.dta", clear
	gen use_mech=s11c2q20==1
	ren plotid plot_id
	merge 1:1 hhid plot_id using "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_plot_areas.dta", nogen keep(1 3) keepusing(field_size)
	gen mech_area = field_size*use_mech 
	bys hhid : egen total_mech_area = sum(mech_area)
	gen frac_mech_area = mech_area/total_mech_area 
	merge m:1 hhid using `mechrenttemp', nogen 
	replace val=val*frac_mech_area if frac_mech_area!=.
	keep if val!=.
	keep zone state lga ea hhid plot_id qty unit input val 
		gen exp="exp"
	tempfile mechrent
	save `mechrent'
restore
drop if strmatch(input,"mech")
merge m:1 hhid using "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_weights.dta", nogen keepusing(weight_pop_rururb)
replace weight=0 if weight==.
gen price = val/qty
recode price (0=.)
gen obs=price!=.
save "${Nigeria_GHS_W5_created_data}/phys_inputs.dta", replace

drop if unit == 0 | unit==. //Dropping things that don't have units
foreach i in zone state lga ea hhid {
preserve
	bys `i' input unit : egen obs_`i' = sum(obs)
	collapse (median) price_`i'=price [aw=weight_pop_rururb], by (`i' input unit obs_`i')
	tempfile price_`i'_median
	save `price_`i'_median'
restore
}

preserve
bys input unit : egen obs_country = sum(obs)
collapse (median) price_country = price [aw=weight_pop_rururb], by(input unit obs_country)
tempfile price_country_median
save `price_country_median'
restore

keep hhid input qty
ren qty hhqty
reshape wide hhqty, i(hhid) j(input) string //Determining implicit ratios
save "${Nigeria_GHS_W5_created_data}/hhqty.dta", replace
tempfile 



use "${Nigeria_GHS_W5_raw_data}/secta11c2_harvestw5.dta", clear
gen qtyherb=s11c2q2a*s11c2q2_conv 
gen qtypest=s11c2q4a*s11c2q4_conv 
gen qtynpk_fert=s11c2q7a*s11c2q7a_conv 

gen qtyurea = s11c2q11a*s11c2q11a_conv
gen qtyorgfert = s11c2q16a*s11c2q16_conv //This looks wrong but it isn't
gen qtyother_fert=s11c2q9a*s11c2q9a_conv 
ren s11c2q2b unitherb
ren s11c2q4b unitpest
ren s11c2q7b unitnpk_fert
ren s11c2q11b uniturea
ren s11c2q9b unitother_fert
ren s11c2q16b unitorgfert
ren plotid plot_id 
replace qtyurea = . if uniturea == 12 & s11c2q11a > 1000



preserve
collapse (sum) qty*, by(hhid)
merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/hhqty.dta", nogen
reshape long hhqty qty, i(hhid) j(input) string
recode hhqty qty (.=0)
gen exp_ratio = hhqty/qty if qty!=0
drop if exp_ratio==.
replace exp_ratio = 1 if exp_ratio > 1
//"hhqty" is the amount purchased by the household, qty is the amount used. If hhqty > qty, the household bought more than it used, and we can assume it paid for all of its inputs.
//if hhqty < qty, the household used more than it bought and so some proportion of the plot inputs come from leftover or free supplies and should be considered implicit.
//if hhqty > 0 but qty==0, the household bought but did not use, and those expenses don't get considered (might be an issue for panel households, because those purchases would become implicit next season 
//but were never accounted for as a household purchase)

tempfile 
save "${Nigeria_GHS_W5_created_data}/exp_ratios.dta", replace
restore

recode unit* (4=3) (2 10 11 12 13 30 31 50 51 52=1) //Everything has been converted to kg/L
keep zone state lga ea hhid plot_id qty* unit* 
reshape long qty unit, i(zone state lga ea hhid plot_id) j(input) string

foreach i in zone state lga ea hhid {
	merge m:1 `i' input unit using `price_`i'_median', nogen keep(1 3) 
}
	merge m:1 input unit using `price_country_median', nogen keep(1 3)
	recode price_hhid (.=0)
	gen price=price_hhid
foreach i in country zone state lga ea {
	replace price = price_`i' if obs_`i' > 9 & obs_`i'!=.
}
//Default to household prices when available
replace price = price_hhid if price_hhid>0
replace qty = 0 if qty <0 //4 households reporting negative quantities of fertilizer.
gen val = qty*price
drop if val==0 | val==.
merge m:1 hhid input using "${Nigeria_GHS_W5_created_data}/exp_ratios.dta", nogen keep(1 3)
recode exp_ratio (.=0) //If there's no match, the hh recorded using an input but didn't provide any information related to its purchase 
gen qtyexp = qty*exp_ratio 
gen qtyimp = qty-qtyexp 
gen valexp = val*exp_ratio 
gen valimp = val-valexp
gen unitimp = unit
gen unitexp = unit
//Fertilizer units
//We can estimate how many nutrient units were applied for most fertilizers; dry urea is 46% N and NPK can have several formulations; we go with a weighted average of 18-12-11 based on https://africafertilizer.org/#/en/vizualizations-by-topic/consumption-data/


gen inorg_fert_kg = qty*strmatch(input, "npk_fert") + qty*strmatch(input, "urea") + qty*strmatch(input, "other_fert")

gen n_kg = qty*strmatch(input, "npk_fert")*0.18 + qty*strmatch(input, "urea")*0.46
gen p_kg = qty*strmatch(input, "npk_fert")*0.12
gen k_kg = qty*strmatch(input, "npk_fert")*0.11
gen n_org_kg = qty*strmatch(input,"orgfert")*0.01
la var n_kg "Kg of nitrogen applied to plot from inorganic fertilizer"
la var p_kg "Kg of phosphorus applied to plot from inorganic fertilizer"
la var k_kg "Kg of potassium applied to plot from inorganic fertilizer"
la var n_org_kg "Kg of nitrogen from manure and organic fertilizer applied to plot"
gen npk_kg = qty*strmatch(input, "npk_fert")
gen urea_kg = qty*strmatch(input, "urea")
la var npk_kg "Total quantity of NPK fertilizer applied to plot"
la var urea_kg "Total quantity of urea fertilizer applied to plot"
collapse (sum) *kg (max) price , by( hhid plot_id)

save "${Nigeria_GHS_W5_created_data}/fert_units.dta", replace






*******************************************************************************
*Wave 4
*******************************************************************************




***************************************************
*starting
***************************************************


global Nigeria_GHS_W4_raw_data 		"C:\Users\obine\Music\Documents\Smallholder lsms STATA\NGA_2018_GHSP-W4_v03_M_Stata12 (1)"
global Nigeria_GHS_W4_created_data  "C:\Users\obine\Music\Documents\food\evans"







********************************************************************************
* HOUSEHOLD IDS *
********************************************************************************
use "${Nigeria_GHS_W4_raw_data}/secta_plantingw4.dta", clear
gen rural = (sector==2)
lab var rural "1= Rural"
keep hhid zone state lga ea wt_wave4 rural
ren wt_wave4 weight
drop if weight == . 
*DYA.11.21.2020 from the the BID
*"The final sample consisted of 4,976 households of which 1,425 were from the long panel sample and 3,551 from the refresh sample."
*Now sure why we have 5,263 obs in this file.
*It seems that Overall, 34 refresh EAs were inaccessible during the listing period or post-planting visit. 
*The EAs were highly concentrated in the North East and North Central Zones where conflict (insurgency and farmer-herder attacks) were prevalent during this period.
*But these likely show up this this file explaing why with have 287 a additional households.
duplicates report hhid
//merge 1:1 hhid using  "${Nigeria_GHS_W4_created_data}\Nigeria_GHS_W4_weights.dta", keep(2 3) nogen  // keeping hh surveyed
save  "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_hhids.dta", replace




********************************************************************************
* INDIVIDUAL IDS *
********************************************************************************
use "${Nigeria_GHS_W4_raw_data}/sect1_plantingw4.dta", clear
gen season="plan"
append using "${Nigeria_GHS_W4_raw_data}/sect1_harvestw4.dta"
replace season="harv" if season==""
*keep if s1q4==1 //Drop individuals who've left household   // AYW_3.5.20 This question wasn't asked of all individuals. 
gen member = s1q4
replace member = 1 if s1q3 != . 
drop if member!=1
gen female= s1q2==2
gen fhh = s1q3==1 & female
recode fhh (.=0)
preserve 
collapse (max) fhh, by(hhid)
tempfile fhh
save `fhh'
restore 
la var female "1= individual is female"
ren s1q6 age
la var age "Individual age"
keep hhid indiv female age season
ren female female_
ren age age_ 
reshape wide female_ age_, i(hhid indiv) j(season) string
gen age = age_plan 
replace age=age_harv if age==.
gen female=female_plan 
replace female=female_harv if female==.
drop *harv *plan
merge m:1 hhid using `fhh'
merge m:1 hhid using  "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_hhids.dta", keep(2 3) nogen  // keeping hh surveyed
save "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_person_ids.dta", replace



global Nigeria_GHS_W4_pop_tot 198387623
global Nigeria_GHS_W4_pop_rur 98511358
global Nigeria_GHS_W4_pop_urb 99876265



********************************************************************************
* HOUSEHOLD SIZE *
********************************************************************************
use "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_person_ids.dta", clear
gen member=1
collapse (max) fhh (sum) hh_members=member, by (hhid)
lab var hh_members "Number of household members"
lab var fhh "1= Female-headed household"
collapse (sum) hh_members (max) fhh, by (hhid)
lab var hh_members "Number of household members"
lab var fhh "1= Female-headed household"
*DYA.11.1.2020 Re-scaling survey weights to match population estimates
merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_hhids.dta", nogen keep(2 3)
*Adjust to match total population
total hh_members [pweight=weight]
matrix temp =e(b)
gen weight_pop_tot=weight*${Nigeria_GHS_W4_pop_tot}/el(temp,1,1)
total hh_members [pweight=weight_pop_tot]
lab var weight_pop_tot "Survey weight - adjusted to match total population"
*Adjust to match total population but also rural and urban
total hh_members [pweight=weight] if rural==1
matrix temp =e(b)
gen weight_pop_rur=weight*${Nigeria_GHS_W4_pop_rur}/el(temp,1,1) if rural==1
total hh_members [pweight=weight_pop_tot]  if rural==1

total hh_members [pweight=weight] if rural==0
matrix temp =e(b)
gen weight_pop_urb=weight*${Nigeria_GHS_W4_pop_urb}/el(temp,1,1) if rural==0
total hh_members [pweight=weight_pop_urb]  if rural==0

egen weight_pop_rururb=rowtotal(weight_pop_rur weight_pop_urb)
total hh_members [pweight=weight_pop_rururb]  
lab var weight_pop_rururb "Survey weight - adjusted to match rural and urban population"
drop weight_pop_rur weight_pop_urb
save "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_hhsize.dta", replace
keep hhid zone state lga ea weight* rural
save "${Nigeria_GHS_W4_created_data}\Nigeria_GHS_W4_weights.dta", replace








******************************************************************************
* PLOT AREAS *
********************************************************************************
*starting with planting
//ALT IMPORTANT NOTE: As of W4, the implied area conversions for farmer estimated units (including hectares) are markedly different from previous waves. I recommend excluding plots that do not have GPS measured areas from any area-based productivity estimates.
use "${Nigeria_GHS_W4_raw_data}/sect11a1_plantingw4.dta", clear
*merging in planting section to get cultivated status
merge 1:1 hhid plotid using "${Nigeria_GHS_W4_raw_data}/sect11b1_plantingw4.dta", nogen
*merging in harvest section to get areas for new plots
merge 1:1 hhid plotid using "${Nigeria_GHS_W4_raw_data}/secta1_harvestw4.dta", gen(plot_merge)
merge m:1 hhid using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_hhids.dta", nogen keep( 3)
ren s11aq4aa area_size
ren s11aq4b area_unit
ren sa1q11 area_size2 //GPS measurement, no units in file
//ren sa1q9b area_unit2 //Not in file
ren s11aq4c area_meas_sqm
//ren sa1q9c area_meas_sqm2
gen cultivate = s11b1q27 ==1 
*assuming new plots are cultivated
//replace cultivate = 1 if sa1q1aa==1
//replace cultivate = 1 if sa1q3==1 //ALT: This has changed to respondent ID for w4
*using conversion factors from LSMS-ISA Nigeria Wave 2 Basic Information Document (Wave 3 unavailable, but Waves 1 & 2 are identical) 
*found at http://econ.worldbank.org/WBSITE/EXTERNAL/EXTDEC/EXTRESEARCH/EXTLSMS/0,,contentMDK:23635560~pagePK:64168445~piPK:64168309~theSitePK:3358997,00.html
*General Conversion Factors to Hectares
//		Zone   Unit         Conversion Factor
//		All    Plots        0.0667
//		All    Acres        0.4
//		All    Hectares     1
//		All    Sq Meters    0.0001

*Zone Specific Conversion Factors to Hectares
//		Zone           Conversion Factor
//				 Heaps      Ridges      Stands
//		1 		 0.00012 	0.0027 		0.00006
//		2 		 0.00016 	0.004 		0.00016
//		3 		 0.00011 	0.00494 	0.00004
//		4 		 0.00019 	0.0023 		0.00004
//		5 		 0.00021 	0.0023 		0.00013
//		6  		 0.00012 	0.00001 	0.00041

//ALT observed from the data
//		Zone           Conversion Factor
//				 Heaps      Ridges      Stands
//		1 		 0.00281 	0.0059 		0.00121
//		2 		 0.00748 	0.0052 		0.0006
//		3 		 0.00787 	0.0051	 	0.0002
//		4 		 0.00003 	0.0010 		0.0003
//		5 		 0.00076 	0.0008 		0.009
//		6  		 0.00437 	0.0005	 	0.002

*farmer reported field size for post-planting
gen field_size= area_size if area_unit==6
replace field_size = area_size*0.0667 if area_unit==4									//reported in plots
replace field_size = area_size*0.404686 if area_unit==5		    						//reported in acres
replace field_size = area_size*0.0001 if area_unit==7									//reported in square meters

replace field_size = area_size*0.00012 if area_unit==1 & zone==1						//reported in heaps
replace field_size = area_size*0.00016 if area_unit==1 & zone==2
replace field_size = area_size*0.00011 if area_unit==1 & zone==3
replace field_size = area_size*0.00019 if area_unit==1 & zone==4
replace field_size = area_size*0.00021 if area_unit==1 & zone==5
replace field_size = area_size*0.00012 if area_unit==1 & zone==6

replace field_size = area_size*0.0027 if area_unit==2 & zone==1							//reported in ridges
replace field_size = area_size*0.004 if area_unit==2 & zone==2
replace field_size = area_size*0.00494 if area_unit==2 & zone==3
replace field_size = area_size*0.0023 if area_unit==2 & zone==4
replace field_size = area_size*0.0023 if area_unit==2 & zone==5
replace field_size = area_size*0.00001 if area_unit==2 & zone==6

replace field_size = area_size*0.00006 if area_unit==3 & zone==1						//reported in stands
replace field_size = area_size*0.00016 if area_unit==3 & zone==2
replace field_size = area_size*0.00004 if area_unit==3 & zone==3
replace field_size = area_size*0.00004 if area_unit==3 & zone==4
replace field_size = area_size*0.00013 if area_unit==3 & zone==5
replace field_size = area_size*0.00041 if area_unit==3 & zone==6

/*ALT 02.23.23*/ gen area_est = field_size
*replacing farmer reported with GPS if available
replace field_size = area_meas_sqm*0.0001 if area_meas_sqm!=.               				
gen gps_meas = (area_meas_sqm!=.)
la var gps_meas "Plot was measured with GPS, 1=Yes"
ren plotid plot_id

ren s11aq6a indiv1
ren s11aq6b indiv2
ren s11aq6c indiv3
ren s11aq6d indiv4

replace indiv1 = sa1q2 if indiv1==. //Post-Harvest (only reported for "new" plot)
replace indiv2 = sa1q2c_1 if indiv2==.
replace indiv3 = sa1q2c_2 if indiv3==. //The ph questionnaire goes up to six for ph but we'll stick to the first four for consistency with the pp questionnaire 
replace indiv4 = sa1q2c_3 if indiv4==.
replace indiv1 = s11b1q6_1 if indiv1==. & indiv2==. & indiv3==. & indiv4==. //plot owner if dm is empty

la var indiv1 "Primary plot manager (indiv id)"
la var indiv2 "First Secondary plot manager (indiv id)"
la var indiv3 "Second secondary plot manager (indiv id)"
la var indiv4 "Third secondary plot manager (indiv id)"
 
drop s11* sa1*
save "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_plot_areas.dta", replace





********************************************************************************
* PLOT DECISION MAKERS *
********************************************************************************
*Using planting data 	
use "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_plot_areas.dta", clear 	
keep hhid plot_id indiv* cultivate //ALT: Based on crop reporting numbers I would take the cultivate response with a grain of salt. 
reshape long indiv, i(hhid plot_id cultivate) j(indivno)
collapse (min) indivno, by(hhid plot_id indiv cultivate) //Removing excess observations to accurately estimate the number of decisionmakers in mixed-managed plots. Taking the highest rank
//At this point, we have the decisionmakers and their relative priority level, as the questionnaire asks to go in descending order of importance. This may be relevant for some applications (e.g., you want only the primary decisionmaker; keep if indivno==1), but we don't use it here.
drop if indiv==.
merge m:1 hhid indiv using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_person_ids.dta", nogen keep(1 3) keepusing(female) 
preserve 
keep hhid plot_id indiv female
save "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_dm_ids.dta", replace
restore
gen dm1_gender = female+1 if indivno==1
collapse (mean) female (firstnm) dm1_gender, by(hhid plot_id)
*Constructing three-part gendered decision-maker variable; male only (=1) female only (=2) or mixed (=3)
gen dm_gender = 3 if female !=1 & female!=0 & female!=.
replace dm_gender = 1 if female == 0
replace dm_gender = 2 if female == 1
la def dm_gender 1 "Male only" 2 "Female only" 3 "Mixed gender"
*replacing observations without gender of plot manager with gender of HOH
merge m:1 hhid using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_hhsize.dta", nogen keep(1 3)
replace dm1_gender=fhh+1 if dm_gender==.
replace dm_gender=fhh+1 if dm_gender==.
gen dm_male = dm_gender==1
gen dm_female = dm_gender==2
gen dm_mixed = dm_gender==3
keep plot_id hhid dm* //fhh 
save "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_plot_decision_makers", replace







********************************************************************************
*crop unit conversion factors
********************************************************************************
/*ALT: Theoretically this should be unnecessary because conversion factors are now
included in their respective files. However, in practice there is a lot of missing info
and so we need to construct a central conversion factors file like the one provided in W3.
Issues this section is used to address:
	*Known but missing conversion factors
	*Calculating conversion factors for seed (see seed section for why we need this)
	*Units that had conversion factors in previous waves that were not used in W4
	*Conversion factors for units that weren't included but which can be inferred from the literature
*/
use "${Nigeria_GHS_W4_raw_data}/secta3i_harvestw4.dta", clear
append using "${Nigeria_GHS_W4_raw_data}/secta3ii_harvestw4.dta"
append using "${Nigeria_GHS_W4_raw_data}/secta3iii_harvestw4.dta"
replace cropcode=1120 if inrange(cropcode, 1121,1124)
label define CROPCODE 1120 "1120. YAM" , add //all yam cfs are the same
//recode cropcode (2170=2030) //Bananas=plaintains ALT 06.23.2020: Bad idea, because the conversion factors vary a bunch (har har)
ren sa3iq6ii unit
ren sa3iq6_4 size
ren sa3iq6_2 condition
ren sa3iq6_conv conv_fact

replace unit=sa3iiq1c if unit==.
replace size=sa3iiq1d if size==.
replace condition=sa3iiq1b if condition==.  //ALT 02.01.21 Typo; fixed //DYA.11.21.2020  I am not sure why this? sa3iiq1d is "What was the total harvest of [CROP] from all HH's plots? (Size)". Should be sa3iiq1b but this is used below
replace conv_fact=sa3iiq1_conv if conv_fact==.

replace unit=sa3iiiq13c if unit==.
replace size=sa3iiiq13d if size==.
replace condition=sa3iiiq13b if condition==.
replace conv_fact=sa3iiiq13_conv if conv_fact==.


replace unit=sa3iq6d2 if unit==.
replace size=sa3iq6d4 if size==.
//ALT 09.25.20: something weird is happening here
replace condition=sa3iq6d2a if condition==.
replace conv_fact=sa3iq6d_conv if conv_fact==.
//drop if sa3iq3==2 | sa3iq3==. //drop if no harvest //ALT 02.03.21: I was mistakenly dropping things needed for conversion factors here
drop if unit==.  //DYA.11.21.2020 So all the missing units are instances where there was no harvest during the season
//At this point we have all cropcode/size/unit/condition combinations that show up in the survey.
//Ordinarily, we'd collapse by state/zone/country to get median values most representative of a hh's area.
//However, here the values are the same across geographies so we don't need to do it - we just need to add in our imputed values.

//ALT 06.23.2020: Code added for bananas/plantains, oil palm, other missing conversions. Turns out conversions are missing from the tree crop harvest in the next section, and so tree crops are being underreported in the final data.
replace conv_fact=1 if unit==1 //kg
replace conv_fact=0.001 if unit==2 //g

replace conv_fact=25 if size==10 //25kg bag
replace conv_fact=50 if size==11 //50kg bag
replace conv_fact=100 if size==12 //100kg bag

replace conv_fact = 21.3 if unit==160 & cropcode==2230 //Conversion factors for sugar cane, because they are not in the files or basic info doc
replace conv_fact = 2.13 if unit==80 & cropcode==2230
replace conv_fact = 53.905 if unit==170 & cropcode==2230
replace conv_fact = 1957.58 if unit==180 //Estimated weight for a pick-up 
//Banana/Plantain & oil palm conversions from W3
replace conv_fact=0.5 if unit==80 & size==0 & cropcode==2030
replace conv_fact=0.6 if unit==80 & (size==1 | size==.) & cropcode==2030
replace conv_fact=0.7 if unit==80 & size==2 & cropcode==2030
replace conv_fact=0.445 if unit==100 & size==0 & cropcode==2030
replace conv_fact=1.345 if unit==100 & (size==1 | size==.) & cropcode==2030
replace conv_fact=2.12 if unit==100 & size==2 & cropcode==2030
replace conv_fact=5.07 if unit==110 & size==0 & cropcode==2030
replace conv_fact=7.14 if unit==110 & (size==1 | size==.) & cropcode==2030
replace conv_fact=21.62 if unit==110 & size==2 & cropcode==2030

replace conv_fact=0.135 if unit==80 & size==0 & cropcode==2170
replace conv_fact=0.23 if unit==80 & (size==1 | size==.) & cropcode==2170
replace conv_fact=0.34 if unit==80 & size==2 & cropcode==2170
replace conv_fact=0.615 if unit==100 & size==0 & cropcode==2170
replace conv_fact=1.06 if unit==100 & (size==1 | size==.) & cropcode==2170
replace conv_fact=2.1 if unit==100 & size==2 & cropcode==2170
replace conv_fact=3.51 if unit==110 & size==0 & cropcode==2170
replace conv_fact=5.14 if unit==110 & (size==1 | size==.) & cropcode==2170
replace conv_fact=7.965 if unit==110 & size==2 & cropcode==2170

replace conv_fact=5.235 if unit==140 & size==0 & cropcode==2170
replace conv_fact=13.285 if unit==140 & (size==1 | size==.) & cropcode==2170
replace conv_fact=15.972 if unit==140 & size==2 & cropcode==2170
replace conv_fact=3.001 if unit==150 & size==0 & cropcode==2170
replace conv_fact=6.959 if unit==150 & (size==1 | size==.) & cropcode==2170
replace conv_fact=16.11 if unit==150 & size==2 & cropcode==2170

//Oil palm bunch data. Lots of papers report weights, but none report variances, so asessing small/med/large is difficult.
//The lit cites bunch weights anywhere from 15-40 kg, but Nigeria-specific research exclusively cites lower values. Here,
//I use the range from Genotype and genotype by environment (GGE) biplot analysis of fresh fruit bunch yield and yield components of oil palm (Elaeis guineensis Jacq.).
//by Okoye et al (2008) to approximate the field variation.

replace conv_fact=9.5 if unit==100 & size==0 & cropcode==3180
replace conv_fact=14.5 if unit==100 & size==2 & cropcode==3180
replace conv_fact=12 if unit==100 & (size==1 | size==.) & cropcode==3180

//Now one-size-fits-all estimates from WB and external sources to get stragglers 
//These from Local weights and measures in Nigeria: a handbook of conversion factors by Kormawa and Ogundapo
//paint rubber - 2.49 //LSMS says about 2.9
replace conv_fact=2.49 if unit==11 & conv_fact==.
replace conv_fact = 1.36 if (unit==20 | unit==30) & size==0 & conv_fact==. //Lower estimate given by Kormawa and Ogundapo
replace conv_fact = 1.5 if (unit==20 | unit==30) & (size==1 | size==.) & conv_fact==. //congo/mudu value from LSMS W1, assuming medium if left blank
replace conv_fact = 1.74 if (unit==20 | unit==30) & size==2 & conv_fact==. //Upper estimate by K&O
replace conv_fact = 2.72 if unit==50 & size==0 & conv_fact==. //1 tiya=2 mudu
replace conv_fact = 3 if unit==50 & (size==1 | size==.) & conv_fact==. //2x med mudu
replace conv_fact = 3.48 if unit==50 & size==2 & conv_fact==. //2x lg mudu
replace conv_fact = 0.35 if unit==40 & size==0  & conv_fact==. //Small derica from W1
replace conv_fact = 0.525 if unit==40 & (size==1 | size==.) & conv_fact==. //central value
replace conv_fact = 0.7 if unit==40 & size==2 & conv_fact==. & conv_fact==. //large derica from W1
replace conv_fact = 15 if unit==140 & size==0 & conv_fact==. //Small basket from W1
replace conv_fact = 30 if unit==140 & (size==1 | size==.) & conv_fact==. //Med basket W1
replace conv_fact = 50 if unit==140 & size==2 & conv_fact==. //Lg basket W1
replace conv_fact = 85 if unit==170 & size==. & conv_fact==. //Med wheelbarrow w1 

drop if conv_fact==.

collapse (median) conv_fact, by(unit size cropcode condition)
ren conv_fact conv_fact_median
save "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_cf.dta", replace


********************************************************************************
*ALL PLOTS
********************************************************************************
/*ALT 08.16.21: Imported the W3 code for this section 
This code is part of a project to create database-style files for use in AgQuery. At the same time,
it simplifies and reduces the ag indicator construction code. Most files generated by the old code
are still constructed (marked as "legacy" files); some files are eliminated where data were consolidated.
*/
	***************************
	*Crop Values
	***************************
	//Nonstandard unit values
use "${Nigeria_GHS_W4_raw_data}/secta3ii_harvestW4.dta", clear
	//Fstat highly insignificant for yam on price, so we'll lump here.
	replace cropcode=1120 if inrange(cropcode, 1121,1124)
	label define CROPCODE 1120 "1120. YAM", add
	keep if sa3iiq3==1
	ren sa3iiq5a qty
	ren sa3iiq1b condition
	ren sa3iiq1c unit
	ren sa3iiq1d size
	ren sa3iiq6 value
	merge m:1 hhid using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_weights.dta", nogen keepusing(weight_pop_rururb) keep(3)
	//ren cropcode crop_code
	gen price_unit = value/qty
	gen obs=price_unit!=.
	keep if obs==1
	foreach i in zone state lga ea hhid {
		preserve
		bys `i' cropcode unit size condition : egen obs_`i'_price = sum(obs)
		collapse (median) price_unit_`i'=price_unit [aw=weight_pop_rururb], by (`i' unit size condition cropcode obs_`i'_price)
		tempfile price_unit_`i'_median
		save `price_unit_`i'_median'
		restore
	}
	bys cropcode unit size condition : egen obs_country_price = sum(obs)
	collapse (median) price_unit_country = price_unit [aw=weight_pop_rururb], by(cropcode unit size condition obs_country_price)
	tempfile price_unit_country_median
	save `price_unit_country_median'
//Because we have several qualifiers now (size and condition), using kg as an alternative for pricing. Results from experimentation suggests that the kg method is less accurate than using original units, so original units should be preferred.
use "${Nigeria_GHS_W4_raw_data}/secta3ii_harvestW4.dta", clear
	keep if sa3iiq3==1
	replace cropcode=1120 if inrange(cropcode, 1121,1124)
	label define CROPCODE 1120 "1120. YAM", add
	ren sa3iiq5a qty
	ren sa3iiq1b condition
	ren sa3iiq1c unit
	ren sa3iiq1d size
	ren sa3iiq6 value
	merge m:1 hhid using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_weights.dta", nogen keepusing(weight_pop_rururb) keep(1 3)
	merge m:1 cropcode unit size condition using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_cf.dta", nogen keep(1 3)
	//ren cropcode crop_code
	gen qty_kg = qty*conv_fact 
	drop if qty_kg==. //34 dropped; largely basin and bowl.
	gen price_kg = value/qty_kg
	gen obs=price_kg !=.
	keep if obs == 1
	foreach i in zone state lga ea hhid {
		preserve
		bys `i' cropcode : egen obs_`i'_pkg = sum(obs)
		collapse (median) price_kg_`i'=price_kg [aw=weight_pop_rururb], by (`i' cropcode obs_`i'_pkg)
		tempfile price_kg_`i'_median
		save `price_kg_`i'_median'
		restore
	}
	bys cropcode : egen obs_country_pkg = sum(obs)
	collapse (median) price_kg_country = price_kg [aw=weight_pop_rururb], by(cropcode obs_country_pkg)
	tempfile price_kg_country_median
	save `price_kg_country_median'
 
	***************************
	*Plot variables
	***************************
use "${Nigeria_GHS_W4_raw_data}/sect11f_plantingW4.dta", clear
	gen crop_code_11f = cropcode
	merge 1:1 hhid plotid cropcode using "${Nigeria_GHS_W4_raw_data}/secta3i_harvestw4.dta", nogen
	merge 1:1 hhid plotid cropcode using "${Nigeria_GHS_W4_raw_data}/secta3iii_harvestw4.dta", nogen
	//ren cropcode crop_code_a3i 
	ren plotid plot_id
	ren s11fq5 number_trees_planted
	gen use_imprv_seed=s11fq3b==1
	
	gen perm_crop = s11fq0==2
	replace perm_crop = 1 if cropcode==1020 //I don't see any indication that cassava is grown as a seasonal crop in Nigeria
	//replace crop_code_11f=crop_code_a3i if crop_code_11f==.
	//replace crop_code_a3i = crop_code_11f if crop_code_a3i==.
	//gen cropcode =crop_code_11f //Generic level
	replace cropcode = crop_code_11f if cropcode==.
	drop if cropcode == 1010 & ((hhid==50053 & plot_id==2) | (hhid==209107 & plot_id==1)) //Reported as mistaken entries in sa3iq4_os
	recode cropcode (2170=2030) (2142 = 2141) (1121 1122 1123 1124=1120) //Only things that carry over from W3 are bananas/plantains, yams, and peppers. The generic pepper category 2040 in W3 is missing from this wave. //Okay to lump yams for price and unit conversions, not for other things. 
	replace cropcode = 4010 if strpos(sa3iq4_os, "FEED") | regexm(sa3iq4_os, "CONSUMP*TION") | regexm(sa3iq4_os, "ONLY.+LEAVES")
	drop if strpos(sa3iq4_os, "FALLOW") | regexm(sa3iq4_os, "NO.+PLANT") | strpos(sa3iq4_os, "MISTAK")
	label define CROPCODE 1120 "1120. YAM" 4010 "4010. FODDER", add
	la values cropcode CROPCODE
	merge m:1 hhid plot_id using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_plot_areas.dta", nogen keep(3) //ALT 05.03.23
	gen percent_field = s11fq1/100
	replace percent_field = s11fq4/100 if percent_field==. 
	recode percent_field field_size (0=.)
	
	bys hhid plot_id : egen tot_pct_planted = sum(percent_field)
	gen miss_pct = percent_field==. 
	bys hhid plot_id : egen tot_miss = sum(miss_pct)
	gen underplant_pct = 1-tot_pct_planted 
	replace percent_field = underplant_pct/tot_miss if miss_pct & underplant_pct > 0 
	replace percent_field = percent_field/tot_pct_planted if tot_pct_planted > 1
	gen ha_planted = percent_field*field_size
	
	gen pct_harvest=1 if sa3iq4b ==2 | sa3iiiq7==1 //Was area planted less than area harvested? 2=No / In the last 12 months, has your household harvested any <Tree Crop>? They don't ask for area harvested, so I assume that the whole area is harvested (not true for some crops)
	replace pct_harvest = sa3iq5/100 if sa3iq5!=. //1075 obs
	replace pct_harvest = 0 if pct_harvest==. & sa3iq4 < 6
	replace pct_harvest = 1 if cropcode==4010 //Assuming fodder crops were fully "harvested"
	gen ha_harvest=ha_planted*pct_harvest
	
	preserve
		gen obs=1
		replace obs=0 if inrange(sa3iq4,1,5) & s11fq0==1
		collapse (sum) obs, by(hhid plot_id cropcode)
		replace obs = 1 if obs > 1
		collapse (sum) crops_plot=obs, by(hhid plot_id)
		tempfile ncrops 
		save `ncrops'
	restore //14 plots have >1 crop but list monocropping; meanwhile 289 list intercropping or mixed cropping but only report one crop
	merge m:1 hhid plot_id using `ncrops', nogen

	
	gen purestand= crops_plot==1 //This includes replanted crops
	bys hhid plot_id : egen permax = max(perm_crop)
	
	gen planting_year = s11fq3_2
	gen planting_month = s11fq3_1
	gen harvest_month_begin = sa3iq4a1
	gen harvest_year_begin = sa3iq4a2
	gen harvest_year_end = sa3iq6c2
	gen harvest_month_end = sa3iq6c1

	
	*renaming unit code for merge
	//ALT 10.14.21: Tree crop harvests are recorded in both s11f (planting) and sa3iii (harvest); thus, it's likely that s11f has a lot of old harvests (range 2010-2018; mean 2017.365) that we wouldn't want to consider here. However, 465 obs note 2018 (vs 300 in harvest questionnaire), so I replace with sa3iii except when sa3iii is empty and the harvest year is 2018
	ren sa3iq6ii unit
	replace unit = sa3iiiq13c if unit==.
	replace unit = s11fq11b if unit==. & s11fq8b==2018 
	ren sa3iq6_4 size
	replace size = sa3iiiq13d if size==.
	replace size = s11fq11c if size==. & s11fq8b==2018
	ren sa3iq6_2 condition
	replace condition = sa3iiiq13b if condition==.
	replace condition = s11fq11d if condition==. & s11fq8b==2018
	ren sa3iq6i quantity_harvested
	replace quantity_harvested = sa3iiiq13a if quantity_harvested==.
	replace quantity_harvested = s11fq11a if quantity_harvested==. & s11fq8b==2018
	*merging in conversion factors
	merge m:1 cropcode unit size condition using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_cf.dta", keep(1 3) nogen //Only 169 obs of units unmerged. 
	replace conv_fact=1 if conv_fact==. & unit==1
	gen quant_harv_kg = quantity_harvested * sa3iq6_conv
	replace quant_harv_kg = quantity_harvested * sa3iiiq13_conv if quant_harv_kg == .
	replace quant_harv_kg = quantity_harvested * conv_fact if quant_harv_kg == .
	//gen quant_harv_kg= quantity_harvested*conv_fact
	ren sa3iq6a val_harvest_est
	replace val_harvest_est = sa3iiiq14 if val_harvest_est==.
	//ALT 09.28.22: I'm going to keep the grower-estimated valuation in here even though it's likely inaccurate for comparison purposes.
	gen val_unit_est = val_harvest_est/quantity_harvested
	gen val_kg_est = val_harvest_est/quant_harv_kg
	merge m:1 hhid using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_weights.dta", nogen keep(1 3)
	gen plotweight = ha_planted*weight_pop_rururb
	//IMPLAUSIBLE ENTRIES - at least 100x the typical yield
	foreach var in quantity_harvested quant_harv_kg val_harvest_est val_unit_est val_kg_est {
	replace `var' = . if (hhid == 299005 & plot_id == 2 & cropcode == 1020) | /* 2000 heaps of cassava on 0.003 ha 
	*/ (hhid == 339038 & plot_id == 2 & cropcode == 2190) | /* 5 tons of pumpkins on 0.0075 ha, an area smaller than my apartment
	*/ (hhid == 229068 & plot_id == 2 & cropcode == 1121) | /* 17 tons of yams on 0.144 ha
	*/ (hhid == 120058 & plot_id == 3 & cropcode == 1121) //14 tons of yams on 0.1 ha.
	}
	gen obs=quantity_harvested>0 & quantity_harvested!=.

foreach i in zone state lga ea hhid {
	merge m:1 `i' unit size condition cropcode using `price_unit_`i'_median', nogen keep(1 3)
	merge m:1 `i' cropcode using `price_kg_`i'_median', nogen keep(1 3)
}
merge m:1 unit size condition cropcode using `price_unit_country_median', nogen keep(1 3)
*merge m:1 unit size condition cropcode using `val_unit_country_median', nogen keep(1 3)
merge m:1 cropcode using `price_kg_country_median', nogen keep(1 3)
*merge m:1 cropcode using `val_kg_country_median', nogen keep(1 3)

//We're going to prefer observed prices first
gen price_unit = . 
gen price_kg = .
recode obs_* (.=0)
foreach i in country zone state lga ea {
	replace price_unit = price_unit_`i' if obs_`i'_price>9 & price_unit_`i'!=.
	replace price_kg = price_kg_`i' if obs_`i'_pkg>9 & price_kg_`i'!=. 
}
	ren price_unit_hhid price_unit_hh 
	ren price_kg_hhid price_kg_hh
	
	replace price_unit_hh = price_unit if price_unit_hh==.
	replace price_kg_hh = price_kg if price_kg_hh==.
	gen value_harvest = price_unit * quantity_harvested
	replace value_harvest = price_kg * quant_harv_kg if value_harvest == .
	replace value_harvest = val_harvest_est if value_harvest == .
	gen value_harvest_hh= price_unit_hh*quantity_harvested 
	replace value_harvest_hh=price_kg_hh*quant_harv_kg if value_harvest_hh==.
	replace value_harvest_hh=value_harvest if value_harvest==.
	
//A few situations (mainly cocoa) where the grower estimated price is substantially below the area median.	

	//Replacing conversions for unknown units
	replace val_unit_est = value_harvest/quantity_harvested if val_unit_est==.
	replace val_kg_est = value_harvest/quant_harv_kg if val_kg_est == .

preserve
//ALT note to double check and see if the changes to valuation mess this up.
	replace val_kg = val_kg_est if val_kg==.
	collapse (mean) val_kg=price_kg conv_fact, by(hhid cropcode)
	save "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_hh_crop_prices_kg.dta", replace //Backup for s-e income.
restore
preserve
	//ALT 02.10.22: NOTE: This should be changed to ensure we get all household values rather than just ones with recorded harvests (although I imagine the number of households that paid in a crop they did not harvest is small)
	replace val_unit = val_unit_est if val_unit==.
	collapse (mean) val_unit=price_unit, by (hhid cropcode unit size condition)
	drop if unit == .
	ren val_unit hh_price_mean
	lab var hh_price_mean "Average price reported for this crop-unit in the household"
	save "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_hh_crop_prices_for_wages.dta", replace //This gets used for self-employment income
restore
	//still-to-harvest value
	gen same_unit=unit==sa3iq6d2 & size==sa3iq6d4 & condition==sa3iq6d2a & unit!=.
	replace price_unit = value_harvest/quantity_harvested if same_unit==1 & price_unit==.
	//ALT 05.12.21: I feel like we should include the expected harvest.
	//Addendum 10.14: Unfortunately we can only reliably do this for annual crops because the question for tree crops was asked in the planting survey; estimates are probably not reliable.
	//Addendum to addendum 9.28.22: The plant survey also asks about temporary crops, not just tree crops. This was causing estimated harvests to be far too high.
	//Addendum to addendum 9.30.24: Adding an additional criterion to only include harvests that had been started, some long-haul crops like cassava and yam were probably not intended for harvest this year.
	replace sa3iq6d1 = . if sa3iq6d1 > 19000 //This corrects two plots, one where the household anticipates harvesting 20,000 paint rubbers of peppers (2000x current harvest) and another that anticipates 722,500 bags of rice.
	drop unit size condition quantity_harvested
	ren sa3iq6d2 unit
	ren sa3iq6d4 size
	ren sa3iq6d2a condition
	ren sa3iq6d1 quantity_harvested
	//replace quantity_harvested = . if hhid == 220016 & plot_id==2 & cropcode==1121 //One obs of 2000 pickups on a quarter of a hectare. Planting estimate was 1 pickup; likely a unit typo. //ALT: Excluded by the 9.30.24 update
	gen quant_harv_kg2 = quantity_harvested * sa3iq6d_conv
	replace quant_harv_kg2 = quantity_harvested * conv_fact if same_unit == 1
	drop conv_fact
	merge m:1 cropcode unit size condition using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_cf.dta", nogen keep(1 3)
	replace quant_harv_kg2= quantity_harvested*conv_fact if quant_harv_kg2 == .
	gen val_harv2 = 0
	gen val_harv2_hh=0
	recode quant_harv_kg2 quantity_harvested value_harvest (.=0) //ALT 02.10.22: This is causing people with "still to harvest" values getting missing where they should have something.
	replace val_harv2=quantity_harvested*price_unit if val_harv2==0 & same_unit==1  //Use household price for consistency. (see line 959)
	replace val_harv2=quant_harv_kg*price_kg if val_harv2==0 
	replace val_harv2_hh = quantity_harvested*price_unit_hh 
	replace val_harv2_hh = quant_harv_kg * price_kg_hh if val_harv2_hh==0
	gen missing_unit =val_harv2 == 0

	replace quant_harv_kg = quant_harv_kg+quant_harv_kg2 if sa3iq3==1
	replace quant_harv_kg = quant_harv_kg2 if sa3iq3==1 & quant_harv_kg==. //this annoying two-step here to deal with how stata processes missing values and the desire to avoid introducing spurious 0s.
	replace value_harvest = value_harvest+val_harv2 if sa3iq3==1 
	replace value_harvest = val_harv2 if sa3iq3==1 & value_harvest==.
	replace value_harvest_hh = value_harvest_hh + val_harv2_hh if sa3iq3==1
	replace value_harvest_hh = val_harv2_hh if sa3iq3==1 & value_harvest==.
	replace ha_harvest = ha_planted if sa3iq3==1 & !inlist(quant_harv_kg2,0,.) & !inlist(sa3iq4c, 1, .)
	replace cropcode = 1124 if crop_code_11f==1124 //Removing three-leaved yams from yams. 
	gen lost_crop=inrange(sa3iq4,1,5) & s11fq0==1
	gen lost_drought = sa3iq4==1 | sa3iq4c==2
	gen lost_flood = sa3iq4==2 | sa3iq4c==3
	gen lost_pest = sa3iq4==3 | sa3iq4c==4
	gen no_harvest = sa3iq4 >= 6 & sa3iq4 <=10
	collapse (sum) quant_harv_kg value_harvest* /*val_harvest_est*/ ha_planted ha_harvest number_trees_planted percent_field (max) lost_pest lost_flood lost_drought no_harvest use_imprv_seed, by(zone state lga sector ea hhid plot_id cropcode purestand field_size gps_meas)
	bys hhid plot_id : gen count_crops = _N
	recode ha_planted (0=.)
	replace purestand = 0 if count_crops > 1 & purestand==1 //Three plots no longer considered monocropped after the disaggregation.
	bys hhid plot_id : egen percent_area = sum(percent_field)
	bys hhid plot_id : gen percent_inputs = percent_field/percent_area
	drop percent_area //Assumes that inputs are +/- distributed by the area planted. Probably not true for mixed tree/field crops, but reasonable for plots that are all field crops
	//Labor should be weighted by growing season length, though. 
	replace ha_harvest=. if (ha_harvest==0 & no_harvest==1) | (ha_harvest==0 & quant_harv_kg>0 & quant_harv_kg!=.)
	replace quant_harv_kg = . if quant_harv_kg==0 & no_harvest==1
	drop no_harvest
	drop if (ha_planted==0 | ha_planted==.) & (ha_harvest==0 | ha_harvest==.) & (quant_harv_kg==0 | quant_harv_kg==.)
	merge m:1 hhid plot_id using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_plot_decision_makers.dta", nogen keep(1 3) keepusing(dm*)
		//We remove small planted areas from the sample for yield, as these areas are likely undermeasured/underestimated and cause substantial outliers. The harvest quantities are retained for farm income and production estimates. 
	gen ha_harv_yld = ha_harvest if ha_planted >=0.05
	gen ha_plan_yld = ha_planted if ha_planted >=0.05
	save "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_all_plots.dta",replace



















use "${Nigeria_GHS_W4_raw_data}/secta11c3_harvestw4.dta", clear
gen qty=s11c3q4a*s11c3q4_conv
ren s11c3q5 val
ren s11c3q4b unit
recode unit (4=3) (2 10 11 12 13 30 31 50 51 52=1) //Everything has been converted to kg/L
replace val=s11c3q10 if inputid==7 | inputid==8 //Equipment rental costs 
//Now we have all hhs for the value calculations and can keep track of implicit/explicit costs later. This'll partially correct for the fact that
//the enumerators stopped asking about free inputs in W3.
keep zone state lga sector ea hhid inputid qty val unit
/*merge 1:1 hhid inputid using `impl_inputs'
replace cost_implicit=0 if _merge!=2
drop _merge
gen exp="exp" if cost_implicit==0
replace exp="imp" if cost_implicit==1 */
//ALT 07.03.20 Note, if _merge==1, this implies that the hh bought inputs but didn't use them. 
gen input = "orgfert" if inputid==1
replace input = "npk_fert" if inputid==2
replace input = "urea" if inputid==3
replace input = "other_fert" if inputid==4
replace input = "pest" if inputid==5
replace input = "herb" if inputid==6
replace input = "mech" if inputid==7 | inputid==8
replace qty = 0 if inputid==7 | inputid==8
replace unit = 0 if inputid==7 | inputid==8
drop inputid
preserve
	keep if strmatch(input,"mech") //We'll add these back in after we do prices
	collapse (sum) val, by(hhid input qty unit)
	tempfile mechrenttemp
	save `mechrenttemp'
	use "${Nigeria_GHS_W4_raw_data}/secta11c2_harvestw4.dta", clear
	gen use_mech=s11c2q27==1
	ren plotid plot_id
	merge 1:1 hhid plot_id using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_plot_areas.dta", nogen keep(1 3) keepusing(field_size)
	gen mech_area = field_size*use_mech 
	bys hhid : egen total_mech_area = sum(mech_area)
	gen frac_mech_area = mech_area/total_mech_area 
	merge m:1 hhid using `mechrenttemp', nogen 
	replace val=val*frac_mech_area if frac_mech_area!=.
	keep if val!=.
	keep zone state lga ea hhid plot_id qty unit input val 
		gen exp="exp"
	tempfile mechrent
	save `mechrent'
restore
drop if strmatch(input,"mech")
merge m:1 hhid using "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_weights.dta", nogen keepusing(weight_pop_rururb)
replace weight=0 if weight==.
gen price = val/qty
recode price (0=.)
gen obs=price!=.
tempfile phys_inputs
save `phys_inputs'

drop if unit == 0 | unit==. //Dropping things that don't have units
foreach i in zone state lga ea hhid {
preserve
	bys `i' input unit : egen obs_`i' = sum(obs)
	collapse (median) price_`i'=price [aw=weight_pop_rururb], by (`i' input unit obs_`i')
	tempfile price_`i'_median
	save `price_`i'_median'
restore
}

preserve
bys input unit : egen obs_country = sum(obs)
collapse (median) price_country = price [aw=weight_pop_rururb], by(input unit obs_country)
tempfile price_country_median
save `price_country_median'
restore

keep hhid input qty
ren qty hhqty
reshape wide hhqty, i(hhid) j(input) string //Determining implicit ratios
tempfile hhqty
save `hhqty'

use "${Nigeria_GHS_W4_raw_data}/secta11c2_harvestw4.dta", clear
gen qtyherb=s11c2q11a*s11c2q11_conv 
gen qtypest=s11c2q2a*s11c2q2_conv 
gen qtynpk_fert=s11c2q37a*s11c2q37a_conv 

gen qtyurea = s11c2q38a*s11c2q38a_conv
gen qtyorgfert = s11dq37a*s11c2q37_conv //This looks wrong but it isn't
gen qtyother_fert=s11c2q39a*s11c2q39a_conv 
ren s11c2q11b unitherb
ren s11c2q2b unitpest
ren s11c2q37b unitnpk_fert
ren s11c2q38b uniturea
ren s11c2q39b unitother_fert
ren s11dq37b unitorgfert
ren plotid plot_id 
replace qtyurea = . if uniturea == 12 & s11c2q38a > 1000
preserve
collapse (sum) qty*, by(hhid)
merge 1:1 hhid using `hhqty'
reshape long hhqty qty, i(hhid) j(input) string
recode hhqty qty (.=0)
gen exp_ratio = hhqty/qty if qty!=0
drop if exp_ratio==.
replace exp_ratio = 1 if exp_ratio > 1
//"hhqty" is the amount purchased by the household, qty is the amount used. If hhqty > qty, the household bought more than it used, and we can assume it paid for all of its inputs.
//if hhqty < qty, the household used more than it bought and so some proportion of the plot inputs come from leftover or free supplies and should be considered implicit.
//if hhqty > 0 but qty==0, the household bought but did not use, and those expenses don't get considered (might be an issue for panel households, because those purchases would become implicit next season 
//but were never accounted for as a household purchase)

tempfile exp_ratios
save `exp_ratios'
restore

recode unit* (4=3) (2 10 11 12 13 30 31 50 51 52=1) //Everything has been converted to kg/L
keep zone state lga ea hhid plot_id qty* unit* 
reshape long qty unit, i(zone state lga ea hhid plot_id) j(input) string

foreach i in zone state lga ea hhid {
	merge m:1 `i' input unit using `price_`i'_median', nogen keep(1 3) 
}
	merge m:1 input unit using `price_country_median', nogen keep(1 3)
	recode price_hhid (.=0)
	gen price=price_hhid
foreach i in country zone state lga ea {
	replace price = price_`i' if obs_`i' > 9 & obs_`i'!=.
}
//Default to household prices when available
replace price = price_hhid if price_hhid>0
replace qty = 0 if qty <0 //4 households reporting negative quantities of fertilizer.
gen val = qty*price
drop if val==0 | val==.
merge m:1 hhid input using `exp_ratios', nogen keep(1 3)
recode exp_ratio (.=0) //If there's no match, the hh recorded using an input but didn't provide any information related to its purchase 
gen qtyexp = qty*exp_ratio 
gen qtyimp = qty-qtyexp 
gen valexp = val*exp_ratio 
gen valimp = val-valexp
gen unitimp = unit
gen unitexp = unit
//Fertilizer units

//We can estimate how many nutrient units were applied for most fertilizers; dry urea is 46% N and NPK can have several formulations; we go with a weighted average of 18-12-11 based on https://africafertilizer.org/#/en/vizualizations-by-topic/consumption-data/
gen inorg_fert_kg = qty*strmatch(input, "npk_fert") + qty*strmatch(input, "urea") + qty*strmatch(input, "other_fert")

gen n_kg = qty*strmatch(input, "npk_fert")*0.18 + qty*strmatch(input, "urea")*0.46
gen p_kg = qty*strmatch(input, "npk_fert")*0.12
gen k_kg = qty*strmatch(input, "npk_fert")*0.11
gen n_org_kg = qty*strmatch(input,"orgfert")*0.01
la var n_kg "Kg of nitrogen applied to plot from inorganic fertilizer"
la var p_kg "Kg of phosphorus applied to plot from inorganic fertilizer"
la var k_kg "Kg of potassium applied to plot from inorganic fertilizer"
la var n_org_kg "Kg of nitrogen from manure and organic fertilizer applied to plot"
gen npk_kg = qty*strmatch(input, "npk_fert")
gen urea_kg = qty*strmatch(input, "urea")
la var npk_kg "Total quantity of NPK fertilizer applied to plot"
la var urea_kg "Total quantity of urea fertilizer applied to plot"
collapse (sum) *kg (max) price, by( hhid plot_id)
save "${Nigeria_GHS_W4_created_data}/fert_units.dta", replace











***********************************************************************************************************************************************
*Merging Dataset
***********************************************************************************************************************************************



//////////////Checking for maize and taking it to the plot level. Currently at the cropcode level...............

use  "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_all_plots.dta",clear

sort hhid plot_id
count
count if cropcode==1080
keep if cropcode==1080

order hhid plot_id cropcode quant_harv_kg value_harvest ha_harvest percent_inputs field_size purestand

collapse (sum) quant_harv_kg value_harvest ha_planted ha_harvest (max) percent_inputs field_size purestand, by (hhid plot_id)

merge 1:1 hhid plot_id using "${Nigeria_GHS_W4_created_data}/fert_units.dta", gen(fert)


gen year = 2018
save "${Nigeria_GHS_W4_created_data}/checking_plot.dta", replace



*********
use "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_all_plots.dta",clear

sort hhid 
count
count if cropcode==1080
keep if cropcode==1080

order hhid plot_id cropcode quant_harv_kg value_harvest ha_harvest percent_inputs field_size purestand

collapse (sum) quant_harv_kg value_harvest ha_planted ha_harvest (max) percent_inputs field_size purestand, by (hhid plot_id)

merge 1:1 hhid plot_id using "${Nigeria_GHS_W5_created_data}/fert_units.dta", gen(fert)

gen year =2023





******


append using "${Nigeria_GHS_W4_created_data}/checking_plot.dta"


save "${Nigeria_GHS_W4_created_data}/apppend_plot.dta", replace


order year


gen dummy = 1

collapse (sum) dummy, by (hhid plot_id)
tab dummy
keep if dummy==2


merge 1:m hhid plot_id  using "${Nigeria_GHS_W4_created_data}/apppend_plot.dta", gen(fil)

drop if fil==2

order year

sort hhid  year
tab ha_planted if ha_planted == 0 | ha_planted == .
drop if ha_planted == 0 | ha_planted == .




sum ha_planted if year ==2023, detail
sum ha_planted if year ==2018, detail
sum quant_harv_kg if year ==2023, detail
sum quant_harv_kg if year ==2018, detail
gen yield_plot =  quant_harv_kg/ ha_planted

sum yield_plot if year ==2023, detail
sum yield_plot if year ==2018, detail


foreach v of varlist  value_harvest  {
	_pctile `v' , p(5 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}


foreach v of varlist  n_kg  {
	_pctile `v' , p(5 95) 
	gen `v'_w=`v'
	replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}

sum value_harvest if year ==2023, detail
sum value_harvest if year ==2018, detail

sum value_harvest_w if year ==2023, detail
sum value_harvest_w if year ==2018, detail

sum field_size if year ==2023, detail
sum field_size if year ==2018, detail
count

*replace inorg_fert_kg = 450 if inorg_fert_kg >= 450 & year == 2023
*replace inorg_fert_kg = 650 if inorg_fert_kg >= 650 & year == 2018

*replace n_kg = 160 if n_kg >= 160 & year == 2023
*replace n_kg = 206 if n_kg >= 206 & year == 2018



sum inorg_fert_kg if year ==2023, detail
sum inorg_fert_kg if year ==2018, detail

sum n_kg if year ==2023, detail
sum n_kg if year ==2018, detail


gen fert_rate = inorg_fert_kg/ field_size
gen n_rate = n_kg/ field_size


sum fert_rate if year ==2023, detail
sum fert_rate if year ==2018, detail

sum n_rate if year ==2023, detail
sum n_rate if year ==2018, detail


************************ttest****************

* Step 1: Keep only 2018 and 2023 data
keep if year == 2018 | year == 2023

* Step 2: Create unique plot ID if needed
gen plot_key = string(hhid) + "_" + string(plot_id)

* Step 3: Reshape to wide format for each variable
reshape wide ha_planted quant_harv_kg yield_plot value_harvest inorg_fert_kg n_kg fert_rate n_rate, i(plot_key) j(year)

* Step 4: Paired t-tests for each variable
ttest ha_planted2023 == ha_planted2018
ttest quant_harv_kg2023 == quant_harv_kg2018
ttest yield_plot2023 == yield_plot2018
ttest value_harvest2023 == value_harvest2018
ttest inorg_fert_kg2023 == inorg_fert_kg2018
ttest n_kg2023 == n_kg2018
ttest fert_rate2023 == fert_rate2018
ttest n_rate2023 == n_rate2018






//////////////Checking for maize and taking it to the hhid level. Currently at the cropcode level...............

use "${Nigeria_GHS_W4_created_data}/fert_units.dta", clear

collapse (sum) *kg (max) price , by(hhid)

save "${Nigeria_GHS_W4_created_data}/fert_unitshh.dta", replace




use  "${Nigeria_GHS_W4_created_data}/Nigeria_GHS_W4_all_plots.dta",clear

sort hhid plot_id
count
count if cropcode==1080
*keep if cropcode==1080

order hhid plot_id cropcode quant_harv_kg value_harvest ha_harvest percent_inputs field_size purestand

collapse (sum) quant_harv_kg value_harvest ha_planted ha_harvest (max) percent_inputs field_size purestand, by (hhid)






merge 1:1 hhid using "${Nigeria_GHS_W4_created_data}/fert_unitshh.dta", gen(fert)


gen year = 2018
save "${Nigeria_GHS_W4_created_data}/checking.dta", replace






use "${Nigeria_GHS_W5_created_data}/fert_units.dta", clear

collapse (sum) *kg (max) price , by(hhid)


save "${Nigeria_GHS_W5_created_data}/fert_unitshh.dta", replace



use "${Nigeria_GHS_W5_created_data}/Nigeria_GHS_W5_all_plots.dta",clear

sort hhid 
count
count if cropcode==1080
*keep if cropcode==1080

order hhid plot_id cropcode quant_harv_kg value_harvest ha_harvest percent_inputs field_size purestand

collapse (sum) quant_harv_kg value_harvest ha_planted ha_harvest (max) percent_inputs field_size purestand, by (hhid)

merge 1:1 hhid using "${Nigeria_GHS_W5_created_data}/fert_unitshh.dta", gen(fert)

gen year =2023



append using "${Nigeria_GHS_W4_created_data}/checking.dta"


save "${Nigeria_GHS_W4_created_data}/apppend.dta", replace


order year


gen dummy = 1

collapse (sum) dummy, by (hhid)
tab dummy
keep if dummy==2


merge 1:m hhid  using "${Nigeria_GHS_W4_created_data}/apppend.dta", gen(fil)

drop if fil==2

order year

sort hhid  year


*tab if ha_planted == 0 | ha_planted == .
drop if ha_planted == 0 | ha_planted == .

replace price = 7500 if price >= 7500 & year == 2023
replace price = 2500 if price >= 2500 & year == 2018


sum price if year ==2023, detail
sum price if year ==2018, detail

sum ha_planted if year ==2023, detail
sum ha_planted if year ==2018, detail
sum quant_harv_kg if year ==2023, detail
sum quant_harv_kg if year ==2018, detail
gen yield_plot =  quant_harv_kg/ ha_planted

sum yield_plot if year ==2023, detail
sum yield_plot if year ==2018, detail


foreach v of varlist  value_harvest  {
	_pctile `v' , p(5 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}


sum value_harvest_w if year ==2023, detail
sum value_harvest_w if year ==2018, detail

sum field_size if year ==2023, detail
sum field_size if year ==2018, detail
count

replace inorg_fert_kg = 400 if inorg_fert_kg >= 400 & year == 2023
replace inorg_fert_kg = 900 if inorg_fert_kg >= 900 & year == 2018


replace inorg_fert_kg = 750 if inorg_fert_kg >= 750 & year == 2023
replace inorg_fert_kg = 1500 if inorg_fert_kg >= 1500 & year == 2018



replace n_kg = 131 if n_kg >= 131 & year == 2023
replace n_kg = 256 if n_kg >= 256 & year == 2018


replace ha_planted = 1.5 if ha_planted >= 1.5 & year == 2023
replace ha_planted = 2 if ha_planted >= 2 & year == 2018

sum inorg_fert_kg if year ==2023, detail
sum inorg_fert_kg if year ==2018, detail

sum n_kg if year ==2023, detail
sum n_kg if year ==2018, detail


gen fert_rate = inorg_fert_kg/ ha_planted
gen n_rate = n_kg/ ha_planted

gen productivity = value_harvest/ ha_planted

sum productivity if year ==2023, detail
sum productivity if year ==2018, detail

foreach v of varlist  productivity  {
	_pctile `v' , p(5 95) 
	gen `v'_w=`v'
	*replace  `v'_w = r(r1) if  `v'_w < r(r1) &  `v'_w!=.
	replace  `v'_w = r(r2) if  `v'_w > r(r2) &  `v'_w!=.
	local l`v' : var lab `v'
	lab var  `v'_w  "`l`v'' - Winzorized top & bottom 1%"
}

sum productivity_w if year ==2023, detail
sum productivity_w if year ==2018, detail


sum fert_rate if year ==2023, detail
sum fert_rate if year ==2018, detail

sum n_rate if year ==2023, detail
sum n_rate if year ==2018, detail


**********************************

* Step 1: Keep only relevant years
keep if year == 2018 | year == 2023

* Step 2: Reshape wide by household
reshape wide quant_harv_kg yield_plot value_harvest, i(hhid) j(year)

* Step 3: Paired t-tests for each variable
ttest quant_harv_kg2023 == quant_harv_kg2018
ttest yield_plot2023 == yield_plot2018
ttest value_harvest2023 == value_harvest2018
ttest inorg_fert_kg2023 == inorg_fert_kg2018
ttest n_kg2023 == n_kg2018


