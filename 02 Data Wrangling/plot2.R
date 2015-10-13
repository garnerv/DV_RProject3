#pull in dataframe from oracle excluding universities with zero dollar tuition and fees
df <- data.frame(fromJSON(getURL(URLencode('129.152.144.84:5001/rest/native/?query="select * from COLLEGESTATS where tuitionfees1314 is not null"'),httpheader=c(DB='jdbc:oracle:thin:@129.152.144.84:1521/PDBF15DV.usuniversi01134.oraclecloud.internal', USER='cs329e_gv4353', PASS='orcl_gv4353', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

#add a new column to the dataframe using the mutate function. graph using ggplot.
df <- df %>% mutate(Enroll_ment = cume_dist(ENROLLMENTTOTAL))
levels <- c(0, .33, .66, 1)
labels <- c('small', 'medium', 'large')
df <- df %>% filter(ENROLLMENTTOTAL != "null") %>% mutate(x = cut(Enroll_ment, levels, labels = labels)) %>% View

df %>% group_by(x, PUBLICPRIVATE) %>% summarise(mean_loans = mean(as.numeric(AVGAMTFIRSTTIMEUGINSGRANT)), n=n(), mean_tuition = mean(as.numeric(TUITIONFEES1314))) %>% ggplot(aes(x=x, y=mean_tuition, color = PUBLICPRIVATE)) + geom_point(size = 5)

#df %>% select(PUBLICPRIVATE, GRADUATIONRATE, AVGAMTFIRSTTIMEUGFED, STUDENTFACULTYRATIO) %>% filter(PUBLICPRIVATE == "Public") %>% mutate(ntile_ratio = ntile(STUDENTFACULTYRATIO, 4)) %>% arrange(desc(ntile_ratio)) %>% mutate(UG_FED = cume_dist(AVGAMTFIRSTTIMEUGFED)) %>% arrange(desc(GRADUATIONRATE)) %>% View 


#%>% ggplot(aes(x = GRADUATIONRATE, y = UG_FED)) + geom_point(aes(color=ntile_ratio)) + labs(title='TITLE') + labs(x="X AXIS", y=paste("Y AXIS")) %>% View

View(df)
