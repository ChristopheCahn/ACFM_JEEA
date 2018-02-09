/******************************************************************************
 Replication File: Can the Provision of Long-Term Liquidity Help to Avoid a 
 Credit Crunch? Evidence from the Eurosystem's LTRO, by P. Andrade, C. Cahn,
 H. Fraisse, and J.-S. Mésonnier, published in the JEEA.

 Forewords: 
  *	the dataset 'ACFM_JEEA_credit_register_gea_firm_data' contains the credit 
	and financial information at the bank-firm level, as described in the paper.
  *	the dataset 'ACFM_JEEA_bank_balsheet_vltro' contains all the balance sheet 
	and operational data for bank groups.
  *	It is assumed that these datasets are in the current directory.

 
 version used for STATA		: Stata/MP 14.1
 version used for REGHDFE	: 3.2.9 21feb2016
 ******************************************************************************/

/******************************************************************************
 Data preparation for descriptive statistics and regressions
 ******************************************************************************/

* Firm level dataset for descriptive statistics
use ACFM_JEEA_credit_register_gea_firm_data.dta, clear
keep if (date==q(2011q3)|date==q(2012q3)) & clean2==1
collapse (mean) ftot_allgea	nbk note age_max _bach ftot_bucket nbk_allgea ///
	fheadcount fassets fnetopprofitratio finterestburden 				  ///
	(sum) tot (max) clean, by(date siren)
keep if clean == 1
tsset siren date
bysort siren (date): gen dltot_i_fwd= 100*log(F4.tot/tot) if tot~=.
* additional descriptive variables at the firm level
g multibk 	= (nbk >1 & nbk<.) 
g eligibecb	= (note<=4)
g acc		= (note==5)
g age_id	= (age_max>36)
g fiben 	= (_bach>1 & _bach<.)
keep if date == q(2011q3) 
save ACFM_firm_data, replace
 
* Merge firm and bank datasets
use ACFM_JEEA_credit_register_gea_firm_data.dta, clear
merge m:1 date gea using ACFM_JEEA_bank_balsheet_vltro.dta, keep(match) nogen
save ACFM_firm_gea_data, replace 
 
* Loan level regression data: ACFM_loan_regression_data
use ACFM_firm_gea_data, clear
keep if date==q(2011q3)	& clean==1
save ACFM_main_regression_data.dta, replace

* GEA level regression data : ACFM_gea_regression_data.dta
use ACFM_firm_gea_data, clear
keep if date == q(2011q3)
duplicates drop gea, force
save ACFM_gea_regression_data.dta, replace

* Loan level placebo regression data: ACFM_loan_placebo_regression_data 
use ACFM_firm_gea_data, clear
keep if date==q(2010q3)	& clean == 1
save ACFM_placebo_regression_data.dta, replace

* loan level survival regression : ACFM_loan_survival_data.dta
use ACFM_firm_gea_data, clear
keep if date==q(2011q3) 
save ACFM_loan_survival_data.dta, replace

 
/******************************************************************************
									TABLE 1
							Stat. Des. Banking Groups
 ******************************************************************************/

use ACFM_gea_regression_data.dta, clear
sum bsize_bns dlbsize loantoa dltot dldrawn bliqasstoa bsectoa bcaptoa 	///
	shortfall_to_rwa_trunc bintbkliabtoa bshareelig bvltrotoa matswap 	///
	ltroqe cib, d

/******************************************************************************
									TABLE 2
							  Bidding behaviour
 ******************************************************************************/

use ACFM_gea_regression_data.dta, clear
sum bsize_bns dlbsize loantoa dltot dldrawn bliqasstoa bsectoa bcaptoa 	///
	shortfall_to_rwa_trunc bintbkliabtoa bshareelig bvltrotoa matswap 	///
	ltroqe cib if bvltrotoa == 0, d
sum bsize_bns dlbsize loantoa dltot dldrawn bliqasstoa bsectoa bcaptoa 	///
	shortfall_to_rwa_trunc bintbkliabtoa bshareelig bvltrotoa matswap 	///
	ltroqe cib if bvltrotoa > 0, d
sum bsize_bns dlbsize loantoa dltot dldrawn bliqasstoa bsectoa bcaptoa 	///
	shortfall_to_rwa_trunc bintbkliabtoa bshareelig bvltrotoa matswap 	///
	ltroqe cib if bvltro1toa > 0, d
