## code to prepare `MUKEY_PROP` dataset goes here
library(soilDB)
data("MUKEY_WCS", package = "rosettaPTF")
varnames <- c("sandtotal_r", "silttotal_r", "claytotal_r", "dbthirdbar_r")
MUKEY_PROP <- soilDB::get_SDA_property(property = varnames,
                                       method = "Dominant Component (numeric)",
                                       mukeys = na.omit(unique(as.numeric(MUKEY_WCS))))
usethis::use_data(MUKEY_PROP, overwrite = TRUE)
