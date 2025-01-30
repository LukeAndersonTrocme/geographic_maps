# Quebec Background Maps

This repository contains an R script and associated data files for building a **background map of Quebec**, including political boundaries, watershed polygons, and watercourses. The result is saved as both an RDS (ggplot object) and a JPEG image for convenient reuse and visualization.

## Contents

- **scripts/create_background_map.R**  
  - An R script that reads the simplified `.rds` data (political boundaries, watersheds, watercourse polygons), fixes invalid geometries, applies filters (e.g., removing small polygons), and saves a final `bg_map` in both `.rds` and `.jpg` format.

- **data/political_processed.rds**  
  - Pre-processed polygons for Canada’s provinces/territories, cropped to focus on Quebec.
- **data/wts_processed.rds**  
  - Watershed polygons (cropped and simplified).
- **data/complete_watercourse_simplified_by_wts.RDS**  
  - Watercourse lines/polygons (rivers, lakes) aggregated and simplified.

- **output/background_map_Jan2025.rds**  
  - The final ggplot object containing the background map layers.
- **output/background_map_Jan2025.jpg**  
  - A high-resolution image of the final map.

## Usage

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/quebec-background-map.git

2. Install required packages in R (e.g., dplyr, sf, ggplot2, ggspatial, rmapshaper, data.table).
3. Run the script:
```
cd quebec-background-map/scripts
Rscript create_background_map.R
```

4. The script reads the RDS files from data/ and saves outputs in output/.

## Data Sources
1. Administrative Boundaries in Canada - CanVec Series

Open Canada: Administrative Boundaries
The CanVec multiscale series provides prepackaged downloads or via a Geospatial data extraction tool.
Used here to obtain the political boundaries for Quebec (political_processed.rds).

2. National Hydro Network - NHN - GeoBase Series

Open Canada: National Hydro Network
Contains geospatial data describing Canada’s inland surface waters (lakes, rivers, streams, obstacles).
We used this to build the watershed polygons (wts_processed.rds) and watercourse data (complete_watercourse_simplified_by_wts.RDS).

3. Canadian Digital Elevation Model (CDEM)

Open Canada: Digital Elevation Model
Note: The script here doesn’t directly use DEM data, but it’s another relevant geospatial dataset from Open Canada.


All of these data sources are made accessible via Open Canada’s geospatial portal.

## License
Licensed under the MIT License.

## Author
Luke Anderson-Trocmé