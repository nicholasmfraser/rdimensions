#' Login to the Dimensions Analytics API
#'
#' @export
#'
#' @param credentials (list) List of user credentials, including username (email)
#' and password
#'
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
dim_login <- function(credentials = NULL) {
  if(is.null(credentials)) {
    credentials <- get_credentials()
  }
  token <- request_token(credentials)
  message("Logged in with token: ", token)
}

# Define environment for storing tokens
dim_env <- new.env(parent=emptyenv())

# Retrieve Dimensions API credentials
get_credentials <- function() {
  credentials <- list(
    "username" = get_username(),
    "password" = get_password()
  )
  return(credentials)
}

# Retrieve Dimensions username from .Renviron file
get_username <- function() {
  username <- Sys.getenv("dimensions_username")
  if (identical(username, "")) {
    stop("Your Dimensions username must be defined in .Renviron file")
  } else {
    return(username)
  }
}

# Retrieve Dimensions password from .Renviron file
get_password <- function() {
  password <- Sys.getenv("dimensions_password")
  if (identical(password, "")) {
    stop("Your Dimensions password must be defined in .Renviron file")
  } else {
    return(password)
  }
}

# Request token
request_token <- function(credentials) {

  # Make request to server
  response <- httr::POST("https://app.dimensions.ai/api/auth.json",
                         body = credentials,
                         encode = "json")

  # Retrieve status code
  status <- response$status_code

  # Handle response
  if(status == 200){
    token <- httr::content(response, as="parsed")$token
    store_token(token)
    return(token)
  } else {
    stop(httr::http_status(response)$message)
  }
}

# Store token
store_token <- function(token) {
  assign("token", token, envir=dimensions_env)
}

# Refresh a token if no longer valid
refresh_token <- function() {
  destroy_token()
  token <- request_token()
  return(token)
}

# Destroy token
destroy_token <- function() {
  token <- tryCatch(get("token", envir = dimensions_env),
                    error = function(e) NULL)
  if (!is.null(token)) {
    remove("token", envir = dimensions_env)
  }
}

# Retrieve an existing dimensions token
fetch_token <- function() {

  # Attempt to retrieve an existing token
  token <- tryCatch(get("token", envir = dimensions_env),
                    error = function(e) stop("Invalid authentication token. Please ensure you are logged in using 'dimensions_login()' before querying.",
                                             call. = FALSE))

  return(token)
}
