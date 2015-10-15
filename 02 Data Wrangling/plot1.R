census <- data.frame(fromJSON(getURL(URLencode('129.152.144.84:5001/rest/native/?query="select * from CENSUSDATA"'),httpheader=c(DB='jdbc:oracle:thin:@129.152.144.84:1521/PDBF15DV.usuniversi01134.oraclecloud.internal', USER='cs329e_gv4353', PASS='orcl_gv4353', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

income <- data.frame(fromJSON(getURL(URLencode('129.152.144.84:5001/rest/native/?query="select * from INCOMEDATA"'),httpheader=c(DB='jdbc:oracle:thin:@129.152.144.84:1521/PDBF15DV.usuniversi01134.oraclecloud.internal', USER='cs329e_gv4353', PASS='orcl_gv4353', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

#make a join data frame using inner join
join <- dplyr::inner_join(census, income, by="ZIP") %>% tbl_df


#add a new grouping by population size cum distribution
join <- join %>% mutate(pop_percent = cume_dist(POPULATION))

#add a new column to get average salaries/wages per person
join <- within (join, singleMotherP <- SINGLEMOTHERHOUSEHOLD/HOUSEHOLDS)
join <- join %>% mutate(mother_percentile = cume_dist(singleMotherP))

#get salaries and wages per person in the population
join <- within (join, avgIncome <- SALARIESWAGES/POPULATION)

#group population sizes into S/M/L
levels <- c(0, .33, .66, 1)
labels <- c("Small", "Medium", "Large")
join <- join %>% mutate(PopSize = cut(pop_percent, levels, labels = labels))

#add a new column to the dataframe using the mutate function. graph using ggplot.
join %>% mutate(salwages_percent = cume_dist(avgIncome)) %>% ggplot(aes(x = salwages_percent, y = mother_percentile)) + geom_point(aes(color=PopSize)) + facet_wrap(~PopSize) + labs(title='Percentile of Salaries/Wages Average Per Person in Every US Zip Code\n by Percentile of Single Mother Households\n in the Same Zip Code') + labs(x="Percentile of Average Salaries/Wage Per Individual", y=paste("Percentile of Single Mother Households in Zip Code"))
