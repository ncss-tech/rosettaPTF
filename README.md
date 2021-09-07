<!-- badges: start -->
[![R-CMD-check](https://github.com/ncss-tech/rosettaPTF/workflows/R-CMD-check/badge.svg)](https://github.com/ncss-tech/rosettaPTF/actions)
[![HTML Docs](https://camo.githubusercontent.com/f7ba98e46ecd14313e0e8a05bec3f92ca125b8f36302a5b1679d4a949bccbe31/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f646f63732d48544d4c2d696e666f726d6174696f6e616c)](https://ncss-tech.github.io/rosettaPTF/docs/)
[![codecov](https://codecov.io/gh/ncss-tech/rosettaPTF/branch/main/graph/badge.svg?token=BYBKW7PKC3)](https://codecov.io/gh/ncss-tech/rosettaPTF)
<!-- badges: end -->

# rosettaPTF

Rosetta is a neural network-based model for predicting unsaturated soil hydraulic parameters from basic soil characterization data. The model predicts parameters for the van Genuchten unsaturated soil hydraulic properties model, using sand, silt, and clay, bulk density and water content. 

The hierarchical ROSETTA model relies on a minimum of 3 soil properties, with increasing (expected) accuracy as additional properties are added:

  *  required, `sand`, `silt`, `clay`: USDA soil texture separates (percentages) that sum to 100%

  *  optional, `bulk density (any moisture basis)`: mass per volume after accounting for >2mm fragments, units of grams/cm3

  *  optional, `volumetric water content at 33 kPa`: roughly “field capacity” for most soils, units of cm3/cm3

  *  optional, `volumetric water content at 1500 kPa`: roughly “permanent wilting point” for most plants, units of cm3/cm3


## Backend

The [rosetta-soil](https://github.com/usda-ars-ussl/rosetta-soil) module is a Python package maintained by Dr. Todd Skaggs (USDA-ARS) and other U.S. Department of Agriculture employees. 

## Frontend (rosettaPTF)

rosettaPTF uses {reticulate} to wrap the Python rosetta-soil pedotransfer functions and provide them in an R environment. 

This R package is intended to provide for use cases that involve many thousands of calls to the pedotransfer function. High-throughput access to the pedotransfer functions is possible using RasterStack (raster) or SpatRaster (terra) objects in the R environment. 

### Other options

Less demanding use cases are encouraged to use the web interface or API endpoint. There are additional wrappers of the API endpoints provided by the soilDB R package `ROSETTA()` method. For small amounts of data consider using the interactive version that has copy/paste functionality: https://www.handbook60.org/rosetta. 

## Set up {reticulate}

If you are using this package for the first time you will need to have Python installed and download the necessary modules. You can set up {reticulate} to install into a virtual or Conda environment. {reticulate} offers `reticulate::install_python()` and `reticulate::install_miniconda()` to download and set up an up-to-date Python/Conda environment. 

```r
rosettaPTF::find_python()
```

`find_python()` provides heuristics for setting up {reticulate} to use Python in commonly installed locations. The {rosettaPTF} does custom handling for ArcGIS Pro Conda environments. If the automatic configuration fails you can set `Sys.setenv(RETICULATE_PYTHON = "path/to/python")` for {reticulate}.

### Using Existing Python Installations

When calling `find_python()` you can optionally specify the `arcpy_path` argument or the `rosettaPTF.arcpy_path` option to use path to ArcGIS Pro Python/Conda environment, for example:

```r
rosettaPTF::find_python(arcpy_path = "C:/Program Files/ArcGIS/Pro/bin/Python")
```

This should locate both the ArcGIS Pro Conda environment and Python binaries in "C:/Program Files/ArcGIS/Pro/bin/Python".

## Install `rosetta-soil` Python Module

The {rosettaPTF} `install_rosetta()` method wraps `reticulate::py_install("rosetta-soil")`. 

By installing the R package you should have `rosetta-soil` installed as it is set as a {reticulate}/Python dependency in the DESCRIPTION file.

```r
rosettaPTF::install_rosetta()
```

You can use `install_rosetta()` to install into custom environments as needed by specifying `envname`. After installing a new version of the module you may need to restart your R session before continuing.

## Batch Rosetta with `run_rosetta()`

First, load the `rosetta-soil` module by loading the R package.

```r
library(rosettaPTF)
```

Batch runs using `list`, `data.frame`, `matrix`, `RasterStack`, `RasterBrick` and `SpatRaster` inputs are supported. 

The default order of inputs is: sand, silt, clay, bulk density (any basis), water content (field capacity; 33 kPa), water content (permanent wilting point; 1500 kPa); of which the first three are required. If you specify field capacity water content, you must specify bulk density. If you specify permanent wilting point water content you must also specify bulk density and field capacity water content.

### `list()` Input Example

```r
run_rosetta(list(c(30, 30, 40, 1.5), c(55, 25, 20),  c(55, 25, 20, 1.1)),
            rosetta_version = 3)
```

```
#>   id model_code theta_r_mean theta_s_mean log10_alpha_mean log10_npar_mean
#> 1  1          3   0.11535773    0.4179120        -2.067139       0.1120102
#> 2  2          2   0.08613275    0.3888528        -1.898150       0.1347136
#> 3  3          3   0.09130753    0.4850320        -2.022388       0.1510716
#>   log10_Ksat_mean  theta_r_sd  theta_s_sd log10_alpha_sd log10_npar_sd
#> 1       0.8325407 0.013350113 0.009377977     0.08251142    0.01323413
#> 2       1.1858005 0.006014445 0.006273536     0.07481303    0.01160419
#> 3       1.9060148 0.012771407 0.013062171     0.10020312    0.01763982
#>   log10_Ksat_sd
#> 1    0.09245277
#> 2    0.08428578
#> 3    0.14163567
```

Output `model_code` reflects the number of parameters in the input. 

### `data.frame()` Input Example

The `data.frame` interface allows for using using custom column names and order. If the `vars` argument is not specified it is assumed that the columns are in the order specified in the `run_rosetta()` manual page.

```r
run_rosetta(data.frame(
  d = c(NA, 1.5),
  b = 60,
  a = 20,
  c = 20
), vars = letters[1:4])
```

```
#>   id model_code theta_r_mean theta_s_mean log10_alpha_mean log10_npar_mean
#> 1  1          2   0.08994502    0.4301366        -2.426236       0.1756873
#> 2  2          3   0.08495731    0.3887858        -2.318826       0.1598879
#>   log10_Ksat_mean  theta_r_sd  theta_s_sd log10_alpha_sd log10_npar_sd
#> 1       1.1927311 0.006707593 0.008785824     0.07413139    0.01323068
#> 2       0.9961317 0.010184683 0.008100061     0.07976954    0.01753829
#>   log10_Ksat_sd
#> 1    0.08709446
```

### Soil Data Access / SSURGO Mapunit Aggregate Input Example

This example pulls mapunit/component data from Soil Data Access (SDA). We use the {soilDB} function `get_SDA_property()` to obtain representative values for sand, silt, clay, and bulk density (1/3 bar), we run Rosetta on the resulting data.frame (one row per mapunit) then use raster attribute table (RAT) to display the results (1:1 with `mukey`).

```r
library(soilDB)
library(raster)

# obtain mukey map from SoilWeb Web Coverage Service (800m resolution SSURGO derived)
res <- mukey.wcs(aoi = list(aoi = c(-114.16, 47.65,-114.08, 47.68), crs = 'EPSG:4326'))

# request input data from SDA
varnames <- c("sandtotal_r", "silttotal_r", "claytotal_r", "dbthirdbar_r")
resprop <- get_SDA_property(property = varnames,
                            method = "Dominant Component (numeric)",
                            mukeys = unique(values(res$gNATSGO.map.unit.keys)))

# keep only those where we have a complete set of 4 parameters (sand, silt, clay, bulk density; model code #3)
soildata <- resprop[complete.cases(resprop), c("mukey", varnames)]

# run Rosetta on the mapunit-level aggregate data
resrose <- run_rosetta(soildata[,varnames])
resrose$mukey <- soildata$mukey

# merge property (input) and rosetta parameters (output) into RAT
levels(res) <- merge(levels(res)[[1]], resprop, by.x = "ID", by.y = "mukey", all.x = TRUE)
levels(res) <- merge(levels(res)[[1]], resrose, by.x = "ID", by.y = "mukey", all.x = TRUE)

# make a plot of the predicted Ksat
plot(res, "log10_Ksat_mean")
```

![](https://i.imgur.com/Kop8y2t.png)

### _RasterStack_ Input Example

The above example shows how to create raster output based on _discrete_ (SSURGO polygon derived) data. A more general case is when each raster cell has "unique" values (i.e. _continuous_ raster inputs). `run_rosetta()` has an S3 method defined for _RasterStack_ input.

We previously merged the input data from SDA (an ordinary _data.frame_) into the RAT of `res`; exploiting the linkage between `mukey` and raster cells to make the map. For comparison with the `mukey` results above we stack de-ratified input layers and create a new _RasterStack_.

```r
resstack <- stack(
  deratify(res, "sandtotal_r"),
  deratify(res, "silttotal_r"),
  deratify(res, "claytotal_r"),
  deratify(res, "dbthirdbar_r")
)

# RasterStack to data.frame interface (one call on all cells)
test2 <- run_rosetta(resstack)

# make a plot of the predicted Ksat (identical to mukey-based results)
plot(test2, "log10_Ksat_mean")
```

![](https://i.imgur.com/BswebdW.png)

You will notice the results for Ksat distrbution are identical, but the latter approach takes significantly longer to run. This is the difference of estimating ~40 (mapunit keys) versus ~30,000 (total number of cells) sets of Rosetta parameters.

## Extended Output with `Rosetta` S3 Class

### Make a _Rosetta_ class instance for running extended output methods

Note that each instance of _Rosetta_ has a fixed version and model code, so if you have heterogeneous input you need to iterate over model code.

```r
# defaults are version 3 and model code 3 (4 parameters: sand, silt, clay and bulk density)
my_rosetta <- Rosetta(rosetta_version = 3, model_code = 3)
```

### `predict()` Rosetta Parameter Values and Standard Deviations from a _Rosetta_ instance

```r
predict(my_rosetta, list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
#> [[1]]
#>            [,1]     [,2]      [,3]      [,4]      [,5]
#> [1,] 0.11535773 0.417912 -2.067139 0.1120102 0.8325407
#> [2,] 0.09130753 0.485032 -2.022388 0.1510716 1.9060148
#> 
#> [[2]]
#>            [,1]        [,2]       [,3]       [,4]       [,5]
#> [1,] 0.01335011 0.009377977 0.08251142 0.01323413 0.09245277
#> [2,] 0.01277141 0.013062171 0.10020312 0.01763982 0.14163567
```

### Extended _Rosetta_ Predictions, Parameter Distributions and Summary Statistics after Zhang & Schaap (2017) with `ann_predict()`

```r
ann_predict(my_rosetta, list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
```

```
#> $var_names
#> $var_names[[1]]
#> b'theta_r'
#> 
#> $var_names[[2]]
#> b'theta_s'
#> 
#> $var_names[[3]]
#> b'alpha'
#> 
#> $var_names[[4]]
#> b'npar'
#> 
#> $var_names[[5]]
#> b'ks'
#> 
#> 
#> $sum_res_mean
#>            [,1]        [,2]
#> [1,]  0.1153577  0.09130753
#> [2,]  0.4179120  0.48503196
#> [3,] -2.0671385 -2.02238809
#> [4,]  0.1120102  0.15107161
#> [5,]  0.8325407  1.90601478
#> 
#> $sum_res_std
#>             [,1]       [,2]
#> [1,] 0.013350113 0.01277141
#> [2,] 0.009377977 0.01306217
#> [3,] 0.082511421 0.10020312
#> [4,] 0.013234131 0.01763982
#> [5,] 0.092452769 0.14163567
#> 
#> $sum_res_cov
#> , , 1
#> 
#>              [,1]         [,2]          [,3]          [,4]         [,5]
#> [1,] 1.782255e-04 3.719987e-05  5.300747e-05  2.278859e-05 5.965812e-05
#> [2,] 3.719987e-05 8.794645e-05  2.570007e-04  3.632187e-06 2.662337e-04
#> [3,] 5.300747e-05 2.570007e-04  6.808135e-03 -3.601399e-04 1.347519e-03
#> [4,] 2.278859e-05 3.632187e-06 -3.601399e-04  1.751422e-04 8.973559e-05
#> [5,] 5.965812e-05 2.662337e-04  1.347519e-03  8.973559e-05 8.547515e-03
#> 
#> , , 2
#> 
#>               [,1]          [,2]          [,3]          [,4]          [,5]
#> [1,]  1.631088e-04  2.342660e-05  2.087559e-05 -9.477980e-06 -0.0003382175
#> [2,]  2.342660e-05  1.706203e-04  3.156961e-04 -4.577936e-05  0.0005664825
#> [3,]  2.087559e-05  3.156961e-04  1.004067e-02 -7.685234e-04  0.0012668368
#> [4,] -9.477980e-06 -4.577936e-05 -7.685234e-04  3.111634e-04  0.0001828960
#> [5,] -3.382175e-04  5.664825e-04  1.266837e-03  1.828960e-04  0.0200606627
#> 
#> 
#> $sum_res_skew
#>             [,1]        [,2]
#> [1,] -4.52570431 -2.33577302
#> [2,] -0.01729594 -0.22228088
#> [3,] -0.18215435 -0.25961263
#> [4,] -0.15345973  0.04145318
#> [5,] -0.20386127 -0.35765020
#> 
#> $sum_res_kurt
#>            [,1]        [,2]
#> [1,] 36.6873026 16.85229297
#> [2,]  0.5975976  0.02966211
#> [3,]  0.3016512  0.11663125
#> [4,]  0.1342581  0.26557316
#> [5,]  0.3127817  0.54242091
#> 
#> $sum_res_bool
#>      [,1] [,2]
#> [1,] TRUE TRUE
#> [2,] TRUE TRUE
#> [3,] TRUE TRUE
#> [4,] TRUE TRUE
#> [5,] TRUE TRUE
#> 
#> $nsamp
#> [1] 2
#> 
#> $nout
#> [1] 5
#> 
#> $nin
#> [1] 4
```

## Selected References

Three versions of the ROSETTA model are available, selected using `rosetta_version` argument.

  - `rosetta_version` 1 - Schaap, M.G., F.J. Leij, and M.Th. van Genuchten. 2001. ROSETTA: a computer program for estimating soil hydraulic parameters with hierarchical pedotransfer functions. Journal of Hydrology 251(3-4): 163-176. doi: 10.1016/S0022-1694(01)00466-8.

  - `rosetta_version` 2 - Schaap, M.G., A. Nemes, and M.T. van Genuchten. 2004. Comparison of Models for Indirect Estimation of Water Retention and Available Water in Surface Soils. Vadose Zone Journal 3(4): 1455-1463. doi: 10.2136/vzj2004.1455.

  - `rosetta_version` 3 - Zhang, Y., and M.G. Schaap. 2017. Weighted recalibration of the Rosetta pedotransfer model with improved estimates of hydraulic parameter distributions and summary statistics (Rosetta3). Journal of Hydrology 547: 39-53. doi: 10.1016/j.jhydrol.2017.01.004.

