# Quebec Geographic Maps

This repository provides an **R script and dataset** for creating a **geographic map of Quebec**, focusing on **topography and hydrology**. The main script processes and visualizes elevation data alongside water features (rivers, lakes, and watersheds). The output is a **high-resolution background map** suitable for presentations, publications, and further geographic analysis.

![Example Map](https://github.com/LukeAndersonTrocme/geographic_maps/blob/main/output/advanced_map_demo.jpg)

## Features

- Uses **pre-processed geospatial data** (elevation, water features) to generate a background map.
- Includes **elevation shading** using rasterized digital elevation model (DEM) data.
- Displays **watercourses and watersheds** from open Canadian datasets.
- Adds a **reference circle** around a focal point (Mont Éboulements), demonstrating geographic visualization techniques.
- Outputs both a **ggplot2 RDS object** and a **JPEG image** for easy reuse.

---

## **Usage**

### **1. Clone the Repository**
```bash
git clone https://github.com/LukeAndersonTrocme/geographic_maps.git
cd geographic_maps/scripts
```
### **2. Install Required R Packages**
```
Rscript install_dependencies.r
```
### 3. **Run the Script**
```
Rscript advanced_map_demo.R
```
The generated map will be saved in the output/ folder as:
- advanced_map_demo.jpg (High-resolution image)
- advanced_map_demo.rds (ggplot2 object for further customization)

## **Contents**

### **Scripts**

- **`scripts/advanced_map_demo.R`**
    - Main script for processing elevation and hydrology data.
    - Crops datasets, applies filters, and generates the final geographic visualization.
    - Saves output as a `.jpg` and `.rds` file.

### **Data (Pre-processed)**

- **`data/alt_raster.RDS`** – Elevation data from a **Canadian Digital Elevation Model (CDEM)** raster.
- **`data/complete_watercourse_simplified_by_wts.RDS`** – Simplified watercourses (rivers, lakes) aggregated by watersheds.

### **Output**

- **`output/advanced_map_demo.jpg`** – Final map visualization (JPEG).
- **`output/advanced_map_demo.rds`** – ggplot2 object for further modification.


---

## **Data Sources**

The geospatial data used in this repository is sourced from **Open Canada’s public datasets**:

### **1. Water Features (Rivers, Lakes, Watersheds)**

**National Hydro Network (NHN) – GeoBase Series**  
[→ Open Canada: National Hydro Network](https://open.canada.ca/data/en/dataset/a4b190fe-e090-4e6d-881e-b87956c07977)

- Provides geospatial data for **rivers, lakes, and drainage basins** across Canada.

### **2. Elevation Data**

**Canadian Digital Elevation Model (CDEM)**  
[→ Open Canada: Digital Elevation Model](https://open.canada.ca/data/en/dataset/7f245e4d-76c2-4caa-951a-45d1d2051333)

- Contains **gridded elevation data** used for terrain visualization.

---

## **Why Use This?**

- **Fast and simple** way to generate **publication-quality geographic maps**.
- Works with **pre-processed datasets**, avoiding complex GIS tools.
- Easy to **extend and customize** (e.g., add new layers, modify themes).
- **Useful for researchers and educators** working with spatial data in R.

---

## **License**

This project is licensed under the **MIT License**.

## **Author**

[Luke Anderson-Trocmé](https://github.com/LukeAndersonTrocme)