****clean and label data****
cd H:\Documents
#delimit ;

   infix
      year     1 - 20
      papres10 21 - 40
      prestg10 41 - 60
      ballot   61 - 80
      intrhome 81 - 100
      compuse  101 - 120
      region   121 - 140
      rincom06 141 - 160
      rincome  161 - 180
      race     181 - 200
      sex      201 - 220
      educ     221 - 240
      age      241 - 260
      hrs2     261 - 280
      wrkstat  281 - 300
      id_      301 - 320
      mapres10 321 - 340
using GSS.dat;


label variable year     "Gss year for this respondent"
label variable papres10 "Father's occupational prestige score (2010)"
label variable prestg10 "Rs occupational prestige score (2010)"
label variable ballot   "Ballot used for interview"
label variable intrhome "Internet access in r's home"
label variable compuse  "R use computer"
label variable region   "Region of interview"
label variable rincom06 "Respondents income"
label variable rincome  "Respondents income"
label variable race     "Race of respondent"
label variable sex      "Respondents sex"
label variable educ     "Highest year of school completed"
label variable age      "Age of respondent"
label variable hrs2     "Number of hours usually work a week"
label variable wrkstat  "Labor force status"
label variable id_      "Respondent id number"
label variable mapres10 "Mother's occupational prestige score (2010)"


label values ballot   gsp001x
label values intrhome gsp002x
label values compuse  gsp003x
label values region   gsp004x
label values rincom06 gsp005x
label values rincome  gsp006x
label values race     gsp007x
label values sex      gsp008x
label values educ     gsp009x
label values age      gsp010x
label values hrs2     gsp011x
label values wrkstat  gsp012x


*change to a format that stata can run
label define gsp001x 4 "Ballot d" 3 "Ballot c" 2 "Ballot b" 1 "Ballot a" 0 "Not applicable"

label define gsp002x 9 "No answer" 8 "Dont know" 2 "No" 1 "Yes" 0 "Not applicable"

label define gsp003x 9 "No answer" 8 "Don't know" 2 "No" 1 "Yes" 0 "Not applicable"

label define gsp004x 9 "Pacific" 8 "Mountain" 7 "W. sou. central" 6 "E. sou. central" 5 "South atlantic" 4 "W. nor. central" 3 "E. nor. central" 2 "Middle atlantic" 1 "New england" 0 "Not assigned"

label define gsp007x/*
*/   3        "Other"/*
*/   2        "Black"/*
*/   1        "White"/*
*/   0        "Not applicable"

label define gsp008x/*
*/   2        "Female"/*
*/   1        "Male"

label define gsp009x/*
*/   99       "No answer"/*
*/   98       "Don't know"/*
*/   97       "Not applicable"

label define gsp010x/*
*/  99       "No answer"/*
*/  98       "Don't know"/*
*/  89       "89 or older"

label define gsp011x/*
*/   99       "No answer"/*
*/   98       "Don't know"/*
*/   -1       "Not applicable"

label define gsp012x/*
*/   9        "No answer"/*
*/   8        "Other"/*
*/   7        "Keeping house"/*
*/   6        "School"/*
*/   5        "Retired"/*
*/   4        "Unempl, laid off"/*
*/   3        "Temp not working"/*
*/   2        "Working parttime"/*
*/   1        "Working fulltime"/*
*/   0        "Not applicable"
   
 ****cleaning done****
 
 *generate prestige score variables
gen avgpres = (papres10 + mapres10)/2
gen difpres= prestg10 -((papres10 + mapres10)/2)
hist difpres, freq
hist avgpres, freq

*check missing values and drop not applicable variables
drop if intrhome==0
drop hrs2
drop region

*generate internet home dummy variable
gen intraccess =.
replace intraccess = 0 if intrhome ==1
replace intraccess = 1 if intrhome ==2
label define intraccesslabel 0 "internet access" 1 "no internet access"
label values intraccess intraccesslabel
drop if intraccess ==.

*computer usage applicable good variable, if applicable usecomputer==1
gen usecomputer =.
replace usecomputer = 0 if compuse ==0
replace usecomputer = 0 if compuse ==9
replace usecomputer = 1 if compuse !=0

*clean for educ varibale
drop if educ >21
gen educlevel=.

replace educlevel=0 if educ<9
replace educlevel=1 if educ>=9 & educ<12
replace educlevel=2 if educ>=12 & educ<16
replace educlevel=3 if educ>=16

label define educlevellabel 0 "below high school" 1"below high school graduate" 2 "below college graduate" 3 "college graduate and above"
label values educlevel educlevellabel


*regress starts here
gen ieduc=avgpres*educ


*model 1
regress prestg10 avgpres i.intraccess

*model 2
regress prestg10 avgpres ieduc i.intraccess

*model 3
summarize avgpres
xi: regress prestg10 avgpres i.sex i.race i.educlevel if intraccess ==0
xi: regress prestg10 avgpres i.sex i.race i.educlevel if intraccess ==0 & avgpres < 31.23998 



