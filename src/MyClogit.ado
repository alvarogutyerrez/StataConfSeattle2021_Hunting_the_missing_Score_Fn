
program MyClogit 
    version 12
    if replay() {
    if ("`e(cmd)'" != "MyClogit") error 301
    Replay `0'
    }
    else Estimate `0'
end

program Estimate, eclass sortpreserve 
    syntax varlist(fv) [if] [in] , GRoup(varname) /// 
	[TECHnique(passthru) noLOg ROBUST ]
    local mlopts  `technique' 
    if ("`technique'" == "technique(bhhh)") {
    di in red "technique(bhhh) is not allowed."
    exit 498
    }
    gettoken lhs rhs : varlist     
    marksample touse              
    markout `touse' `group' 
    global MY_panel = "`group'"
    ml model d0 MyLikelihood_LL()      ///
	(MyClogit: `lhs' = `rhs', nocons)  ///
	if `touse', missing  first   `log' ///
	title("MyClogit") `robust' maximize       
	// Show model
	ereturn local cmd MyClogit
	Replay , level(`level') 
	ereturn local  cmdline `"`0'"'      
end

 program Replay
    syntax [, Level(cilevel) ]
    ml display , level(`level')  
 end

// include mata functions from MyLikelihood_LL.mata
findfile "MyLikelihood_LL.mata" 
do "`r(fn)'"



 
 