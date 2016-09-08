library("rgeos")
library("dismo")
library("ggmap")
library("rgdal")

#import shape file (.shp), make sure all the other files in the zip are included in
#your file location!
state_poly <- readOGR(dsn = 'C:/Users/chopp/Documents/R', layer='cb_2015_us_state_500k')

#data containing lng and lat coordinates with radii
data <- read.csv("C:/Users/chopp/Documents/R/radlatlong.csv", header = T)

#create spatial point objects out of your lng and lat data
pts <- SpatialPoints(data[,c("lng","lat")], proj4string = CRS("+proj=longlat"))

#convert spatial points to projected coordinates (points and map lines)
ptsproj <- spTransform(pts, CRS("+init=epsg:3347"))
state_poly_proj<- spTransform(state_poly, CRS("+init=epsg:3347"))

#convert radii units to meters, used in our gBuffer argument later on 
radii <- data$rad*1609.344

#create circular polygons with. byid = TRUE will create a circle for each point
circ <- gBuffer(ptsproj, width = radii, byid = TRUE)

#convert state polygons to state lines    
state_lines<- as(state_poly_proj, "SpatialLines")

#use gIntersects with byid = TRUE to return a matrix where "TRUE" represents 
#crossing state boundaries or water
intdata <- t(gIntersects(circ, state_lines, byid = TRUE))

totaldata <- cbind(data$Campaign,t(intdata))

#write the matrix out into a csv file
write.csv(intdata, "C:/Users/chopp/Documents/R/intercept_data.csv")
