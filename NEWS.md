## wormbase 0.2.10 (2020-01-03)

### Minor changes

- Working example and unit test updates for `description` function, now that
  the corresponding file on the WormBase FTP server is no longer malformed.
  This has been fixed as of WS274.

## wormbase 0.2.9 (2019-08-29)

### Major changes

- Functions now return `DataFrame` instead of `tbl_df`.
- Updated R dependency to 3.6.
- Reworked internal code to use base R / Bioconductor methods, instead of
  tidyverse / dplyr approach.
  
### Minor changes

- Improved documentation and updated basejump dependency versions.

## wormbase 0.2.8 (2019-07-24)

- Updated basejump dependency versions.

## wormbase 0.2.7 (2019-03-26)

- Added support for WS269 release. Functions that parse files from the WormBase
  FTP server had to be modified to ensure only annotations matching N2 gene
  identifiers (e.g. `WBGene`) are returned.
- Removed `dir` argument for all functions that parse files from WormBase FTP
  server. Files now always download to `tempdir` instead.
- Improved internal tidyeval code where applicable, notably inside `mutate`
  calls using `sym` and `:=` [rlang][] functions.

## wormbase 0.2.6 (2019-03-23)

- Migrated code to [Acid Genomics][].

## wormbase 0.2.5 (2019-03-19)

- Reworked progress bar handling via `pbapply::pblapply`. This is now disabled
  for all functions by default, but can be enabled with `progress = TRUE`.
  pbapply package is now declared in "Enhances:" rather than "Imports:".
- Switched all internal assert checks to goalie package from assertive.

## wormbase 0.2.4 (2018-11-21)

- Maintenance release updating the package to require R 3.5.
- Improved documentation for functions and rebuild pkgdown website.
- Added `progress = TRUE` option for functions that can take a long time to
  parse data. Previously, this was always enabled but now can be disabled
  using this `progress = FALSE`. Note that `invisible(capture.output(x))` also
  works to suppress progress bars.

## wormbase 0.2.3 (2018-07-21)

- Fixed `geneID()` function to work with latest WormBase release that now
  returns an extra biotype column.
- Removed internal parallel `mclapply()` calls in favor of `pblapply()` for
  better compatibility across platforms.

## wormbase 0.2.2 (2018-04-23)

- Broke out assertive imports into separate packages: assertive.properties,
  assertive.strings, assertive.types.
- Removed todo comment in `description.R` file.

## wormbase 0.2.1 (2018-04-18)

- Renamed `gene` column to `geneID` where applicable.
- Removed fs package dependency.
- Added progress bars for functions that take a long time to load.

## wormbase 0.2.0 (2018-03-04)

- Renamed package to `wormbase` from `worminfo`.
- Simplified core functionality to simply pull genome annotations from the
  WormBase website into R.
- Previous functionality querying the ENSEMBL, PANTHER, and EggNOG databases
  will be split out into organism-agnostic packages.
- RNAi clone support is being migrated to the rnaiscreen package.

## wormbase 0.1.0 (2018-02-14)

(worminfo): Pre-release using internal build annotations from WormBase, ENSEMBL,
PANTHER, and EggNOG databases. RNAi clone support for ORFeome (WORFDB),
Ahringer, and Ruvkun Lab cherrypick libraries.

## wormbase 0.0.99 (2017-12-06)

(worminfo): Initial pre-release version.

[Acid Genomics]: https://acidgenomics.com/
[rlang]: https://rlang.r-lib.org/
