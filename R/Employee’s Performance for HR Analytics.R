# Dataset Source: [Employee’s Performance for HR Analytics]
# Kaggle: [https://www.kaggle.com/datasets/sanjanchaudhari/employees-performance-for-hr-analytics]
# Data Provider: [Sanjana Chaudhari]

library(readxl)
library(ggplot2)
library(dplyr)
library(ggthemes)


data <- read_excel('/Users/samihaque/Library/CloudStorage/OneDrive-Personal/Projects/R/Employee Performance/Uncleaned_employees_dataset.xlsx')
head(data)

# Remove any rows with missing values
data <- na.omit(data)

# Check the data types of each column
str(data)

# Summary statistics of performance metrics
summary(data[, c("no_of_trainings", "age", "previous_year_rating", "length_of_service", "KPIs_met_more_than_80", "awards_won", "avg_training_score")])

# Visualize the distribution of age
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

# Visualize the distribution of average training score
ggplot(data, aes(x = avg_training_score)) +
  geom_histogram(binwidth = 5, fill = "lightgreen", color = "black") +
  labs(title = "Average Training Score Distribution", x = "Average Training Score", y = "Count") +
  theme_minimal() +                    # Clean and minimal theme
  theme(plot.title = element_text(size = 18, face = "bold"),    # Adjust the title appearance
        axis.text = element_text(size = 12),                   # Adjust the axis labels' appearance
        axis.title = element_text(size = 14, face = "bold"),   # Adjust the axis titles' appearance
        panel.grid.major = element_blank(),                    # Remove major grid lines
        panel.grid.minor = element_blank(),                    # Remove minor grid lines
        panel.border = element_blank(),                        # Remove the border around the plot
        panel.background = element_blank())                    # Remove the background color


# Box plot to compare average training score by department
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

# Violin plot to compare previous year rating by age group
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

# Calculate the correlation between engagement score and performance metrics
correlation_matrix <- cor(data[, c("no_of_trainings", "age", "previous_year_rating", "length_of_service", "avg_training_score")])

# Print the correlation matrix
print(correlation_matrix)

# No. of Trainings: The number of trainings attended by employees has a very weak negative correlation (-0.086) with their age. This means that younger employees tend to participate in slightly more training sessions compared to older employees.

# Age: Age shows a weak positive correlation (0.017) with the previous year rating. This indicates that as employees get older, they tend to receive slightly higher ratings in their performance assessments from the previous year.

# Previous Year Rating: There is a very weak positive correlation (0.056) between the previous year rating and the average training score. This suggests that employees who received higher ratings in the previous year's performance assessment tend to have slightly higher average training scores.

# Length of Service: The length of service in the company has a relatively stronger positive correlation (0.601) with age. This means that as employees grow older, they tend to have a longer tenure or history of working with the company.

# Avg Training Score: There is a very weak positive correlation (0.045) between the average training score and the number of trainings attended. This suggests that employees who attend more training sessions tend to have slightly higher average training scores.

rm(list = ls())
invisible(dev.off())
