---
title: "Iris Dataset Practice"
author: "Sami Haque"
date: "2023-09-27"
output: html_document
---

```{r message=FALSE, warning=FALSE, include=FALSE}
knitr::opts_chunk$set(warning = FALSE)
```

## Load Packages

```{r packages, message=FALSE}
library(ggplot2)    # For creating plots
library(dplyr)      # For data manipulation
library(ggthemes)   # For themes in ggplot
library(ggridges)   # For ridge plots
theme_set(theme_minimal())  # Set a minimal theme for plots
```

I added the **ggplot2** package for advanced plotting, making data visuals clearer. To handle data more efficiently, I used the **dplyr** package. **ggthemes** enriched the look of my plots with different styles. For a unique touch, I brought in the **ggridges** package for ridge plots. The **theme_minimal()** function kept the background simple and neat.

## Importing & Pre-Processing Data

```{r Importing, message=FALSE}
# Load the iris dataset
data("iris")

# Display information about the iris dataset
str(iris)  # Show the structure of the dataset
summarise(iris)  # Summarise the dataset

# Generate summary statistics for the first four columns of the iris dataset
summary(iris[, 1:4])
```

In this block of code, I begin by loading the well-known Iris dataset. Using the **str()** function, I present a concise overview of the dataset's structure, revealing details about its variables and their types. Following this, I employ the **summarise()** function to provide a summary of the entire dataset, encapsulating key statistical measures. Additionally, summary statistics for the initial four columns of the Iris dataset are generated using the **summary()** function. This code snippet serves as an initial exploration of the Iris dataset, offering insights into its composition and statistical characteristics.

## Plots:

### Plot for the scatterplot of Sepal Length vs. Sepal Width colored by Species:

```{r Scatterplot, echo=TRUE}
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
```

### Plot for the box plot of Sepal Length by Species:

```{r Boxplot, echo=TRUE}
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
```

### Plot for the histogram plot of Sepal Length by Species:

```{r Histogram, echo=TRUE}
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
```

### Plot for the density ridge plot with coloured points by Species:

```{r Ridge, echo=TRUE, message=FALSE, warning=FALSE}
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
```

In this set of R code, I employed the **ggplot2** package to create a series of visually compelling plots using the classic Iris dataset. The initial **scatterplot** juxtaposes sepal length against sepal width, highlighting the distinct species with varying colours. To further explore the dataset, I created a **box plot** showcasing the distribution of sepal lengths across different species, employing transparency for a polished appearance. Subsequently, a **histogram** delves into the distribution of sepal lengths, providing a frequency perspective for each species. The final plot is a **density ridges plot**, revealing the density distribution of sepal lengths, with coloured points representing the species. These plots are not only informative but also aesthetically pleasing, as I carefully adjusted themes, colors, and other elements to enhance visual appeal and clarity.

## Statistical Analysis and Model Prediction on Iris Dataset:

```{r Aggregate, message=FALSE, warning=FALSE}
aggregate(. ~ iris$Species, data = iris[, 1:4], FUN = function(x) c(mean = mean(x), median = median(x), sd = sd(x)))
```

In this code, I aggregated statistics for each species in the Iris dataset. Using the **aggregate** function, I calculated the mean, median, and standard deviation for the first four columns, shedding light on the distribution of key variables within each species.

```{r ANOVA, message=FALSE, warning=FALSE}
anova_lm <- aov(Sepal.Length ~ Species, data = iris)
summary(anova_lm)
```

I performed an analysis of variance (ANOVA) for the Sepal Length variable across different species in the Iris dataset. The **aov** function was employed to conduct the ANOVA, and the results were summarised using the **summary** function

```{r Seed, echo=TRUE, message=FALSE, warning=FALSE}
set.seed(123)
```

Firstly, I set a random seed with **set.seed(123)** to ensure the reproducibility of the analysis. The random seed initialises the random number generator, guaranteeing that any random processes, such as dataset splitting or model initialisation, will be the same each time the code is run. This is essential for consistency in testing and comparing different models.

```{r Training, echo=TRUE, message=FALSE, warning=FALSE}
sample_indices <- sample(1:nrow(iris), 0.7 * nrow(iris))
train_data <- iris[sample_indices, ]
test_data <- iris[-sample_indices, ]
```

Next, I split the Iris dataset into a training set and a test set. This division is fundamental for evaluating the performance of the model. The sample function is utilised to randomly select indices for the training set, and the rest of the data forms the test set. A **70-30** split (0.7 * nrow(iris)) is commonly used, but this proportion can be adjusted based on the specific requirements of the analysis.

```{r Logistic regression model, echo=TRUE, message=FALSE, warning=FALSE}
model <- glm(Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, data = train_data, family = "binomial")
```

Then, a **logistic regression model** is fitted to predict the species of iris flowers. This model, implemented with **glm**, takes into account the variables **Sepal.Length, Sepal.Width, Petal.Length**, and **Petal.Width** to make predictions about the species. The logistic regression model is particularly suitable for binary classification problems, which is the case here where the species is either "versicolor" or "setosa."

```{r Prediction, echo=TRUE, message=FALSE, warning=FALSE}
predicted_probs <- predict(model, newdata = test_data, type = "response")
predicted_classes <- ifelse(predicted_probs > 0.5, "versicolor", "setosa")
```

After the model is trained on the training dataset, it is applied to the test dataset to generate predictions. The **predicted probabilities of each observation** belonging to a particular species are calculated using the predict function. These probabilities are then converted into predicted classes based on a threshold (0.5 in this case), resulting in the final predicted species.

```{r Accuracy, echo=TRUE, message=FALSE, warning=FALSE}
accuracy <- mean(predicted_classes == test_data$Species)
cat("Accuracy:", accuracy)
```

Finally, the accuracy of the model is calculated by comparing the predicted species to the actual species in the test set. This accuracy value, displayed using the **cat** function, provides a measure of how well the model performs in classifying iris species based on the selected features. A higher accuracy indicates better predictive performance.

## Clearing Up

```{r clearing, message=FALSE, warning=FALSE}
rm(list = ls())
dev.off()
```

The two lines of code provided perform essential tasks in an R script. The first line, **rm(list = ls())**, clears the R environment by removing all existing objects from memory. This step ensures a clean slate for the script, preventing potential conflicts or interference from previously defined variables. The second line, **dev.off()**, turns off the current graphics device used by ggplot, which is a commonly used package for creating data visualisations. By closing the graphics device, system resources are freed up, and plots are fully rendered and saved before moving on to other tasks. Together, these lines facilitate efficient memory management and a fresh start for the script's execution.
