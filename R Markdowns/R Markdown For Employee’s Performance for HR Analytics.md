---
title: "Employee performance for HR analytics"
author: "Sami Haque"
date: "2023-07-21"
output: html_document
---

```{r include=FALSE}
knitr::opts_chunk$set(warning = FALSE)
```

## Load Packages

```{r packages, message=FALSE}
library(readxl)
library(ggplot2)
library(dplyr)
library(ggthemes)
```

In this R code, I utilised four essential packages for distinct purposes. The **readxl** package enabled the import of data from Excel into R, transforming it into data frames for subsequent analysis.

With the **ggplot2** package, I crafted visually engaging bar plots to illustrate the relationships between colour-band combinations and frequencies within different snail categories.

Efficient data manipulation and summarisation were achieved through the versatile **dplyr** package, known for its intuitive syntax, making tasks like filtering, arranging, grouping, and summarising data seamless.

Additionally, I incorporated the **ggthemes** package to elevate the visual aesthetics of the bar plots. It provides custom themes and colour palettes tailored for **ggplot2**, enhancing the overall professionalism of the visualisations.


## Importing Data

```{r Importing, message=FALSE}
data <- read_excel('/Users/samihaque/Library/CloudStorage/OneDrive-Personal/Projects/R/Employee Performance/Uncleaned_employees_dataset.xlsx')
head(data)
```

