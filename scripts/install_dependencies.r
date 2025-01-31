#!/usr/bin/env Rscript

# install_dependencies.R
# This script installs all necessary R packages for running the geographic_maps repository.

# Set CRAN mirror to avoid "trying to use CRAN without setting a mirror" error
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Install pacman if not installed
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

# Load pacman to streamline package installation
pacman::p_load(
  dplyr,          # Data manipulation
  sf,             # Spatial features
  rmapshaper,     # Simplifying and modifying spatial objects
  ggplot2,        # Visualization
  ggspatial,      # Scale bar and north arrow
  raster,         # For handling elevation data
  data.table,     # Efficient data wrangling
  lwgeom,         # Needed for st_area() when s2 is disabled
  here            # For relative file paths
)

message("All required packages are installed and loaded successfully!")
