# wormbase

[![Repo status: active](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Travis CI build status](https://travis-ci.com/acidgenomics/wormbase.svg?branch=master)](https://travis-ci.com/acidgenomics/wormbase)
[![AppVeyor CI build status](https://ci.appveyor.com/api/projects/status/8hmhfpsfngn5kcg9/branch/master?svg=true)](https://ci.appveyor.com/project/mjsteinbaugh/wormbase/branch/master)

*Caenorhabditis elegans* genome annotations from [WormBase][].

## Installation

### [R][] method

```r
if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes")
}
Sys.setenv(R_REMOTES_UPGRADE = "always")
# Set `GITHUB_PAT` in `~/.Renviron` if you get a rate limit error.
remotes::install_github("acidgenomics/wormbase")
```

Here's how to update to the latest version on GitHub:

```r
Sys.setenv(R_REMOTES_UPGRADE = "always")
remotes::update_packages()
```

Always check that your Bioconductor installation is valid before proceeding.

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}
BiocManager::valid()
```

[BiocManager]: https://cran.r-project.org/package=BiocManager
[Bioconductor]: https://bioconductor.org/
[R]: https://www.r-project.org/
[WormBase]: http://www.wormbase.org/
