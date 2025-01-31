#!/usr/bin/env Rscript

# advanced_map_demo.R
# This script demonstrates how to:
# 1) Load and visualize elevation data from an RDS file
# 2) Plot a geographic map with water features
# 3) Draw a circle around a focal point on the map

suppressPackageStartupMessages({
  library(dplyr)
  library(sf)
  library(ggplot2)
  library(ggspatial)   # For annotation_scale, annotation_north_arrow
  library(here)        # For relative file paths
})

# ─────────────────────────────────────────────────────────────────────────────
# 1. Define Paths (Relative to Repository)
# ─────────────────────────────────────────────────────────────────────────────

data_dir   <- here::here("data")
output_dir <- here::here("output")

water_file      <- file.path(data_dir, "complete_watercourse_simplified_by_wts.rds")
elevation_file  <- file.path(data_dir, "alt_raster.RDS")  # Preprocessed elevation data

output_file     <- file.path(output_dir, "advanced_map_demo.jpg")

# ─────────────────────────────────────────────────────────────────────────────
# 2. Define Map Limits and Focal Point
# ─────────────────────────────────────────────────────────────────────────────

# Define focal point (Mont Éboulements)
focal_point <- data.frame(name = "Mont Éboulements", lon = -70.3, lat = 47.5333)

# Function to convert kilometers to degrees (~valid at mid-latitudes)
km_to_deg <- function(km) km / 111  

# Define bounding box limits (10 km buffer from focal point)
buffer_km <- 100  

# Define the current bounding box
bbox <- sf::st_bbox(c(
  xmin = -73.0,  
  xmax = -68.0,  
  ymin = 46.5,  
  ymax = 49.0  
), crs = 4269)

# Define cropping factor (5% margin reduction)
margin_factor <- 0.05  
x_range <- bbox$xmax - bbox$xmin
y_range <- bbox$ymax - bbox$ymin

# Print bbox details before cropping
message("Bounding box limits: xmin=", bbox$xmin, ", xmax=", bbox$xmax,
        ", ymin=", bbox$ymin, ", ymax=", bbox$ymax)


# ─────────────────────────────────────────────────────────────────────────────
# 3. Read and Crop Data
# ─────────────────────────────────────────────────────────────────────────────

# Ensure all required files exist
missing_files <- c(water_file, elevation_file)[!file.exists(c(water_file, elevation_file))]
if (length(missing_files) > 0) {
  stop("Error: Missing input files:\n", paste(missing_files, collapse = "\n"))
}

# Read spatial data
simplified_water <- readRDS(water_file)

# Print CRS info
message("CRS of water features from RDS: ", st_crs(simplified_water))

# Read elevation data
gplot_elevation <- readRDS(elevation_file)

# Check if elevation data has CRS (it may not, since it's a data frame)
if ("sf" %in% class(gplot_elevation)) {
  message("CRS of elevation data: ", st_crs(gplot_elevation))
} else {
  message("Elevation data does not have an explicit CRS (assumed lat/lon)")
}


# Ensure CRS consistency and prevent geometry issues
sf::sf_use_s2(FALSE)  
projected_crs <- 32198  # NAD83 / Quebec Lambert (better for local projections)

# Reproject to a projected CRS for accurate cropping
simplified_water    <- st_transform(st_make_valid(simplified_water), crs = projected_crs)

# Convert bbox to projected CRS and crop data
bbox_projected <- st_transform(st_as_sfc(bbox), crs = projected_crs)

simplified_water    <- st_crop(simplified_water, bbox_projected)
message("Simplified water data after cropping: ", st_geometry_type(simplified_water))
message("Number of features after cropping: ", nrow(simplified_water))


# Convert back to latitude/longitude for plotting
simplified_water    <- st_transform(simplified_water, crs = 4269)

# Read elevation data and filter for bounding box region
gplot_elevation <- readRDS(elevation_file) %>%
  filter(x >= bbox$xmin, x <= bbox$xmax, y >= bbox$ymin, y <= bbox$ymax)

message("Number of elevation points after filtering: ", nrow(gplot_elevation))


# ─────────────────────────────────────────────────────────────────────────────
# 4. Create a Circle Around Focal Point
# ─────────────────────────────────────────────────────────────────────────────

make_circle <- function(lon, lat, radius_km, n_points = 100) {
  angle <- seq(0, 2 * pi, length.out = n_points)
  radius_lon <- km_to_deg(radius_km) / cos(lat * pi / 180)  
  radius_lat <- km_to_deg(radius_km)

  data.frame(
    lon = lon + radius_lon * cos(angle),
    lat = lat + radius_lat * sin(angle)
  )
}

# Create a circle with a 30 km radius around the focal point
circle_data <- make_circle(focal_point$lon, focal_point$lat, 25)

# ─────────────────────────────────────────────────────────────────────────────
# 5. Plot the Map with Elevation Data and Circle
# ─────────────────────────────────────────────────────────────────────────────

p <- ggplot() +
  # (A) Elevation Background
  geom_raster(data = gplot_elevation, aes(x = x, y = y, fill = value), alpha = 0.8) +
  scale_fill_gradientn(colors = terrain.colors(10), name = "Elevation (m)") +

  # (C) Water Features
  geom_sf(data = simplified_water, color = "grey60", fill = 'aliceblue', size = 0.3, alpha = 0.6) +

  # (D) Draw Circle
  geom_polygon(data = circle_data, aes(x = lon, y = lat), color = "red", fill = NA, linetype = "dashed") +
  
  # (E) Mark the Focal Point
  geom_point(data = focal_point, aes(x = lon, y = lat), shape = 3, size = 6, color = "red") +
  geom_text(data = focal_point, aes(x = lon, y = lat, label = name), nudge_y = 0.3, size = 5, color = "black") +

  # (F) Map Adjustments
  theme_classic() +
  coord_sf(
    xlim = c(bbox$xmin + margin_factor * x_range, bbox$xmax - margin_factor * x_range),
    ylim = c(bbox$ymin + margin_factor * y_range, bbox$ymax - margin_factor * y_range)) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  annotation_north_arrow(location = "bl", which_north = "true",
                         pad_x = unit(0.2, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) +
  labs(title = "Charlevoix Astrobleme",x="Longitude", y="Latitude")

# Save the plot
ggsave(p, filename = output_file, width = 8, height = 8, dpi = 300)
message("Plot saved to: ", output_file)
