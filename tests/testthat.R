library(testthat)

# rosettaPTF.arcpy_path Path to ArcGIS Pro Python installation
# Default: `"C:/Program Files/ArcGIS/Pro/bin/Python"`.
# Set as `NULL` to prevent use of ArcGIS Pro instance.
options(rosettaPTF.arcpy_path = "C:/Program Files/ArcGIS/Pro/bin/Python")

library(rosettaPTF)

test_check("rosettaPTF")

