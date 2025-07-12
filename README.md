# Pan_African_Trials_Network 🚀🌱  
**High-resolution soybean trial data supporting the expansion of agriculture in Africa**

**Authors**:  
Mauricio S. Araújo¹\*, Saulo F.S. Chaves², Gerson N.C. Ferreira¹, Godfree Chigeza³, Brian W. Diers⁴, Erica P. Leles⁴, Michelle F. Santos⁴, Peter Goldsmith⁴, José B. Pinheiro¹\*  

¹ Department of Genetics, University of São Paulo, Genetics Diversity and Breeding Laboratory, Piracicaba - SP, Brazil

² Department of Genetics, University of São Paulo, Genomics, Analytics and Breeding Laboratory, Piracicaba - SP, Brazil 

³ Feed the Future Innovation Lab, University of Illinois Urbana-Champaign, United States Agency for International Development (USAID), Washington, DC, United States 

⁴ Department of Crop Sciences, University of Illinois at Urbana-Champaign, Urbana, 61801, USA 

\*mauricioaraujj@usp.br and jbaldin@usp.br

---

## 🔎 Overview

This repository contains a comprehensive dataset and full analysis pipeline for understanding soybean cultivar responses to diverse African agroecologies using multi-environment trials (METs) from 2015 to 2024/25.

**Key features:**
- 292 trials across 138 locations in 21 countries
- 366 soybean varieties
- Agronomic + nutritional + environmental (soil, weather, management) data
- Includes environmental covariates for enviromics
- Facilitates genotype × environment × management (G×E×M) modeling and recommendation


![Overview](figures/fig.jpg)



---

## 📁 Repository Structure

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

## 📊 Data Preview

> **Directory:** [`/data`](./data)

Contains:
- `Malawi_data.csv`: Raw data for trials in Malawi  
- `Covamb.csv`, `Weather.csv`, `Soil.csv`, `Elevation.csv`: Environmental variables  
- `bioclimatic.csv`: Bioclimatic features from WorldClim  
- `coords.txt`: Latitude/longitude of sites  
- `data.csv`: Cleaned dataset used in most analyses

---

## 🧬 Scripts

> **Directory:** [`/scripts`](./scripts)

Includes well-documented R scripts:
- `Fa_Model.R`, `PLS.R`: FA modeling and regression
- `LRT.R`, `Residual.R`, `Outliers.R`: Model testing and diagnostics
- `SoilData.R`, `weather.R`, `altitude.R`, `worldclim.R`: Environmental data processing
- `boxplot.R`, `Map.R`, `country_conn.R`, `Water_regime.R`: Visualization and spatial analysis

---

## 🖼️ Figures

> **Directory:** [`/figures`](./figures)

Includes plots for:
- Genetic correlation and heritability (`Correlation.pdf`, `H2.pdf`)
- Boxplots by genotype (`boxplot.pdf`)
- Environmental elevation map (`Elevation.pdf`)
- FA summaries (`fast.pdf`, `sPLS.pdf`)
- Geographic figures (`mappp.png`)
- Example JPEG image (`Fig (2).jpg`)

---

## 📚 Metadata / Publications

> **Directory:** [`/metadata`](./metadata)

Published research using this dataset:
- *Evaluating genetic diversity and seed composition stability within Pan-African trials*
- *Soybean rust resistant and tolerant varieties identified through the Pan African trials*
- *Optimizing soybean variety selection for the Pan African Trial network using G×E models*
- *Implementation of a GAM for Soybean Maturity modeling*

---

## 💡 Suggested Citation

> Araújo, M.S., Chaves, S.F.S., Ferreira, G.N.C., Chigeza, G., Diers, B.W., Leles, E.P., Santos, M.F., Goldsmith, P., Pinheiro, J.B.  
> High-resolution soybean trial data supporting the expansion of agriculture in Africa. (2025)  

---

## 📩 Contact

Feel free to reach out to us for collaboration, questions, or feedback:  
📧 mauricioaraujj@usp.br | jbaldin@usp.br
