# helper methods so reticulate can find the ArcPro conda binary (or any other custom PATH)
get_conda <- function() { 
  getOption("reticulate.conda_binary") 
} 

set_conda <- function(x = "C:/Program Files/ArcGIS/Pro/bin/Python/Scripts/conda.exe") {
  options(reticulate.conda_binary = x)
}

set_conda()
get_conda()

# load reticulate
library(reticulate)

# list conda environments
conda_list()

conda_install(packages = "scipy")

# create a new environment 
# "C:/Program Files (x86)/PYTHON27/ArcGISx6410.7/python.exe" -m pip install --upgrade --user virtualenv
virtualenv_create("r-reticulate")

# install SciPy
virtualenv_install("r-reticulate", "scipy")

# import SciPy (it will be automatically discovered in "r-reticulate")
scipy <- import("scipy")

# install rosetta-soil into local reticulate env (envname = NULL)
# e.g. C:\Users\Andrew.G.Brown\AppData\Local\ESRI\conda\envs\r-reticulate
conda_install(packages = "rosetta-soil")

# several dependencies fail to install:
# OSError(22, 'This program is blocked by group policy. For more information, contact your system administrator', None, 1260, None)

# fails to find right python executable?
# reticulate::py_install("rosetta-soil")
