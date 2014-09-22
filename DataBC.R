library(plyr);
library(reshape2);
library(stringr);

## Goals
## 1. each variable should be in one column
## 2. each observation of that variable should be in a diferent row
## 3. Once the file cleaned and with tidy data, set up a dynamic google visualisation

## Set up the working directory
getwd()
# [1] "C:/Users/eugene.nzengou/Documents/data"
setwd("C:/Users/eugene.nzengou/Documents/data/Projects_R/DataBC")

## Data source
# http://www.data.gov.bc.ca/dbc/catalogue/detail.page?config=dbc&P110=recorduid:179884&recorduid=179884&title=British%20Columbia%20Greenhouse%20Gas%20Emissions

message("Read csv file (source: ...)")
# Read csv file (source: ...) skiping the first  two lines and starting from the header on the third
## remove NA from data frame 

df = read.csv("bc_ghg_related_data.csv", header=TRUE,sep=",");
## Or
# df = read.csv(text=readLines('bc_ghg_related_data.csv'))

## Dimension of the data frame
# dim(df)
# [1] 23   8

## Check for the the data frame column names
# colnames(df)

## Check for the the data frame row names
# rownames(df)


## Check for the data structure of the first and last 3 rows
# head(df, n=3)
# tail(df, n=3)


## FYI A = matrix of 5 columns and 20 rows made of random numbers from normal distribution
# A <- replicate(5, rnorm(20))

## Convert the first row of df dataframe into column names. Tips: by safety, let's initially assign df to another df so df stays untouched
# df3 <- df;
# df3$new_sp <- NULL;
# names(df3) <- str_replace(names(df3), "new_sp_", "");
# names(df3) <- c("Year","BC_GHG_Emissions_ktCO2e","Population","GHGs_per_Capita_tCO2e_person","GDP","GHGs_per_GDP_tCO2e_million_GDP","Energy_Use_TJ","GHGs_Energy_Use_kgCO2e_GJ");

## Check dataframe structure
# head(df3, n=3)
# tail(df3, n=3)

## Transpose the dataset df3
T <- t(df)
# T3 <- t(df3);

## Clean the dataframe that includes multivariables (var1 and var2) in columns to turn it into a tidy dataset
# tidy <- melt(T, id=c("Year"), na.rm=TRUE);

## Check tidy dataframe structure
# tail(tidy, n=3);
#                               Var1 Var2        value
# 182 GHGs_per_GDP_tCO2e_million_GDP   23    294.31359
# 183                  Energy_Use_TJ   23 853605.00000
# 184      GHGs_Energy_Use_kgCO2e_GJ   23     72.04745
# we want to change Var2 into their "real" names (1990, 1991, ..., 2012)

## Convert the values in the first row of the transposed dataframe (T) into column names
T2 <- T[-1,];
colnames(T2) <- T[1,];

## Clean the dataframe that includes multivariables (var1 and var2) in columns to turn it into a tidy dataset
tidy <- melt(T2, id=c("Year"), na.rm=TRUE);

## Change Var1 and Var2 names into Indicator.Name and Year
names(tidy)[1] <- "Indicator.Name"; names(tidy)[2] <- "Year";

## Check dataframe structure
# head(tidy, n=3);
# tail(tidy, n=3);
#                Indicator.Name Year    value
# 160 GHGs_Energy_Use_kgCO2e_GJ 2011 72.72778
# 161 GHGs_Energy_Use_kgCO2e_GJ 2012 72.04745

## Ceck class type for column Year (it should not be a Factor of Character)
# class(tidy$Year)
# [1] "integer"
## Or
# sapply(tidy, class)
# Indicator.Name           Year          value 
#       "factor"      "integer"      "numeric"

# Another possibility is to order the rows by Indicator.Name (rather than what's done usually sorting by variable "Year")
# message("Arrange the tidy dataset by Indicator.Name");
tidy <- arrange(tidy, Indicator.Name, Year);

## Create a backup csv file
sink("tidy.txt");
tidy;
sink();



## Eliminate missig values (NA)
# df4 <- na.omit(newdf3)
## Check dataframe structure
# head(df3, n=3)
# tail(df3, n=3)


## Dimension of the data frame
# dim(tidy)
# [1] 1566    3


## FYI Summary of tidy and subset
# summary(tidy)  # Indicator.Name : 108...
# summary(subset)  # Indicator.Name : 2...
# str(subset)  # 'data.frame':	29 obs. of  55 variables:...


## If list of indicators
# unique(tidy$Indicator.Name, incomparables=FALSE)


## Data dynamic visualization on GoogleVis
# Install.packages("googleVis")
library(googleVis);

# install.packages("zoo")
library("zoo");
# "zoo" had an as.Date.numeric() long before base R had it.
# It was designed to allow users to switch back and forth between "Date" andd "numeric".


# M <- gvisMotionChart(tidy_newsubset, idvar="Indicator.Name", timevar="Year")
# Error in testTimevar(x[[options$data$timevar]], options$data$date.format) : 
#  The timevar has to be of numeric or Date format. Currently it is  factor
## Problem: Year is of factor c
# sapply(tidy_newsubset, class) # or class(tidy_newsubset$Year)
# Indicator.Name           Year          Value 
#      "factor"       "factor"      "numeric"

## If needed, save tidy dataset into excel format
# sink("tidy.xlsx");
# tidy;
# sink();

# install.packages("XLConnect");
# library("XLConnect");
# excel.file <- file.path("~/tidy.xlsx");
# tidyXL <- readWorksheetFromFile(excel.file, sheet=1)

## Or Import tidy.xlsx excel file into R
# install.packages("RODBC");
# library(RODBC);
# channel <- odbcConnectExcel("C:./tidy.xlsx");
# mydata <- sqlFetch(channel, "Sheet1");
# odbcClose(channel);


## Data dynamic visualization on GoogleVis
message("Visualize DataBC on a motion chart");
M <- gvisMotionChart(tidy, idvar="Indicator.Name", timevar="Year");
plot(P)
# http://127.0.0.1:29539/custom/googleVis/MotionChartID3378454c4af0.html

## Integrating gvis objects in existing sites
# Copy and paste the output from the R console
# print(M, 'chart');

## Or Create a back up file with the googleVisMotionChart script
# message("Create a text file with the output script for futur use");
# sink("MotionChart.txt");
# print(M, 'chart');
# sink();

