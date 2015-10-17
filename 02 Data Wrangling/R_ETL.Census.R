setwd("C:/Users/Wes James/Documents/Data Visualization/DV_RProject3/01 Data")
file_path <- "2010CensusPopulationData.csv"
getwd()

# str(df) # Uncomment this and  run just the lines to here to get column types to use for getting the list of measures.

df <- read.csv(file_path, stringsAsFactors = FALSE)

measures <- c("Population", "PopulationMale", "PopulationFemale", "MedianAge", "MedianAgeMale", "MedianAgeFemale", "PopulationRaceWhite", "PopulationRaceBlack", "PopulationAmerindian", "PopulationRaceAsian", "PopulationRacePacific", "PopulationRaceOther", "PopulationRaceMulti","PopulationRaceLatino", "Households", "HusbandWifeHouseholds", "SingleFatherHousehold", "SingleMotherHousehold", "NonFamilyHouseholds", "HouseHolder15to24","HouseHolder25to34", "HouseHolder35to44", "HouseHolder45to54", "HouseHolder55to59", "HouseHolder60to64", "HouseHolder65to74", "HouseHolder75to84", "HouseHolder85over", "HouseholdsWith60Plus", "HouseholdsWith75Plus", "Households2Person", "Households3Person", "Households4Person", "Households5Person", "Households6Person", "Households7PlusPerson") 

#measures <- NA # Do this if there are no measures.

# Get rid of special characters in each column.
# Google ASCII Table to understand the following:
for(n in names(df)) {
  df[n] <- data.frame(lapply(df[n], gsub, pattern="[^ -~]",replacement= ""))
}

dimensions <- setdiff(names(df), measures)
if( length(measures) > 1 || ! is.na(dimensions)) {
  for(d in dimensions) {
    # Get rid of " and ' in dimensions.
    df[d] <- data.frame(lapply(df[d], gsub, pattern="[\"']",replacement= ""))
    # Change & to and in dimensions.
    df[d] <- data.frame(lapply(df[d], gsub, pattern="&",replacement= " and "))
    # Change : to ; in dimensions.
    df[d] <- data.frame(lapply(df[d], gsub, pattern=":",replacement= ";"))
  }
}

# The following is an example of dealing with special cases like making state abbreviations be all upper case.
# df["State"] <- data.frame(lapply(df["State"], toupper))

#Get rid of all characters in measures except for numbers, the - sign, and period.dimensions
#if( length(measures) > 1 || ! is.na(measures)) {
#  for(m in measures) {
#    df[m] <- data.frame(lapply(df[m], gsub, pattern="[^--.0-9]",replacement= ""))
#  }
#}

write.csv(df, paste(gsub(".csv", "", file_path), ".reformatted.csv", sep=""), row.names=FALSE, na = "")

CensusData <- gsub(" +", "_", gsub("[^A-z, 0-9, ]", "", gsub(".csv", "", file_path)))
sql <- paste("CREATE TABLE", CensusData, "(\n-- Change table_name to the table name you want.\n")
if( length(measures) > 1 || ! is.na(dimensions)) {
  for(d in dimensions) {
    sql <- paste(sql, paste(d, "varchar2(4000),\n"))
  }
}

if( length(measures) > 1 || ! is.na(measures)) {
  for(m in measures) {
    if(m != tail(measures, n=1)) sql <- paste(sql, paste(m, "number(38,4),\n"))
    else sql <- paste(sql, paste(m, "number(38,4)\n"))
  }
}
sql <- paste(sql, ");")
cat(sql)
