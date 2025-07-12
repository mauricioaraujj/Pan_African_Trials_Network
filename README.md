# Pan_African_Trials_Network 🌍🌱  
**High-resolution soybean trial data supporting the expansion of agriculture in Africa**

![badges](https://img.shields.io/badge/Scientific-Data-blue) 
![badges](https://img.shields.io/badge/Funding-USAID-yellow) 
![badges](https://img.shields.io/badge/Trials-292%20across%2021%20countries-green) 
![badges](https://img.shields.io/badge/Years-2015--2024/25-blueviolet) 
![badges](https://img.shields.io/badge/Modeling-FA%2BPLS-red)

---

## 👩‍🔬 Authors

Mauricio S. Araújo¹\*, Saulo F.S. Chaves², Gerson N.C. Ferreira¹, Godfree Chigeza³, Brian W. Diers⁴, Erica P. Leles⁴, Michelle F. Santos⁴, Peter Goldsmith⁴, José B. Pinheiro¹\*  

¹ Department of Genetics, University of São Paulo, Genetics Diversity and Breeding Laboratory, Piracicaba - SP, Brazil  
² Department of Genetics, University of São Paulo, Genomics, Analytics and Breeding Laboratory, Piracicaba - SP, Brazil  
³ Feed the Future Innovation Lab, University of Illinois Urbana-Champaign, United States Agency for International Development (USAID), Washington, DC, United States  
⁴ Department of Crop Sciences, University of Illinois at Urbana-Champaign, Urbana, 61801, USA  

📧 *mauricioaraujj@usp.br and jbaldin@usp.br*

---

## 🧭 Project Overview

This repository contains a comprehensive dataset and full analysis pipeline for understanding soybean cultivar responses to diverse African agroecologies using multi-environment trials (METs) from 2015 to 2024/25.

**Key features:**
- 292 trials across 138 locations in 21 countries
- 366 soybean varieties
- Agronomic + nutritional + environmental (soil, weather, management) data
- Includes environmental covariates for enviromics
- Facilitates genotype × environment × management (G×E×M) modeling and recommendation

---

## 🗺️ Graphical Overview

The figure below summarizes the core pipeline, from trials to prediction and recommendation:

![Overview](figures/fig.jpg)

---

## 📂 Repository Structure

| Folder/File       | Description |
|-------------------|-------------|
| [`/data`](./data) | Environmental covariates, trial data, coordinates, etc. |
| [`/figures`](./figures) | All plots (H², yield boxplots, FA results, maps, sPLS, etc.) |
| [`/metadata`](./metadata) | Related scientific publications derived from this dataset |
| [`/output`](./output) | Outputs from statistical models and analyses (e.g., `.RData`, `.csv`) |
| [`/scripts`](./scripts) | R scripts for each step of the analysis pipeline |
| `Pan_African_Trials_Network.Rproj` | RStudio project file |
| `README.md` | This description page |
| `LICENSE` | License for this repository |

---

## 🧬 Scripts

> **Directory:** [`/scripts`](./scripts)

Includes R scripts to run and reproduce the analysis:
- `Fa_Model.R`, `PLS.R` – Modeling
- `Outliers.R`, `Residual.R`, `LRT.R` – Diagnostics
- `Map.R`, `boxplot.R`, `country_conn.R` – Visualization
- `weather.R`, `worldclim.R`, `SoilData.R` – Envirotyping tools

---

## 📊 Data Summary

> **Directory:** [`/data`](./data)

- `Malawi_data.csv`: Trial data from Malawi  
- `Covamb.csv`, `Weather.csv`, `Soil.csv`, `Elevation.csv`: Environmental variables  
- `bioclimatic.csv`: WorldClim bioclimatic data  
- `coords.txt`: Geographic coordinates  
- `data.csv`: Full cleaned dataset used in the models

---

## 📚 Previous Publications

> **Directory:** [`/metadata`](./metadata)

Below are scientific publications derived from the Pan-African soybean trials:

<div align="center">
  <a href="metadata/Evaluating genetic diversity and seed composition stability within Pan-African trials.pdf">
    <img src="figures/pub1.png" alt="Publication 1" width="180" style="margin-right: 10px;"/>
  </a>
  <a href="metadata/Soybean rust resistant and tolerant varieties identified through the Pan African trials.pdf">
    <img src="figures/pub2.png" alt="Publication 2" width="180" style="margin-right: 10px;"/>
  </a>
  <a href="metadata/Optimizing soybean variety selection for the Pan African Trial network using GxE models.pdf">
    <img src="figures/pub3.png" alt="Publication 3" width="180" style="margin-right: 10px;"/>
  </a>
  <a href="metadata/Implementation of a Generalized Additive Model (GAM) for Soybean Maturity modeling.pdf">
    <img src="figures/pub4.png" alt="Publication 4" width="180"/>
  </a>
</div>

---

## 📘 Citation

> Araújo, M.S., Chaves, S.F.S., Ferreira, G.N.C., Chigeza, G., Diers, B.W., Leles, E.P., Santos, M.F., Goldsmith, P., Pinheiro, J.B.  
> **High-resolution soybean trial data supporting the expansion of agriculture in Africa** (2025)

---

## 📬 Contact

Have questions, want to collaborate, or found a bug?  
Feel free to contact:

📧 *mauricioaraujj@usp.br*  
📧 *jbaldin@usp.br*
