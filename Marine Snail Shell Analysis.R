# Load Packages
library(readxl)
library(reshape2)
library(ggplot2)
library(stats)
library(readr)

# Create a list of lists, where each inner list represents a row of the data table
forest_brown <- list(c("Yellow No Band", 12), c("Yellow One Band", 79), c("Yellow Many Band", 92), c("Pink No Band", 23), c("Pink One Band", 67), c("Pink Many Band", 56), c("Brown No Band", 3), c("Brown One Band", 9), c("Brown Many Band", 26))
# Convert the list of lists into a dataframe
data_bf <- data.frame(matrix(unlist(forest_brown), nrow=9, byrow=TRUE))
# Assign column names to the dataframe
colnames(data_bf) <- c("Colour", "Total")
# The chi-squared test will assess the association between color-band combinations and their respective frequencies in the given datasets.
# it is appropriate for analyzing the independence between two categorical variables, which is relevant in our analysis of color-band occurrences. The results will help us determine if there is a statistically significant relationship between color-band combinations and their frequencies, providing insights into any potential associations in the data.
fb_result <- chisq.test(data_bf$Total, data_bf$Colour)


forest_white <- list(c("Yellow No Band", 4), c("Yellow One Band", 13), c("Yellow Many Band", 12), c("Pink No Band", 2), c("Pink One Band", 10), c("Pink Many Band", 27), c("Brown No Band", 30), c("Brown One Band", 2), c("Brown Many Band", 68))
data_wf <- data.frame(matrix(unlist(forest_white), nrow=9, byrow=TRUE))
colnames(data_wf) <- c("Colour", "Total")
fw_result <- chisq.test(data_wf$Total, data_wf$Colour)


sand_brown <- list(c("Yellow No Band", 61), c("Yellow One Band", 175), c("Yellow Many Band", 42), c("Pink No Band", 8), c("Pink One Band", 81), c("Pink Many Band", 34), c("Brown No Band", 1), c("Brown One Band", 8), c("Brown Many Band", 21))
data_sb <- data.frame(matrix(unlist(sand_brown), nrow=9, byrow=TRUE))
colnames(data_sb) <- c("Colour", "Total")
sb_result <- chisq.test(data_sb$Total, data_sb$Colour)


sand_white <- list(c("Yellow No Band", 16), c("Yellow One Band", 34), c("Yellow Many Band", 10), c("Pink No Band", 4), c("Pink One Band", 15), c("Pink Many Band", 37), c("Brown No Band", 1), c("Brown One Band", 0), c("Brown Many Band", 30))
data_sw <- data.frame(matrix(unlist(sand_white), nrow=9, byrow=TRUE))
colnames(data_sw) <- c("Colour", "Total")
sw_result <- chisq.test(data_sw$Total, data_sw$Colour)

# Printing the chi square results
print(fb_result)
print(fw_result)
print(sb_result)
print(sw_result)

rm(list = ls())

Snail_Table <- read_excel('/Users/samihaque/Library/CloudStorage/OneDrive-Personal/Projects/R/Copy of Marine snail.xlsx')
head(Snail_Table)

forest_brown <- Snail_Table[1,]
forest_white <- Snail_Table[2,]
sand_brown <- Snail_Table[3,]
sand_white <- Snail_Table[4,]

# Melt the data to reshape it into a long format
melted_BFdata <- melt(forest_brown, id.vars = "...1")
melted_WFdata <- melt(forest_white, id.vars = "...1")
melted_BSdata <- melt(sand_brown, id.vars = "...1")
melted_WSdata <- melt(sand_white, id.vars = "...1")

# Brown shell forest snails
ggplot(data = melted_BFdata, aes(x = "Species and Site", y = value, fill = variable)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  xlab("Brown shell forest snails") + 
  ylab("Number of shells") + 
  scale_y_continuous(breaks = seq(0, max(melted_BFdata$value), 5))

# White shell forest snails
ggplot(data = melted_WFdata, aes(x = "Species and Site", y = value, fill = variable)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  xlab("White shell forest snails") + 
  ylab("Number of shells") + 
  scale_y_continuous(breaks = seq(0, max(melted_WFdata$value), 5))

# Brown shell sand dune snails
ggplot(data = melted_BSdata, aes(x = "Species and Site", y = value, fill = variable)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  xlab("Brown shell sand dune snails") + 
  ylab("Number of shells") + 
  scale_y_continuous(breaks = seq(0, max(melted_BSdata$value), 5))

# White shell sand dune snails
ggplot(data = melted_WSdata, aes(x = "Species and Site", y = value, fill = variable)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  xlab("White shell sand dune snails") + 
  ylab("Number of shells") + 
  scale_y_continuous(breaks = seq(0, max(melted_WSdata$value), 5))

# Clear the environment, removing all objects from memory
rm(list = ls())

# Turn off the graphics device used by ggplot
dev.off()
