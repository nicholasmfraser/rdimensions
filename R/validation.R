# Validate query strings
validate <- function(query, format) {
  check_query(query)
  check_format(format)
  return(query)
}

check_query <- function(query) {
  # Cannot be empty
  if (is.null(query) | identical(query, "")) {
    stop("Query cannot be empty", call. = FALSE)
  }
  # Must be a character string
  if (typeof(query) != "character") {
    stop("Query must be a string", call. = FALSE)
  }
  # Must be UTF-8 encoded {
  if (!validUTF8(query)) {
    stop("Query must be UTF-8 encoded", call. = FALSE)
  }
}

check_format <- function(format) {
  # Must be either empty, or one of "list" or "json"
  if (!is.null(format)) {
    if (!format %in% c("list", "json")) {
      stop("'format' must be one of 'list' or 'json'", call. = FALSE)
    }
  }
}
