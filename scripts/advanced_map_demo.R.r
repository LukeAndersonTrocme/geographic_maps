#!/usr/bin/env Rscript

# advanced_map_demo.R
# This script introduces geographic data visualization by:
# 1) Loading and visualizing elevation data from an RDS file
# 2) Plotting a geographic map with water features
# 3) Drawing a reference circle around a focal point

suppressPackageStartupMessages({
  library(dplyr)      # Data manipulation
  library(sf)         # Handling spatial data
  library(ggplot2)    # Data visualization
  library(ggspatial)  # Scale bar and north arrow
  library(here)       # Relative file paths
})

# ─────────────────────────────────────────────────────────────────────────────
# 1. Define Paths and Load Data
# ─────────────────────────────────────────────────────────────────────────────

# Define file paths for input datasets
data_dir   <- here::here("data")
output_dir <- here::here("output")

water_file      <- file.path(data_dir, "complete_watercourse_simplified_by_wts.rds") # Simplified water features (rivers, lakes)
elevation_file  <- file.path(data_dir, "alt_raster.RDS")  # Preprocessed elevation raster

output_file     <- file.path(output_dir, "advanced_map_demo.jpg") # Output file

# Load spatial datasets
simplified_water <- readRDS(water_file)   # Load water features
gplot_elevation <- readRDS(elevation_file) # Load preprocessed elevation raster

# ─────────────────────────────────────────────────────────────────────────────
# 2. Define Map Limits and Focal Point
# ─────────────────────────────────────────────────────────────────────────────

# Define the focal point: Mont Éboulements (impact crater site in Charlevoix)
focal_point <- data.frame(name = "Mont Éboulements", lon = -70.3, lat = 47.5333)

# Define bounding box (xmin, xmax, ymin, ymax) in geographic coordinates (EPSG:4269)
bbox <- sf::st_bbox(c(
  xmin = -73.0,  # Western boundary
  xmax = -68.0,  # Eastern boundary
  ymin = 46.5,   # Southern boundary
  ymax = 49.0    # Northern boundary
), crs = 4269)

# Define margin factor (5% inward crop)
# This ensures the map content aligns properly by trimming mismatched edges
margin_factor <- 0.05  
x_range <- bbox$xmax - bbox$xmin  # Longitude range
y_range <- bbox$ymax - bbox$ymin  # Latitude range

# Filter elevation data to match bounding box
gplot_elevation <- gplot_elevation %>%
  filter(x >= bbox$xmin, x <= bbox$xmax, y >= bbox$ymin, y <= bbox$ymax)

# Crop water features directly using bbox (EPSG:4269, already in latitude/longitude)
sf::sf_use_s2(FALSE)  # Disable spherical geometry to simplify planar operations
simplified_water <- st_crop(simplified_water, bbox)

# ─────────────────────────────────────────────────────────────────────────────
# 3. Create a Reference Circle (27 km radius)
# ─────────────────────────────────────────────────────────────────────────────

# Function to convert kilometers to degrees (~valid at mid-latitudes)
km_to_deg <- function(km) km / 111  

# Generate a lat/lon circle using trigonometry
# We approximate the Earth's surface as a sphere, so we:
# - Generate `n_points` along a unit circle (0 to 2π radians)
# - Scale by `radius_lon` and `radius_lat` to account for latitude distortion
# - Adjust longitude scaling with `cos(lat)` to preserve proportionality
make_circle <- function(lon, lat, radius_km, n_points = 100) {
  angle <- seq(0, 2 * pi, length.out = n_points)  # Angles from 0 to 2π
  radius_lon <- km_to_deg(radius_km) / cos(lat * pi / 180)  # Adjusted for latitude
  radius_lat <- km_to_deg(radius_km)  # Latitude radius conversion

  data.frame(
    lon = lon + radius_lon * cos(angle),  # X-coordinates (longitude)
    lat = lat + radius_lat * sin(angle)   # Y-coordinates (latitude)
  )
}

# Create a circle with a 27 km radius
circle_data <- make_circle(focal_point$lon, focal_point$lat, 27)

# ─────────────────────────────────────────────────────────────────────────────
# 4. Generate and Save the Map
# ─────────────────────────────────────────────────────────────────────────────

p <- ggplot() +
  # (A) Elevation background
  geom_raster(data = gplot_elevation, aes(x = x, y = y, fill = value), alpha = 0.8) +
  scale_fill_gradientn(colors = terrain.colors(10), name = "Elevation (m)") +  # Terrain-like color scale

  # (B) Water features (rivers and lakes)
  geom_sf(data = simplified_water, color = "grey60", fill = "aliceblue", size = 0.1, alpha = 1) +

  # (C) Reference circle and focal point
  geom_polygon(data = circle_data, aes(x = lon, y = lat), color = "grey20", fill = NA, linetype = "solid", linewidth = 0.2) +
  geom_point(data = focal_point, aes(x = lon, y = lat), shape = 3, size = 2, color = "grey20") +
  geom_text(data = focal_point, aes(x = lon, y = lat, label = name), nudge_y = 0.05, size = 2, color = "black") +

  # (D) Map adjustments
  theme_classic() +
  coord_sf(
    xlim = c(bbox$xmin + margin_factor * x_range, bbox$xmax - margin_factor * x_range), # Crop 5% inward
    ylim = c(bbox$ymin + margin_factor * y_range, bbox$ymax - margin_factor * y_range)
  ) +
  annotation_scale(location = "bl", width_hint = 0.5) +  # Scale bar
  annotation_north_arrow(location = "bl", which_north = "true",
                         pad_x = unit(0.2, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) +  # North arrow
  labs(title = "Charlevoix Astrobleme", x = "Longitude", y = "Latitude") +
  theme(plot.title = element_text(hjust = 0.5))  # Center title

# Save the plot
ggsave(p, filename = output_file, width = 8, height = 6, dpi = 600)
message("Plot saved to: ", output_file)
