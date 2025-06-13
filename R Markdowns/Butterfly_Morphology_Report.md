Morphological Adaptations in UK Butterflies
================
Sami Haque
2025-02-20

# Introduction

This project investigates how forewing length varies in two UK butterfly
species: *Aglais urticae* (Small Tortoiseshell) and *Coenonympha
pamphilus* (Small Heath). The aim is to explore whether differences in
wing size are associated with geographic location and climate,
potentially reflecting local environmental adaptations.

The analysis is based on historical specimen data sourced from the
Natural History Museum, combined with regional climate variables such as
temperature, rainfall, and sunlight. The project applies a full data
science workflow, from wrangling and statistical modelling to
visualisation and interpretation.

Key tools and techniques used include:

- Data cleaning and transformation using `dplyr`

- Data visualisation using `ggplot2`

- Statistical modelling with linear regression and ANOVA

- Predictive modelling using Random Forests

- Geospatial mapping using `sf` and `rnaturalearth`

# 1. Data Import and Pre-processing

This section loads and prepares the butterfly dataset for analysis. The
data were collected from the Natural History Museum Data Portal and
processed in ImageJ to extract morphological measurements, specifically
forewing length. Then climatic data collected from the Met Office was
joined using SQL to create a final dataset with the butterfly and the
corresponding climatic data for each sample.

``` r
Final_Butterfly_Data <- read_excel("Butterfly_data.xlsx")

data <- Final_Butterfly_Data %>% 
  rename_all(~gsub(" ", "_", .)) %>%
  mutate(
    year = as.numeric(year),
    region = as.factor(region),
    Scientific_name = as.factor(Scientific_name),
    Latitude = as.numeric(Latitude),
    Longitude = as.numeric(Longitude),
    Forewing_length = as.numeric(Forewing_length),
    avg_meantemp = as.numeric(avg_meantemp))
```

# 2. Normality Checks

To validate the use of parametric statistical models, we tested whether
forewing length followed a normal distribution in both species.

``` r
data_Aglais <- data[data$Scientific_name == "Aglais urticae", ]
data_Coenonympha <- data[data$Scientific_name == "Coenonympha pamphilus", ]

theme_scientific <- function(base_size = 12) {
  theme_minimal(base_size = base_size) %+replace%
    theme(
      panel.grid.major = element_line(color = "grey90"),
      axis.text = element_text(size = rel(0.9), color = "black"),
      axis.title = element_text(size = rel(1), face = "bold"),
      plot.title = element_text(size = rel(1.2), face = "bold"),
      plot.subtitle = element_text(size = rel(1), face = "italic"))
}
```

### Histogram and Shapiro-Wilk Test for *Aglais urticae*

``` r
ggplot(data_Aglais, aes(x = Forewing_length)) +
  geom_histogram(binwidth = 1, fill = "#E69F00", colour = "black", alpha = 0.7) +
  geom_density(aes(y = ..count.. * 1), colour = "red", size = 1.5, bw = 1) +
  xlim(c(min(data_Aglais$Forewing_length) - 5, max(data_Aglais$Forewing_length) + 5)) +
  labs(title = expression("Histogram of Forewing Length (" * italic("Aglais urticae") * ")"),
    x = "Forewing Length (mm)",
    y = "Frequency") +
  theme_bw() +
  theme_scientific()
```

<figure>
<img src="Butterfly_Morphology_Report_files/figure-gfm/fig3a-1.png"
alt="(a) Histogram of forewing length for Aglais urticae." />
<figcaption aria-hidden="true">(a) Histogram of forewing length for
<em>Aglais urticae</em>.</figcaption>
</figure>

``` r
shapiro.test(data_Aglais$Forewing_length)
```

    ## 
    ##  Shapiro-Wilk normality test
    ## 
    ## data:  data_Aglais$Forewing_length
    ## W = 0.98368, p-value = 0.2543

The histogram for *Aglais urticae* shows a unimodal, approximately
symmetrical bell-shaped curve. The Shapiro-Wilk test returns a p-value
greater than 0.05, suggesting no significant deviation from normality.
Therefore, parametric tests are appropriate for this species.

### Histogram and Shapiro-Wilk Test for *Coenonympha pamphilus*

