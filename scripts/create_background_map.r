#!/usr/bin/env Rscript

# create_background_map.R
# Script to build and save a background map (bg_map) of Quebec,
# including political boundaries, watershed polygons, and watercourses.

# Required packages:
#   dplyr, sf, rmapshaper, ggplot2, ggspatial, data.table

suppressPackageStartupMessages({
  library(dplyr)
  library(sf)
  library(rmapshaper)
  library(ggplot2)
  library(ggspatial)
  library(data.table)
})

# 1. Config
rdsPath       <- "~/Documents/Genizon/Data/RDS/"
figurePath    <- "~/Documents/Genizon/Genizon_Scripts/Latex/Figures/"
output_map_rds<- file.path(rdsPath, "background_map_Jan2025.rds")
output_map_jpg<- file.path(figurePath, "background_map_Jan2025.jpg")

political_file<- file.path(rdsPath, "political_processed.rds")
wts_file      <- file.path(rdsPath, "wts_processed.rds")
water_file    <- file.path(rdsPath, "complete_watercourse_simplified_by_wts.RDS")

# 2. Read data
message("Reading input RDS files...")
political_processed <- readRDS(political_file)
wts_processed       <- readRDS(wts_file)
simplified_water    <- readRDS(water_file)

# 3. Fix geometry issues
message("Fixing invalid geometries...")
political_processed <- st_make_valid(political_processed)
wts_processed       <- st_make_valid(wts_processed)
simplified_water    <- st_make_valid(simplified_water)

valid_geometries <- c("POLYGON", "MULTIPOLYGON","LINESTRING","MULTILINESTRING")
political_processed <- filter(political_processed, st_geometry_type(.) %in% valid_geometries)
wts_processed       <- filter(wts_processed,       st_geometry_type(.) %in% valid_geometries)
simplified_water    <- filter(simplified_water,    st_geometry_type(.) %in% valid_geometries)

# 4. Filter small polygons
message("Filtering small water polygons...")
watercourses <- filter(simplified_water, TYPE_TEXT == "Watercourse")
bodies       <- filter(simplified_water, TYPE_TEXT != "Watercourse")

area_info <- data.frame(area = as.numeric(st_area(bodies))) %>%
  mutate(keep = ifelse(area > 1e7, TRUE, FALSE))

bodies_large   <- bodies[area_info$keep, ]
water_filtered <- bind_rows(watercourses, bodies_large)

# 5. Simplify watershed polygons
wts_processed <- ms_simplify(wts_processed, keep = 0.05)

# 6. Build ggplot
message("Building ggplot background map...")
bg_map <- ggplot() +
  geom_sf(data = filter(political_processed, juri_en == "Quebec"),
          fill = "gray90", color = NA) +
  geom_sf(data = filter(political_processed, ctry_en == "Canada", juri_en != "Quebec"),
          fill = "gray95", color = NA) +
  geom_sf(data = filter(political_processed, !ctry_en %in% c("Canada", "Ocean")),
          fill = "gray95", color = NA) +
  geom_sf(data = wts_processed, fill = NA, color = "white", size = 0.75) +
  geom_sf(data = water_filtered, size = 0.2, color = "gray55", fill = "aliceblue") +
  theme_classic() +
  annotation_scale(location = "br", width_hint = 0.5) +
  annotation_north_arrow(location = "br", which_north = "true",
                         pad_x = unit(0.75, "in"), pad_y = unit(0.5, "in"),
                         style = north_arrow_fancy_orienteering) +
  theme(
    axis.line        = element_blank(),
    panel.grid.major = element_blank(),
    panel.background = element_rect(fill = "aliceblue")
  )

# 7. Save outputs
message("Saving outputs...")
saveRDS(bg_map, file = output_map_rds)
ggsave(bg_map, filename = output_map_jpg, width = 24, height = 18, dpi = 300)

message("Done!")