This data was sourced from **Kaggle** (https://www.kaggle.com/datasets/sanjanchaudhari/employees-performance-for-hr-analytics), called Employee’s Performance for HR Analytics, and was provided by **Sanjana Chaudhari**

## Data Pre-Proccessing

```{r Processing, }
data <- na.omit(data)
str(data)
```

I started by cleaning the dataset, removing any rows with missing or "NA" values using the **na.omit()** function. This ensured that our data remained complete and accurate, laying a strong foundation for our analysis and visualisations.

Next, I used the **str()** function to inspect the data types of each column, gaining insights into how the data was organised. Understanding variables' data types, whether numerical, categorical, or date formats, was crucial for effective data handling and visualisation.

These pre-processing steps set the stage for robust data exploration in my project. I could confidently proceed with subsequent data analysis and visualisation tasks by eliminating missing values and grasping the dataset's structure.

```{r Summary, }
summary(data[, c("no_of_trainings", "age", "previous_year_rating", "length_of_service", "KPIs_met_more_than_80", "awards_won", "avg_training_score")])
```

I employed the **summary()** function to provide a concise and informative summary of key statistical measures for specific columns in the "data" dataset. These columns included **"no_of_trainings," "age," "previous_year_rating," "length_of_service," "KPIs_met_more_than_80," "awards_won," ** and **"avg_training_score." ** This allowed me to gain insights into both the central tendency and spread of numerical variables and the frequency distribution of categorical variables.

The summary delivered essential statistics, encompassing minimum and maximum values, 1st and 3rd quartiles (25th and 75th percentiles), and the median (2nd quartile or 50th percentile) for each selected column. For categorical variables, it presented the frequency count of unique categories, providing a clear view of category distribution.

By utilising the **summary()** function, I efficiently understood data distribution and garnered valuable insights into the characteristics of the variables under scrutiny. This summary formed the groundwork for further data exploration and analysis, empowering me to make informed decisions and draw meaningful conclusions in my project.

## Plots:

### Plot for the distribution of age:

```{r Age, echo=FALSE}
ggplot(data, aes(x = age)) +
  geom_histogram(binwidth = 5, fill = "lightblue", color = "black") +
  labs(title = "Age Distribution", x = "Age", y = "Count") +
  theme_minimal() +
  theme(plot.title = element_text(size = 18, face = "bold"),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14, face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank())
```

![Dist of age](https://github.com/SamiHaque2607/PortfolioProjects/assets/138823522/6b104075-8c12-40cb-9f8f-d57b86279323)

### Plot for the distribution of average training score:

```{r Training, echo=FALSE}
ggplot(data, aes(x = avg_training_score)) +
  geom_histogram(binwidth = 5, fill = "lightgreen", color = "black") +
  labs(title = "Average Training Score Distribution", x = "Average Training Score", y = "Count") +
  theme_minimal() +                   
  theme(plot.title = element_text(size = 18, face = "bold"),    
        axis.text = element_text(size = 12),                   
        axis.title = element_text(size = 14, face = "bold"),   
        panel.grid.major = element_blank(),                    
        panel.grid.minor = element_blank(),                    
        panel.border = element_blank(),                        
        panel.background = element_blank())  
```

![Dist of training](https://github.com/SamiHaque2607/PortfolioProjects/assets/138823522/b82ebe26-c806-4ad4-9341-3ef980a66483)

### Box plot to compare average training score by department:

```{r Department, echo=FALSE}
ggplot(data, aes(x = department, y = avg_training_score)) +
  geom_boxplot(fill = "lightpink", color = "darkred", alpha = 0.8, outlier.shape = NA) +
  labs(title = "Average Training Score by Department", x = "Department", y = "Average Training Score") +
  theme_minimal() +
  theme(plot.title = element_text(size = 18, face = "bold"),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14, face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank()) +
  scale_y_continuous(breaks = seq(0, 100, by = 5))
```

![Dist of training per department](https://github.com/SamiHaque2607/PortfolioProjects/assets/138823522/fc10f3a1-407c-41ae-9436-2a0dcdd98fbc)

### Violin plot to compare previous year rating by age group:

```{r Rating, echo=FALSE}
ggplot(data, aes(x = cut(age, breaks = seq(20, 60, by = 5)), y = previous_year_rating)) +
  geom_violin(fill = "lightblue", color = "darkblue", trim = FALSE, width = 0.6) +
  labs(title = "Previous Year Rating by Age Group", x = "Age Group", y = "Previous Year Rating") +
  theme_minimal() +
  theme(plot.title = element_text(size = 18, face = "bold"),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14, face = "bold"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank()) +
   scale_y_continuous(breaks = seq(1, 5, by = 1))
```

![year rating per age](https://github.com/SamiHaque2607/PortfolioProjects/assets/138823522/bb5e273f-ad7f-4d71-92ab-cf2abb1bc209)

## Calculating Correlation 

I performed a correlation analysis to explore the relationship between engagement scores and various performance metrics. The code first calculated the correlation coefficients among the selected performance metrics, namely **"no_of_trainings," "age," "previous_year_rating," "length_of_service,"** and **"avg_training_score."** The **cor()** function was used to compute the correlation matrix, which provides insights into the strength and direction of the linear relationships between these variables.

```{r Corrleation, }
correlation_matrix <- cor(data[, c("no_of_trainings", "age", "previous_year_rating", "length_of_service", "avg_training_score")])
print(correlation_matrix)
```

Upon executing the code, the correlation matrix was printed, displaying the **correlation coefficients** between the performance metrics. Positive correlation values indicate a positive linear relationship, while negative values suggest a negative linear relationship. A correlation coefficient close to **1** or **-1** suggests a **strong correlation**, whereas values near **0** indicate a **weak or no linear relationship**.

#### Findings from the correlation analysis:

- **No. of Trainings:** The number of trainings attended by employees has a **very weak negative correlation** (-0.086) with their age. This means that younger employees tend to participate in slightly more training sessions compared to older employees.
- **Age:** Age shows a **weak positive correlation** (0.017) with the previous year rating. This indicates that as employees get older, they tend to receive slightly higher ratings in their performance assessments from the previous year.
- **Previous Year Rating:** There is a **very weak positive correlation** (0.056) between the previous year rating and the average training score. This suggests that employees who received higher ratings in the previous year's performance assessment tend to have slightly higher average training scores.
- **Length of Service:** The length of service in the company has a **relatively stronger positive correlation** (0.601) with age. This means that as employees grow older, they tend to have a longer tenure or history of working with the company.
- **Avg Training Score:** There is a **very weak positive correlation** (0.045) between the average training score and the number of trainings attended. This suggests that employees who attend more training sessions tend to have slightly higher average training scores.

## Clearing Up

```{r clearing, message=FALSE, warning=FALSE}
rm(list = ls())
invisible(dev.off())
```

The two lines of code provided perform essential tasks in an R script. The first line, **rm(list = ls())**, clears the R environment by removing all existing objects from memory. This step ensures a clean slate for the script, preventing potential conflicts or interference from previously defined variables. The second line, **invisible(dev.off()**, turns off the current graphics device used by ggplot, which is a commonly used package for creating data visualisations. By closing the graphics device, system resources are freed up, and plots are fully rendered and saved before moving on to other tasks. Together, these lines facilitate efficient memory management and a fresh start for the script's execution.
