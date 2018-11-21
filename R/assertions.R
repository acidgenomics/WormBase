.assertAllAreGenes <- function(x) {
    assert_is_character(x)
    assert_all_are_matching_regex(
        x = x,
        pattern = paste0("^", genePattern, "$")
    )
    assert_has_no_duplicates(x)
}



.assertFormalVersion <- function(x) {
    assertIsStringOrNULL(x)
    if (is_a_string(x)) {
        .assertIsVersion(x)
    }
}



.assertIsVersion <- function(x) {
    assert_is_a_string(x)
    assert_all_are_matching_regex(x, versionPattern)
}