``` r
ggplot(data_Coenonympha, aes(x = Forewing_length)) +
  geom_histogram(binwidth = 1, fill = "#009E73", colour = "black", alpha = 0.7) +
  geom_density(aes(y = ..count.. * 1), fill = "transparent", colour = "red", size = 1.5, bw = 1) +
  xlim(c(min(data_Coenonympha$Forewing_length) - 5, max(data_Coenonympha$Forewing_length) + 5)) +
  labs(title = expression("Histogram of Forewing Length (" * italic("Coenonympha pamphilus") * ")"),
    x = "Forewing Length (mm)",
    y = "Frequency") +
  theme_bw() +
  theme_scientific()
```

<figure>
<img src="Butterfly_Morphology_Report_files/figure-gfm/fig3b-1.png"
alt="(b) Histogram of forewing length for Coenonympha pamphilus." />
<figcaption aria-hidden="true">(b) Histogram of forewing length for
<em>Coenonympha pamphilus</em>.</figcaption>
</figure>

``` r
shapiro.test(data_Coenonympha$Forewing_length)
```

    ## 
    ##  Shapiro-Wilk normality test
    ## 
    ## data:  data_Coenonympha$Forewing_length
    ## W = 0.98064, p-value = 0.149

The distribution for *Coenonympha pamphilus* is similarly bell-shaped
and passes the Shapiro-Wilk test for normality. This confirms that
parametric analyses can also be used for this species.

# 3. Making Sampling Map

This code builds a detailed map showing butterfly sampling locations
across the UK. It begins by importing spatial data for country and
administrative boundaries, then defines three geographic regions (South,
Midlands, North) based on latitude using custom functions. Each region
is visualised with semi-transparent coloured polygons. Finally,
butterfly sampling points are plotted and jittered slightly to reduce
overlap, with points coloured by species.

``` r
# Load UK boundaries
uk <- ne_countries(scale = "large", country = "united kingdom", returnclass = "sf")
uk_regions <- ne_states(country = "united kingdom", returnclass = "sf")
uk_grid <- st_make_grid(uk, n = c(10, 10))

# Define region boundary functions
find_boundary_counties <- function(regions, boundary_lat) {
  region_centroids <- st_centroid(regions)
  region_coords <- st_coordinates(region_centroids)
  region_lats <- region_coords[,2]
  distance_to_boundary <- abs(region_lats - boundary_lat)
  closest_regions <- regions[distance_to_boundary < 1,]
  return(closest_regions)
}

create_zone_by_counties <- function(regions, min_lat, max_lat) {
  region_centroids <- st_centroid(regions)
  region_coords <- st_coordinates(region_centroids)
  in_zone <- region_coords[,2] >= min_lat & region_coords[,2] < max_lat
  zone_regions <- regions[in_zone,]
  if(length(zone_regions) > 0) {
    zone <- st_union(zone_regions)
  } else {
    zone <- NULL
  }
  return(zone)
}

# Define latitude-based regional zones
south_boundary <- 52.5
north_boundary <- 54.5
south <- create_zone_by_counties(uk_regions, 50, south_boundary)
midlands <- create_zone_by_counties(uk_regions, south_boundary, north_boundary)
north <- create_zone_by_counties(uk_regions, north_boundary, 59)

# Plot the map
ggplot() +
  geom_sf(data = uk, fill = "white", color = "black", size = 0.5) +
  geom_sf(data = uk_regions, fill = NA, color = "gray", size = 0.2) +
  geom_sf(data = south,    fill = "lightgreen", color = "green", alpha = 0.3) +
  geom_sf(data = midlands, fill = "lightblue",  color = "blue",  alpha = 0.3) +
  geom_sf(data = north,    fill = "pink",       color = "red",   alpha = 0.3) +
  geom_sf(data = uk_grid, fill = NA, color = "lightgray", size = 0.1) +
  geom_point(data = data,
             aes(x = Longitude, y = Latitude, color = Scientific_name),
             position = position_jitter(width = 0.1, height = 0.1),
             alpha = 0.7,
             size = 2) +
  scale_color_manual(values = c("#E69F00", "#009E73"), name = "Species") +
  coord_sf(xlim = c(-9, 4), ylim = c(50, 59), expand = FALSE) +
  theme_minimal(base_size = 12) +
  theme(panel.grid.major = element_line(color = "lightgray", size = 0.1),
        panel.grid.minor = element_blank(),
        legend.position = "bottom") +
  labs(title = "UK Regional Zones and Species Locations",
       x = "Longitude",
       y = "Latitude")
```

