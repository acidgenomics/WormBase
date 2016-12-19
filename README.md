worminfo
================

*C. elegans* genome annotations assembled from [WormBase](http://www.wormbase.org), [Ensembl](http://www.ensembl.org/Caenorhabditis_elegans), and [PANTHER](http://pantherdb.org). RNAi clone mapping support for [ORFeome](http://worfdb.dfci.harvard.edu) and [Ahringer](http://www.us.lifesciences.sourcebioscience.com/clone-products/non-mammalian/c-elegans/c-elegans-rnai-library/) libraries.

[![Build Status](https://travis-ci.org/steinbaugh/worminfo.svg?branch=master)](https://travis-ci.org/steinbaugh/worminfo)

Installation
============

This is an [R](https://www.r-project.org) data package.

[`devtools`](https://cran.r-project.org/package=devtools) is required to install the latest version directly from GitHub:

``` r
install.packages("devtools")
devtools::install_github("steinbaugh/worminfo", build_vignettes = TRUE)
```

Instructions on how to use the functions in this package are available as vignettes:

``` r
browseVignettes("worminfo")
```

Build information for the underlying source data used in this package is available at the [data branch](https://github.com/steinbaugh/worminfo/tree/data) of this repository.
