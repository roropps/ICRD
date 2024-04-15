capture program drop heatmaster
capture program drop progA
capture program drop progB
capture program drop progC
capture program drop progD
capture program drop prog
capture program drop progBETA
capture log close
*Created on March 30
*Updated on April 12, 2024
program progA

clear

import excel "F:\2024\HKU_Mar\IDRC\Stata_Liu\raw_data.xlsx", sheet("Sheet1") firstrow
*************************

*this program transfer RR and its standard error into log term


//Define the variable lists
local rr rrlag0 rrlag1_5 rrlag6_21
local topci topci0 topci1_5 topci6_21
local bottomci bottomci0 bottomci1_5 bottomci6_21

//Transaform RR and CI into log scale

foreach var of varlist rrlag0 bottomci0 topci0 rrlag1_5 bottomci1_5 topci1_5 rrlag6_21 bottomci6_21 topci6_21{
capture gen log`var'=ln(`var')
}
 
//Make the RR's SD out of CI difference in log term
local sd sd0 sd1_5 sd6_21
local logrrlag logrrlag0 logrrlag1_5 logrrlag6_21 //draw a normal mean of rr and sd in log term
local logtopci logtopci0 logtopci1_5 logtopci6_21
local logbottomci logbottomci0 logbottomci1_5 logbottomci6_21
foreach i in 0 1_5 6_21 {
    capture gen logsd`i' = (logtopci`i' - logbottomci`i') / 3.92
}
end


program progB
//take a random draw from the normal distribution with the mean and standard error in log term) and exponentiate to give the lognormally distributed relative risk
foreach male in 0 1 {
	foreach age in 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 {
		foreach i in 0 1_5 6_21 {
			 capture qui sum logrrlag`i' if age == `age' & male == `male'
			 capture scalar logrrlag`i'_a_`age's_`male' = r(mean)
			 capture qui sum logsd`i' if age == `age' & male == `male'
			 capture scalar logsd`i'_a_`age's_`male' = r(mean)
		}
		capture qui sum dailydeath if age == `age' & male == `male'
		capture scalar dailydeath_a_`age's_`male' = r(mean)
	}
}


//calculate the stochastic heat death: exp(random draw from normal distribution of logRR and logRRSD)* daily death
**
foreach male in 0 1 {
	foreach age in 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 {
		foreach i in 0 1_5 6_21 {
			set seed 0
			*capture scalar hdp_`i'_`age'_`male' = exp((invnorm   (uniform()  ) * logsd`i'_a_`age's_`male') + logrrlag`i'_a_`age's_`male')
			capture scalar hdp_`i'_`age'_`male' = exp(   (invnorm(uniform())) * (logsd`i'_a_`age's_`male') + (logrrlag`i'_a_`age's_`male'))
		}
	}
}
end


program progC
progA
progB
*Calculate the daily heat death
foreach male in 0 1 {
	foreach age in 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85{
		foreach i in 0 1_5 6_21 {
			capture gen hd`i'_a_`age's_`male'= hdp_`i'_`age'_`male' * dailydeath_a_`age's_`male'
			capture qui sum hd`i'_a_`age's_`male'if age == `age' & male == `male'
			scalar hd`i'_a_`age's_`male' = hdp_`i'_`age'_`male' * dailydeath_a_`age's_`male'
		}
	}
}
end


