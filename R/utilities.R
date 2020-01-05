# Return the data in the requested format
return_data <- function(data, format) {
  if (format == "list") {
    return(data)
  }
  if (format == "json") {
    json <- data_to_json(data = data)
    return(json)
  }
}

# Parse data to json
data_to_json <- function(data) {
  json <- jsonlite::toJSON(data)
  return(json)
}
