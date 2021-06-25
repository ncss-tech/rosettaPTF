library(reticulate)
library(rosettaPTF)

ARCPY_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3"
PYEXE_PATH <- file.path(ARCPY_PATH, "python.exe")
CONDA_PATH <- "C:/Program Files/ArcGIS/Pro/bin/Python/Scripts/conda.exe"

reticulate::use_python(PYEXE_PATH, required = TRUE)
reticulate::use_condaenv(ARCPY_PATH)
options(reticulate.conda_binary = CONDA_PATH)

# install rosetta if needed
if (!rosettaPTF::rosetta_module_available())
  install_rosetta(pip = TRUE)

rose <- get_rosetta_module()

run_rosetta(list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
#>   id model_code theta_r_mean theta_s_mean log10_alpha_mean log10_npar_mean
#> 1  1          3   0.11535773     0.417912        -2.067139       0.1120102
#> 2  2          3   0.09130753     0.485032        -2.022388       0.1510716
#>   log10_Ksat_mean theta_r_sd  theta_s_sd log10_alpha_sd log10_npar_sd
#> 1       0.8325407 0.01335011 0.009377977     0.08251142    0.01323413
#> 2       1.9060148 0.01277141 0.013062171     0.10020312    0.01763982
#>   log10_Ksat_sd
#> 1    0.09245277
#> 2    0.14163567

predict(Rosetta(), list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
#> [[1]]
#>            [,1]     [,2]      [,3]      [,4]      [,5]
#> [1,] 0.11535773 0.417912 -2.067139 0.1120102 0.8325407
#> [2,] 0.09130753 0.485032 -2.022388 0.1510716 1.9060148
#>
#> [[2]]
#>            [,1]        [,2]       [,3]       [,4]       [,5]
#> [1,] 0.01335011 0.009377977 0.08251142 0.01323413 0.09245277
#> [2,] 0.01277141 0.013062171 0.10020312 0.01763982 0.14163567
#



