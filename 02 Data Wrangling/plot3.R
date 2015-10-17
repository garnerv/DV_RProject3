#census <- data.frame(fromJSON(getURL(URLencode('129.152.144.84:5001/rest/native/?query="select * from CENSUSDATA"'),httpheader=c(DB='jdbc:oracle:thin:@129.152.144.84:1521/PDBF15DV.usuniversi01134.oraclecloud.internal', USER='cs329e_gv4353', PASS='orcl_gv4353', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

#income <- data.frame(fromJSON(getURL(URLencode('129.152.144.84:5001/rest/native/?query="select * from INCOMEDATA"'),httpheader=c(DB='jdbc:oracle:thin:@129.152.144.84:1521/PDBF15DV.usuniversi01134.oraclecloud.internal', USER='cs329e_gv4353', PASS='orcl_gv4353', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

#make a join data frame using inner join
join <- dplyr::inner_join(census, income, by="ZIP") %>% tbl_df

#add a new grouping by population size cum distribution
join <- join %>% mutate(pop_percent = cume_dist(POPULATION))

#add a new column to get Ratio of households with seven or more
join <- within (join, SevenPlusRatio <- HOUSEHOLDS7PLUSPERSON/HOUSEHOLDS)

#group population sizes into S/L
levels <- c(0, .5, 1)
labels <- c("Small", "Large")
join <- join %>% mutate(PopSize = cut(pop_percent, levels, labels = labels))

#add a new column to the dataframe using the mutate function. graph using ggplot.
join %>% mutate(SevenPlusPercent = cume_dist(SevenPlusRatio)) %>% ggplot(aes(x = SevenPlusPercent, y = POPULATIONRACELATINO)) + geom_point(aes(color=PopSize)) + facet_wrap(~PopSize) + labs(title='Percentile of Households with 7 or more \n by Percentile of Population of Latino Race') + labs(x="Percentile of Households with Seven Plus" ,  y=paste("Percentile of Population with Latino Race"))

