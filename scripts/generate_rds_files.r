#!/usr/bin/env Rscript

# generate_rds_files.R
# A minimal script to create three RDS files:
#   1) political_processed.rds
#   2) wts_processed.rds
#   3) complete_watercourse_simplified_by_wts.RDS
#
# Steps:
#  - Read & process political boundaries (crop, simplify => political_processed)
#  - Read & process watershed polygons => wts_processed
#  - Read & process watercourse data => complete_watercourse_simplified_by_wts.RDS
#
# Adjust file paths as needed.

suppressPackageStartupMessages({
  library(dplyr)
  library(sf)
  library(rmapshaper) # for ms_simplify
  library(data.table)
})

# ----------------------------------------------------------------------------
# 1) File paths and bounding box
# ----------------------------------------------------------------------------

rdsPath       <- "~/Documents/Genizon/Data/RDS/"   
geo_data      <- "/Volumes/Luke Data/geobase/"  # or wherever your shapefiles are

# Output RDS files
political_out <- file.path(rdsPath, "political_processed.rds")
wts_out       <- file.path(rdsPath, "wts_processed.rds")
water_out     <- file.path(rdsPath, "complete_watercourse_simplified_by_wts.RDS")

# Shapefile/Inputs
political_shp <- "/Volumes/Two-Tee-Luke/canvec/canvec_1M_CA_Admin_shp/canvec_1M_CA_Admin/geo_political_region_2.shp"
watershed_shp <- "~/Documents/Genizon/Data/geobase/shp/NHN_INDEX_WORKUNIT_LIMIT_2/"

# For watercourse data we have a text file listing shapefiles
waterbody_filenames <- file.path(geo_data, "waterbody_shape_filenames.txt")

# Example bounding box (xmin, ymin, xmax, ymax)
crop_box <- c(xmin = -85, ymin = 40, xmax = -50, ymax = 55)

# ----------------------------------------------------------------------------
# 2) Process Political Boundaries => political_processed.rds
# ----------------------------------------------------------------------------
message("Processing political boundaries...")

# Read raw shapefile
political <- read_sf(political_shp)
political$geo_type <- st_geometry_type(st_geometry(political))

# Filter geometry
accepted_geometries <- c("LINESTRING","MULTILINESTRING","POLYGON","MULTIPOLYGON")
political_processed <- political %>%
  filter(geo_type %in% accepted_geometries) %>%
  ms_simplify(keep = 0.5) %>%
  st_crop(crop_box)

# Save RDS
saveRDS(political_processed, file = political_out)
message("Saved: ", political_out)

# ----------------------------------------------------------------------------
# 3) Process Watershed Polygons => wts_processed.rds
# ----------------------------------------------------------------------------
message("Processing watershed polygons...")

# Read the watershed polygon from NHN
wts_raw <- read_sf(watershed_shp, layer = "NHN_INDEX_21_INDEX_WORKUNIT_LIMIT_2")

wts_processed <- wts_raw %>%
  st_crop(crop_box) %>%
  ms_simplify(keep = 0.5)

saveRDS(wts_processed, file = wts_out)
message("Saved: ", wts_out)

# ----------------------------------------------------------------------------
# 4) Process Watercourse => complete_watercourse_simplified_by_wts.RDS
# ----------------------------------------------------------------------------
message("Processing watercourse data...")

# We read a list of shapefiles from 'waterbody_shape_filenames.txt'
shp_list <- list()
shp_fn <- fread(waterbody_filenames, header = FALSE)

cut <- 2e5             # size limit for bodies of water
simplify_limit <- 0.5  # simplification factor

for (f in shp_fn$V1) {
  # Full path to each shapefile
  fpath <- file.path(geo_data, f)
  if (!file.exists(fpath)) {
    message("File not found: ", fpath)
    next
  }
  
  # Read SF
  wts_sf <- read_sf(fpath) %>%
    mutate_if(is.character, ~gsub("[^0-9A-Za-z///' ]","'", ., ignore.case = TRUE))
  
  # Separate watercourse vs. others
  ww <- filter(wts_sf, TYPE_TEXT == "Watercourse")
  bw <- filter(wts_sf, TYPE_TEXT != "Watercourse")
  
  # Remove small polygons from bw
  area_cut <- data.frame(area = as.numeric(st_area(bw))) %>%
    mutate(cutoff = ifelse(area > cut, TRUE, FALSE))
  bw <- bw[area_cut$cutoff, ]
  
  # Simplify if not empty
  if (nrow(ww) > 0) ww <- ms_simplify(ww, keep = simplify_limit)
  if (nrow(bw) > 0) bw <- ms_simplify(bw, keep = simplify_limit)
  if (nrow(bw) == 0 & nrow(ww) == 0) next
  
  shp_list[[f]] <- bind_rows(ww, bw)
}

# Combine all water shapefiles
single_sf <- bind_rows(shp_list)

# Example: assign crs (NAD83?), if known:
st_crs(single_sf) <- 4269 

# Crop
single_sf <- st_make_valid(single_sf) %>%
  st_crop(crop_box)

# Next, if you want to group by watershed or weird watersheds, etc:
# (We omit the extended loop from the snippet that handles weird watersheds or
#  '03OB000' unless you truly need that logic.)

# For demonstration, we do a final simplify or usage:
# final_simplified <- single_sf # or further ms_simplify

saveRDS(single_sf, file = water_out)
message("Saved: ", water_out)

message("All RDS files created successfully!")
