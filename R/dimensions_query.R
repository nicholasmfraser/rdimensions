#' Make a basic query request to the Dimensions Analytics API
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
#' my_query <- paste0("search publications",
#'                    "where doi = \"10.3389/frma.2018.00023\"",
#'                    "return publications")
#' dimensions_query(query = my_query)
#'
#'
#'
#' A full overview of query syntax can be found in the [Dimensions Search
#' Language](https://docs.dimensions.ai/dsl/) documentation.

dimensions_query <- function(query = NULL, format = "list") {

  # Retrieve Dimensions token
  token <- fetch_token()

  # Validate arguments
  validate(query, format)

  # Submit query
  data <- do_query(query, token, retry = 0)

  return_data(data, format)

}

do_query <- function(query, token, retry = 0) {

  # Stop if too many retries
  if(retry > 10) {
    stop("Too many retries.", call. = FALSE)
  }

  # Make request
  r <- httr::POST("https://app.dimensions.ai/api/dsl.json",
                  body = query,
                  httr::add_headers("Authorization" = paste0("JWT ", token)))


  # Handle responses
  if (r$status_code == 403) {
    message(paste0("403 Forbidden: Login token expired. ",
            "Refreshing login token and trying again..."))
    token <- refresh_token()
    retry <- retry + 1
    do_query(query, token, retry)
  } else if (r$status_code == 429) {
    message("429 Too many requests. Sleeping for 30 seconds then retrying...")
    sys.sleep(30)
    retry <- retry + 1
    do_query(query, token, retry)
  } else if (r$status_code %in% c(200, 400, 500)) {
    data <- httr::content(r, as="parsed")
    if(!is.null(data$errors)) {
      stop(paste0(gsub("[\r\n]", "", data$errors$query$header), ": ",
                  gsub("[\r\n]", "", data$errors$query$details)),
           call. = FALSE)
    }
  } else {
    stop(r$status_code)
  }

  return(data)

}
