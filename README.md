# WormBase

[![Repo status: active](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Travis CI build status](https://travis-ci.com/acidgenomics/wormbase.svg?branch=master)](https://travis-ci.com/acidgenomics/wormbase)
[![AppVeyor CI build status](https://ci.appveyor.com/api/projects/status/8hmhfpsfngn5kcg9/branch/master?svg=true)](https://ci.appveyor.com/project/mjsteinbaugh/wormbase/branch/master)

*Caenorhabditis elegans* genome annotations from [WormBase][].

## Installation

### [R][] method

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}
install.packages(
    pkgs = "WormBase",
    repos = c(
        "r.acidgenomics.com",
        BiocManager::repositories()
    )
)
```

[R]: https://www.r-project.org/
[WormBase]: http://www.wormbase.org/
