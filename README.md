# statagod
Mine afhængige variable er: "ac_index (0-4)" og "vote (0=nej, 1=ja)"
Mine uafhængige variable er: "nwspol (0-1440)" og "pstplonl (0=nej, 1=ja)"

Min moderations variabel er "agea"

Mine kontrol variabler er "female (køn omkodet til female=1 male=0)"  "hincfel" "edu_cat (uddannelses niveau omkodet til kategorisk var)" "polin (politisk interesse)" "cptppola" "lrscale" "ppltrst" landid (alle lande med i datasæt)"


ac_index er et index bestående af fire binære variabler 

ac index er kodet således 

 "recode pbldmna (1=1) (2=0)"
"recode bctprd  (1=1) (2=0)"
"recode sgnptit (1=1) (2=0)"
"recode volunfp (1=1) (2=0)"

"egen ac_index_rowtotal = rowtotal(pbldmna sgnptit bctprd volunfp)"