sum bsize_bns dlbsize loantoa dltot dldrawn bliqasstoa bsectoa bcaptoa 	///
	shortfall_to_rwa_trunc bintbkliabtoa bshareelig bvltrotoa matswap 	///
	ltroqe cib if bvltro2toa > 0, d

/******************************************************************************
									TABLE 3
									 Firms
 ******************************************************************************/

use ACFM_firm_data, clear
* All firms
sum dltot_i_fwd ftot_allgea eligibecb age_id nbk fiben if dltot_i_fwd~=., d
* Monobank firms
sum dltot_i_fwd ftot_allgea eligibecb age_id nbk fiben if dltot_i_fwd~=. ///
	& multibk == 0, d
* Multi-bank firms
sum dltot_i_fwd ftot_allgea eligibecb age_id nbk fiben if dltot_i_fwd~=. ///
	& multibk == 1, d
* With balance sheet info
sum dltot_i_fwd ftot_allgea eligibecb age_id nbk fheadcount fassets 	 ///
	fnetopprofitratio finterestburden if dltot_i_fwd~=. 				 ///
	& fnetopprofitratio ~= . & multibk == 1, d 
	
/******************************************************************************
									TABLE 4
						multi-bank firms by borrower size
 ******************************************************************************/

use ACFM_firm_data, clear
* very small
sum ftot_allgea dltot_i_fwd  nbk_allgea if multibk == 1 & ftot_bucket == 1 	///
	& dltot_i_fwd~=., d
* small
sum ftot_allgea dltot_i_fwd  nbk_allgea if multibk == 1 & ftot_bucket == 2 	///
	& dltot_i_fwd~=., d
* Interm.
sum ftot_allgea dltot_i_fwd  nbk_allgea if multibk == 1 & ftot_bucket == 3 	///
	& dltot_i_fwd~=., d
* Large
sum ftot_allgea dltot_i_fwd  nbk_allgea if multibk == 1 & ftot_bucket == 4 	///
	& dltot_i_fwd~=., d
* very small + w/ financial info
sum ftot_allgea fassets fheadcount if multibk == 1 & ftot_bucket == 1 		///
	& _bach == 3 , d
* small + w/ financial info
sum ftot_allgea fassets fheadcount if multibk == 1 & ftot_bucket == 2 		///
	& _bach == 3 , d
* Interm. + w/ financial info
sum ftot_allgea fassets fheadcount if multibk == 1 & ftot_bucket == 3 		///
	& _bach == 3 , d
* Large + w/ financial info
sum ftot_allgea fassets fheadcount if multibk == 1 & ftot_bucket == 4 		///
	& _bach == 3 , d

/******************************************************************************
									TABLE 5
									Baseline
 ******************************************************************************/

use ACFM_main_regression_data.dta, clear
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa ///
	  loantoa bshareelig bsectoa 	  
/** all firms*/
reg dltot_ij_fwd bvltrotoa, cluster(gea_naf1d)
/** all firms, + bank controls*/
reg dltot_ij_fwd bvltrotoa $bank_characteristics, cluster(gea_naf1d)
/* multibank firms*/
reg dltot_ij_fwd bvltrotoa if multi==1, cluster(gea_naf1d)
/* multibank firms + bank controls*/
reg dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, cluster(gea_naf1d)
/* multibank firms + Firms FE*/
reghdfe dltot_ij_fwd bvltrotoa if multi==1, absorb(siren) vce(cluster gea_naf1d) 
/* multibank firms + Firms FE + bank controls*/
reghdfe dltot_ij_fwd bvltrotoa  $bank_characteristics if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d)
/* multibank firms + Firms FE + bank controls - robust */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, ///
	absorb(siren) vce(robust)
/* multibank firms + Firms FE + bank controls - cluster bank */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, ///
	absorb(siren) vce(cluster gea)
/* maturity swap vs QE effect 1+2 */
reghdfe dltot_ij_fwd matswap ltroqe $bank_characteristics  if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d) 
/* Round 1: multibank firms + Firms FE + bank controls*/
reghdfe dltot_ij_fwd bvltro1toa $bank_characteristics if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d)
/* Round 2: multibank firms + Firms FE + bank controls*/
reghdfe dltot_ij_fwd bvltro2toa $bank_characteristics if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d)
/* Round 1: maturity swap vs QE effect 1 */
reghdfe dltot_ij_fwd matswap1 ltroqe1 $bank_characteristics  if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d) 

