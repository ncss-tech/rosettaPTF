# rosettaPTF 0.1.3

* Fixes for recent changes in {reticulate} (>= 1.29)

  * Add custom `py_to_r()` S3 wrapper for `rosetta.rosetta.SoilData` objects (#8)

* Suppress some output on non-Windows platforms

* Update tests for modern usage of {terra} categorical rasters

# rosettaPTF 0.1.2

* Set minimum R version to 3.5

# rosettaPTF 0.1.1

* Improvements to `find_python()` (now uses user path `python` if defined, and calls `reticulate::use_python()` as needed)

* Changed `.onLoad()` behavior (should reduce amount of custom Python settings needed)

# rosettaPTF 0.1.0
 
* Updated unit tests to skip if required Python modules are not installed

# rosettaPTF 0.0.0.9005

* Fixes for `find_python()` heuristics

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
