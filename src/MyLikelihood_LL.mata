mata:
    void MyLikelihood_LL(transmorphic scalar M, real scalar todo,
    real rowvector b, real scalar lnf,
    real rowvector g, real matrix H)
{
  // variables declaration    
  real matrix panvar  
  real matrix paninfo 
  real scalar npanels
  real scalar n 
  real matrix Y 
  real matrix X 
  real matrix x_n 
  real matrix y_n 

  Y = moptimize_util_depvar(M, 1)               // Response Variable    
  X = moptimize_init_eq_indepvars(M,1)          // Attributes
  id_beta_eq=moptimize_util_eq_indices(M,1)     // id parameters
  betas= b[|id_beta_eq|]                        // parameters 
  st_view(panvar = ., ., st_global("MY_panel"))
  paninfo = panelsetup(panvar, 1)     
  npanels = panelstats(paninfo)[1] 
  lnfj = J(npanels, 1, 0)                       // object to store loglikelihood

  for(n=1; n <= npanels; ++n) {
	x_n = panelsubmatrix(X, n, paninfo) 
	y_n = panelsubmatrix(Y, n, paninfo)         
	U_n =exp(rowsum(betas :* x_n))        // Linear utility
	p_i = colsum(U_n:* y_n) / colsum(U_n) // Probability of each alternative
	lnfj[n] = ln(p_i)                     // Add contribution to the likelihood

}
  lnf = moptimize_util_sum(M, lnfj)
}
end
