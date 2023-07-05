#Ch1 RdNBR dNBR Compare

library(raster)
library(sp)
library(rgdal)

raster1 <- raster("C:\\Users\\gisma\\OneDrive - University of Arizona\\Dissertation_KL_2023\\data\\clip_data\\dNBR_lid_2019.tif")
raster2 <- raster("C:\\Users\\gisma\\OneDrive - University of Arizona\\Dissertation_KL_2023\\data\\clip_data\\RdNBR_lid_2019.tif")

#2019 lidar boundary
boundary <- readOGR(dsn = "S:\\Bighorn_Fire\\Remotely_sensed_data\\2019_USGS_LiDAR\\boundary\\2019_lidar_BD.shp")

# Extract values within the boundary
values1 <- extract(raster1, boundary)
values2 <- extract(raster2, boundary)

# Convert extracted values to numeric vectors
values1 <- unlist(raster1)
values2 <- unlist(raster2)

# Identify "no data" values
no_data <- is.na(values1) | is.na(values2)

# Exclude "no data" values
values1_clean <- values1[!no_data]
values2_clean <- values2[!no_data]

# Plot values1 and values2 while excluding "no data" values
plot(values1, values2)

plot(values1[!no_data], values2[!no_data], xlab = "dNBR", ylab = "RdNBR", main = "RdNBR vs dNBR")


plot(values1_clean, values2_clean, xlab = "dNBR", ylab = "RdNBR", main = "RdNBR vs dNBR")
#abline(lm(values2_clean ~ values1_clean), col = "red")
lm_model <- lm(values2_clean ~ values1_clean)
abline(lm_model, col = "red")

# Add regression equation and R-squared value
equation <- paste("y =", round(coef(lm_model)[1], 2), "* x +", round(coef(lm_model)[2], 2))
rsquared <- paste("R-squared =", round(summary(lm_model)$r.squared, 2))
text(x = min(values1_clean), y = max(values2_clean), labels = c(equation, rsquared), pos = 4, col = "blue")

# Perform correlation analysis
correlation_coeff <- cor(values1_clean, values2_clean)
print(correlation_coeff)



# Fit linear regression model
lm_model <- lm(values2_clean ~ values1_clean)

# Create scatter plot with regression line
plot(values1_clean, values2_clean, xlab = "dNBR", ylab = "RdNBR", main = "Regression Model Visualization")
abline(lm_model, col = "red")

# Residuals vs Fitted Plota
plot(lm_model, which = 1)

# Normal Q-Q Plot
plot(lm_model, which = 2)

# Scale-Location (Square Root of Standardized Residuals) vs Fitted Plot
plot(lm_model, which = 3)

# Residuals vs Leverage Plot
plot(lm_model, which = 5)

