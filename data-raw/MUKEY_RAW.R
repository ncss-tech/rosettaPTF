## code to prepare internal `MUKEY_WCS` dataset goes here
library(soilDB)
MUKEY_WCS <- as.matrix(soilDB::mukey.wcs(aoi = list(aoi=c(-114.16, 47.65, -114.08, 47.68),
                                                    crs='+init=epsg:4326'), quiet = TRUE))
usethis::use_data(MUKEY_WCS, overwrite = TRUE)

