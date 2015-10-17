census <- data.frame(fromJSON(getURL(URLencode('129.152.144.84:5001/rest/native/?query="select * from CENSUSDATA"'),httpheader=c(DB='jdbc:oracle:thin:@129.152.144.84:1521/PDBF15DV.usuniversi01134.oraclecloud.internal', USER='cs329e_gv4353', PASS='orcl_gv4353', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

income <- data.frame(fromJSON(getURL(URLencode('129.152.144.84:5001/rest/native/?query="select * from INCOMEDATA"'),httpheader=c(DB='jdbc:oracle:thin:@129.152.144.84:1521/PDBF15DV.usuniversi01134.oraclecloud.internal', USER='cs329e_gv4353', PASS='orcl_gv4353', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

#make a join data frame using inner join
join <- dplyr::outer_join(census, income, by="ZIP") %>% tbl_df


#add a new grouping by net income cum distribution
join <- join %>% mutate(net_income = cume_dist(NETINCOME))

#add a new column to get average salaries/wages per person
join <- within (join, twoparentP <- HUSBANDWIFEHOUSEHOLDS/HOUSEHOLDS)
join <- join %>% mutate(twoparent_percentile = cume_dist(twoparentP))

#get salaries and wages per person in the population
join <- within (join, avgAGIncome <- ADJUSTGROSSINCOME/POPULATION)

#group population sizes into S/M/L
levels <- c(0, .33, .66, 1)
labels <- c("Small", "Medium", "Large")
join <- join %>% mutate(NetIncome = cut(net_income, levels, labels = labels))

#add a new column to the dataframe using the mutate function. graph using ggplot.
join %>% mutate(netinc_percent = cume_dist(avgAGIncome)) %>% ggplot(aes(x = netinc_percent, y = twoparent_percentile)) + geom_point(aes(color=NetIncome)) + facet_wrap(~NetIncome) + labs(title='Percentile of Average Net Income Per Person in Every US Zip Code\n by Percentile of Husband and Wife Households\n in the Same Zip Code') + labs(x="Percentile of Average Adjust Gross Income Per Individual", y=paste("Percentile of Husband and Wife Households in Zip Code"))
