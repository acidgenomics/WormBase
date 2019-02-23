# wormbase

[![Travis CI](https://travis-ci.org/steinbaugh/wormbase.svg?branch=master)](https://travis-ci.org/steinbaugh/wormbase)
[![AppVeyor CI](https://ci.appveyor.com/api/projects/status/8hmhfpsfngn5kcg9/branch/master?svg=true)](https://ci.appveyor.com/project/mjsteinbaugh/wormbase/branch/master)
[![Codecov](https://codecov.io/gh/steinbaugh/wormbase/branch/master/graph/badge.svg)](https://codecov.io/gh/steinbaugh/wormbase)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

*Caenorhabditis elegans* genome annotations from [WormBase][].

## Installation

This is an [R][] package.

### [Bioconductor][] method

We recommend installing the package with [BiocManager][].

```r
if (!require("BiocManager")) {
    install.packages("BiocManager")
}
BiocManager::install("remotes")
BiocManager::install("steinbaugh/wormbase")
```

[BiocManager]: https://cran.r-project.org/package=BiocManager
[Bioconductor]: https://bioconductor.org/
[R]: https://www.r-project.org/
[WormBase]: http://www.wormbase.org/
