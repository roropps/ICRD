*Compute SD of RR
gen sd0=(topci0-bottomci0)/3.92
gen sd1_5=(topci1_5-bottomci1_5)/3.92
gen sd5_21=(topci5_21-bottomci5_21)/3.92

*Calculate the probability of dying in one day
gen time=1
gen p0=1-exp(-rrlag0 * time)
gen p1_5=1-exp(-rrlag1_5*time)
gen p5_21=1-exp(-rrlag5_21*time)

*// Calculate the standard error of p using the delta method (approximation)
gen se_p0 = sd0 * exp(-rrlag0 * time)
gen se_p1_5 = sd1_5 * exp(-rrlag1_5 * time)
gen se_p5_21= sd0 * exp(-rrlag5_21 * time)

* //Calculate the variance of p
gen var_p0 = se_p0^2
gen var_p1_5 = se_p1_5^2
gen var_p5_21 = se_p5_21^2

* Derive alpha and beta parameters for the beta distribution
gen a1 = ((1 - p0) / var_p0 - 1 / p0) * p0^2
gen b1 = a1 * (1 / p0 - 1)
gen a2 = ((1 - p1_5) / var_p1_5 - 1 / p1_5) * p1_5^2
gen b2 = a2 * (1 / p1_5 - 1)
gen a3 = ((1 - p5_21) / var_p5_21 - 1 / p5_21) * p5_21^2
gen b3 = a3 * (1 / p5_21 - 1)

//non-stochastic excess deaths
gen exsd_0 = p0 * dailydeath
gen exsd_1_5 = p1_5 * dailydeath
gen exsd5_21 = p5_21 * dailydeath
//stochastic excess deaths
* Set seed for reproducibility
set seed 12345

* Loop through each age-sex cell and compute stochastic excess deaths
gen p0_draw = rbeta(a1, b1) 
gen p1_5_draw = rbeta(a2,b2)
gen p5_21_draw = rbeta(a3,b3)

// Draw stochastic excess deaths from beta distribution
gen sexsd_0 = p0_draw * dailydeath
gen sexsd_1_5 = p1_5_draw * dailydeath
gen sexsd5_21 = p5_21_draw * dailydeath

//Monte Carlo Simulation to simulate daily deaths
* Set the number of simulations
local num_sims 1000

* Set the seed for reproducibility
set seed 12345
* Create a matrix to hold simulation results
matrix results = J(`num_sims', 1, .)
* Loop through each simulation
forval i = 1/`num_sims' {
    * Draw a random p from the beta distribution for each age-sex cell
    * Compute the stochastic excess deaths
    * Replace X with the age-sex cell identifier
    gen p0_sim_`i' = rbeta(a1, b1)
	gen p1_5_sim_`i' = rbeta(a2, b2)
	gen p5_2121_sim_`i' = rbeta(a3, b3)
	
    gen XSD_m_XS_`i' = daily_mortality * p_sim_`i'
    
    * Store the results of the simulation
    matrix results[`i', 1] = XSD_m_XS_`i'
