# Validate query strings
validate_query <- function(query) {

  # Cannot be empty
  if(is.null(query) | identical(query, "")) {
    stop("Query cannot be empty", call. = F)
  }

  # Must be a character string
  if (typeof(query) != "character") {
    stop("Query must be a string", call. = F)
  }

  # UTF8 encode string
  query <- enc2utf8(query)

  return(query)
}
