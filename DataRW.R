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
setwd("C:/Users/eugene.nzengou/Documents/data/Projects_R/DataRW")
## Data source: http://data.worldbank.org/country/rwanda

message("Read csv file (source: ...)")
# Read csv file (source: ...) skiping the first  two lines and starting from the header on the third
## remove NA from data frame 

df = read.csv("rwa_Country_en_cav_v2.csv", skip = 2,sep=",");
## Or
# df = read.csv(text=readLines('crwa_Country_en_cav_v2.csv')[-(1:2)])

## Dimension of the data frame
# dim(df)
# [1] 1335   59


## Check for the the data frame column names
# colnames(df)

## Check for the the data frame row names
# rownames(df)

## If NAs (missing values) on colnames, in this case in column 59, remove them from df
df <- df[, -(59)];

## Check for the data structure of the first and last 3 rows
# head(df, n=3)
# tail(df, n=3)

## Now that we have complete column names, remove NAs from the rows in df
df_complete <- na.omit(df);

## (Same) check for the data structure
# head(df_complete, n=3)
# tail(df_complete, n=3)

## Dimension of the data frame
# dim(df_complete)
# [1] 89 58


## As columns names start with X before Years, let us rename them with the correct writting
df_complete$new_sp <- NULL;
names(df_complete) <- str_replace(names(df_complete), "new_sp_", "");
names(df_complete) <- c("Country.Name", "Country.Code", "Indicator.Name", "Indicator.Code", "1960","1961","1962","1963","1964","1965","1966","1967","1968","1969","1970","1971","1972","1973","1974","1975","1976","1977","1978","1979","1980","1981","1982","1983","1984","1985","1986","1987","1988","1989","1990","1991","1992","1993","1994","1995","1996","1997","1998","1999","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013");

## Create a file with complete data
## Note. characters like é, è, à, ê, â, ... (in other languages than english) might note be retranscripted correctly on the file
# sink("df_complete.txt")
# df_complete
# sink()

## Create a subset from df_complete processed dataset
message("Create a tidy subset complete data frame");

subset <- df_complete[, -(1:2), drop=FALSE] # this removes the colums Country.Name and Country.Code;
subset <- subset[, -2, drop=FALSE] # this removes the colums Indicator.Code, second column on the new subset;

## Create a file with subset data
# sink("subset.txt");
# subset;
# sink();


## Clean the data subset that includes multivariables in columns to turn it into a tidy dataset
tidy <- melt(subset, id=c("Indicator.Name"), na.rm=TRUE);

## Dimension of the data frame
# dim(tidy)
# [1] 4806    3

## Name the second (variable) and third column (value) Year and Value
names(tidy)[2] <- "Year"; names(tidy)[3] <- "Value"  # Or names(tidy) <- c("Indicator.Name", "Year", "Value");

# Often a good idea to ensure the rows are ordered by the variables (Year here)
# tidy <- arrange(tidy, Year, Indicator.Name)

## Check data structure
# head(tidy, n=3)

## Check dataframe class. Change Year class if factor/character
# sapply(tidy, class)
# Indicator.Name           Year          Value 
#      "factor"       "factor"      "numeric"

## FYI Summary of tidy and subset
# summary(tidy)  # Indicator.Name : ...
# summary(subset)  # Indicator.Name : ...
# str(subset)  # 'data.frame':	 obs. of   variables:...

## Create a file with subset data
# sink("tidy.txt")
# tidy
# sink()


## If list of indicators
# unique(tidy$Indicator.Name, incomparables=FALSE)

# Another possibility is to order the rows by Indicator.Name
message("Arrange the tidy dataset by Indicator.Name");
tidy <- arrange(tidy, Indicator.Name, Year);


## Check data structure
# head(tidy, n=3)
# tail(tidy, n=3)

## Create a file with the subset data frame
# sink("tidy_byIndicatorName.txt")
# tidy
# sink()

# Problem :  when importing dataframe on excel, " [ reached getOption("max.print") -- omitted 1473 rows  " --> need for subsetting
## As the big numbers of indicators in subset makes the program GoogleVis to turn too slowly. Let's subset the dataframe from the indicator no 3334 to the end (indic. no 4806)
# nrow(tidy)
#[1] 4806

tidy2 <- tidy[3334:nrow(tidy),]
## Create a back-up file with the second part of the dataframe
# sink("tidy2_byIndicatorName.txt")
# tidy2
# sink()
 
