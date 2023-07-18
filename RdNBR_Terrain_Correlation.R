# Load necessary libraries
install.packages(c("readxl", "corrplot", "ggplot2"))
library(readxl)
library(corrplot)
library(ggplot2)

# Load the data
data <- read_excel("C:/Users/gisma/OneDrive - University of Arizona/Dissertation_KL_2023/data/Summary/Summary_1.xlsx")

# Calculate correlations
correlations <- cor(data, use = "pairwise.complete.obs") 

# Print correlations
print(correlations)

# Visualize correlations
corrplot(correlations, method = "circle")

# If you want to visualize correlations as a heatmap
corrplot(correlations, method = "color")