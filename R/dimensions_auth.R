# Define environment for storing tokens
dimensions_env <- new.env(parent=emptyenv())

# Retrieve dimensions token
get_token <- function() {

  # Attempt to retrieve an existing token
  token <- tryCatch(get("token", envir = dimensions_env),
                    error = function(e) NULL)

  # If token does not exist, generate a new one
  if (is.null(token) || identical(token, "")) {
    token <- generate_token()
  }

  return(token)
}

# Generate a new token
generate_token <- function() {
  credentials <- get_credentials()
  token <- request_token(credentials)
  return(token)
}

# Refresh a token if no longer valid
refresh_token <- function() {
  destroy_token()
  token <- generate_token()
  return(token)
}

# Dimensions API credentials
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

# Request token from API endpoint
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

# Destroy token
destroy_token <- function() {
  token <- tryCatch(get("token", envir = dimensions_env),
                    error = function(e) NULL)
  if (!is.null(token)) {
    remove("token", envir = dimensions_env)
  }
}
