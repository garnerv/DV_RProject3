require(tidyr)
require(dplyr)

df <- data.frame(fromJSON(getURL(URLencode('129.152.144.84:5001/rest/native/?query="select * from COLLEGESTATS"'),httpheader=c(DB='jdbc:oracle:thin:@129.152.144.84:1521/PDBF15DV.usuniversi01134.oraclecloud.internal', USER='cs329e_gv4353', PASS='orcl_gv4353', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))
head(df)

df %>% select(TUITIONFEES1314, AVGAMTFIRSTTIMEUGGRANTAID) %>% tbl_df
df %>% select(., TUITIONFEES1314, AVGAMTFIRSTTIMEUGGRANTAID) %>% tbl_df
df %>% select(PFIRSTTIMEUGANYAID:AVGAMTFIRSTTIMEUGGRANTAID) %>% tbl_df # Equivalent SQL: none
#all of the columns between color and price
df %>% select(-cut, -clarity) %>% tbl_df # Equivalent SQL: none
x <- df %>% select(cut, clarity) %>% tbl_df #assign data frame to x
x

# filter
df %>% select(PUBLICPRIVATE, GRADUATIONRATE) %>% filter(PUBLICPRIVATE == "Public") %>% tbl_df # Equivalent SQL: 
# select cut, clarity from diamonds where cut = 'Good'
diamonds %>% select(cut, clarity) %>% filter(cut %in% c("Good", "Fair")) %>% tbl_df #cut to be in the collection of good and fair     where cut = 'Good' or cut = 'Fair'; we need to study the entire workflow in the quiz
#send %>% into View instead of into tbl_df
diamonds %>% select(cut, clarity) %>% filter(cut %in% c("Good", "Fair"), clarity == "VS1") %>% tbl_df
#select cut, clarity from diamonds where (cut = 'Good' or cut = 'Fair') and clarity = 'VS1'
diamonds %>% select(cut, clarity) %>% filter(cut %in% c("Good", "Fair"), clarity == "VS1" | is.na(cut)) %>% tbl_df
#select cut, clarity from diamonds where (cut = 'Good' or cut = 'Fair') and (clarity = 'VS1' or cut is null)
diamonds %>% select(carat, clarity) %>% filter(carat > 2) %>% tbl_df
#select carat, clarity from diamonds where carat > 2
diamonds %>% select(cut, clarity, x, y, z) %>% filter(cut %in% c("Good", "Fair"), clarity == "VS1" | is.na(cut)) %>% tbl_df

# arrange
data.frame(x=c(1,1,1,2,2), y=c(5:1), z=(1:5)) %>% arrange(desc(x)) %>% tbl_df
data.frame(x=c(1,1,1,2,2), y=c(5:1), z=(1:5)) %>% arrange(desc(x),y) %>% tbl_df #if you don't specify descending, it is ascending
diamonds %>% arrange(carat) %>% tbl_df
#select * from diamonds order by carat; #
diamonds %>% arrange(desc(carat)) %>% tbl_df
#select * from diamonds order by carat desc;

# rename
diamonds %>% rename(tbl= table) %>% tbl_df
#select cut, color, clarity, carat, depth, tbl as "table", Price, x, y, z from diamonds;

# mutate adds a new column
diamonds %>% select(cut, clarity, x, y, z) %>% filter(cut %in% c("Good", "Fair"), clarity == "VS1" | is.na(cut)) %>% mutate(sum = x+y+z) %>% tbl_df
#creates a new column with name sum with values x + Y + Z
#select cut, clarity, x + y + z sum from diamonds where ((cut = 'fair' or cut = 'fair) and clarity = 'VS1) or cut is null
ndf <- diamonds %>% select(cut, clarity, x, y, z) %>% filter(cut %in% c("Good", "Fair"), clarity == "VS1" | is.na(cut)) %>% mutate(sum = x+y+z) %>% tbl_df

ndf

# Useful mutate functions:
    # pmin(), pmax() Parallel, Element-wise min and max
    # cummin(), cummax() Cumulative min and max
    # cumsum(), cumprod() Cumulative sum and product
  # Windowing functions
    # between() Are values between a and b?
    # cume_dist() Cumulative distribution of values
    # cumall(), cumany() Cumulative all and any
    # cummean() Cumulative mean
    # lead(), lag() Copy with values one position
    # ntile() Bin vector into n buckets
    # dense_rank(), min_rank(),
    # percent_rank(), row_number() Various ranking methods

pmin(c(1:5), (5:1)) # Pairwise min
diamonds %>% mutate(minxy = pmin(x,y)) %>% tbl_df
pmax(c(1:5), (5:1)) # Pairwise max
c(1,1,2,0,4,3,5) %>% cummin()
diamonds %>% mutate(cummin_x = cummin(x)) %>% tbl_df
c(1,1,2,5,4,3,5) %>% cummax()
c(1,1,2,3,4,3,5) %>% cumsum()
diamonds %>% mutate(cumsum_x = cumsum(x)) %>% tbl_df
c(1,1,2,3,4,3,5) %>% cumprod()
c(1,1,2,3,4,3,5) %>% between(2,4)
diamonds %>% mutate(between_x = between(x,4,4.1)) %>% tbl_df
c(1:5) %>% cummean()
c(1:5) %>% lead() - c(1:5)
diamonds %>% mutate(lead_z = lead(z)-z) %>% tbl_df
c(1:5) %>% lag() - c(1:5)
diamonds %>% mutate(lag_z = lag(z)-z) %>% tbl_df
c(1:10)
c(1:10) %>% ntile(4) # bucket edges are rounded
diamonds %>% mutate(ntile_z = ntile(z,100)) %>% arrange(desc(ntile_z)) %>% tbl_df
diamonds %>% mutate(ntile_z = ntile(z,100)) %>% group_by(ntile_z) %>% summarise(n=n()) %>% tbl_df

c(1,1,2,5,4,3,5) %>% cume_dist() %>% View
c(1:5) %>% cume_dist()
c(1,1:5) %>% cume_dist()
# c(TRUE, TRUE, FALSE, FALSE, TRUE) %>% cumall()
# c(FALSE, TRUE, FALSE, FALSE, TRUE) %>% cumany()
# Now let's try them in the mutate function
what <- df %>% mutate(anyaid_percent = cume_dist(PFIRSTTIMEUGANYAID)) %>% arrange(desc(anyaid_percent)) %>% tbl_df
View(what)
#price in that row, what the percentile for that price is in the overall dataset

# select d.*, cume_dist() OVER (order by price) cume_dist from diamonds d order by 11 desc;
# select d.*, cume_dist() OVER (PARTITION BY cut order by price) cume_dist from (select * from diamonds where rownum < 100) d order by cut desc, 11 desc;

p_anyaid <- df %>% mutate(anyaid_percent = cume_dist(PFIRSTTIMEUGANYAID)) %>% filter(anyaid_percent <= 97 ) %>% arrange(desc(anyaid_percent)) %>% tbl_df
p_anyaid
View(p_anyaid)
diamonds %>% mutate(price_percent = cume_dist(price)) %>% filter(price_percent >= .80) %>% arrange(desc(price_percent)) %>% tbl_df
top20_diamonds <- diamonds %>% mutate(price_percent = cume_dist(price)) %>% filter(price_percent >= .80) %>% arrange(desc(price_percent)) %>% tbl_df
diamonds %>% mutate(price_percent = cume_dist(price)) %>% filter(price_percent <= .20 | price_percent >= .80) %>% ggplot(aes(x = price, y = carat)) + geom_point(aes(color=cut))

# summarize (summarise)
diamonds %>% summarize(mean = mean(x), sum = sum(x,y,z), n = n())
# Useful Summary functions:
# min(), max() Minimum and maximum values
# mean() Mean value
# median() Median value
# sum() Sum of values
# var, sd() Variance and standard deviation of a vector
# first() First value in a vector
# last() Last value in a vector
# nth() Nth value in a vector
# n() The number of values in a vector
# n_distinct() The number of distinct values in a vector

diamonds %>% group_by(cut,color) %>% summarise(mean = mean(x), sum = sum(x,y,z), n = n())
diamonds %>% group_by(cut,color) %>% summarise(mean = mean(x), sum = sum(x,y,z), n = n()) %>% ungroup %>% summarize(sum(n))

diamonds %>% group_by(cut,color) %>% summarise(mean = mean(x), sum = sum(x,y,z), n = n()) %>% arrange(n)
diamonds %>% group_by(cut,color) %>% summarise(mean = mean(x), sum = sum(x,y,z), n = n()) %>% arrange(desc(n), cut, color)

df %>% group_by(PUBLICPRIVATE) %>% summarise(mean_carat = mean(carat)) %>% ggplot(aes(x=cut, y=mean_carat, color=color)) + geom_point() + facet_wrap(~clarity)