program progD
progA
progB
progC
*Caluculate the excess death due to heat
foreach male in 0 1 {
    foreach age in 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 {
        foreach i in 0 1_5 6_21 {
			if "`i'" == "0" {
				capture gen ehd`i'_a_`age's_`male' = (hd`i'_a_`age's_`male' - dailydeath_a_`age's_`male') * 1
				capture qui sum ehd`i'_a_`age's_`male'if age == `age' & male == `male'
     			scalar ehd`i'_a_`age's_`male' = (hd`i'_a_`age's_`male' - dailydeath_a_`age's_`male') * 1

			}
            if "`i'" == "1_5" {
				capture gen ehd`i'_a_`age's_`male' = (hd`i'_a_`age's_`male' - dailydeath_a_`age's_`male') * 5
				capture qui sum ehd`i'_a_`age's_`male'if age == `age' & male == `male'
				scalar ehd`i'_a_`age's_`male' = (hd`i'_a_`age's_`male' - dailydeath_a_`age's_`male') * 5

			}
            if "`i'" == "6_21" {
      			capture gen ehd`i'_a_`age's_`male' = (hd`i'_a_`age's_`male' - dailydeath_a_`age's_`male') * 15
				capture qui sum ehd`i'_a_`age's_`male'if age == `age' & male == `male'
                scalar ehd`i'_a_`age's_`male' = (hd`i'_a_`age's_`male' - dailydeath_a_`age's_`male') * 15
			}
		}
	}
}
end





program progEHD
postfile mymcsresult ehd0_0_0 ehd0_5_0 ehd0_10_0 ehd0_15_0 ehd0_20_0 ehd0_25_0 ehd0_30_0 ehd0_35_0 ehd0_40_0 ehd0_45_0 ehd0_50_0 ehd0_55_0 ehd0_60_0 ehd0_65_0 ehd0_70_0 ehd0_75_0 ehd0_80_0 ehd0_85_0 ehd0_0_1 ehd0_5_1 ehd0_10_1 ehd0_15_1 ehd0_20_1 ehd0_25_1 ehd0_30_1 ehd0_35_1 ehd0_40_1  ehd0_45_1 ehd0_50_1 ehd0_55_1 ehd0_60_1 ehd0_65_1 ehd0_70_1 ehd0_75_1 ehd0_80_1 ehd0_85_1 ehd1_5_0_0 ehd1_5_5_0 ehd1_5_10_0 ehd1_5_15_0 ehd1_5_20_0 ehd1_5_25_0 ehd1_5_30_0  ehd1_5_35_0 ehd1_5_40_0 ehd1_5_45_0 ehd1_5_50_0 ehd1_5_55_0 ehd1_5_60_0 ehd1_5_65_0 ehd1_5_70_0 ehd1_5_75_0 ehd1_5_80_0 ehd1_5_85_0 ehd1_5_0_1 ehd1_5_5_1 ehd1_5_10_1 ehd1_5_15_1 ehd1_5_20_1 ehd1_5_25_1 ehd1_5_30_1 ehd1_5_35_1 ehd1_5_40_1 ehd1_5_45_1 ehd1_5_50_1 ehd1_5_55_1 ehd1_5_60_1 ehd1_5_65_1 ehd1_5_70_1 ehd1_5_75_1 ehd1_5_80_1 ehd1_5_85_1 ehd6_21_0_0 ehd6_21_5_0 ehd6_21_10_0 ehd6_21_15_0 ehd6_21_20_0 ehd6_21_25_0 ehd6_21_30_0 ehd6_21_35_0 ehd6_21_40_0 ehd6_21_45_0 ehd6_21_50_0 ehd6_21_55_0 ehd6_21_60_0 ehd6_21_65_0 ehd6_21_70_0 ehd6_21_75_0 ehd6_21_80_0 ehd6_21_85_0 ehd6_21_0_1 ehd6_21_5_1 ehd6_21_10_1 ehd6_21_15_1 ehd6_21_20_1 ehd6_21_25_1 ehd6_21_30_1 ehd6_21_35_1 ehd6_21_40_1 ehd6_21_45_1 ehd6_21_50_1 ehd6_21_55_1 ehd6_21_60_1 ehd6_21_65_1 ehd6_21_70_1 ehd6_21_75_1 ehd6_21_80_1 ehd6_21_85_1 using mymcsresult, replace
local index=1
while `index'<1001{
progD
post ehd0_0_0(r(ehd0_a_0s_0)) ehd0_5_0(r(ehd0_a_5s_0)) ehd0_10_0(r(ehd0_a_10s_0)) ehd0_15_0(r(ehd0_a_15s_0)) ehd0_20_0(r(ehd0_a_20s_0)) ehd0_25_0(r(ehd0_a_25s_0)) ehd0_30_0(r(ehd0_a_30s_0)) ehd0_35_0(r(ehd0_a_35s_0)) ehd0_40_0(r(ehd0_a_40s_0)) ehd0_45_0(r(ehd0_a_45s_0)) ehd0_50_0(r(ehd0_a_50s_0)) ehd0_55_0(r(ehd0_a_55s_0)) ehd0_60_0(r(ehd0_a_60s_0)) ehd0_65_0(r(ehd0_a_65s_0)) ehd0_70_0(r(ehd0_a_70s_0)) ehd0_75_0(r(ehd0_a_75s_0)) ehd0_80_0(r(ehd0_a_80s_0)) ehd0_85_0(r(ehd0_a_85s_0)) ehd0_0_1(r(ehd0_a_0s_1)) ehd0_5_1(r(ehd0_a_5s_1)) ehd0_10_1(r(ehd0_a_10s_1)) ehd0_15_1(r(ehd0_a_15s_1)) ehd0_20_1(r(ehd0_a_20s_1)) ehd0_25_1(r(ehd0_a_25s_1)) ehd0_30_1(r(ehd0_a_30s_1)) ehd0_35_1(r(ehd0_a_35s_1)) ehd0_40_1(r(ehd0_a_40s_1)) ehd0_45_1(r(ehd0_a_45s_1)) ehd0_50_1(r(ehd0_a_50s_1)) ehd0_55_1(r(ehd0_a_55s_1)) ehd0_60_1(r(ehd0_a_60s_1)) ehd0_65_1(r(ehd0_a_65s_1)) ehd0_70_1(r(ehd0_a_70s_1)) ehd0_75_1(r(ehd0_a_75s_1)) ehd0_80_1(r(ehd0_a_80s_1)) ehd0_85_1(r(ehd0_a_85s_1)) ehd1_5_0_0(r(ehd1_5_a_0s_0)) ehd1_5_5_0(r(ehd1_5_a_5s_0)) ehd1_5_10_0(r(ehd1_5_a_10s_0)) ehd1_5_15_0(r(ehd1_5_a_15s_0)) ehd1_5_20_0(r(ehd1_5_a_20s_0)) ehd1_5_25_0(r(ehd1_5_a_25s_0)) ehd1_5_30_0 (r(ehd1_5_a_30s_0)) ehd1_5_35_0(r(ehd1_5_a_35s_0)) ehd1_5_40_0(r(ehd1_5_a_40s_0)) ehd1_5_45_0(r(ehd1_5_a_45s_0)) ehd1_5_50_0(r(ehd1_5_a_50s_0)) ehd1_5_55_0(r(ehd1_5_a_55s_0)) ehd1_5_60_0(r(ehd1_5_a_60s_0)) ehd1_5_65_0(r(ehd1_5_a_65s_0)) ehd1_5_70_0(r(ehd1_5_a_70s_0)) ehd1_5_75_0(r(ehd1_5_a_75s_0)) ehd1_5_80_0(r(ehd1_5_a_80s_0)) ehd1_5_85_0(r(ehd1_5_a_85s_0)) ehd1_5_0_1(r(ehd1_5_a_0s_1)) ehd1_5_5_1(r(ehd1_5_a_5s_1)) ehd1_5_10_1(r(ehd1_5_a_10s_1)) ehd1_5_15_1(r(ehd1_5_a_15s_1)) ehd1_5_20_1(r(ehd1_5_a_20s_1)) ehd1_5_25_1(r(ehd1_5_a_25s_1)) ehd1_5_30_1(r(ehd1_5_a_30s_1)) ehd1_5_35_1(r(ehd1_5_a_35s_1)) ehd1_5_40_1(r(ehd1_5_a_40s_1)) ehd1_5_45_1(r(ehd1_5_a_45s_1)) ehd1_5_50_1(r(ehd1_5_a_50s_1)) ehd1_5_55_1(r(ehd1_5_a_55s_1)) ehd1_5_60_1(r(ehd1_5_a_60s_1)) ehd1_5_65_1(r(ehd1_5_a_65s_1)) ehd1_5_70_1(r(ehd1_5_a_70s_1)) ehd1_5_75_1(r(ehd1_5_a_75s_1)) ehd1_5_80_1(r(ehd1_5_a_80s_1)) ehd1_5_85_1(r(ehd1_5_a_85s_1)) ehd6_21_0_0(r(ehd6_21_a_0s_0)) ehd6_21_5_0(r(ehd6_21_a_5s_0)) ehd6_21_10_0(r(ehd6_21_a_10s_0)) ehd6_21_15_0(r(ehd6_21_a_15s_0)) ehd6_21_20_0(r(ehd6_21_a_20s_0)) ehd6_21_25_0(r(ehd6_21_a_25s_0)) ehd6_21_30_0(r(ehd6_21_a_30s_0)) ehd6_21_35_0(r(ehd6_21_a_35s_0)) ehd6_21_40_0(r(ehd6_21_a_40s_0)) ehd6_21_45_0(r(ehd6_21_a_45s_0)) ehd6_21_50_0(r(ehd6_21_a_50s_0)) ehd6_21_55_0(r(ehd6_21_a_55s_0)) ehd6_21_60_0(r(ehd6_21_a_60s_0)) ehd6_21_65_0(r(ehd6_21_a_65s_0)) ehd6_21_70_0(r(ehd6_21_a_70s_0)) ehd6_21_75_0(r(ehd6_21_a_75s_0)) ehd6_21_80_0(r(ehd6_21_a_80s_0)) ehd6_21_85_0(r(ehd6_21_a_85s_0)) ehd6_21_0_1(r(ehd6_21_a_0s_1)) ehd6_21_5_1(r(ehd6_21_a_5s_1)) ehd6_21_10_1(r(ehd6_21_a_10s_1)) ehd6_21_15_1(r(ehd6_21_a_15s_1)) ehd6_21_20_1(r(ehd6_21_a_20s_1)) ehd6_21_25_1(r(ehd6_21_a_25s_1)) ehd6_21_30_1(r(ehd6_21_a_30s_1)) ehd6_21_35_1(r(ehd6_21_a_35s_1)) ehd6_21_40_1(r(ehd6_21_a_40s_1)) ehd6_21_45_1(r(ehd6_21_a_45s_1)) ehd6_21_50_1(r(ehd6_21_a_50s_1)) ehd6_21_55_1(r(ehd6_21_a_55s_1)) ehd6_21_60_1(r(ehd6_21_a_60s_1)) ehd6_21_65_1(r(ehd6_21_a_65s_1)) ehd6_21_70_1(r(ehd6_21_a_70s_1)) ehd6_21_75_1(r(ehd6_21_a_75s_1)) ehd6_21_80_1(r(ehd6_21_a_80s_1)) ehd6_21_85_1(r(ehd6_21_a_85s_1))
local index=`index' +1
disp `index'
}
sum
end





program progBETA
simulate hd0_0_0=hd0_a_0s_0 hd0_5_0=hd0_a_5s_0 hd0_10_0=hd0_a_10s_0 hd0_15_0=hd0_a_15s_0 hd0_20_0=hd0_a_20s_0 hd0_25_0=hd0_a_25s_0 hd0_30_0=hd0_a_30s_0 hd0_35_0=hd0_a_35s_0 hd0_40_0=hd0_a_40s_0 hd0_45_0=hd0_a_45s_0 hd0_50_0=hd0_a_50s_0 hd0_55_0=hd0_a_55s_0 hd0_60_0= hd0_a_60s_0 hd0_65_0=hd0_a_65s_0 hd0_70_0=hd0_a_70s_0 hd0_75_0=hd0_a_75s_0 hd0_80_0=hd0_a_80s_0 hd0_85_0=hd0_a_85s_0 hd0_0_1=hd0_a_0s_1 hd0_5_1=hd0_a_5s_1 hd0_10_1=hd0_a_10s_1 hd0_15_1=hd0_a_15s_1 hd0_20_1=hd0_a_20s_1 hd0_25_1=hd0_a_25s_1 hd0_30_1=hd0_a_30s_1 hd0_35_1=hd0_a_35s_1 hd0_40_1=hd0_a_40s_1 hd0_45_1=hd0_a_45s_1 hd0_50_1=hd0_a_50s_1 hd0_55_1=hd0_a_55s_1 hd0_60_1=hd0_a_60s_1 hd0_65_1=hd0_a_65s_1 hd0_70_1=hd0_a_70s_1 hd0_75_1=hd0_a_75s_1 hd0_80_1=hd0_a_80s_1 hd0_85_1=hd0_a_85s_1 hd1_5_0_0=hd1_5_a_0s_0 hd1_5_5_0=hd1_5_a_5s_0 hd1_5_10_0=hd1_5_a_10s_0 hd1_5_15_0=hd1_5_a_15s_0 hd1_5_20_0=hd1_5_a_20s_0 hd1_5_25_0=hd1_5_a_25s_0 hd1_5_30_0 =hd1_5_a_30s_0 hd1_5_35_0=hd1_5_a_35s_0 hd1_5_40_0=hd1_5_a_40s_0 hd1_5_45_0=hd1_5_a_45s_0 hd1_5_50_0=hd1_5_a_50s_0 hd1_5_55_0=hd1_5_a_55s_0 hd1_5_60_0=hd1_5_a_60s_0 hd1_5_65_0=hd1_5_a_65s_0 hd1_5_70_0=hd1_5_a_70s_0 hd1_5_75_0=hd1_5_a_75s_0 hd1_5_80_0=hd1_5_a_80s_0 hd1_5_85_0=hd1_5_a_85s_0 hd1_5_0_1=hd1_5_a_0s_1 hd1_5_5_1=hd1_5_a_5s_1 hd1_5_10_1=hd1_5_a_10s_1 hd1_5_15_1=hd1_5_a_15s_1 hd1_5_20_1=hd1_5_a_20s_1 hd1_5_25_1=hd1_5_a_25s_1 hd1_5_30_1=hd1_5_a_30s_1 hd1_5_35_1=hd1_5_a_35s_1 hd1_5_40_1=hd1_5_a_40s_1 hd1_5_45_1=hd1_5_a_45s_1 hd1_5_50_1=hd1_5_a_50s_1 hd1_5_55_1=hd1_5_a_55s_1 hd1_5_60_1=hd1_5_a_60s_1 hd1_5_65_1=hd1_5_a_65s_1 hd1_5_70_1=hd1_5_a_70s_1 hd1_5_75_1=hd1_5_a_75s_1 hd1_5_80_1=hd1_5_a_80s_1 hd1_5_85_1=hd1_5_a_85s_1 hd6_21_0_0=hd6_21_a_0s_0 hd6_21_5_0=hd6_21_a_5s_0 hd6_21_10_0=hd6_21_a_10s_0 hd6_21_15_0=hd6_21_a_15s_0 hd6_21_20_0=hd6_21_a_20s_0 hd6_21_25_0=hd6_21_a_25s_0 hd6_21_30_0=hd6_21_a_30s_0 hd6_21_35_0=hd6_21_a_35s_0 hd6_21_40_0=hd6_21_a_40s_0 hd6_21_45_0=hd6_21_a_45s_0 hd6_21_50_0=hd6_21_a_50s_0 hd6_21_55_0=hd6_21_a_55s_0 hd6_21_60_0=hd6_21_a_60s_0 hd6_21_65_0=hd6_21_a_65s_0 hd6_21_70_0=hd6_21_a_70s_0 hd6_21_75_0=hd6_21_a_75s_0 hd6_21_80_0=hd6_21_a_80s_0 hd6_21_85_0=hd6_21_a_85s_0 hd6_21_0_1=hd6_21_a_0s_1 hd6_21_5_1=hd6_21_a_5s_1 hd6_21_10_1=hd6_21_a_10s_1 hd6_21_15_1=hd6_21_a_15s_1 hd6_21_20_1=hd6_21_a_20s_1 hd6_21_25_1=hd6_21_a_25s_1 hd6_21_30_1=hd6_21_a_30s_1 hd6_21_35_1=hd6_21_a_35s_1 hd6_21_40_1=hd6_21_a_40s_1 hd6_21_45_1=hd6_21_a_45s_1 hd6_21_50_1=hd6_21_a_50s_1 hd6_21_55_1=hd6_21_a_55s_1 hd6_21_60_1=hd6_21_a_60s_1 hd6_21_65_1=hd6_21_a_65s_1 hd6_21_70_1=hd6_21_a_70s_1 hd6_21_75_1=hd6_21_a_75s_1 hd6_21_80_1=hd6_21_a_80s_1 hd6_21_85_1=hd6_21_a_85s_1, reps(10) dots: progD
sum
end


*simulate  ehd0_0_0=ehd0_a_0s_0 ehd0_5_0=ehd0_a_5s_0 ehd0_10_0=ehd0_a_10s_0 ehd0_15_0=ehd0_a_15s_0 ehd0_20_0=ehd0_a_20s_0 ehd0_25_0=ehd0_a_25s_0 ehd0_30_0=ehd0_a_30s_0 ehd0_35_0=ehd0_a_35s_0 ehd0_40_0=ehd0_a_40s_0 ehd0_45_0=ehd0_a_45s_0 ehd0_50_0=ehd0_a_50s_0 ehd0_55_0=ehd0_a_55s_0 ehd0_60_0= ehd0_a_60s_0 ehd0_65_0=ehd0_a_65s_0 ehd0_70_0=ehd0_a_70s_0 ehd0_75_0=ehd0_a_75s_0 ehd0_80_0=ehd0_a_80s_0 ehd0_85_0=ehd0_a_85s_0 ehd0_0_1=ehd0_a_0s_1 ehd0_5_1=ehd0_a_5s_1 ehd0_10_1=ehd0_a_10s_1 ehd0_15_1=ehd0_a_15s_1 ehd0_20_1=ehd0_a_20s_1 ehd0_25_1=ehd0_a_25s_1 ehd0_30_1=ehd0_a_30s_1 ehd0_35_1=ehd0_a_35s_1 ehd0_40_1=ehd0_a_40s_1 ehd0_45_1=ehd0_a_45s_1 ehd0_50_1=ehd0_a_50s_1 ehd0_55_1=ehd0_a_55s_1 ehd0_60_1=ehd0_a_60s_1 ehd0_65_1=ehd0_a_65s_1 ehd0_70_1=ehd0_a_70s_1 ehd0_75_1=ehd0_a_75s_1 ehd0_80_1=ehd0_a_80s_1 ehd0_85_1=ehd0_a_85s_1 ehd1_5_0_0=ehd1_5_a_0s_0 ehd1_5_5_0=ehd1_5_a_5s_0 ehd1_5_10_0=ehd1_5_a_10s_0 ehd1_5_15_0=ehd1_5_a_15s_0 ehd1_5_20_0=ehd1_5_a_20s_0 ehd1_5_25_0=ehd1_5_a_25s_0 ehd1_5_30_0 =ehd1_5_a_30s_0 ehd1_5_35_0=ehd1_5_a_35s_0 ehd1_5_40_0=ehd1_5_a_40s_0 ehd1_5_45_0=ehd1_5_a_45s_0 ehd1_5_50_0=ehd1_5_a_50s_0 ehd1_5_55_0=ehd1_5_a_55s_0 ehd1_5_60_0=ehd1_5_a_60s_0 ehd1_5_65_0=ehd1_5_a_65s_0 ehd1_5_70_0=ehd1_5_a_70s_0 ehd1_5_75_0=ehd1_5_a_75s_0 ehd1_5_80_0=ehd1_5_a_80s_0 ehd1_5_85_0=ehd1_5_a_85s_0 ehd1_5_0_1=ehd1_5_a_0s_1 ehd1_5_5_1=ehd1_5_a_5s_1 ehd1_5_10_1=ehd1_5_a_10s_1 ehd1_5_15_1=ehd1_5_a_15s_1 ehd1_5_20_1=ehd1_5_a_20s_1 ehd1_5_25_1=ehd1_5_a_25s_1 ehd1_5_30_1=ehd1_5_a_30s_1 ehd1_5_35_1=ehd1_5_a_35s_1 ehd1_5_40_1=ehd1_5_a_40s_1 ehd1_5_45_1=ehd1_5_a_45s_1 ehd1_5_50_1=ehd1_5_a_50s_1 ehd1_5_55_1=ehd1_5_a_55s_1 ehd1_5_60_1=ehd1_5_a_60s_1 ehd1_5_65_1=ehd1_5_a_65s_1 ehd1_5_70_1=ehd1_5_a_70s_1 ehd1_5_75_1=ehd1_5_a_75s_1 ehd1_5_80_1=ehd1_5_a_80s_1 ehd1_5_85_1=ehd1_5_a_85s_1 ehd6_21_0_0=ehd6_21_a_0s_0 ehd6_21_5_0=ehd6_21_a_5s_0 ehd6_21_10_0=ehd6_21_a_10s_0 ehd6_21_15_0=ehd6_21_a_15s_0 ehd6_21_20_0=ehd6_21_a_20s_0 ehd6_21_25_0=ehd6_21_a_25s_0 ehd6_21_30_0=ehd6_21_a_30s_0 ehd6_21_35_0=ehd6_21_a_35s_0 ehd6_21_40_0=ehd6_21_a_40s_0 ehd6_21_45_0=ehd6_21_a_45s_0 ehd6_21_50_0=ehd6_21_a_50s_0 ehd6_21_55_0=ehd6_21_a_55s_0 ehd6_21_60_0=ehd6_21_a_60s_0 ehd6_21_65_0=ehd6_21_a_65s_0 ehd6_21_70_0=ehd6_21_a_70s_0 ehd6_21_75_0=ehd6_21_a_75s_0 ehd6_21_80_0=ehd6_21_a_80s_0 ehd6_21_85_0=ehd6_21_a_85s_0 ehd6_21_0_1=ehd6_21_a_0s_1 ehd6_21_5_1=ehd6_21_a_5s_1 ehd6_21_10_1=ehd6_21_a_10s_1 ehd6_21_15_1=ehd6_21_a_15s_1 ehd6_21_20_1=ehd6_21_a_20s_1 ehd6_21_25_1=ehd6_21_a_25s_1 ehd6_21_30_1=ehd6_21_a_30s_1 ehd6_21_35_1=ehd6_21_a_35s_1 ehd6_21_40_1=ehd6_21_a_40s_1 ehd6_21_45_1=ehd6_21_a_45s_1 ehd6_21_50_1=ehd6_21_a_50s_1 ehd6_21_55_1=ehd6_21_a_55s_1 ehd6_21_60_1=ehd6_21_a_60s_1 ehd6_21_65_1=ehd6_21_a_65s_1 ehd6_21_70_1=ehd6_21_a_70s_1 ehd6_21_75_1=ehd6_21_a_75s_1 ehd6_21_80_1=ehd6_21_a_80s_1 ehd6_21_85_1=ehd6_21_a_85s_1, reps(1000) nodots: progD
*sum



*program progF
*simulate hd0_0_0=hd0_a_0s_0 hd0_5_0=hd0_a_5s_0 hd0_10_0=hd0_a_10s_0 hd0_15_0=hd0_a_15s_0 hd0_20_0=hd0_a_20s_0 hd0_25_0=hd0_a_25s_0 hd0_30_0=hd0_a_30s_0 hd0_35_0=hd0_a_35s_0 hd0_40_0=hd0_a_40s_0 hd0_45_0=hd0_a_45s_0 hd0_50_0=hd0_a_50s_0 hd0_55_0=hd0_a_55s_0 hd0_60_0= hd0_a_60s_0 hd0_65_0=hd0_a_65s_0 hd0_70_0=hd0_a_70s_0 hd0_75_0=hd0_a_75s_0 hd0_80_0=hd0_a_80s_0 hd0_85_0=hd0_a_85s_0 hd0_0_1=hd0_a_0s_1 hd0_5_1=hd0_a_5s_1 hd0_10_1=hd0_a_10s_1 hd0_15_1=hd0_a_15s_1 hd0_20_1=hd0_a_20s_1 hd0_25_1=hd0_a_25s_1 hd0_30_1=hd0_a_30s_1 hd0_35_1=hd0_a_35s_1 hd0_40_1=hd0_a_40s_1 hd0_45_1=hd0_a_45s_1 hd0_50_1=hd0_a_50s_1 hd0_55_1=hd0_a_55s_1 hd0_60_1=hd0_a_60s_1 hd0_65_1=hd0_a_65s_1 hd0_70_1=hd0_a_70s_1 hd0_75_1=hd0_a_75s_1 hd0_80_1=hd0_a_80s_1 hd0_85_1=hd0_a_85s_1 hd1_5_0_0=hd1_5_a_0s_0 hd1_5_5_0=hd1_5_a_5s_0 hd1_5_10_0=hd1_5_a_10s_0 hd1_5_15_0=hd1_5_a_15s_0 hd1_5_20_0=hd1_5_a_20s_0 hd1_5_25_0=hd1_5_a_25s_0 hd1_5_30_0 =hd1_5_a_30s_0 hd1_5_35_0=hd1_5_a_35s_0 hd1_5_40_0=hd1_5_a_40s_0 hd1_5_45_0=hd1_5_a_45s_0 hd1_5_50_0=hd1_5_a_50s_0 hd1_5_55_0=hd1_5_a_55s_0 hd1_5_60_0=hd1_5_a_60s_0 hd1_5_65_0=hd1_5_a_65s_0 hd1_5_70_0=hd1_5_a_70s_0 hd1_5_75_0=hd1_5_a_75s_0 hd1_5_80_0=hd1_5_a_80s_0 hd1_5_85_0=hd1_5_a_85s_0 hd1_5_0_1=hd1_5_a_0s_1 hd1_5_5_1=hd1_5_a_5s_1 hd1_5_10_1=hd1_5_a_10s_1 hd1_5_15_1=hd1_5_a_15s_1 hd1_5_20_1=hd1_5_a_20s_1 hd1_5_25_1=hd1_5_a_25s_1 hd1_5_30_1=hd1_5_a_30s_1 hd1_5_35_1=hd1_5_a_35s_1 hd1_5_40_1=hd1_5_a_40s_1 hd1_5_45_1=hd1_5_a_45s_1 hd1_5_50_1=hd1_5_a_50s_1 hd1_5_55_1=hd1_5_a_55s_1 hd1_5_60_1=hd1_5_a_60s_1 hd1_5_65_1=hd1_5_a_65s_1 hd1_5_70_1=hd1_5_a_70s_1 hd1_5_75_1=hd1_5_a_75s_1 hd1_5_80_1=hd1_5_a_80s_1 hd1_5_85_1=hd1_5_a_85s_1 hd6_21_0_0=hd6_21_a_0s_0 hd6_21_5_0=hd6_21_a_5s_0 hd6_21_10_0=hd6_21_a_10s_0 hd6_21_15_0=hd6_21_a_15s_0 hd6_21_20_0=hd6_21_a_20s_0 hd6_21_25_0=hd6_21_a_25s_0 hd6_21_30_0=hd6_21_a_30s_0 hd6_21_35_0=hd6_21_a_35s_0 hd6_21_40_0=hd6_21_a_40s_0 hd6_21_45_0=hd6_21_a_45s_0 hd6_21_50_0=hd6_21_a_50s_0 hd6_21_55_0=hd6_21_a_55s_0 hd6_21_60_0=hd6_21_a_60s_0 hd6_21_65_0=hd6_21_a_65s_0 hd6_21_70_0=hd6_21_a_70s_0 hd6_21_75_0=hd6_21_a_75s_0 hd6_21_80_0=hd6_21_a_80s_0 hd6_21_85_0=hd6_21_a_85s_0 hd6_21_0_1=hd6_21_a_0s_1 hd6_21_5_1=hd6_21_a_5s_1 hd6_21_10_1=hd6_21_a_10s_1 hd6_21_15_1=hd6_21_a_15s_1 hd6_21_20_1=hd6_21_a_20s_1 hd6_21_25_1=hd6_21_a_25s_1 hd6_21_30_1=hd6_21_a_30s_1 hd6_21_35_1=hd6_21_a_35s_1 hd6_21_40_1=hd6_21_a_40s_1 hd6_21_45_1=hd6_21_a_45s_1 hd6_21_50_1=hd6_21_a_50s_1 hd6_21_55_1=hd6_21_a_55s_1 hd6_21_60_1=hd6_21_a_60s_1 hd6_21_65_1=hd6_21_a_65s_1 hd6_21_70_1=hd6_21_a_70s_1 hd6_21_75_1=hd6_21_a_75s_1 hd6_21_80_1=hd6_21_a_80s_1 hd6_21_85_1=hd6_21_a_85s_1, reps(1000) nodots: progC
*sum












