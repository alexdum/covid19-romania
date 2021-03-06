## Dashboard to present COVID-19 pandemic spread in Romania

Built in [R](https://www.r-project.org/) using [Shiny](https://shiny.rstudio.com/), this dashboard aims to provide accurate and relevant facts and statistics about COVID-19 spread in Romania.

The dashboard is structured in two main sections:

* [Key figures and plots](https://covid-19.shinyapps.io/romania/#facts)
* [Relevant maps](https://covid-19.shinyapps.io/romania/#maps)


### Tools

* Visualisation: [shiny](https://shiny.rstudio.com/)
* Map: [leaflet](https://rstudio.github.io/leaflet/) 
* NetCDF manipulating: [ncdf4](https://cran.r-project.org/web/packages/ncdf4/index.html)
* Chart: [dygraphs](https://rstudio.github.io/dygraphs/); [plotly](https://plot.ly/r/)
* Table: [DT](https://rstudio.github.io/DT/)
* Deployment: [shinyapps.io](https://www.shinyapps.io/)


### Data source

#### Romania COVID-19 data 

- Provided by [covid19.geo-spatial.org](https://covid19.geo-spatial.org/despre).

- Active cases are computed as <em>total confirmed - total recovered - total deaths</em>.
<em>Active critical cases</em> are COVID-19 patients needing acute and intensive care in hospitals.
  
    
#### NO<sub>2</sub> concentration data 

- Extracted from the Level 3 gridded product [OMNO2d.003](https://disc.gsfc.nasa.gov/datasets/OMNO2d_003/summary), obtianed from the Ozone Monitoring Instrument (OMI) installed on NASA’s Aura scientific research satellite.
- The variable extracted is <em>Tropospheric Cloud Screened NO<sub>2</sub></em>.


### Source code 

Repository: [https://github.com/alexdum](https://github.com/alexdum/covid19-romania)  
Report issue(s) or feature(s) request [here](https://github.com/alexdum/covid19-romania/issues)


### Developer

Alexandru Dumitrescu <br/>
Email: [alexandru.dumitrescu@gmail.com](mailto:alexandru.dumitrescu@gmail.com)  

---

(c) 2020 Alexandru Dumitrescu | [MIT License](https://github.com/alexdum/covid19-romania/blob/master/LICENSE) 

