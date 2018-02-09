# Can the provision of long-term liquidity help to avoid a credit crunch? Evidence from the Eurosystem’s LTRO

P. Andrade, C. Cahn, H. Fraisse, and J.-S. Mésonnier  
*Banque de France*  
Article published in the Journal of the European Economic Association 

This directory contains materials required to replicate the tables to be found in the JEEA article.



To replicate the results of the paper, run the Stata routine `ACFM_JEEA_main.do` on a computer containing the different datasets used for this study.

The `*.do` file makes use of two datasets

*    `ACFM_JEEA_credit_register_gea_firm_data.dta` contains the credit and financial information at the bank-firm level, as described in the paper.
*    `ACFM_JEEA_bank_balsheet_vltro.dta` contains all the balance sheet and operational data for bank groups.


For the sake of replication, we provide the two respective codebooks:

* `codebook_ACFM_JEEA_credit_register_gea_firm_data.txt`
* `codebook_ACFM_JEEA_bank_balsheet_vltro.txt`
 
These two datasets derive from the cleaning strategy described in the paper appliead to the raw data. Access to raw data may be granted via the Banque de France's *Open Data Room* upon request at

<https://www.banque-france.fr/en/statistics/access-granular-data/open-data-room>

Contact : [DGS-DIMOS-acces-donnees-ut@banque-france.fr](mailto:DGS-DIMOS-acces-donnees-ut@banque-france.fr)


A minimal request to replicate the paper should include an access to:

*    the French Credit Register: drawn, undrawn, total, short-term, medium/long-term exposures at the firm-month-(bank)counter level, for 2010q3, 2011q3, and 2012q3, and since 1998m1 to compute the bank-firm relationships.
*    the credit rating for the sample of firms.
*    the bank group-level balance-sheet information from the regulatory reporting of banks to the French Supervisory Authority (ACPR).
*    the Supervisor's mapping of individual credit institutions into GEA.
*    the firm-level accounting information available from the Banque de France's "FIchier Bancaire des ENtreprises" (FIBEN) database. 




---

ACFM (c) 2018

