<!-- badges: start -->
[![R-CMD-check](https://github.com/ncss-tech/rosettaPTF/workflows/R-CMD-check/badge.svg)](https://github.com/ncss-tech/rosettaPTF/actions)
<!-- badges: end -->

# rosettaPTF

An R package using {reticulate} to wrap the Python [rosetta-soil](https://github.com/usda-ars-ussl/rosetta-soil) module.

```{r}
library(rosettaPTF)
```

## Install Rosetta Module

This method wraps `reticulate::py_install()`. You can set up reticulate to install into a virtual environment or conda environment. The default will be the `"r-reticulate"` virtualenv.

```{r}
install_rosetta()
```

## Batch Rosetta with `run_rosetta()`

```{r}
run_rosetta(list(c(30, 30, 40, 1.5), c(55, 25, 20),  c(55, 25, 20, 1.1)),
            rosetta_version = 3)
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

## Extended output with `Rosetta` S3 class

### Make a _Rosetta_ class instance for running extended output methods

Note that each instance of _Rosetta_ has a fixed version and model code, so if you have heterogeneous input you need to iterate over model code.

```{r}
# defaults are version 3 and model code 3 (4 parameters: sand, silt, clay and bulk density)
my_rosetta <- Rosetta(rosetta_version = 3, model_code = 3)
```

### Standard predictions with `predict()`

```{r}
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

### Extended Artificial Neural Network output with `ann_predict()`

```{r}
ann_predict(my_rosetta, list(c(30, 30, 40, 1.5), c(55, 25, 20, 1.1)))
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
