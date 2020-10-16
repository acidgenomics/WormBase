# WormBase

[![Repo status: active](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Travis CI build status](https://travis-ci.com/acidgenomics/wormbase.svg?branch=master)](https://travis-ci.com/acidgenomics/wormbase)

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

[r]: https://www.r-project.org/
[wormbase]: https://www.wormbase.org/
