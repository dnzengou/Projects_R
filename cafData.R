library(plyr)
library(reshape2)
library(stringr)

## Goals
## 1. each variable should be in one column
## 2. each observation of that variable should be in a diferent row
## 3. Once the file cleaned and with tidy data, set up a dynamic google visualisation

## Set up the working directory
getwd()
# [1] "C:/Users/eugene.nzengou/Documents/data"
setwd("C:/Users/eugene.nzengou/Documents/data/Projects_R/datacaf_R")


message("Read csv file (source: ...)")
# Read csv file (source: ...) skiping the first  two lines and starting from the header on the third
## remove NA from data frame 

df = read.csv("caf_Country_fr_v2.csv", skip = 2,sep=",")
## Or
# df = read.csv(text=readLines('caf_Country_fr_v2.csv')[-(1:2)])

## Dimension of the data frame
# dim(df)
# [1] 1335   58

## Check for the the data frame column names
# colnames(df)

## Check for the the data frame row names
# rownames(df)

## If NAs (missing values) on colnames, in this case in column 59, remove them from df
df <- df[, -(59)]

## Check for the data structure of the first and last 3 rows
# head(df, n=3)
# tail(df, n=3)

## Now that we have complete column names, remove NAs from the rows in df
complete_df <- na.omit(df)

## (Same) check for the data structure
# head(complete_df, n=3)
# tail(complete_df, n=3)

## Dimension of the data frame
# dim(complete_df)
# [1] 29 58

## If ok, then create a text file for future analysis
## Note. characters like é, è, à, ê, â, ... might note be retranscripted correctly on the file
# sink("complete_df.txt")
# complete_df
# sink()

## As columns names start with X before Years, let us rename them with the correct writting
complete_df$new_sp <- NULL
names(complete_df) <- str_replace(names(complete_df), "new_sp_", "")
names(complete_df) <- c("Country.Name", "Country.Code", "Indicator.Name", "Indicator.Code", "1960","1961","1962","1963","1964","1965","1966","1967","1968","1969","1970","1971","1972","1973","1974","1975","1976","1977","1978","1979","1980","1981","1982","1983","1984","1985","1986","1987","1988","1989","1990","1991","1992","1993","1994","1995","1996","1997","1998","1999","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013")

## Create a file with complete data
# sink("complete_df.txt")
# complete_df
# sink()

## Create a subset from complete_df processed dataset
message("Create a tidy subset complete data frame")

subset <- complete_df[, -(1:2), drop=FALSE] # this removes the colums Country.Name and Country.Code
subset <- subset[, -2, drop=FALSE] # this removes the colums Indicator.Code, second column on the new subset

## Clean the data subset that includes multivariables in columns to turn it into a tidy dataset
tidy <- melt(subset, id=c("Indicator.Name"), na.rm=TRUE)

## Dimension of the data frame
# dim(tidy)
# [1] 1566    3

## Name the second (variable) and third column (value) Year and Value
names(tidy)[2] <- "Year"; names(tidy)[3] <- "Value"  # Or names(tidy) <- c("Indicator.Name", "Year", "Value")

# Often a good idea to ensure the rows are ordered by the variables (Year here)
# tidy <- arrange(tidy, Year, Indicator.Name)

## Check data structure
# head(tidy, n=3)

## FYI Summary of tidy and subset
# summary(tidy)  # Indicator.Name : 108...
# summary(subset)  # Indicator.Name : 2...
# str(subset)  # 'data.frame':	29 obs. of  55 variables:...

## Create a file with subset data
# sink("subset.txt")
# subset
# sink()


## If list of indicators
# unique(tidy$Indicator.Name, incomparables=FALSE)

# Another possibility is to order the rows by Indicator.Name
message("Arrange the tidy dataset by Indicator.Name")
tidy <- arrange(tidy, Indicator.Name, Year)

## Rows 109 to 1566 have Indicator.Name missing cases. Let us subsetting the data frame by withdrawing it
tidy2 <- tidy[109:1566,]

## Check data structure
# head(tidy2, n=3)
# tail(tidy2, n=3)

## Create a file with the subset data frame
# sink("tidy2.txt")
# tidy2
# sink()


