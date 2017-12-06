# worminfo

[![Build Status](https://travis-ci.org/steinbaugh/worminfo.svg?branch=master)](https://travis-ci.org/steinbaugh/worminfo)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![codecov](https://codecov.io/gh/steinbaugh/worminfo/branch/master/graph/badge.svg)](https://codecov.io/gh/steinbaugh/worminfo)

*C. elegans* gene annotations and RNAi clone mappings.

Gene annotation databases: [WormBase][], [Ensembl][], [PANTHER][], and [EggNOG][].

RNAi clones: [Worm ORFeome](http://worfdb.dfci.harvard.edu), [Ahringer](http://www.us.lifesciences.sourcebioscience.com/clone-products/non-mammalian/c-elegans/c-elegans-rnai-library/), and [Ruvkun Lab][] cherrypick libraries.


## Installation

This is an [R][] package.

### [Bioconductor][] method

```r
source("https://bioconductor.org/biocLite.R")
biocLite(
    "steinbaugh/worminfo",
    dependencies = c("Depends", "Imports", "Suggests")
)
```


## Usage

Tutorials and code examples are available as a vignette.

```r
browseVignettes("worminfo")
```


[Bioconductor]: https://bioconductor.org
[devtools]: https://cran.r-project.org/package=devtools
[EggNOG]: http://eggnogdb.embl.de
[Ensembl]: http://www.ensembl.org/Caenorhabditis_elegans
[PANTHER]: http://pantherdb.org
[R]: https://www.r-project.org
[Ruvkun Lab]: https://molbio.mgh.harvard.edu/laboratories/ruvkun
[WormBase]: http://www.wormbase.org
