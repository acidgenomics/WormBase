# wormbase

[![Build Status](https://travis-ci.org/steinbaugh/wormbase.svg?branch=master)](https://travis-ci.org/steinbaugh/wormbase)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![codecov](https://codecov.io/gh/steinbaugh/wormbase/branch/master/graph/badge.svg)](https://codecov.io/gh/steinbaugh/wormbase)

*C. elegans* genome annotations from [WormBase][].


## Installation

This is an [R][] package.

### [Bioconductor][] method

```r
source("https://bioconductor.org/biocLite.R")
biocLite(
    "steinbaugh/wormbase",
    dependencies = c("Depends", "Imports", "Suggests")
)
```


## Usage

Tutorials and code examples are available as a vignette.

```r
browseVignettes("wormbase")
```


[Bioconductor]: https://bioconductor.org
[devtools]: https://cran.r-project.org/package=devtools
[R]: https://www.r-project.org
[WormBase]: http://www.wormbase.org
