# Define environment for storing tokens
dimensions_env <- new.env(parent=emptyenv())

# Retrieve dimensions token
# If no token is set or token is empty, attempt authentication
get_dimensions_token <- function() {
  token <- tryCatch(get("token", envir = dimensions_env),
                    error = function(e) NULL)
  if (is.null(token) || identical(token, "")) {
    token <- tryCatch(authenticate_dimensions(),
                      error = function(e) stop(e))
  }
  return(token)
}

# Authenticate user with Dimensions API
authenticate_dimensions <- function() {
  credentials <- get_dimensions_credentials()
  token <- request_dimensions_token(credentials)
  return(token)
}

# Dimensions API credentials
get_dimensions_credentials <- function() {
  credentials <- list(
    "username" = get_dimensions_username(),
    "password" = get_dimensions_password()
  )
  return(credentials)
}

# Retrieve Dimensions username from .Renviron file
get_dimensions_username <- function() {
  username <- Sys.getenv("dimensions_username")
  if (identical(username, "")) {
    stop("Your Dimensions username must be defined in .Renviron file")
  } else {
    return(username)
  }
}

# Retrieve Dimensions password from .Renviron file
get_dimensions_password <- function() {
  password <- Sys.getenv("dimensions_password")
  if (identical(password, "")) {
    stop("Your Dimensions password must be defined in .Renviron file")
  } else {
    return(password)
  }
}

# Request token from API endpoint
request_dimensions_token <- function(credentials) {
  response <- httr::POST("https://app.dimensions.ai/api/auth.json",
                         body = credentials,
                         encode = "json")
  status <- response$status_code
  if(status == 200){
    token <- httr::content(response, as="parsed")$token
    assign("token", token, envir=dimensions_env)
    return(token)
  } else {
    stop(dimensions_status_codes[as.character(status)])
  }
}

# Potential status codes that can be returned by Dimensions API
dimensions_status_codes <- c(
  "200: OK",
  "401: Authorization failed. Please check credentials in your .Renviron file",
  "500: Internal Server error. Please try again later"
)
names(dimensions_status_codes) <- c("200", "401", "500")
