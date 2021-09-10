## [#StataConferenceSeattle2021](https://twitter.com/alvarogutyerrez/status/1422926920593952777)


### Source code from my talk called: *Hunting the missing score functions*.

Below you might find the source code that generates the examples presented in my talk at the Stata Conference 2021.


The adofile that replicates the examples from the talk is called [main_Seattle_2021.do](https://github.com/alvarogutyerrez/StataConfSeattle2021_Hunting_the_missing_Score_Fn/blob/main/src/main_Seattle_2021.do) and it is stored in the [src](https://github.com/alvarogutyerrez/StataConfSeattle2021_Hunting_the_missing_Score_Fn/tree/main/src) folder. The [MyClogit.ado](https://github.com/alvarogutyerrez/StataConfSeattle2021_Hunting_the_missing_Score_Fn/blob/main/src/MyClogit.ado) and its evaluator [MyLikelihood_LL.mata](https://github.com/alvarogutyerrez/StataConfSeattle2021_Hunting_the_missing_Score_Fn/blob/main/src/MyLikelihood_LL.mata) are stored in the same folder.


The slides of the presentation can be downloaded from [here](https://www.dropbox.com/s/ttbopzcp3n371yy/StataConfSeattle2021_Gutierrez-Vargas.pdf?dl=0).

A follow up talk presented at the [2021 UK Stata Conference](https://www.statauk.timberlake-conferences.com/) can be found [here](https://www.dropbox.com/s/454j72hwqwz8izv/UK_StataConf2021_Gutierrez-Vargas.pdf). 



### Further information

I wrote some small posts about [-clogit-](https://www.stata.com/manuals/rclogit.pdf) in the past and how to implement it using the ml command using a Mata evaluator. You can check those below.

* [How to implement a conditional logit using ml interactive mode](https://alvarogutyerrez.github.io/2020/07/03/fitting-conditional-logit-using-d0-mata-based-evaluator-using-maximum-likelihood-ml-on-stata/)

* [Write your own command to fit a likelihood using a Mata-evaluator with ml command on Stata](https://alvarogutyerrez.github.io/2020/07/04/how-to-write-your-own-command-to-fit-a-likelihood-using-a-mata-evaluator-with-ml-command-on-stata/)




### Tell a friend!


In case you found this relevant consider sharing it with your friends :)!

<blockquote class="twitter-tweet" data-lang="en" data-theme="dark"><p lang="en" dir="ltr">I&#39;ll be giving a small talk at the <a href="https://twitter.com/Stata?ref_src=twsrc%5Etfw">@Stata</a> conference about computing numerical derivatives using Mata&#39;s deriv() function. We will use them to numerically approximate robust variance-covariance matrices when fitting models that do not meet the linear-form restriction :)<a href="https://twitter.com/hashtag/EconTwitter?src=hash&amp;ref_src=twsrc%5Etfw">#EconTwitter</a> <a href="https://t.co/S0M9Q8VwH5">https://t.co/S0M9Q8VwH5</a> <a href="https://t.co/sXkxIDSDYF">pic.twitter.com/sXkxIDSDYF</a></p>&mdash; 



