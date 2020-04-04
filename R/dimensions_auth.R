#' Login to the Dimensions Analytics API
#'
#' @export
#'
#' @param credentials (list) List of user credentials, including username
#' (email) and password. To avoid providing a manual list each time, you may
#' instead add your credentials to your .Renviron file. These should be named
#' `dimensions_username` and `dimensions_password`. `dimensions_login()` will
#' then use these credentials automatically to login.
#'
#' @examples
#' # Login with a list of credentials
#' dimensions_login(credentials = list(
#'     "username" = "your_username",
#'     "password" = "your_password"))
#'
#' Alternatively with credentials added to .Renviron file:
#' dimensions_login()
dimensions_login <- function(credentials = NULL) {
  if(is.null(credentials)) {
    credentials <- get_credentials()
  }
  store_credentials(credentials)
  token <- request_token(credentials)
  message("Logged in with token: ", token)
}

#' Logout of the Dimensions Analytics API
#'
#' @export
#'
#' @examples
#' # Logout and destroy existing login token
#' dimensions_logout()

dimensions_logout <- function() {
  destroy_token()
  message("Successfully logged out.")
}

# Define environment for storing tokens
dimensions_env <- new.env(parent = emptyenv())

# Retrieve Dimensions API credentials
get_credentials <- function() {
  credentials <- list(
    "username" = get_username(),
    "password" = get_password()
  )
  return(credentials)
}

# Store credentials. Necessary for auto-refreshing of expired tokens
store_credentials <- function(credentials) {
  assign("credentials", credentials, envir = dimensions_env)
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
    token <- httr::content(response, as = "parsed")$token
    store_token(token)
    return(token)
  } else {
    stop(httr::http_status(response)$message)
  }
}

# Store token
store_token <- function(token) {
  assign("token", token, envir = dimensions_env)
}

# Refresh an expired token
refresh_token <- function() {
  destroy_token()
  credentials <- tryCatch(get("credentials", envir = dimensions_env),
                          error = function(e) stop("Login credentials not found. Ensure you are logged in using 'dimensions_login()' and try again",
                                                   call. = FALSE))
  token <- request_token(credentials)
  message("Token refreshed. New token: ", token)
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
