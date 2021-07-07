library(rosettaPTF)

# setup for USDA computers using ArcPro Python installation
source("misc/setup_CCE.R")

# convenient and "tidy" interfaces to rosetta

# data.frame interface: using default column order
run_rosetta(data.frame(
  a = 20,
  b = 60,
  c = 20,
  d = c(NA, 1.5)
))

# data.frame interface: using custom column names/order
run_rosetta(data.frame(
  d = c(NA, 1.5),
  b = 60,
  a = 20,
  c = 20
), vars = letters[1:4])

# SDA example interface (calculate rosetta values by mapunit, and use RAT to display)
library(soilDB)
library(raster)
res <- mukey.wcs(aoi = list(aoi=c(-114.16, 47.65, -114.08, 47.68), crs='+init=epsg:4326'))
varnames <- c("sandtotal_r", "silttotal_r", "claytotal_r", "dbthirdbar_r")
resprop <- get_SDA_property(property = varnames,
                            method = "Dominant Component (numeric)",
                            mukeys = unique(terra::values(res$gNATSGO.map.unit.keys)))
soildata <- resprop[complete.cases(resprop), c("mukey", varnames)]
resrose <- run_rosetta(soildata[,varnames])
resrose$mukey <- soildata$mukey
levels(res) <- merge(levels(res)[[1]], resprop, by.x = "ID", by.y = "mukey", all.x = TRUE)
levels(res) <- merge(levels(res)[[1]], resrose, by.x = "ID", by.y = "mukey", all.x = TRUE)
plot(res, "log10_Ksat_mean")

# working with a raster stack
resstack <- stack(lapply(c("sandtotal_r","silttotal_r","claytotal_r","dbthirdbar_r"),
                         function(x) deratify(res, x)))
plot(resstack)

# data.frame v.s. raster interface
smallstack_raster <- raster::crop(resstack, raster::extent(resstack) / 10)
smallstack_terra <- terra::crop(terra::rast(resstack), terra::ext(resstack) / 10)

# convert rasterstack to data.frame, works if it fits in memory
system.time(test1 <- run_rosetta(as.data.frame(smallstack_raster)))
system.time(test1 <- run_rosetta(as.data.frame(smallstack_terra)))

# run calculations in blocks using a temporary file to store output, return a SpatRaster
system.time(test2 <- run_rosetta(smallstack_raster))
system.time(test2 <- run_rosetta(smallstack_terra))

# set a specific block size (smaller calls to run_rosetta)
system.time(test3 <- run_rosetta(smallstack_raster, nrows = 20))
system.time(test3 <- run_rosetta(smallstack_terra, nrows = 20))

plot(test2["log10_Ksat_mean"])

