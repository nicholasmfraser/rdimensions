#' Make a raw query request to the Dimensions Analytics API
#'
#' @param query (character) String containing a raw Dimensions Search Language
#' query.
#' @param format (character) The format in which data should be returned. One of
#' "list" or "json"
#' @examples
#' # The most basic query: search and return all publications
#' dimensions_raw(query = "search publications return publications")
#'
#' # Dimensions automatically limits results to 20 records. Add a "limit" clause
#' to increase the number of returned results
#' dimensions_raw(query = "search publications return publications limit 100")
#'
#' # Search for a specific DOI. Note that quotation marks surrounding DOIs must
#' be escaped by placing a backwards slash (\) in front of the quotation marks.
#' You may find the `paste0` function helpful to build longer query strings.
#' dimensions_raw(query = paste0("search publications",
#'                               "where doi = \"10.3389/frma.2018.00023\"",
#'                               "return publications")
#'
#' A full overview of query syntax can be found in the [Dimensions Search
#' Language](https://docs.dimensions.ai/dsl/) documentation.
dimensions_raw <- function(query = NULL, format = "list") {

  # Validate query string
  query <- validate_query_string(query)

  # Retrieve Dimensions token
  token <- get_dimensions_token()

  # Submit query
  response <- httr::POST('https://app.dimensions.ai/api/dsl.json',
                          body = query,
                          httr::add_headers("Authorization" = paste0("JWT ",
                                                                     token)))

  # Retrieve content
  content <- httr::content(response, as="parsed")

  if (format == "list") {
    data <- content
  } else if (format == "json") {
    data <- jsonlite::toJSON(content)
  } else {
    stop("'format' must be one of 'list' or 'json'")
  }
  return(data)
}

validate_query_string <- function(query) {
  if (identical(query, "")) stop("'query' cannot be empty", call. = F)
  if (typeof(query) != "character") stop("'query' must be a string", call. = F)
  query <- enc2utf8(query)
  return(query)
}