![](Butterfly_Morphology_Report_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

This map clearly shows butterfly sampling sites across the UK, coloured
by species. The North, Midlands, and South regions are highlighted using
coloured overlays derived from the centroids of administrative regions
grouped by latitude. The use of `position_jitter` ensures overlapping
points are visible, and the manually assigned colours improve species
distinction.

# 4. Simple Linear Regression

We next modelled the relationship between morphological traits and
environmental gradients.

## 4.1 Forewing Length ~ Mean Temperature

``` r
model_au_temp <- lm(Forewing_length ~ avg_meantemp, data = data_Aglais)
model_cp_temp <- lm(Forewing_length ~ avg_meantemp, data = data_Coenonympha)
```

### Plot for *Aglais urticae*

``` r
ggplot(data_Aglais, aes(x = avg_meantemp, y = Forewing_length)) +
  geom_point(aes(color = region, shape = region), size = 2.5, alpha = 0.8) +
  geom_smooth(aes(group = 1), method = "lm", se = TRUE, linewidth = 1.2, color = "black") +
  scale_color_manual(name = "Geographic Region",
                     breaks = c("North", "Midlands", "South"),
                     values = c("North" = "#009E73", "Midlands" = "#E69F00", "South" = "#0072B2")) +
  scale_shape_manual(name = "Geographic Region",
                     breaks = c("North", "Midlands", "South"),
                     values = c("North" = 15, "Midlands" = 17, "South" = 16)) +
  labs(title = "Temperature Response in Small Tortoiseshell Butterfly",
       subtitle = "Aglais urticae",
       x = "Mean Temperature (°C)",
       y = "Forewing Length (mm)") +
  theme_scientific()
```

<figure>
<img src="Butterfly_Morphology_Report_files/figure-gfm/fig4a-1.png"
alt="(a) Forewing length vs. mean temperature for Aglais urticae." />
<figcaption aria-hidden="true">(a) Forewing length vs. mean temperature
for <em>Aglais urticae</em>.</figcaption>
</figure>

This regression model shows a clear negative relationship between
temperature and forewing length in *Aglais urticae*. Higher temperatures
are associated with shorter wings, indicating a strong thermal
sensitivity.

### Plot for *Coenonympha pamphilus*

``` r
ggplot(data_Coenonympha, aes(x = avg_meantemp, y = Forewing_length)) +
  geom_point(aes(color = region, shape = region), size = 2.5, alpha = 0.8) +
  geom_smooth(aes(group = 1), method = "lm", se = TRUE, linewidth = 1.2, color = "black") +
  scale_color_manual(name = "Geographic Region",
                     breaks = c("North", "Midlands", "South"),
                     values = c("North" = "#009E73", "Midlands" = "#E69F00", "South" = "#0072B2")) +
  scale_shape_manual(name = "Geographic Region",
                     breaks = c("North", "Midlands", "South"),
                     values = c("North" = 15, "Midlands" = 17, "South" = 16)) +
  labs(title = "Temperature Response in Small Heath Butterfly",
       subtitle = "Coenonympha pamphilus",
       x = "Mean Temperature (°C)",
       y = "Forewing Length (mm)") +
  theme_scientific()
```

<figure>
<img src="Butterfly_Morphology_Report_files/figure-gfm/fig4b-1.png"
alt="(b) Forewing length vs. mean temperature for Coenonympha pamphilus." />
<figcaption aria-hidden="true">(b) Forewing length vs. mean temperature
for <em>Coenonympha pamphilus</em>.</figcaption>
</figure>

A similar negative trend is observed for *Coenonympha pamphilus*, but
the relationship is weaker, indicating this specialist species may be
less responsive to mean temperature.

## 4.2 Forewing Length ~ Latitude

``` r
model_au_lat <- lm(Forewing_length ~ Latitude, data = data_Aglais)
model_cp_lat <- lm(Forewing_length ~ Latitude, data = data_Coenonympha)
```

### Plot for *Aglais urticae*

``` r
ggplot(data_Aglais, aes(x = Latitude, y = Forewing_length)) +
  geom_point(aes(color = region, shape = region), size = 2.5, alpha = 0.8) +
  geom_smooth(aes(group = 1), method = "lm", se = TRUE, linewidth = 1.2, color = "black") +
  scale_color_manual(name = "Geographic Region",
    breaks = c("North", "Midlands", "South"),
    values = c("North" = "#009E73", "Midlands" = "#E69F00", "South" = "#0072B2")) +
  scale_shape_manual(name = "Geographic Region",
    breaks = c("North", "Midlands", "South"),
    values = c("North" = 15, "Midlands" = 17, "South" = 16)) +
  labs(title = "Geographic Variation in Small Tortoiseshell Butterfly",
    subtitle = "Aglais urticae",
    x = "Latitude (°N)",
    y = "Forewing Length (mm)") +
  theme_scientific()
```

<figure>
<img src="Butterfly_Morphology_Report_files/figure-gfm/fig5a-1.png"
alt="(a) Forewing length vs. latitude for Aglais urticae." />
<figcaption aria-hidden="true">(a) Forewing length vs. latitude for
<em>Aglais urticae</em>.</figcaption>
</figure>

Forewing length increases with latitude in *Aglais urticae*, consistent
with Bergmann’s Rule and larger body sizes in colder climates.

### Plot for *Coenonympha pamphilus*

``` r
ggplot(data_Coenonympha, aes(x = Latitude, y = Forewing_length)) +
  geom_point(aes(color = region, shape = region), size = 2.5, alpha = 0.8) +
  geom_smooth(aes(group = 1), method = "lm", se = TRUE, linewidth = 1.2, color = "black") +
  scale_color_manual(name = "Geographic Region",
                     breaks = c("North", "Midlands", "South"),
                     values = c("North" = "#009E73", "Midlands" = "#E69F00", "South" = "#0072B2")) +
  scale_shape_manual(name = "Geographic Region",
                     breaks = c("North", "Midlands", "South"),
                     values = c("North" = 15, "Midlands" = 17, "South" = 16)) +
  labs(title = "Geographic Variation in Small Heath Butterfly",
       subtitle = "Coenonympha pamphilus",
       x = "Latitude (°N)",
       y = "Forewing Length (mm)") +
  theme_scientific()
```

<figure>
<img src="Butterfly_Morphology_Report_files/figure-gfm/fig5b-1.png"
alt="(b) Forewing length vs. latitude for Coenonympha pamphilus." />
<figcaption aria-hidden="true">(b) Forewing length vs. latitude for
<em>Coenonympha pamphilus</em>.</figcaption>
</figure>

Although a positive relationship is also seen in *C. pamphilus*, the
model fit is weaker, again suggesting more variable or buffered
morphology.

# 5. ANOVA for Regional Differences

This section tests whether forewing size differs across regions (North,
Midlands, South).

``` r
# Subset by species
species1_data <- filter(data, Scientific_name == "Aglais urticae")
species2_data <- filter(data, Scientific_name == "Coenonympha pamphilus")

# Run one-way ANOVA
anova_au <- aov(Forewing_length ~ region, data = species1_data)
anova_cp <- aov(Forewing_length ~ region, data = species2_data)

# Post hoc tests
posthoc_au <- emmeans(anova_au, pairwise ~ region)
posthoc_cp <- emmeans(anova_cp, pairwise ~ region)

# Show results
summary(anova_au)
```

    ##             Df Sum Sq Mean Sq F value  Pr(>F)    
    ## region       2  107.7   53.87   40.66 1.5e-13 ***
    ## Residuals   97  128.5    1.33                    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

``` r
summary(anova_cp)
```

    ##             Df Sum Sq Mean Sq F value   Pr(>F)    
    ## region       2  37.30  18.649   29.23 1.16e-10 ***
    ## Residuals   97  61.89   0.638                     
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

``` r
posthoc_au
```

    ## $emmeans
    ##  region   emmean    SE df lower.CL upper.CL
    ##  Midlands   23.6 0.197 97     23.2     24.0
    ##  North      24.8 0.197 97     24.4     25.2
    ##  South      22.2 0.203 97     21.8     22.6
    ## 
    ## Confidence level used: 0.95 
    ## 
    ## $contrasts
    ##  contrast         estimate    SE df t.ratio p.value
    ##  Midlands - North    -1.14 0.279 97  -4.075  0.0003
    ##  Midlands - South     1.42 0.284 97   4.995  <.0001
    ##  North - South        2.55 0.284 97   9.008  <.0001
    ## 
    ## P value adjustment: tukey method for comparing a family of 3 estimates

``` r
posthoc_cp
```

    ## $emmeans
    ##  region   emmean    SE df lower.CL upper.CL
    ##  Midlands   15.6 0.139 97     15.3     15.9
    ##  North      16.3 0.137 97     16.1     16.6
    ##  South      14.9 0.139 97     14.6     15.1
    ## 
    ## Confidence level used: 0.95 
    ## 
    ## $contrasts
    ##  contrast         estimate    SE df t.ratio p.value
    ##  Midlands - North   -0.743 0.195 97  -3.807  0.0007
    ##  Midlands - South    0.749 0.197 97   3.811  0.0007
    ##  North - South       1.492 0.195 97   7.646  <.0001
    ## 
    ## P value adjustment: tukey method for comparing a family of 3 estimates

The ANOVA results show that forewing length differs significantly across
UK regions in both species. For *Aglais urticae*, the ANOVA returned a
highly significant F value, indicating strong between-group variance
relative to within-group variance. Post hoc Tukey tests confirmed that
individuals from the North had significantly longer wings than those
from the Midlands and South, and all pairwise regional comparisons were
statistically significant.

Similarly, for *Coenonympha pamphilus*, the ANOVA also indicated
significant regional structuring, though with a slightly lower effect
magnitude. Post hoc comparisons again revealed significant differences
between all regions, with northern individuals having the longest wings
and southern individuals the shortest. These findings support a
latitudinal gradient in wing size, consistent with ecological principles
such as Bergmann’s Rule.

### Regional Mean Comparison Plot

``` r
regional_summary <- data %>%
  group_by(Scientific_name, region) %>%
  summarise(mean_length = mean(Forewing_length),
            sd_length = sd(Forewing_length), .groups = 'drop')

regional_summary$region <- factor(regional_summary$region, levels = c("South", "Midlands", "North"))

ggplot(regional_summary, aes(x = region, y = mean_length, fill = Scientific_name)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
  geom_errorbar(aes(ymin = mean_length - sd_length,
                    ymax = mean_length + sd_length),
                position = position_dodge(0.9),
                width = 0.2) +
  labs(title = "Regional Variation in Forewing Length",
    x = "Region",
    y = "Mean Forewing Length (mm)") +
  theme_scientific() +
  scale_fill_manual(values = c("#E69F00", "#009E73"),
    name = "Species",
    labels = unique(data$Scientific_name))
```

<figure>
<img src="Butterfly_Morphology_Report_files/figure-gfm/fig6-1.png"
alt="Figure 6. Regional mean forewing length with standard deviation bars." />
<figcaption aria-hidden="true">Figure 6. Regional mean forewing length
with standard deviation bars.</figcaption>
</figure>

Mean forewing size increases consistently from South to North in both
species. One-way ANOVA and Tukey’s post hoc tests confirm significant
differences across all regions.

# 6. Random Forest Models and Variable Importance

We used Random Forest regression to assess the relative importance of
climate variables in predicting wing length.

``` r
create_rf_model <- function(data) {
  randomForest(Forewing_length ~ avg_tmax + avg_tmin + avg_meantemp + avg_rain + avg_sun + region,
               data = data, ntree = 1000, importance = TRUE)
}

rf_model1 <- create_rf_model(species1_data)
rf_model2 <- create_rf_model(species2_data)

importance_df <- data.frame(
  Variable = rownames(importance(rf_model1)),
  Species1 = importance(rf_model1)[, "%IncMSE"],
  Species2 = importance(rf_model2)[, "%IncMSE"])
importance_melt <- reshape2::melt(importance_df, id.vars = "Variable")
```

### Variable Importance Comparison

``` r
ggplot(importance_melt, aes(x = reorder(Variable, value), y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge", alpha = 0.8) +
  coord_flip() +
  labs(title = "Variable Importance Comparison Between Species",
    x = "Environmental Variables",
    y = "% Increase in MSE") +
  theme_scientific() +
  scale_fill_manual(values = c("#E69F00", "#009E73"),
    name = "Species",
    labels = unique(data$Scientific_name))
```

<figure>
<img src="Butterfly_Morphology_Report_files/figure-gfm/fig7-1.png"
alt="Figure 7. Random Forest variable importance for both butterfly species." />
<figcaption aria-hidden="true">Figure 7. Random Forest variable
importance for both butterfly species.</figcaption>
</figure>

*Aglais urticae* showed strong importance across all temperature
variables, with mean temperature contributing the most. In contrast, *C.
pamphilus* showed a narrower set of key predictors, with minimum
temperature dominating.

### Model Performance Metrics

``` r
rmse1 <- sqrt(mean((species1_data$Forewing_length - predict(rf_model1))^2))
rmse2 <- sqrt(mean((species2_data$Forewing_length - predict(rf_model2))^2))

cat("Species 1 R-squared:", round(rf_model1$rsq[length(rf_model1$rsq)] * 100, 2), "%\n")
```

    ## Species 1 R-squared: 39.83 %

``` r
cat("Species 2 R-squared:", round(rf_model2$rsq[length(rf_model2$rsq)] * 100, 2), "%\n")
```

    ## Species 2 R-squared: 5.96 %

``` r
cat("Species 1 RMSE:", round(rmse1, 3), "mm\n")
```

    ## Species 1 RMSE: 1.192 mm

``` r
cat("Species 2 RMSE:", round(rmse2, 3), "mm\n")
```

    ## Species 2 RMSE: 0.966 mm

The Random Forest model explained ~40.2% of variance in *A. urticae* and
only ~6.1% in *C. pamphilus*, suggesting greater morphological
predictability in the generalist species.

# Conclusion

This analysis revealed clear and biologically meaningful patterns in
butterfly wing morphology across the United Kingdom, aligning with
established ecological theories while also uncovering species-specific
nuances. Both *Aglais urticae* (a generalist) and *Coenonympha
pamphilus* (a specialist) exhibited significant morphological adaptation
to environmental gradients, with forewing length increasing at higher
latitudes and decreasing with higher mean temperatures. These trends are
broadly consistent with **Bergmann’s Rule**, which posits that organisms
in colder climates tend to be larger-bodied, potentially for
thermoregulatory efficiency. The results also suggest limited support
for **Allen’s Rule**, although this study did not directly assess
limb-to-body size ratios.

Linear models demonstrated stronger and more tightly constrained
relationships in *A. urticae*, suggesting that generalist species may
exhibit greater phenotypic plasticity or environmental responsiveness
compared to specialists like *C. pamphilus*. This interpretation was
supported by Random Forest regression, which showed substantially higher
predictive power for *A. urticae* (R² ≈ 40.2%) than *C. pamphilus* (R² ≈
6.1%). Key predictive variables for *A. urticae* included mean
temperature, rainfall, and minimum temperature, while *C. pamphilus*
showed a narrower predictor profile dominated by minimum temperature.
These interspecific differences likely reflect variation in ecological
niche breadth, developmental constraints, or behavioural
thermoregulation.

Importantly, the Random Forest results suggest that **climatic variables
alone do not fully explain morphological variation**, especially for
specialist species. This highlights a key limitation and an opportunity
for future research. Additional factors such as host plant availability,
photoperiod, genetic structure, and microhabitat use may also play
significant roles in shaping trait distributions. Furthermore, while
wing length is a practical and ecologically relevant metric,
incorporating other morphological dimensions (e.g. wing shape, thorax
size) could offer a more complete picture of adaptive responses.

Future research should also explore **longitudinal datasets** to
distinguish between phenotypic plasticity and evolutionary change, and
consider integrating **genomic data** to identify heritable components
of morphological traits. Comparative studies across more species with
varying ecological strategies could help generalise the observed
patterns and further test the predictive limits of ecogeographical
rules.

Overall, this study demonstrates the value of combining museum specimen
data, spatial environmental datasets, and both statistical and machine
learning models to understand the drivers of morphological adaptation.
It highlights the complexity of trait-environment interactions and
underscores the need for multi-factor, species-specific approaches when
predicting biological responses to environmental change.

Thanks for reading :)
