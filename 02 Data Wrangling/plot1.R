#pull in dataframe from oracle excluding universities with zero dollar tuition and fees
df <- data.frame(fromJSON(getURL(URLencode('129.152.144.84:5001/rest/native/?query="select * from COLLEGESTATS where tuitionfees1314 is not null"'),httpheader=c(DB='jdbc:oracle:thin:@129.152.144.84:1521/PDBF15DV.usuniversi01134.oraclecloud.internal', USER='cs329e_gv4353', PASS='orcl_gv4353', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
#add a new column to the dataframe using the mutate function. graph using ggplot.
df %>% mutate(insgrant_percent = cume_dist(AVGAMTFIRSTTIMEUGINSGRANT)) %>% arrange(desc(insgrant_percent)) %>% ggplot(aes(x = insgrant_percent, y = TUITIONFEES1314)) + geom_point(aes(color=PUBLICPRIVATE)) + labs(title='Avg Institutional Grant Money\n Received by Freshmen by Percentile\n vs. Tuition and Fees for the 13-14 School Year') + labs(x="Percentile of Average Institutional Grant Offered to Freshmen", y=paste("Tuition and Fees for 2013-2014 Academic School Year ($)"))

View(df)