/******************************************************************************
									TABLE 6
	 Determinants of LTRO bids by selected banks, first vs second round
 ******************************************************************************/

use ACFM_gea_regression_data.dta, clear
* Probit VLTRO1 
probit vltro1 bcaptoa, vce(robust) 
* Probit VLTRO2
probit vltro2 bcaptoa, vce(robust)
* Tobit VLTRO1	
tobit bvltro1toa bcaptoa, ll(0) vce(robust) 
* Tobit VLTRO2
tobit bvltro2toa bcaptoa, ll(0) vce(robust) 

/******************************************************************************
									TABLE 7
						Robustness on bank controls
 ******************************************************************************/

use ACFM_main_regression_data.dta, clear 
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa ///
	  loantoa bshareelig bsectoa 
macro define bank_additional bprovtoa undrawntoa  bdeptoa 	  
/** all firms*/
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d)
/** all firms + MRO user +  foreign + public */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics MRO_user foreign_bank ///
	public_bank if multi==1, absorb(siren) vce(cluster gea_naf1d)
/** all firms + all others */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics MRO_user foreign_bank ///
	public_bank shortfall_to_rwa_trunc  if multi==1, absorb(siren) ///
	vce(cluster gea_naf1d)
/** all firms only no foreign bidders */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics  if multi==1 & ///
	id_foreign_ltro==0, absorb(siren) vce(cluster gea_naf1d)

	
/******************************************************************************
								      TABLE 8
								Placebo regressions
 ******************************************************************************/

use ACFM_placebo_regression_data.dta, clear
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa ///
	  loantoa bshareelig bsectoa 
/** all firms*/
reg dltot_ij_fwd bvltrotoa, cluster(gea_naf1d)
/** all firms, + bank controls*/
reg dltot_ij_fwd bvltrotoa $bank_characteristics, cluster(gea_naf1d)
/* multibank firms*/
reg dltot_ij_fwd bvltrotoa if multi==1, cluster(gea_naf1d)
/* multibank firms + bank controls*/
reg dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, cluster(gea_naf1d)
/* multibank firms + Firms FE*/
reghdfe dltot_ij_fwd bvltrotoa if multi==1, absorb(siren) vce(cluster gea_naf1d) 
/* multibank firms + Firms FE + bank controls*/
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d)
/* multibank firms + Firms FE + bank controls*/
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, ///
	absorb(siren) vce(robust)
/* multibank firms + Firms FE + bank controls*/
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, ///
	absorb(siren) vce(cluster gea)
/* maturity swap vs QE effect 1+2 */
reghdfe dltot_ij_fwd matswap ltroqe $bank_characteristics  if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d) 
/* multibank firms + Firms FE + bank controls*/
reghdfe dltot_ij_fwd  bvltro1toa $bank_characteristics if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d)
/* multibank firms + Firms FE + bank controls*/
reghdfe dltot_ij_fwd  bvltro2toa $bank_characteristics if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d)
/* maturity swap vs QE effect 1 */
reghdfe dltot_ij_fwd matswap1 ltroqe1 $bank_characteristics  if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d) 
	
/******************************************************************************
									TABLE 9
							Effect by borrowers' size
 ******************************************************************************/

use ACFM_main_regression_data.dta, clear 
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa ///
	  loantoa bshareelig bsectoa 
/** all firms*/
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, ///
	absorb(siren) vce(cluster gea_naf1d)
/** firms by buckets */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1 & ///
	ftot_bucket==1, absorb(siren) vce(cluster gea_naf1d)
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1 & ///
	ftot_bucket==2, absorb(siren) vce(cluster gea_naf1d)
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1 & ///
	ftot_bucket==3, absorb(siren) vce(cluster gea_naf1d)
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1 & ///
	ftot_bucket==4, absorb(siren) vce(cluster gea_naf1d)

/******************************************************************************
									TABLE 10
					Probability of maintaining relationships
 ******************************************************************************/
 
