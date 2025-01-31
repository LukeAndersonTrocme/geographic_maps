# Quebec Geographic Maps

This repository provides an **R script and dataset** for creating a **geographic map of Quebec**, focusing on **topography and hydrology**. The main script processes and visualizes elevation data alongside water features (rivers, lakes, and watersheds). The output is a **high-resolution background map** suitable for presentations, publications, and further geographic analysis.

These scripts are **highly customizable**, allowing users to modify layers, add new data sources, and experiment with **different geographic features**. This project serves as a **great starting point for programmatic map-making**, demonstrating how to:
- Load and **combine multiple geospatial datasets** from different sources.
- Customize **labels, points, and geometric annotations** (e.g., circles, north arrows, scale bars).
- Generate **publication-quality maps** with **ggplot2** and **sf**.

Whether you're a researcher, student, or GIS enthusiast, this repository provides a **practical introduction to geographic visualization in R** and can be adapted for various use cases.

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

## **Future Updates**

I plan to update this repository with more details on how the **pre-processed RDS files** (elevation, water features) were generated. This will include:
- The raw geospatial data sources used.
- The processing steps taken in **R** (e.g., cropping, simplifying, and filtering datasets).
- Scripts to allow users to recreate the datasets from scratch.

Stay tuned for future updates! 🚀

---


## **License**

This project is licensed under the **MIT License**.

## **Contributing & Citation**

### **Report Issues**
If you encounter any **bugs** or have **suggestions**, please feel free to **open an issue** in the repository. Your feedback is welcome!

### **Cite This Work**
If you use this project in your research, please consider citing:

**Luke Anderson-Trocmé et al.** (2023).  
*"On the genes, genealogies, and geographies of Quebec."*  
Science, 380, 849-855.  
[DOI: 10.1126/science.add5300](https://www.science.org/doi/10.1126/science.add5300)