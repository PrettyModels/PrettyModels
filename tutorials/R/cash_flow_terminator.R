##############################+#############
# Plot Cash Flow Terminator Endpoint Results
############################################
# Initialize ----
if(sys.nframe() == 0L) rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# install & load package "httr" to access API later
if (!require("httr", quietly = TRUE)) {
  install.packages("httr")
}

# Set API Base URL & API keys -----

base_product_url <- "https://base-product-url.app"
primary_api_key <- "needed-for-authentication"
secondary_api_key <- "needed-for-authentication"

if (file.exists("api_root.R")) source("api_root.R")

# Send API requests -----

# Choose one of these three endpoints
endpoints = list(
  "cft_23/user_assumptions/cash_flow_quantiles?quantile=0.5",
  "cft_23/user_assumptions/cash_flow_paths",
  "cft_23/user_assumptions/cash_flow_expectations"
)

# Define the request body
post_request <- httr::GET(url = paste0(base_product_url, "common/fund_segments"))
fund_segments <- unlist(content(post_request, "parsed"))
print(fund_segments)
post_request <- httr::GET(url = paste0(base_product_url, "common/macro_environments"))
macro_environments <- unlist(content(post_request, "parsed"))
print(macro_environments)

request_body <- list(
  fund_segment = fund_segments[1],
  start_age = 0,
  macro_environment = macro_environments[1],
  cum_contributions = 0,
  cum_distributions = 0,
  net_cash_flow = 0,
  nav = 0,
  commitment = 100,
  open_commitment = 100,
  annualized_alpha = 0,
  overdraw_percentage = 0,
  recallable_percentage = 0,
  recallable = 0,
  expected_investment_period = 5,
  expected_fund_age = 12
)

download.plot.cft <- function(endpoint) {
  
  # Build API URL
  api_url <- paste0(base_product_url, endpoint)
  
  # Create the POST request
  post_request <- httr::POST(api_url,
                             add_headers(.headers = c("X-BLOBR-KEY" = primary_api_key)),
                             body = request_body,
                             encode = "json")
  print(post_request)
  
  # OPTIONAL: add header
  #post_request <- post_request %>%
  #  add_headers(Authorization = "Bearer YourAuthToken")
  
  # Send the POST Request:
  response <- httr::content(post_request, "parsed")
  print(response)
  
  # Convert to data.frame
  df <- data.frame(lapply(response, unlist))
  
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

for (endpoint in endpoints) df <- download.plot.cft(endpoint)