## As the big numbers of indicators (1566) in subset makes the program GoogleVis to turn too slowly. Let's create a new subset by selecting specific indicators
newsubset <- rbind(subset[2,] , subset[5:6,] , subset[10,] , subset[15:29,]);
## Check data structure for newsubset
# head(newsubset, n=3)
# tail(newsubset, n=3)

## Create newsubset text file
# sink("newsubset.txt")
# newsubset
# sink()


## Clean the new data subset that includes multivariables in columns to turn it into a tidy dataset
tidy_newsubset <- melt(newsubset, id=c("Indicator.Name"), na.rm=TRUE)

## Name the second (variable) and third column (value) Year and Value
names(tidy_newsubset)[2] <- "Year"; names(tidy_newsubset)[3] <- "Value"

# Often a good idea to ensure the rows are ordered by the variables (Year here)
tidy_newsubset <- arrange(tidy_newsubset, Year, Indicator.Name)

## Check data structure for tidy_newsubset
# head(tidy_newsubset, n=3)
# tail(tidy_newsubset, n=3)

##  Order the rows by the Indicator.Name
#  Tidy_newsubset <- arrange(tidy_newsubset, Indicator.Name)

## Data dynamic visualization on GoogleVis
# Install.packages("googleVis")
library(googleVis)

# install.packages("zoo")
library("zoo")
# "zoo" had an as.Date.numeric() long before base R had it
# It was designed to allow users to switch back and forth between "Date" andd "numeric"


# M <- gvisMotionChart(tidy_newsubset, idvar="Indicator.Name", timevar="Year")
# Error in testTimevar(x[[options$data$timevar]], options$data$date.format) : 
#  The timevar has to be of numeric or Date format. Currently it is  factor
## Problem: Year is of factor c
# sapply(tidy_newsubset, class) # or class(tidy_newsubset$Year)
# Indicator.Name           Year          Value 
#      "factor"       "factor"      "numeric"


# install.packages("XLConnect")
# library("XLConnect")
# excel.file <- file.path("~/tidy2_v0.xlsx")
# tidy2_v0 <- readWorksheetFromFile(excel.file, sheet=1)

## Import manually data frame "tidy2_v0.txt" into Excel.
## Separate into 3 colonnes ("Indicator.Name", "Year", "Value"), ignoring the first one (row numbers)
## Save it into "tidy2_v0.xlsx"
## Import this excel file into R
install.packages("RODBC")
library(RODBC)
channel <- odbcConnectExcel("C:./tidy2_v0.xlsx")
mydata <- sqlFetch(channel, "Sheet1")
odbcClose(channel)

## Check data structure
# head(mydata, n=3)
#                          Indicator#Name _Year    Value
# 1 Croissance de la population (% annuel)  1960 1.611112
# 2 Croissance de la population (% annuel)  1961 1.696730
# 3 Croissance de la population (% annuel)  1962 1.777624

# Check class of "_Year" column
# class(mydata[,2])
# [1] "numeric"

## Check colum names and rename
# colnames(mydata)
# [1] "Indicator#Name" "_Year"          "Value"         

names(mydata)<- c("Indicator.Name", "Year", "Value")

## Check column names
# head(mydata, n=3)
#                           Indicator.Name Year    Value
# 1 Croissance de la population (% annuel) 1960 1.611112
# 2 Croissance de la population (% annuel) 1961 1.696730
# 3 Croissance de la population (% annuel) 1962 1.777624

## Create back up mydata text file, similar to tidy2_v0.xlsx but created directly on R
# sink("mydata.txt")
# mydata
# sink()

## Data dynamic visualization on GoogleVis
message("Visualize CAF data on a motion chart");
P <- gvisMotionChart(mydata, idvar="Indicator.Name", timevar="Year")
plot(P)
# http://127.0.0.1:12125/custom/googleVis/MotionChartID348c74cd1dc.html

## Integrating gvis objects in existing sites
# Copy and paste the output from the R console
# print(P, 'chart');

## Create a back up file with the googleVisMotionChart script
# message("Create a text file with the output script for futur use")
# sink("MotionChart.txt")
# MotionChart
# sink()

