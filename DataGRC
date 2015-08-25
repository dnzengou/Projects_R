# install.packages("plyr");
# install.packages("reshape2");
# install.packages("stringr");
library("plyr");
library("reshape2");
library("stringr");

## Goals
## 1. each variable should be in one column
## 2. each observation of that variable should be in a diferent row
## 3. Once the file cleaned and with tidy data, set up a dynamic google visualisation

## Set up the working directory
getwd()
# [1] "/Users/enzengou"
setwd("~/Desktop/Coursera/Project_R/Data_GRC")
## Data source: http://data.worldbank.org/country/greece

message("Read csv file (source: ...)")
# Read csv file (source: ...) skiping the first  two lines and starting from the header on the third
## remove NA from data frame 

df = read.csv("grc_Country_en_csv_v2.csv", skip = 4,sep=",");
## Or
# df = read.csv(text=readLines('grc_Country_en_csv_v2.csv')[-(1:4)])

## Dimension of the data frame
# dim(df)
# [1] 852  60
# NB. Column 60 is empty (and shifted)


## Check for the the data frame column names
# colnames(df)

## Check for the the data frame row names
# rownames(df)

# df$new_sp <- NULL

## If NAs (missing values) on colnames or dataframe shifted, in this case in column 60, remove them from df
# df <- df[, -(60)];

## Check for the data structure of the first and last 3 rows
# head(df, n=3);
# tail(df, n=3);

## Now that we have complete column names, remove NAs from the rows in df
df_complete <- na.omit(df);

## (Same) check for the data structure
# head(df_complete, n=3);
# tail(df_complete, n=3);

## Dimension of the data frame
# dim(df_complete)
# [1] 65 59


## As columns names start with X before Years, let us rename them without the Xs
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
# [1] 3575    3

## Name the second (variable) and third column (value) Year and Value
names(tidy)[2] <- "Year"; names(tidy)[3] <- "Value"
# Or names(tidy) <- c("Indicator.Name", "Year", "Value");

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
# sink("tidy.txt");
# tidy;
# sink();


## If list of indicators
# unique(tidy$Indicator.Name, incomparables=FALSE)

# Another possibility is to order the rows by Indicator.Name
message("Arrange the tidy dataset by Indicator.Name");
tidy <- arrange(tidy, Indicator.Name, Year);


## Check data structure
# head(tidy, n=3)
# tail(tidy, n=3)

## Create a file with the subset data frame
# sink("tidy_byIndicatorName.txt");
# tidy;
# sink();

# Problem :  when importing dataframe on excel, " [ reached getOption("max.print") -- omitted 1242 rows  " --> need for subsetting
## As the big numbers of indicators in subset makes the program GoogleVis to turn too slowly. Let's subset the dataframe from the indicator no 3334 to the end (indic. no 3575)
# nrow(tidy)
#[1] 3575

tidy2 <- tidy[3334:nrow(tidy),]
## Create a back-up file with the second part of the dataframe
# sink("tidy2_byIndicatorName.txt");
# tidy2;
# sink();

## Join manually (with NotePad * column selection with ALT+CTRL | excel) - faster - the two files (tidy and tidy2) into one that lists all the indicators #1 to 3575
# tidy_byIndicatorName_complete.txt --> import on excel for conversion of column "Year" from factor into General (numeric)
# --> tidy_complete.txt, as well as create a back up excel file tidy_complete.xlsx


## Data dynamic visualization on GoogleVis
# install.packages("googleVis");
library("googleVis");

# install.packages("zoo");
library("zoo");
# "zoo" had an as.Date.numeric() long before base R had it.
# It was designed to allow users to switch back and forth between "Date" andd "numeric".



# install.packages("XLConnect");
library("XLConnect");
# excel.file <- file.path("~/tidy_complete.xlsx");
# tidy_complete <- readWorksheetFromFile(excel.file, sheet=1); ## OU
# tidy2_v0_caf <- readWorksheetFromFile("/Users/enzengou/Desktop/Coursera/Project_R/Data_GRC/tidy2_v0_caf.xlsx", sheet=1);
DataGRC <- readWorksheetFromFile("/Users/enzengou/Desktop/Coursera/Project_R/Data_GRC/tidy_byIndicatorName_GRC.xlsx", sheet=1);

## Import this excel file into R
# install.packages("RODBC");
# library("RODBC");
# channel <- odbcConnectExcel("C:./tidy_complete.xlsx");
# DataRW <- sqlFetch(channel, "tidy_complete");
# odbcClose(channel);

# Or
# library("xlsx");
# channel <- read.xlsx("C:./tidy_complete.xlsx", sheetIndex=1, header=TRUE);


## Check class of "_Year" column (#2) and "_Value" (#3), that should now be numeric
# class(DataGRC[,2])
# [1] "numeric"
# class(DataGRC[,3])
# [1] "character"

## Convert char into numeric
# DataGRC[,3] <- as.numeric(DataGRC[,3])
# class(DataGRC[,3])
# [1] "numeric"


## Check colum names and rename
# colnames(DataGRC)
# [1] "Indicator.Name" "X.Year"          "Value"         
# Rename by "Indicator.Name", "Year", "Value"
names(DataGRC)<- c("Indicator.Name", "Year", "Value");
# names(DataGRC)[3]<- "Value";

## Check that the structure is correct before data vizualisation on motion charts
# head(DataGRC, n=3)
# Indicator.Name Year    Value
# 1 ...


## Create back up mydata text file, similar to tidy2_v0.xlsx but created directly on R
# sink("DataGRC.txt");
# DataGRC;
# sink();

# dim(DataGRC)
# [1] 1458    3

# Create from tidy2_v0_caf.csv or tidy2_v0_caf.txt (open with Notepad)

## Data dynamic visualization on GoogleVis
message("Visualize GRC data on a motion chart");
Chart <- gvisMotionChart(DataGRC, idvar="Indicator.Name", timevar="Year");
print(Chart, file="DataGRCGoogleVisChart.html");
# plot(Chart)
# http://127.0.0.1:16507/custom/googleVis/MotionChartID536d15383928.html

## Integrating gvis objects in existing sites
# Copy and paste the output from the R console
# print(Chart, 'chart');

## Create a back up file with the googleVisMotionChart script
# message("Create a text file with the output script for futur use");
# sink("MotionChartGRC.txt");
# print(Chart, 'chart');
# sink()
