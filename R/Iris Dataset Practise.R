# Load necessary libraries
library(ggplot2)    # For creating plots
library(dplyr)      # For data manipulation
library(ggthemes)   # For themes in ggplot
library(ggridges)   # For ridge plots
theme_set(theme_minimal())  # Set a minimal theme for plots

# Load the iris dataset
data("iris")

# Display information about the iris dataset
str(iris)  # Show the structure of the dataset
summarise(iris)  # Summarise the dataset
View(iris)  # View the dataset in a tabular format

# Generate summary statistics for the first four columns of the iris dataset
summary(iris[, 1:4])

# Create a scatterplot of Sepal Length vs. Sepal Width colored by Species
ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point() +
  labs(
    title = "Scatterplot of Sepal Length vs. Sepal Width",
    x = "Sepal Length (cm)",
    y = "Sepal Width (cm)"
  ) +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 14, face = "bold"),  # Increase font size and make it bold
    axis.title.y = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 12),  # Adjust axis text font size
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),  # Center the title and make it larger
    panel.grid.major = element_line(color = "gray", linetype = "dotted"),  # Add dotted grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    panel.background = element_rect(fill = "white"),  # Set a white background
    plot.background = element_rect(fill = "#F0F0F0")  # Set a light gray plot background
  )

# Create a box plot of Sepal Length by Species
ggplot(iris, aes(x = Species, y = Sepal.Length, fill = Species)) +
  geom_boxplot(alpha = 0.5) +  
  labs(
    title = "Box Plot of Sepal Length by Species",
    x = "Species",
    y = "Sepal Length (cm)"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("#D73939", "#43E56F", "#5DC3E2")) +  
  theme(
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 12),
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    panel.grid.major = element_line(color = "gray", linetype = "dotted"), 
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white"),
    plot.background = element_rect(fill = "#F0F0F0")
  )

# Create a histogram of Sepal Length by Species
ggplot(iris, aes(x = Sepal.Length, fill = Species)) +
  geom_histogram(
    binwidth = 0.2,
    alpha = 0.6
  ) +
  labs(
    title = "Histogram of Sepal Length by Species",
    x = "Sepal Length (cm)",
    y = "Frequency"
  ) +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 12),
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    panel.grid.major = element_line(color = "gray", linetype = "dotted"),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white"),
    plot.background = element_rect(fill = "#F0F0F0")
  )

# Create a density ridge plot with coloured points by Species
ggplot(iris, aes(x = Sepal.Length, y = Species, fill = Species)) +
  geom_density_ridges(
    aes(point_color = Species, point_fill = Species, point_shape = Species),  # Colour the points based on Species
    alpha = .2,  # Set the transparency of the density ridges
    point_alpha = 1,  # Set the transparency of the points
    jittered_points = TRUE  # Add jitter to avoid overlapping points
  ) +
  labs(
    title = "Density Ridges Plot of Sepal Length by Species",
    x = "Sepal Length (cm)",
    y = "Species"
  ) +
  scale_point_color_hue(l = 40) +  # Adjust the hue of point colours
  scale_discrete_manual(aesthetics = "point_shape", values = c(21, 22, 23)) +  # Set specific shapes for points
  theme_minimal() +  # Use a minimal theme
  theme(
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 12),
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    panel.grid.major = element_line(color = "gray", linetype = "dotted"),  # Add dotted grid lines
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white"),  # Set panel background colour
    plot.background = element_rect(fill = "#F0F0F0")  # Set plot background colour
  )

# Calculate aggregate statistics for each Species
aggregate(. ~ iris$Species, data = iris[, 1:4], FUN = function(x) c(mean = mean(x), median = median(x), sd = sd(x)))

# Perform analysis of variance (ANOVA) for Sepal Length by Species
anova_lm <- aov(Sepal.Length ~ Species, data = iris)
summary(anova_lm)

# Calculate correlations for the first four columns of the iris dataset
cor(iris[, 1:4])

# Set a random seed for reproducibility
set.seed(123)

# Split the dataset into a training set and a test set
sample_indices <- sample(1:nrow(iris), 0.7 * nrow(iris))
train_data <- iris[sample_indices, ]
test_data <- iris[-sample_indices, ]

# Fit a logistic regression model to predict Species
model <- glm(Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, data = train_data, family = "binomial")

# Make predictions on the test data
predicted_probs <- predict(model, newdata = test_data, type = "response")
predicted_classes <- ifelse(predicted_probs > 0.5, "versicolor", "setosa")

# Calculate accuracy
accuracy <- mean(predicted_classes == test_data$Species)
cat("Accuracy:", accuracy)

# Clear the workspace
rm(list = ls())

# Close all plotting devices
dev.off()

