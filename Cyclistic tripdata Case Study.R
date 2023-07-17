# Loading the packages
library(tidyverse)
library(janitor)
library(lubridate)
library(ggplot2)

# Inporting the datasets and assiging them to a name referring to the month and year of the data
Jan2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_01_tripdata.csv")
Feb2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_02_tripdata.csv")
Mar2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_03_tripdata.csv")
Apr2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_04_tripdata.csv")
May2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_05_tripdata.csv")
Jun2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_06_tripdata.csv")
Jul2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_07_tripdata.csv")
Aug2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_08_tripdata.csv")
Sep2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_09_tripdata.csv")
Oct2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_10_tripdata.csv")
Nov2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_11_tripdata.csv")
Dec2022 <- read_csv("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_12_tripdata.csv")

# Checking for any discrepancies with formatting before merging
str(Jan2022)
str(Feb2022)
str(Mar2022)
str(Apr2022)
str(May2022)
str(Jun2022)
str(Jul2022)
str(Aug2022)
str(Sep2022)
str(Oct2022)
str(Nov2022)
str(Dec2022)

# Creating new dataset that contains all the datasets
# Create a list of all the datasets
annual_tripdata <- list(Jan2022, Feb2022, Mar2022, Apr2022, May2022, Jun2022, Jul2022, Aug2022, Sep2022, Oct2022, Nov2022, Dec2022)

# Merge the datasets and add a new column for the month
merged_data <- bind_rows(annual_tripdata, .id = "Month")
        
#Cleaning & removing any spaces, parentheses, etc.
merged_df <- clean_names(merged_data)
remove_empty(merged_df, which = c())

# Extract the day and month of when the rides took place and the trip duration and the hour of when the trip started 
merged_df$day_of_week <- wday(merged_df$started_at, label = T, abbr = T)
merged_df$starting_hour <- format(as.POSIXct(merged_df$started_at), '%H')
merged_df$month <- format(as.Date(merged_df$started_at), '%m')
merged_df$trip_duration <- difftime(merged_df$ended_at, merged_df$started_at, units ='sec')

# New dataset that does not include trip durations of 0 seconds or less
cleaned_df <- merged_df[!(merged_df$trip_duration<=0),]

# Selecting specific columns
selected_columns <- cleaned_df[, c("month", "rideable_type", "start_station_name", "member_casual", "day_of_week", "starting_hour", "trip_duration")]

# Creating a new dataframe with selected columns
cleaned_df <- data.frame(selected_columns)

# Extract the folder path from the imported dataset file path
folder_path <- dirname("Documents/OneDrive/Google Analytics/Case Study/Annual_Tripdata/2022_01_tripdata.csv")

# Construct the file path for saving the cleaned dataset
output_file <- file.path(folder_path, "Cleaned_tripdata.csv")

# Save the cleaned dataset
write.csv(cleaned_df, file = output_file, row.names = FALSE)

# Create the total_month dataset
total_month <- data.frame(count = table(cleaned_df$month))
output_file <- file.path(folder_path, "total_month.csv")
write.csv(total_month, file = output_file)

# Create the total_day dataset
total_day <- data.frame(count = table(cleaned_df$day_of_week))
output_file <- file.path(folder_path, "total_day.csv")
write.csv(total_day, file = output_file)

# Create the total_hour dataset
total_hour <- data.frame(count = table(cleaned_df$starting_hour))
output_file <- file.path(folder_path, "total_hour.csv")
write.csv(total_hour, file = output_file)

# Creating simple viz's, data was exported and used to create a dashboard in Tableau
ggplot(data = cleaned_df) +
  aes(x = day_of_week, fill = member_casual) +
  geom_bar(position = 'dodge') +
  labs(x = 'Day of week', y = 'No. of rides', fill = 'Membership type', title = 'No. of rides by membership type')

ggplot(data = cleaned_df) +
  aes(x = month, fill = member_casual) +
  geom_bar(position = 'dodge') +
  labs(x = 'Month', y = 'No. of rides', fill = 'Membership type', title = 'No. of rides per month')

ggplot(data = cleaned_df) +
  aes(x = starting_hour, fill = member_casual) +
  facet_wrap(~day_of_week) +
  geom_bar() +
  labs(x = 'Starting hour', y = 'No. of rides', fill = 'Membership type', title = 'Hourly use of bikes throughout the week') +
  theme(axis.text = element_text(size = 5))

# Clearing library and plots
rm(list = ls())
dev.off()






