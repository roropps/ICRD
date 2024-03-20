**Created on 8 March 2024
**Updated on 8 March 2024
**Master Program to Calculate Excess Heat Mortality in Hong Kong
**Has 3 subroutines named mkheatbeta, anheatdeath, anMC_heatdeath
capture program drop masterheatdeath
capture program drop mkheatbeta
capture program drop anheatdeath
capture program drop anMC_heatdeath
capture log close
clear

*Directory for Dr. Bishai
* cd /Users/dbishai/Library/CloudStorage/OneDrive-TheUniversityOfHongKong/HKU-Director/ActiveResearchHKU/Heat/HeatDeathData/
*****mkheatbeta

program masterheatdeath
mkheatbeta
anheatdeath
anMC_heatdeath

end



program mkheatbeta
*this file takes the RRs from the Liu paper Liu, Jingwen, Alana Hansen, Blesson Varghese, Zhidong Liu, Michael Tong, Hong Qiu, Linwei Tian et al. "Cause-specific mortality attributable to cold and hot ambient temperatures in Hong Kong: a time-series study, 2006–2016." Sustainable Cities and Society 57 (2020): 102131.
*It exponentiates the RRs to probability of dying in 1 day using p=1-exp (RR* time) where time is 1. from page 184
*It computes alpha and beta from page 194
* It assigns global macros to p, alpha, beta
* it calls them $m_1p, $m_5p, $m_10p for males age 1 prob,  $f_1p, etc. $m_1alpha, $m_1beta, etc.
*This do file just names things
use RRsfromLiu


disp "Hello 1"


end
*****anheatdeath
program anheatdeath
*This file starts with daily mortality data for Hong Kong
*It multiplies daily mortality by p for each age sex cell and computes non-stochastic excess deaths for each cell. Generates XSD_m_1, XSD_m_5, etc
*THen it does this stochastically by drawing p from the respective beta and generating XSD_m_1S

disp "Hello 2"



end

*****anMC_heatdeath
program anMC_heatdeath


disp "Hello 3"



end




