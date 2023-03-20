# WormBase

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
        "https://r.acidgenomics.com",
        BiocManager::repositories()
    ),
    dependencies = TRUE
)
```

### [Docker][] method

```sh
image='acidgenomics/r-packages:wormbase'
workdir='/mnt/work'
docker pull "$image"
docker run -it \
    --volume="${PWD}:${workdir}" \
    --workdir="$workdir" \
    "$image" \
    R
```

[docker]: https://www.docker.com/
[r]: https://www.r-project.org/
[wormbase]: https://wormbase.org/
