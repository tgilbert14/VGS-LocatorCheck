## setting directory to this source file
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
## silence loading warning for sp/rgdal
"rgdal_show_exportToProj4_warnings"="none"

library(sf)
library(sp)
library(rgdal)
library(uuid)
library(tidyverse)
library(DBI)
library(RSQLite)
library(stringr)
library(readxl)
library(openxlsx)

## SQL local Connection info from R to local VGS5 (VGS50.db)
db_loc <- "C:/ProgramData/VGSData/VGS50.db"
mydb <- dbConnect(RSQLite::SQLite(), dbname = db_loc)

## get locator data from VGS .db
query_get_loctors <- "Select SiteID, DDLong as lon, DDLat as lat, Ancestry from locator
inner join site on site.PK_Site = Locator.FK_Site
inner join AncestryCombinedPath ON AncestryCombinedPath.PK_Site = Site.PK_Site
order by Ancestry, SiteID"

locator_data<- dbGetQuery(mydb, query_get_loctors)
# end VGS connection
dbDisconnect(mydb)

# read in shape file
shapefile_pasture<- rgdal::readOGR(dsn="E:/VGS - Deathstar II/GIS II/S_USA.Pasture", "S_USA.Pasture")
#pasture<- as.data.frame(shapefile_pasture)

# Convert lat and lon to numeric
locator_data$lat <- as.numeric(locator_data$lat)
locator_data$lon <- as.numeric(locator_data$lon)

# Create a point data frame
point <- locator_data[, c("lon", "lat")]
coordinates(point) <- ~lon+lat

# Set the projection of point to match shapefile_pasture
proj4string(point) <- proj4string(shapefile_pasture)

# Find what row each point falls in
pasture_result <- over(point, shapefile_pasture)

# Combine the results with the original data
results_table <- cbind(locator_data, pasture_result)

# create excel sheet to show results
#View(results_table)
write.xlsx(results_table, paste0("results/placingLocators_by_Shapefile_",Sys.Date(),".xlsx"))



new_data<- results_table %>% 
  mutate("PredictedName" = paste0( substr(MANAGING_O,1,2),"-",
                                   substr(MANAGING_O,3,4),"-",
                                   substr(MANAGING_O,5,6),"-",
                                   ALLOTMENT1,"-",PASTURE_NU,"-KA#"))

site_name_compare<- new_data %>% 
  select(SiteID, PredictedName, Ancestry)

write.xlsx(site_name_compare, paste0("results/Projected_SiteName_Comparison_",Sys.Date(),".xlsx"))

