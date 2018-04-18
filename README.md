# wormbase

[![Travis CI](https://travis-ci.org/steinbaugh/wormbase.svg?branch=master)](https://travis-ci.org/steinbaugh/wormbase)
[![AppVeyor CI](https://ci.appveyor.com/api/projects/status/8hmhfpsfngn5kcg9/branch/master?svg=true)](https://ci.appveyor.com/project/mjsteinbaugh/wormbase/branch/master)
[![Codecov](https://codecov.io/gh/steinbaugh/wormbase/branch/master/graph/badge.svg)](https://codecov.io/gh/steinbaugh/wormbase)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

*C. elegans* genome annotations from [WormBase][].


## Installation

This is an [R][] package.

### [Bioconductor][] method

```r
source("https://bioconductor.org/biocLite.R")
biocLite("devtools")
biocLite("steinbaugh/wormbase")
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
