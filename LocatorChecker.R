## setting directory to this source file
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
## silence loading warning for sp/rgdal
"rgdal_show_exportToProj4_warnings"="none"

library(sf)
library(sp)
library(rgdal)

# read in shape file
shapefile_pasture<- rgdal::readOGR(dsn="E:/VGS - Deathstar II/GIS II/S_USA.Pasture", "S_USA.Pasture")
pasture<- as.data.frame(shapefile_pasture)

#View(allotment)
#View(pasture)

# create a sample point / check sampling point
point <- data.frame(lat = 31.36, lon = -111.06)
coordinates(point) <- c("lon", "lat")

#proj4string(point) <- proj4string(shapefile_allotment)
# find what row the point falls in
#allotment_result <- over(point, shapefile_allotment)

proj4string(point) <- proj4string(shapefile_pasture)
# find what row the point falls in
pasture_result <- over(point, shapefile_pasture)

View(pasture_result)
