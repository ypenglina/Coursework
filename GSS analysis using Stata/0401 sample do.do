*1------------------------------------------------------------------

***prepare data***

*drop if no value in prestige score
drop if prestg10 ==.

*make dummy variables for internet access; clean and label them properly
gen intraccess =.
replace intraccess = 0 if intrhome ==1
replace intraccess = 1 if intrhome ==2
label define intraccesslabel 0 "internet access" 1 "no internet access"
label values intraccess intraccesslabel
drop if intraccess ==.

*check missing values in educ and drop them
codebook educ, tab(99) *missing values are listed as 98 and 99
drop if educ >21
gen educlevel=.

*make dummy variables for education levels
replace educlevel=0 if educ<9
replace educlevel=1 if educ>=9 & educ<12
replace educlevel=2 if educ>=12 & educ<16
replace educlevel=3 if educ>=16


*label education levels 
label define educlevellabel 0 "below high school" 1"below high school graduate" 2 "below college graduate" 3 "college graduate and above"
label values educlevel educlevellabel
***prepare data***
*data in Github is the cleaned version and there's no need to prepare data again

***regression test***
use "C:\Users\lina\Documents\Coursework\GSS analysis using Stata\original.dta"
xi:regress prestg10 i.educlevel i.intraccess
test _Ieduclevel_1 _Ieduclevel_2 _Ieduclevel_3
test _Ieduclevel_1=_Ieduclevel_2=_Ieduclevel_3

xi:regress prestg10 i.educlevel i.intraccess*i.educlevel
test _IintXeduc_1_1 _IintXeduc_1_2 _IintXeduc_1_3
test _IintXeduc_1_1=_IintXeduc_1_2=_IintXeduc_1_3
***regression test***

*2------------------------------------------------------------------
***prepare data***
use "C:\Users\lina\Documents\Coursework\GSS analysis using Stata\gss2008.dta"

*make dummy variables for income
codebook income06, tab(99)
recode income06 1=500 2=2000 3=3500 4=4500 5=5500 6=6500 7=7500 8=9000 9=11250 10=13750 11=16250 12=18750 /*
	*/ 13=21250 14=23750 15=27500 16=32500 17=37500 18=45000 19=55000 20=67500 21=82500 22=100000 23=120000 /*
	*/ 24=140000 25=175000 *=., gen(incomenew) label(incomenew)
tab incomenew

*combine work hours variables into one
codebook hrs1 hrs2, tab(99)
gen hrs1new=hrs1
replace hrs1new=. if hrs1==.d | hrs1==.i | hrs1==.n

gen hrs2new=hrs2
replace hrs2new=. if hrs2==.i | hrs2==.n

gen hrs_wrked=hrs1new
replace hrs_wrked=hrs2new if hrs1new==.
tab hrs_wrked

*make one variable to check if there's missing value in any of the variables being tested
gen good=1
replace good=0 if incomenew==. | educ==. | educ==.d | educ==.n | hrs_wrked==. 
tab good

gen incomelog = log(incomenew)
***prepare data***

***test***
ladder incomenew if good==1
regress incomelog educ hrs_wrked i.sex if good==1

*graphing regression
predict mcoeff if sex==1
predict fcoeff if sex==2
twoway (lfit incomelog mcoeff) (lfit incomelog fcoeff), legend(label(1 "male") label(2 "female")) ytitle(incomelog)


*calculate group average
mean educ if sex==2 & good==1
mean hrs_wrked if sex==2 & good==1

mean educ if sex==1 & good==1
mean hrs_wrked if sex==1 & good==1
***test***

*3------------------------------------------------------------------
use "C:\Users\lina\Documents\Coursework\GSS analysis using Stata\GSS2004.dta"
*labeling income levels
codebook rincom98, tab(99)
recode rincom98 1=500 2=2000 3=3500 4=4500 5=5500 6=6500 7=7500 8=9000 9=11250 10=13750 11=16250 12=18750 13=21250 14=23750 15=27500 16=32500 17=37500 18=45000 19=55000 20=67500 21=82500 22=100000 23=120000 .a=. .i=. *=., gen(incomenew) label(incomenew)

*generating variables for quadratic formula and check missing values
gen good=1
replace good=0 if incomenew==. | age==.n
gen agesqr=age^2

*perform regression and graph it
regress incomenew age agesqr if good ==1
twoway qfit incomenew age if good==1, ytitle(income)

