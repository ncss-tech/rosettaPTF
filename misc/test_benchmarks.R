# benchmarks
library(rosettaPTF)

# setup for USDA computers using ArcPro Python installation
source("misc/setup_CCE.R")

data("MUKEY_PROP", package = "rosettaPTF")
idx <- sample(1:nrow(MUKEY_PROP), replace = TRUE, size = 1000)
bench::mark(run_rosetta(MUKEY_PROP[idx,grep("total|db", colnames(MUKEY_PROP))]))
# 1s
idx <- sample(1:nrow(MUKEY_PROP), replace = TRUE, size = 10000)
bench::mark(run_rosetta(MUKEY_PROP[idx,grep("total|db", colnames(MUKEY_PROP))]))
# 10s
idx <- sample(1:nrow(MUKEY_PROP), replace = TRUE, size = 10000)
bench::mark(run_rosetta(MUKEY_PROP[idx,grep("total|db", colnames(MUKEY_PROP))]))
# 20s
idx <- sample(1:nrow(MUKEY_PROP), replace = TRUE, size = 50000)
bench::mark(run_rosetta(MUKEY_PROP[idx,grep("total|db", colnames(MUKEY_PROP))]))
# 58s
idx <- sample(1:nrow(MUKEY_PROP), replace = TRUE, size = 100000)
bench::mark(run_rosetta(MUKEY_PROP[idx,grep("total|db", colnames(MUKEY_PROP))]))
# 118s