use ACFM_loan_survival_data.dta, clear
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa ///
	  loantoa bshareelig bsectoa 	  
/** all firms*/
reghdfe f4totactive bvltrotoa $bank_characteristics if nbk>1 ///
	& totactive==1, absorb(siren) vce(cluster gea_naf1d)
/** by buckets */
reghdfe f4totactive bvltrotoa $bank_characteristics if nbk>1 ///
	& ftot_bucket==1 & totactive==1, absorb(siren) vce(cluster gea_naf1d)
reghdfe f4totactive bvltrotoa $bank_characteristics if nbk>1 ///
	& ftot_bucket==2 & totactive==1, absorb(siren) vce(cluster gea_naf1d)
reghdfe f4totactive bvltrotoa $bank_characteristics if nbk>1 ///
	& ftot_bucket==3 & totactive==1, absorb(siren) vce(cluster gea_naf1d)
reghdfe f4totactive bvltrotoa $bank_characteristics if nbk>1 ///
	& ftot_bucket==4 & totactive==1, absorb(siren) vce(cluster gea_naf1d) 
 	  
/******************************************************************************
									TABLE 11
							Non-linear firm effects
 ******************************************************************************/
 	  
use ACFM_main_regression_data.dta, clear 
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa ///
	  loantoa bshareelig bsectoa 
macro define interaction eligibecb acc nbk_allgea age_id ///
	  lfassets fnetopprofitratio finterestburden	  
gen X_bvltrotoa=bvltrotoa*eligibecb
reghdfe dltot_ij_fwd bvltrotoa X_bvltrotoa $bank_characteristics 		///
	if multi==1, absorb(siren) vce(cluster gea_naf1d) 
drop X_bvltrotoa
gen X_bvltrotoa=bvltrotoa*acc
reghdfe dltot_ij_fwd bvltrotoa X_bvltrotoa $bank_characteristics 		///
	if multi==1, absorb(siren) vce(cluster gea_naf1d) 
drop X_bvltrotoa
gen X_bvltrotoa=bvltrotoa*nbk_allgea
reghdfe dltot_ij_fwd bvltrotoa X_bvltrotoa $bank_characteristics 		///
	if multi==1, absorb(siren) vce(cluster gea_naf1d) 
drop X_bvltrotoa
gen X_bvltrotoa=bvltrotoa*age_id
reghdfe dltot_ij_fwd bvltrotoa X_bvltrotoa $bank_characteristics 		///
	if multi==1, absorb(siren) vce(cluster gea_naf1d) 
drop X_bvltrotoa
gen X_bvltrotoa=bvltrotoa*lfassets
reghdfe dltot_ij_fwd bvltrotoa X_bvltrotoa $bank_characteristics 		///
	if multi==1, absorb(siren) vce(cluster gea_naf1d) 
drop X_bvltrotoa
gen X_bvltrotoa=bvltrotoa*fnetopprofitratio
reghdfe dltot_ij_fwd bvltrotoa X_bvltrotoa $bank_characteristics 		///
	if multi==1, absorb(siren) vce(cluster gea_naf1d) 
drop X_bvltrotoa
gen X_bvltrotoa=bvltrotoa*finterestburden
reghdfe dltot_ij_fwd bvltrotoa X_bvltrotoa $bank_characteristics 		///
	if multi==1, absorb(siren) vce(cluster gea_naf1d) 
drop X_bvltrotoa

/******************************************************************************
								Online Appendix
 ******************************************************************************/

/******************************************************************************
									TABLE B.1
				Automatic Model Selection of Credit Supply Drivers
 ******************************************************************************/

use ACFM_placebo_regression_data.dta, clear 	
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa ///
	  loantoa bshareelig bsectoa
macro define bank_additional undrawntoa  bdeptoa 
* get the same sample as for placebo regression
quiet reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics $bank_additional ///
	if multi==1, absorb(siren) vce(cluster gea_naf1d)
gen inSample = e(sample)
gsreg dltot_ij_fwd $bank_characteristics $bank_additional if inSample == 1,	///
	cmdest(areg) samesample cmdoptions(absorb(siren) vce(cluster gea)) 		///
	nindex(1 r_sqr_a ) replace
