validate_query <- function(query) {
  if(is.null(query)) stop("Query cannot be empty", call. = F)
  if (identical(query, "")) stop("Query cannot be empty", call. = F)
  if (typeof(query) != "character") stop("Query must be a string", call. = F)
  query <- enc2utf8(query)
  return(query)
}

allowed_sources <- names(dimensions_schema$sources)
