---
title: "Marine Snail Shell Analysis"
author: "Sami Haque"
date: "2023-07-17"
output:
  html_document: default
  pdf_document: default
---
```{r, echo=FALSE}
knitr::opts_chunk$set(warning = FALSE)
```

## Load Packages

In the provided R code, four packages were utilized for different purposes. The **readxl** package enabled the reading of data from an Excel file into R, allowing the manipulation of the data as data frames for subsequent analysis. 

The  **reshape2** package facilitated data transformation from wide to long format using the  **melt()** function, crucial for creating informative visualizations. 

Utilizing the  **ggplot2** package, bar plots were generated, visualizing the relationships between color-band combinations and their corresponding frequencies for different snail categories in a customizable and visually appealing manner. 

Finally, the  **stats** package played a vital role in conducting the  **chi-squared test**, determining the statistical significance of associations between color-band combinations and frequencies, providing valuable insights into potential relationships within the data.
```{r packages}
library(readxl)
library(reshape2)
library(ggplot2)
library(stats)
```

## Creating Data Frames

In this code, I first created four lists, each representing different snail data categories with corresponding color-band combinations and their frequencies. I then converted these lists into data frames (**data_bf, data_wf, data_sb, data_sw**) to organize the data in a tabular format. Column names **"Colour"** and **"Total"** were assigned to the data frames. 

The chi-squared test was employed to assess associations between color-band combinations and their frequencies in the datasets. As an appropriate method for analyzing independence between two categorical variables, this test was particularly relevant to my analysis of color-band occurrences, enabling the determination of any statistically significant relationships. The chisq.test() function was used to perform the chi-squared test for each data frame, generating fb_result, fw_result, sb_result, and sw_result as the outcomes, providing insights into potential associations within the data.
```{r DataFrame, }
forest_brown <- list(c("Yellow No Band", 12), c("Yellow One Band", 79), c("Yellow Many Band", 92), c("Pink No Band", 23), c("Pink One Band", 67), c("Pink Many Band", 56), c("Brown No Band", 3), c("Brown One Band", 9), c("Brown Many Band", 26))
data_bf <- data.frame(matrix(unlist(forest_brown), nrow=9, byrow=TRUE))
colnames(data_bf) <- c("Colour", "Total")
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
```

## Chi-squared Test Results

```{r Chisquared, echo=FALSE}
print(fb_result)
print(fw_result)
print(sb_result)
print(sw_result)
```
The chi-squared test results reveal that there was **no statistically significant association** between color-band combinations and their frequencies in the different snail datasets. The p-values obtained for all four tests (fb_result, fw_result, sb_result, sw_result) are greater than the common significance level of  **0.05**. 

This suggested that color-band occurrences appear to be independent of each other within their respective datasets. Therefore, I can conclude that the observed color-band distributions are  **not significantly different** from what would be expected under the assumption of independence

## Importing Data

```{r Importing, message=FALSE}
Snail_Table <- read_excel('/Users/samihaque/Library/CloudStorage/OneDrive-Personal/Projects/R/Copy of Marine snail.xlsx')
head(Snail_Table)
```

## Preparing Data For Visulisation

I separated the data from the **"Snail_Table"** data frame into **four** different categories: **forest_brown, forest_white, sand_brown**, and **sand_white**. Each category corresponds to a specific type of snail data and its respective color-band combinations and frequencies.
```{r Seperate, }
forest_brown <- Snail_Table[1,]
forest_white <- Snail_Table[2,]
sand_brown <- Snail_Table[3,]
sand_white <- Snail_Table[4,]
```

Then I performed data reshaping by melting each of the four previously separated data frames (**forest_brown, forest_white, sand_brown, and sand_white**) into a long format using the **"melt"** function from the **"reshape2"** package. The **"melted_BFdata," "melted_WFdata," "melted_BSdata,"** and **"melted_WSdata"** data frames are created, and they now represent the data in a format where each row contains a unique combination of **"Species and Site"** and a corresponding value for a color-band combination. This data transformation is essential for preparing the data to be plotted using **ggplot2** for visualization and further analysis. 
```{r melted, }
melted_BFdata <- melt(forest_brown, id.vars = "...1")
melted_WFdata <- melt(forest_white, id.vars = "...1")
melted_BSdata <- melt(sand_brown, id.vars = "...1")
melted_WSdata <- melt(sand_white, id.vars = "...1")
```
## Plots:

Plot for Brown-shelled Forest Snails:

```{r bf snail, echo=FALSE}
ggplot(data = melted_BFdata, aes(x = "Species and Site", y = value, fill = variable)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  xlab("Brown shell forest snails") + 
  ylab("Number of shells") + 
  scale_y_continuous(breaks = seq(0, max(melted_BFdata$value), 5))
```
Plot for White-shelled Forest Snails:

```{r wf snail, echo=FALSE}
ggplot(data = melted_WFdata, aes(x = "Species and Site", y = value, fill = variable)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  xlab("White shell forest snails") + 
  ylab("Number of shells") + 
  scale_y_continuous(breaks = seq(0, max(melted_WFdata$value), 5))
```
Plot for Brown-shelled Sand Dune Snails:

```{r bs snail, echo=FALSE}
ggplot(data = melted_BSdata, aes(x = "Species and Site", y = value, fill = variable)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  xlab("Brown shell sand dune snails") + 
  ylab("Number of shells") + 
  scale_y_continuous(breaks = seq(0, max(melted_BSdata$value), 5))
```
Plot for White-shelled Sand Dune Snails:

```{r ws snail, }
ggplot(data = melted_WSdata, aes(x = "Species and Site", y = value, fill = variable)) + 
  geom_bar(stat = "identity", position = "dodge") + 
  xlab("White shell sand dune snails") + 
  ylab("Number of shells") + 
  scale_y_continuous(breaks = seq(0, max(melted_WSdata$value), 5))
```
The four plots display the number of shells with different color-bands for **four** categories of snails:  **"Brown shell forest snails," "White shell forest snails," "Brown shell sand dune snails,"** and  **"White shell sand dune snails."** Each plot presents the species and site of the snails on the x-axis and the count of shells on the y-axis. The bars represent the frequency of color-band combinations for each snail category. By visually comparing these plots, we can observe any  **variations in color-band occurrences** among different snail species and sites. These visualizations provide valuable insights into potential relationships between color-bands and snail characteristics, aiding in the analysis of snail populations and their distribution patterns.

## Clearing Up

```{r clearing, message=FALSE, warning=FALSE}
rm(list = ls())
invisible(dev.off())
```

The two lines of code provided perform essential tasks in an R script. The first line, **rm(list = ls())**, clears the R environment by removing all existing objects from memory. This step ensures a clean slate for the script, preventing potential conflicts or interference from previously defined variables. The second line, **invisible(dev.off()**, turns off the current graphics device used by ggplot, which is a commonly used package for creating data visualizations. By closing the graphics device, system resources are freed up, and plots are fully rendered and saved before moving on to other tasks. Together, these lines facilitate efficient memory management and a fresh start for the script's execution.