## Join manually (with NotePad * column selection with ALT+CTRL | excel) - faster - the two files (tidy and tidy2) into one that lists all the indicators 1 to 4806
# tidy_byIndicatorName_complete.txt --> import on excel for conversion of column "Year" from factor into General (numeric)
# --> tidy_complete.txt, as well as create a back up excel file tidy_complete.xlsx


## Data dynamic visualization on GoogleVis
# Install.packages("googleVis")
library(googleVis);

# install.packages("zoo")
library("zoo");
# "zoo" had an as.Date.numeric() long before base R had it.
# It was designed to allow users to switch back and forth between "Date" andd "numeric".



# install.packages("XLConnect");
# library("XLConnect");
# excel.file <- file.path("~/tidy_complete.xlsx");
# tidy_complete <- readWorksheetFromFile(excel.file, sheet=1)


## Import this excel file into R
# install.packages("RODBC");
library(RODBC);
channel <- odbcConnectExcel("C:./tidy_complete.xlsx");
DataRW <- sqlFetch(channel, "tidy_complete");
odbcClose(channel);

# Or
# library(xlsx);
# channel <- read.xlsx("C:./tidy_complete.xlsx", sheetIndex=1, header=TRUE);


# Check class of "_Year" column, that should now be numeric
# class(DataRW[,2])
# [1] "numeric"

## Check colum names and rename
# colnames(DataRW)
# [1] "Indicator#Name" "_Year"          "Value"         
# Rename by "Indicator.Name", "Year", "Value"
names(DataRW)<- c("Indicator.Name", "Year", "Value");

## Check that the structure is correct before data vizualisation on motion charts
# head(DataRW, n=3)
#   Indicator.Name 									   Year    Value
# 1 Age dependency ratio (% of working-age population) 1960 103.0221
# 2 Age dependency ratio (% of working-age population) 1961 104.8461
# 3 Age dependency ratio (% of working-age population) 1962 106.6447


## Create back up mydata text file, similar to tidy2_v0.xlsx but created directly on R
# sink("DataRW.txt")
# mydata
# sink()

# dim(DataRW)
# [1] 4806    3


## Data dynamic visualization on GoogleVis
message("Visualize RW data on a motion chart");
Chart <- gvisMotionChart(DatRW, idvar="Indicator.Name", timevar="Year");
print(Chart, file="DataRWGoogleVisChart.html");
# plot(Chart)
# http://127.0.0.1:29539/custom/googleVis/MotionChartID3378251518af.html

## Integrating gvis objects in existing sites
# Copy and paste the output from the R console
# print(Chart, 'chart');

## Create a back up file with the googleVisMotionChart script
# message("Create a text file with the output script for futur use");
# sink("MotionChart.txt");
# print(Chart, 'chart');
# sink();



## Problem : negative values among Year and Value columns
# Let's subset DataRW dataframe by selecting only the positive Value and Year parameters
# Install.packages("sqldf");
librar(sqldf);
DataRW_sub <- sqldf("select * from DataRW where Year > 0 & Value > 0");


## Check dataframe structure
# head(DataRW_sub, n=3)
#                                       Indicator_Name	Year    Value
# 1 Age dependency ratio (% of working-age population)  1960 103.0221
# 2 Age dependency ratio (% of working-age population)  1961 104.8461
# 3 Age dependency ratio (% of working-age population)  1962 106.6447

## Or
# DataRW_subset <- sqldf("select * from DataRW group by Indicator_Name having Year between 1960 and 2013");
# But it sort the data by Year

## Check structure
# tail(DataRW_subset, n=3)
#                       Indicator_Name Year        Value
# 87                   Urban population 2013 2.324403e+06
# 88      Urban population (% of total) 2013 1.973760e+01
# 89 Urban population growth (annual %) 2013 4.322688e+00

## Change names of DataRW to match previous data frames
names(DataRW_sub)<- c("Indicator.Name", "Year", "Value");

## Create back up file
# sink("DataRW_sub.txt")
# DataRW_sub
# sink()

## Check data classes
# sapply(DataRW, class)
# Indicator.Name           Year          Value 
#       "factor"      "numeric"      "numeric"

## Create motion graphics
Chart_sub <- gvisMotionChart(DataRW_sub, idvar="Indicator.Name", timevar="Year");
print(Chart_sub, file="DataRW_sub_GoogleVisChart.html");
# plot(Chart_sub)
# http://127.0.0.1:29539/custom/googleVis/MotionChartID337862ba71c5.html
