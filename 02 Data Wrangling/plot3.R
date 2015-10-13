#pull in dataframe from oracle excluding universities with zero dollar tuition and fees
df <- data.frame(fromJSON(getURL(URLencode('129.152.144.84:5001/rest/native/?query="select * from COLLEGESTATS where tuitionfees1314 is not null"'),httpheader=c(DB='jdbc:oracle:thin:@129.152.144.84:1521/PDBF15DV.usuniversi01134.oraclecloud.internal', USER='cs329e_gv4353', PASS='orcl_gv4353', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))


df <- df %>% mutate(pell_percent = cume_dist(AVGAMTFIRSTTIMEUGPELL))
levels <- c(0, .25, .5, .75, 1)
labels <- c("4th Q Highest Pell Grant", "3rd Q Highest Pell Grant", "2nd Q Highest Pell Grant", "1st Q Highest Pell Grant")
df <- df %>% filter(AVGAMTFIRSTTIMEUGPELL != "null") %>% mutate(x = cut(pell_percent, levels, labels = labels))

df %>% group_by(x, PUBLICPRIVATE) %>% summarise(mean_fac = mean(as.numeric(STUDENTFACULTYRATIO)), n=n(), mean_tuition = mean(as.numeric(TUITIONFEES1314))) %>% ggplot(aes(x=mean_fac, y=mean_tuition, color=x)) + geom_point(size=5) + facet_wrap(~PUBLICPRIVATE) + labs(title='Mean Average Faculty\n vs. Mean Tuition and Fees (Year 13-14)\n, Grouped by Quartile Ranking\n of Highest Average Pell Grants Students Receive') + labs(x="Average Student:Faculty Ratio", y=paste("Tuition and Fees for 2013-2014 Academic School Year ($)"))
