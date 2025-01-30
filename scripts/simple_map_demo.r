#!/usr/bin/env Rscript

# simple_map_demo.R
# A super simple example that:
# 1) Reads an SF object from an RDS file.
# 2) Crops it to a bounding box.
# 3) Reprojects (rotates) it to a new coordinate system.
# 4) Creates some dummy points (SF).
# 5) Plots everything with ggplot2 and saves an output image.

suppressPackageStartupMessages({
  library(dplyr)
  library(sf)
  library(ggplot2)
})

# 1) File paths (EDIT THESE as needed)
map_rds_file <- "my_map.rds"           # An RDS file containing an SF object
output_file  <- "my_map_cropped_rotated.jpg"

# 2) Read the SF object from RDS
message("Reading the SF object...")
my_map <- readRDS(map_rds_file)

# 3) Crop to a bounding box
#    Here we define a bounding box from (xmin, ymin) to (xmax, ymax)
#    Adjust values based on your data region
message("Cropping the map to bounding box...")
crop_box <- c(xmin = -75, ymin = 40, xmax = -55, ymax = 50)
my_map_cropped <- st_crop(my_map, crop_box)

# 4) Rotate (reproject) by assigning a new projection
#    e.g., an oblique mercator or Lambert conformal conic, etc.
#    Here we do a simple transformation to WGS84 (EPSG:4326) for demonstration.
#    Replace with your desired projection.
message("Reprojecting the map...")
new_crs <- "EPSG:4326"   # Or any valid PROJ string, e.g., '+proj=omerc ...'
my_map_rotated <- st_transform(my_map_cropped, crs = new_crs)

# 5) Create some dummy points
#    E.g., two made-up towns with Lon/Lat
dummy_points <- data.frame(
  name = c("Town A", "Town B"),
  Lon  = c(-65.0, -62.5),
  Lat  = c(45.5, 44.7)
)

# Convert to SF (same CRS as my_map_rotated)
sf_points <- st_as_sf(dummy_points, coords = c("Lon", "Lat"), crs = new_crs)

# 6) Plot with ggplot2
message("Plotting and saving output...")
p <- ggplot() +
  # Plot the map geometry
  geom_sf(data = my_map_rotated, fill = "gray80", color = "black") +
  # Plot dummy points
  geom_sf(data = sf_points, aes(color = name), size = 3) +
  theme_minimal() +
  labs(title = "Simple Cropped + Rotated Map with Dummy Points")

# 7) Save the final plot
ggsave(p, filename = output_file, width = 6, height = 4, dpi = 300)
message("Done! Saved to: ", output_file)
