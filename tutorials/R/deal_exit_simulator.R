##############################+############
# Plot Deal Exit Simulator Endpoint Results
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

base_product_url <- "https://base-product-url.app"
primary_api_key <- "needed-for-authentication"
secondary_api_key <- "needed-for-authentication"

if (file.exists("api_root.R")) source("api_root.R")

# Send API requests -----

# Choose one of these three endpoints
endpoints = list(
  "tbs_22/cash_flow_quantiles?quantile=0.5",
  "tbs_22/cash_flow_expectations",
  "tbs_22/cash_flow_paths"
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
  macro_environment = macro_environments[1],
  deal_age = 0,
  fund_age_at_entry = 0,
  current_deal_fmv = 1,
  current_deal_rvpi = 1
)

download.plot.tbs_22 <- function(endpoint) {
  
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
  # print(response)
  
  # Convert to data.frame
  df <- data.frame(lapply(response, unlist))
  
  if (endpoint == "tbs_22/cash_flow_paths") {
    # Scatter Plot
    plot(df$timing, df$multiple, pch=20, 
         xlab = "Exit Time", ylab = "Exit Multiple",
         main=endpoint)
  } else {
    df <- data.frame(t(df))
    rownames(df) <- as.numeric(sub("X", "", rownames(df)))
    
    # Plot data.fame containing results
    matplot(
      rownames(df), df, 
      type = "l", lty = 1, 
      xlab = "Time (in years)", ylab = "Cash Flow", 
      col = 1:ncol(df), lwd=2,
      main=endpoint
    )
    legend(
      "right", bty="n", legend = "cumulative cash flow", 
      col = 1:ncol(df), lty=1, cex=0.5, lwd=2
    )
    abline(h=0, col="grey", lty=3, lwd=2)
  }

  return(df)
}

for (endpoint in endpoints) df <- download.plot.tbs_22(endpoint)
