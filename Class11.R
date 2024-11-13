
library(sf)
library(terra)
library(rnaturalearth)
library(viridis)  # For magma color palette
# Version 03

# Load post-breeding data shapefile
shape_file <- st_read("C:/Contina LAb/OCW Papers/Data OCW/ebird/Ras_file/Range_files/orcwar_range_2022/orcwar_range_2022.gpkg")
shape_data <- vect(shape_file)

# Filter for post-breeding migration data
post_breeding_data <- shape_data[shape_data$type == "range" & shape_data$season == "postbreeding_migration", ]

# Convert post-breeding data to sf object
post_breeding_data_sf <- st_as_sf(post_breeding_data)

# Load North America shapefile
north_america <- ne_countries(continent = 'North America', returnclass = 'sf')

# Transform North America shapefile to match CRS of post-breeding data
north_america_transformed <- st_transform(north_america, st_crs(post_breeding_data_sf))

# Get the extent of North America to use for cropping
north_america_extent <- st_bbox(north_america_transformed)

# Load the raster data
raster_file <- rast("C:/Contina LAb/OCW Papers/Data OCW/ebird/Ras_file/Range_files/orcwar_range_2022/orcwar_abundance_median_2022-08-02.tif")

# Project the raster to the CRS of the post-breeding data
raster_data_proj <- project(raster_file, crs(post_breeding_data))

# Crop the raster to the extent of North America
raster_data_cropped <- crop(raster_data_proj, north_america_extent)

# Normalize raster values between 0 and 1
raster_min <- minmax(raster_data_cropped)[1]  # Min value
raster_max <- minmax(raster_data_cropped)[2]  # Max value
raster_normalized <- (raster_data_cropped - raster_min) / (raster_max - raster_min)

# Set zero values to NA for transparency
raster_normalized[raster_normalized == 0] <- NA

# Plot the cropped raster first (this will be the base layer)
plot(raster_normalized, 
     col = rev(magma(100)),    # Use reversed magma color palette
     main = "new map ",
     legend = TRUE,            # Show legend
     na.col = "transparent",   # Transparent NA values
     axes = TRUE)

# Overlay the North America map
plot(st_geometry(north_america_transformed), add = TRUE, border = "black")

# Overlay the post-breeding data with a red border
plot(st_geometry(post_breeding_data_sf), add = TRUE, border = "red", lwd = 1)
