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
  query <- validate_dimensions_query(query)

  # Retrieve Dimensions token
  token <- get_dimensions_token()

  # Submit query
  data <- submit_dimensions_query(query, token, retry = 0)

  if (format == "list") {
  } else if (format == "json") {
    data <- jsonlite::toJSON(data)
  } else if (format == "dataframe") {
    data <- jsonlite::fromJSON(jsonlite::toJSON(data))
  } else {
    stop("'format' must be one of 'list' or 'json'")
  }
  return(data)
}

submit_dimensions_query <- function(query, token, retry) {

  # Send query
  r <- httr::POST("https://app.dimensions.ai/api/dsl.json",
                  body = query,
                  httr::add_headers("Authorization" = paste0("JWT ", token)))

  # Handle responses
  if (r$status_code == 403) {
    if (retry == 0) {
      print("403 Forbidden. Refreshing login token and trying again...")
      token <- refresh_dimensions()
      submit_dimensions_query(query, token, retry = 1)
    } else {
      stop(paste0("403 Forbidden.",
                  "Please ensure credentials in your .Renviron file are correct"),
           call. = FALSE)
    }
  } else if (r$status_code == 429) {
    if (retry < 10) {
      print("429 Too many requests. Sleeping for 30 seconds then retrying...")
      sys.sleep(30)
      submit_dimensions_query(query, token, retry = retry + 1)
    } else {
      stop("429 Too many requests. Aborting.")
    }
  } else if (r$status_code %in% c(200, 400, 500)) {
    body <- httr::content(r, as="parsed")
    if(!is.null(body$errors)) {
      stop(paste0(gsub("[\r\n]", "", body$errors$query$header), ": ",
                  gsub("[\r\n]", "", body$errors$query$details)),
           call. = FALSE)
    } else {
      return(body)
    }
  }
}

validate_dimensions_query <- function(query) {
  if (identical(query, "")) stop("'query' cannot be empty", call. = F)
  if (typeof(query) != "character") stop("'query' must be a string", call. = F)
  query <- enc2utf8(query)
  return(query)
}
