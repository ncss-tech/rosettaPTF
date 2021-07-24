# rosettaPTF 0.0.0.9004

* Clarified virtual and Conda environments for {reticulate} setup in function documentation and README
  * Add `find_python()` helper method
    * This method is called when you load the package with `library(rosettaPTF)` AND in individual calls to `rosettaPTF::install_rosetta()`
    * Sets the package option `rosettaPTF.python_path` and returns the value
* `run_rosetta()` 
  * Pass through variable order (`vars`) and parallel/block processing arguments (`core`, `file`, `nrows`, `overwrite`) to SpatRaster method for Raster* objects

# rosettaPTF 0.0.0.9003

* Use {terra} internally for raster data inputs and outputs
* Add S3 `run_rosetta()` methods for `matrix`, `RasterBrick` and `SpatRaster`

# rosettaPTF 0.0.0.9002

* Add S3 `run_rosetta()` methods for `data.frame` and `RasterStack`  

# rosettaPTF 0.0.0.9001

* Initial R package
* Use {reticulate} to handle install of Python modules: `rosetta-soil`, `numpy`
* Provide `list`-input interface; directly coercible to Python data structures used for `run_rosetta()`
