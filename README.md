worminfo
================
Michael J. Steinbaugh
2016-11-29

<!-- README.md is generated from README.Rmd. Please edit that file -->
*C. elegans* genome annotations assembled from [WormBase](http://www.wormbase.org), [Ensembl](http://www.ensembl.org/Caenorhabditis_elegans), and [PANTHER](http://pantherdb.org). RNAi clone mapping support for [ORFeome](http://worfdb.dfci.harvard.edu), [Ahringer](http://www.us.lifesciences.sourcebioscience.com/clone-products/non-mammalian/c-elegans/c-elegans-rnai-library/) and cherrypick libraries.

[![Build Status](https://travis-ci.org/steinbaugh/worminfo.svg?branch=master)](https://travis-ci.org/steinbaugh/worminfo)

Installation
============

This is an [R](https://www.r-project.org) data package. [`devtools`](https://cran.r-project.org/package=devtools) is required to install the latest version directly from GitHub.

To install, run this code in [R](https://www.r-project.org):

``` r
install.packages("devtools")
devtools::install_github("steinbaugh/worminfo", build_vignettes = TRUE)
```

Instructions on how to use the functions in this package are available as vignettes:

``` r
browseVignettes("worminfo")
```

Annotations
===========

-   50983 gene annotations
-   30242 RNAi clones

Compiled from these sources:

-   WormBase WS255
-   Ensembl Genes 86
-   PANTHER 11.0

Built with R version 3.3.2 (2016-10-31) running on x86\_64-apple-darwin13.4.0.
