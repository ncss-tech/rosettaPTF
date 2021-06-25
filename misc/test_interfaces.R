library(reticulate)
library(rosettaPTF)

ARCPY_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3"
PYEXE_PATH <- file.path(ARCPY_PATH, "python.exe")
CONDA_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/Scripts/conda.exe"

reticulate::use_python(PYEXE_PATH, required = TRUE)
reticulate::use_condaenv(ARCPY_PATH)
options(reticulate.conda_binary = CONDA_PATH)

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
                            mukeys = unique(values(res$gNATSGO.map.unit.keys)))
soildata <- resprop[complete.cases(resprop), c("mukey", varnames)]
resrose <- run_rosetta(soildata[,varnames])
resrose$mukey <- soildata$mukey
levels(res) <- merge(levels(res)[[1]], resprop, by.x = "ID", by.y = "mukey", all.x = TRUE)
levels(res) <- merge(levels(res)[[1]], resrose, by.x = "ID", by.y = "mukey", all.x = TRUE)
plot(res, "log10_Ksat_mean")

# working with a raster stack (use case for each cell has "unique" values)
resstack <- stack(
  deratify(res, "sandtotal_r"),
  deratify(res, "silttotal_r"),
  deratify(res, "claytotal_r"),
  deratify(res, "dbthirdbar_r")
)

# rasterstack to data.frame interface (one call on all cells)
test2 <- run_rosetta(resstack)
plot(test2, "log10_Ksat_mean")
