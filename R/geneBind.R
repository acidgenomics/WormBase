#' Bind gene annotations to input data.frame
#'
#' @param df data.frame with identifier column.
#' @param ... Optional parameters for `gene` function.
#'
#' @return data.frame cbind with metadata
#' @export
geneBind <- function(df, ...) {
  vec <- df[, id]
  df <- cbind(df, gene(vec, ...))
  df <- df[, unique(names(df))]
  return(df)
}
