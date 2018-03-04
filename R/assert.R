#' Assert Checks
#'
#' @rdname assert
#' @name assert
#' @family Assert Checks
#' @keywords internal
#'
#' @importFrom assertive assert_all_are_matching_regex
#' @importFrom assertive assert_has_no_duplicates
#' @importFrom assertive assert_is_a_string
#' @importFrom assertive assert_is_character
#' @importFrom assertive is_a_string
#'
#' @importFrom basejump assertIsAStringOrNULL
NULL



.assertAllAreGenes <- function(x) {
    assert_is_character(x)
    assert_all_are_matching_regex(
        x,
        pattern = paste0("^", genePattern, "$")
    )
    assert_has_no_duplicates(x)
}



.assertFormalVersion <- function(x) {
    assertIsAStringOrNULL(x)
    if (is_a_string(x)) {
        .assertIsVersion(x)
    }
}



.assertIsVersion <- function(x) {
    assert_is_a_string(x)
    assert_all_are_matching_regex(x, versionPattern)
}