gsreg dltot_ij_fwd $bank_characteristics $bank_additional if inSample == 1, ///
	cmdest(areg) samesample cmdoptions(absorb(siren) vce(cluster gea))  	///
	nindex(-1 aic ) aic replace
gsreg dltot_ij_fwd $bank_characteristics $bank_additional if inSample == 1, ///
	cmdest(areg) samesample cmdoptions(absorb(siren) vce(cluster gea))  	///
	nindex(-1 bic ) aic replace
 
/******************************************************************************
									TABLE B.2
				Automatic Model Selection of LTRO Uptakes Drivers
 ******************************************************************************/
 
use ACFM_main_regression_data.dta, clear
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa 	///
	  loantoa bshareelig bsectoa
macro define bank_additional undrawntoa  bdeptoa 
* get the same sample as for baseline regression
quiet reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics $bank_additional ///
	if multi==1, absorb(siren) vce(cluster gea_naf1d)
gen inSample = e(sample)
gsreg bvltrotoa $bank_characteristics $bank_additional if inSample == 1, 	///
	cmdest(areg) samesample cmdoptions(absorb(siren) vce(cluster gea))  	///
	nindex(1 r_sqr_a ) replace
gsreg bvltrotoa  $bank_characteristics $bank_additional if inSample == 1, 	///
	cmdest(areg) samesample cmdoptions(absorb(siren) vce(cluster gea))  	///
	nindex(-1 aic ) aic replace
gsreg bvltrotoa  $bank_characteristics $bank_additional if inSample == 1, 	///
	cmdest(areg) samesample cmdoptions(absorb(siren) vce(cluster gea))  	///
	nindex(-1 bic ) aic replace

/******************************************************************************
									TABLE B.3
					Automatic Model Selection – Model Comparison
 ******************************************************************************/

use ACFM_main_regression_data.dta, clear
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa ///
	  loantoa bshareelig bsectoa
macro define set_one lsize bliqasstoa  bintbkliabtoa bsectoa
macro define set_two bcaptoa	  
* baseline
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, 	///
	absorb(siren) vce(cluster gea_naf1d)
* set 1 et set 2
reghdfe dltot_ij_fwd bvltrotoa $set_one $set_two if multi==1, 		///
	absorb(siren) vce(cluster gea_naf1d)

/******************************************************************************
									TABLE C.1
					Robustness Check – Bank Business Model
 ******************************************************************************/
	
use ACFM_main_regression_data.dta, clear
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa 	///
	  loantoa bshareelig bsectoa 
/* Baseline */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, 			///
	absorb(siren) vce(cluster gea_naf1d)
/* Excluding Diversified */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1 			///
	& business_model~="Diversified lender", absorb(siren) vce(cluster gea_naf1d)
/* Excluding Retail */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1 			///
	& business_model~="Retail Lender", absorb(siren) vce(cluster gea_naf1d)
/* Excluding Sectoral */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1 & gea~=52 	///
	& gea~=63, absorb(siren) vce(cluster gea_naf1d)
/* Excluding Universal */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1 			///
	& business_model~="Universal bank", absorb(siren) vce(cluster gea_naf1d)

/******************************************************************************
									TABLE C.2
						Robustness Check – Credit Category
 ******************************************************************************/
	
use ACFM_main_regression_data.dta, clear 
macro define bank_characteristics lsize bliqasstoa bcaptoa bintbkliabtoa ///
	  loantoa bshareelig bsectoa 
/* Baseline */
reghdfe dltot_ij_fwd bvltrotoa $bank_characteristics if multi==1, 		///
	absorb(siren) vce(cluster gea_naf1d)
/* Short term */
reghdfe dlst_ij_fwd bvltrotoa $bank_characteristics if multi==1, 		///
	absorb(siren) vce(cluster gea_naf1d)
/* Medium Long Term */
reghdfe dlmlt_ij_fwd  bvltrotoa $bank_characteristics if multi==1, 		///
	absorb(siren) vce(cluster gea_naf1d)
/* Drawn */
reghdfe dldrawn_ij_fwd bvltrotoa $bank_characteristics if multi==1, 	///
	absorb(siren) vce(cluster gea_naf1d)
/* Undrawn */
reghdfe mlt_to_drawn  bvltrotoa $bank_characteristics if multi==1, 		///
	absorb(siren) vce(cluster gea_naf1d)

exit


	