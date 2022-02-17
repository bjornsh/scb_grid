#---------------------------------------------------------------------------------------------------
# clean
#---------------------------------------------------------------------------------------------------
rm(list = ls())
invisible(gc())

# Peter testar att lägga till en meningslös rad text i Björns skript, ta gärna bort denna

#---------------------------------------------------------------------------------------------------
# Libraries
#---------------------------------------------------------------------------------------------------

library(jsonlite)
library(dplyr)
library(sf)
library(sp)
library(mapview)

#---------------------------------------------------------------------------------------------------
# Fetch exempel data
#---------------------------------------------------------------------------------------------------

# create directory to store data
dir.create("data")

#### SCB befolkningsdata för 1km2 rutor (4.6 MB)
download.file("https://www.scb.se/contentassets/790b7863da264730b626e4289dcb15a5/grid1km_totpop_20181231.zip",
              destfile= "data/grid.zip")

unzip("data/grid.zip", exdir="data", overwrite=TRUE)

filenames <- list.files(path="data",pattern="*shp")

scb = st_read(paste0("data/", filenames), 
              options = "ENCODING=WINDOWS-1252")

# 50% of grid diameter to be added to corner coordinates to create center coordinates 
dist_to_center = unique(scb$Rutstorl)/2

# create grid center coordinates from grid ID (bottom left corner + grid diameter in x and y direction
scb = scb %>%
  as.data.frame() %>%
  dplyr::select(Ruta, Pop) %>%  
  mutate(x_center = as.numeric(substr(Ruta, 1, 6)) + dist_to_center,   
         y_center = as.numeric(substr(Ruta, 7, 13)) + dist_to_center)

xy = scb[,c("x_center", "y_center")]

spdf <- SpatialPointsDataFrame(coords = xy, data = scb) # create spatial points

spdf1 = st_as_sf(spdf) %>% # convert to sf object
  st_set_crs(3006) # SCB data comes in Sweref 99TM

# View grid in map
mapview(spdf1)

