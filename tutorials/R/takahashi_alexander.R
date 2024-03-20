###########################################
# Plot Takahashi Alexander Endpoint Results
###########################################
# Initialize ----
if(sys.nframe() == 0L) rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# install & load package "httr" to access API later
if (!require("httr", quietly = TRUE)) {
  install.packages("httr")
}

# Set API Base URL & API keys -----

base_product_url <- "https://monkfish-app-xcac2.ondigitalocean.app/"
primary_api_key <- "needed-for-authentication"
secondary_api_key <- "needed-for-authentication"

# Send API requests -----

# Choose one of these three endpoints
endpoints = list(
  "ta_02/cash_flow_expectations",
  "ta_02/commitment_planner"
)

# Define the request body

request_body_cash_flow_expectations <- list(
  rate_of_contribution = 0.3,
  investment_period_end = 5,
  fund_lifetime = 13,
  growth_rate = 0.1,
  annual_yield = 0,
  bow_factor = 2.5,
  cumulative_output = TRUE,
  commitment = 100
)

request_body_commitment_planner <- list(
  rate_of_contribution = 0.3,
  investment_period_end = 5,
  fund_lifetime = 13,
  growth_rate = 0.1,
  annual_yield = 0,
  bow_factor = 2.5,
  cumulative_output = TRUE,
  future_commitment_list = list(
    list(time = 0, commitment = 100),
    list(time = 1, commitment = 100),
    list(time = 2, commitment = 100),
    list(time = 3, commitment = 100)
    )
)

download.plot.ta_02 <- function(endpoint) {
  
  # select correct request body
  if (endpoint == "ta_02/cash_flow_expectations") {
    request_body <- request_body_cash_flow_expectations
  } else if (endpoint == "ta_02/commitment_planner") {
    request_body <- request_body_commitment_planner
  }
  
  # Build API URL
  api_url <- paste0(base_product_url, endpoint)
  
  # Create the POST request
  post_request <- httr::POST(api_url,
                             add_headers(.headers = c("X-BLOBR-KEY" = primary_api_key)),
                             body = request_body,
                             encode = "json")
  print(post_request)
  
  # Send the POST Request:
  response <- httr::content(post_request, "parsed")
  print(response)
  
  # Convert to data.frame
  df <- data.frame(lapply(response, unlist))
  print(df)
  
  # Plot data.fame containing results
  matplot(
    rownames(df), df, 
    type = "l", lty = 1, 
    xlab = "Time", ylab = "Value", 
    col = 1:ncol(df), lwd=2,
    main=endpoint
  )
  legend(
    "bottomright", bty="n", legend = colnames(df), 
    col = 1:ncol(df), lty=1, cex=0.5, lwd=2
  )
  abline(h=0, col="grey", lty=3, lwd=2)
  
  return(df)
}

for (endpoint in endpoints) df <- download.plot.ta_02(endpoint)
