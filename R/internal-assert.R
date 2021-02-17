## Updated 2019-07-24.
.allAreGenes <- function(x) {
    ok <- isCharacter(x)
    if (!isTRUE(ok)) return(FALSE)
    ok <- allAreMatchingRegex(
        x = x,
        pattern = paste0("^", .genePattern, "$")
    )
    if (!isTRUE(ok)) return(FALSE)
    ok <- hasNoDuplicates(x)
    if (!isTRUE(ok)) return(FALSE)
    TRUE
}



## Updated 2021-02-17.
.isVersion <- function(x) {
    if (is.null(x)) return(TRUE)
    ok <- isString(x)
    if (!isTRUE(ok)) return(FALSE)
    ok <- allAreMatchingRegex(x, pattern = "^WS\\d{3}$")
    if (!isTRUE(ok)) return(FALSE)
    TRUE
}
