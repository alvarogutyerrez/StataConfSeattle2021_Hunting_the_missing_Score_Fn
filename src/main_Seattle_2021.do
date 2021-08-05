/*-------------------------------------------------*/
/* Stata Conference Seattle 2021                   */
/* Title: Hunting for the missing score functions  */
/* Author: Álvaro A. Gutiérrez-Vargas              */
/*-------------------------------------------------*/


/*--------------------------------------------------*/
/*    Change directory where MyClogit is located    */
/*--------------------------------------------------*/
clear all
global route = "G:\Mi unidad\PhD\Talks\StataConf2021\public_git_repo\StataConfSeattle2021_Hunting_the_missing_Score_Fn\src"
cd "$route"
/*--------------------------------------*/
/*         Data Generating Process      */
/*--------------------------------------*/
set more off
mata: mata clear 
set seed 777
set obs 100 
gen id = _n 
local n_choices =3 
expand `n_choices'
bys id : gen alternative = _n
gen x1 =  runiform(-2,2)
gen x2 =  runiform(-2,2)
matrix betas = (0.5 ,2)
global individuals = "id"
mata: 
betas =st_matrix("betas")               // Calls from Stata the matrix "betas"
st_view(X = ., ., "x*")                 // View of all attributes x*
st_view(panvar = ., ., st_global("individuals")) // View of individuals id 
paninfo = panelsetup(panvar, 1)         // Sets up panel processing
npanels = panelstats(paninfo)[1]        // number of panels (choice situations) 
for(n=1; n <= npanels; ++n) {           // Looping over individuals (n)
    x_n = panelsubmatrix(X, n, paninfo) // Extract submatrix of individual n
    U   = rowsum(betas :* x_n)          // Observed Utility 
    p_i = exp(U) :/ colsum(exp(U))      // Probability of each alternative
    
    cum_p_i =runningsum(p_i)            // Multinomial Draws of each alternative
    rand_draws = J(rows(x_n),1,uniform(1,1)) 
    pbb_balance = rand_draws:<cum_p_i
    cum_pbb_balance = runningsum(pbb_balance)
    choice_n = (cum_pbb_balance:== J(rows(x_n),1,1)) 
    if (n==1) Y =choice_n               // Storing each individual choice.
    else       Y = Y \ choice_n    
}
idx = st_addvar("float", "choice") // Creates Stata variable called "choice"    
st_store(., idx, Y)                // Allocate "Y" on Stata variable "choice" 
end

*Listing Data 
list in 1/6 , sep(3)



/*-----------------------------------------------*/
/*         Checking MyClogit against clogit      */
/*-----------------------------------------------*/
qui clogit choice x1 x2 , gr(id) nolog
matrix b_clogit = e(b)
MyClogit choice x1 x2 , gr(id) nolog
matrix b_MyClogit = e(b)
di mreldif(b_MyClogit, b_clogit)


/*-----------------------------------------------*/
/*       ml fails to provide robust std.err      */
/*-----------------------------------------------*/

*MyClogit choice x1 x2 , gr(id) nolog robust  /*Uncomment to see the error!*/
* option vce(robust) is not allowed with evaltype d0
* r(198);
 
 
/*--------------------------------------------------------------------*/
/* Providing Mata with all we need  to reconstruct the Log-likelihood */
/*--------------------------------------------------------------------*/

// We create relevant matrices on Stata to push them to Mata afterwards.
matrix b = e(b)                // Maximum Likelihood estimates 
matrix W = e(V)                // Non-robust variance-covariance matrix
// We initialize Mata
mata:
// Invoking Stata matrices
betas = st_matrix("b")          // Calls from Stata the matrix "b"
W     = st_matrix("W")          // Calls from Stata the matrix "W"

// Invoking Stata Variables
st_view(X = ., ., "x1 x2")      // View of all regressors x1 and x2
st_view(Y = ., ., "choice")     // View of response variable "choice"
XY = (Y,X)                      // Generates XY matrix for future usage.

// Extracting information about the id of individuals.
st_view(panvar = ., ., "id")    // View of individuals id 
paninfo = panelsetup(panvar, 1) // Sets up panel processing 
N = panelstats(paninfo)[1]      // Number of Individuals 
end

/*----------------------------------------------------------*/
/*   Log-likelihood function to be used by deriv() function */
/*----------------------------------------------------------*/

mata:
// Creating the function we will invoke using Mata's deriv().
void LL_d(real rowvector b ,   // 1ST ARGUMENT: Maximum likelihood estimates
          real matrix    XY ,  // 2ND ARGUMENT: Convariates + dependent variable
          real scalar lnf)     // Output:       Log-likelihood contribution       
{
  Y = XY[.,1]                 // Extract variable Y
  X = XY[., (2::cols(XY))]    // Extract the regressors (x1 and x2)
  U = rowsum(b:*X)            // Observed Utility 
  P = exp(U):/colsum(exp(U )) // Multinomial Probability
  lnf = colsum(Y:*ln(P))      // Individual contribution to the log-likelihood
}	
end 


/*----------------------------------------------------------*/
/*          Score Functions of the First Individual          */
/*----------------------------------------------------------*/


mata: 
D = deriv_init()                 // Init deriv() object	and call it "D"
deriv_init_evaluator(D, &LL_d()) // We provide the object D with function LL_d() 
deriv_init_evaluatortype(D,"d")  // Set that deriv() must returns a scalar
deriv_init_params(D, betas) 	 // Provide D with beta estimates (deriv at)
xy_n = panelsubmatrix(XY, 1, paninfo) // Extract first individual's X and Y 
xy_n 
deriv_init_argument(D, 1, xy_n)  // provide D with X and Y of the first individual
score_fn= deriv(D, 1)            // <--- Perform the numerical derivation!
score_fn                         // Display it
end



/*----------------------------------------------------------*/
/*          Score Functions of the Entire Sample             */
/*----------------------------------------------------------*/



mata: 
D = deriv_init()                 // Init deriv() object	
deriv_init_evaluator(D, &LL_d()) // Object D is prodived with the pointer LL_d() 
deriv_init_evaluatortype(D,"d")  // Set that deriv() must returns a scalar
score_fn = J(0, cols(betas),.)   // Vector length 0xcols(betas)
for(n=1; n <= N; ++n) {          // Looping over n individuals
	  xy_n = panelsubmatrix(XY, n, paninfo)  // Extract submatrix of individual n
	  deriv_init_params(D, betas) 	         // provide D with beta estimates
	  deriv_init_argument(D, 1, xy_n)        // provide D with attributes values
	  score_fn = score_fn \  deriv(D, 1)     // Collect score functions from each individual      
}
score_fn[1..4,]  // display the score functions of the first 4 individuals
// Finally, we save the score functions  as S just for a handy matrix multiplication afterwards.
S = score_fn  
end


/*-------------------------------------*/
/*          Sandwich Matrix            */
/*-------------------------------------*/

mata: 
meat =  (N/(N-1)) * S' * S                    // Some people call this part the "meat".
V_robust_approx= W * meat * W                 // Approximated robust variance-covariance matrix.
st_matrix("V_robust_approx", V_robust_approx) // Save robust matrix into a Stata Matrix.
end


/*-----------------------------------------------*/
/*         Checking MyClogit against clogit , robust      */
/*-----------------------------------------------*/
clogit choice x* ,gr(id) robust nolog
mat V_robust_clogit = e(V)
display mreldif(V_robust_approx, V_robust_clogit)



