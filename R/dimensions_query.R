#' Make a raw query request to the Dimensions Analytics API
#'
#'
#' @export
#'
#' @param query (character) String containing a raw Dimensions Search Language
#' query.
#' @param format (character) The format in which data should be returned. One of
#' "list" or "json"
#' @examples
#' # The most basic query: search and return all publications
#' dimensions_query(query = "search publications return publications")
#'
#' # Return results in JSON format
#' dimensions_query(query = "search publications return publications",
#' format = "json")
#'
#' # Dimensions automatically limits results to 20 records. Add a "limit" clause
#' to increase the number of returned results
#' dimensions_query(query = "search publications return publications limit 100")
#'
#' # Search for a specific DOI. Note that quotation marks surrounding DOIs must
#' be escaped by placing a backwards slash (\) in front of the quotation marks.
#' You may find the `paste` and `paste0` functions helpful to build longer query
#' strings.
#' query <- paste0("search publications",
#'                               "where doi = \"10.3389/frma.2018.00023\"",
#'                               "return publications")
#' dimensions_query(query = query)
#'
#'
#'
#' A full overview of query syntax can be found in the [Dimensions Search
#' Language](https://docs.dimensions.ai/dsl/) documentation.
dimensions_query <- function(query = NULL, format = "list") {

  # Retrieve Dimensions token
  token <- fetch_token()

  # Validate query string
  query <- validate_query(query)

  # Submit query
  data <- do_query(query, token, retry = 0)

  if (format == "list") {
    return(data)
  } else if (format == "json") {
    return(jsonlite::toJSON(data))
  } else {
    stop("'format' must be one of 'list' or 'json'")
  }
}

do_query <- function(query, token, retry) {

  # Make request
  r <- httr::POST("https://app.dimensions.ai/api/dsl.json",
                  body = query,
                  httr::add_headers("Authorization" = paste0("JWT ", token)))

  # Handle responses
  if (r$status_code == 403) {
    message("403 Forbidden: Login token expired. Refreshing login token and trying again...")
    token <- refresh_token()
    do_query(query, token, retry)
  } else if (r$status_code == 429) {
    message("429 Too many requests. Sleeping for 30 seconds then retrying...")
    sys.sleep(30)
    do_query(query, token, retry)
  } else if (r$status_code %in% c(200, 400, 500)) {
    body <- httr::content(r, as="parsed")
    if(!is.null(body$errors)) {
      stop(paste0(gsub("[\r\n]", "", body$errors$query$header), ": ",
                  gsub("[\r\n]", "", body$errors$query$details)),
           call. = FALSE)
    } else {
      return(body)
    }
  } else {
    stop(r$status_code)
  }
}

validate_query <- function(query) {
  if (identical(query, "")) stop("query is empty", call. = F)
  if (typeof(query) != "character") stop("query must be a string", call. = F)
  query <- enc2utf8(query)
  return(query)
}
