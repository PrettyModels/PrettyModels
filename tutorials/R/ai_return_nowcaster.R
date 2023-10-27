###########################################
# Plot AI Return Nowcaster Endpoint Results
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

# source("api_root.R")


# Send API requests ----
# Retrieve available fund_segments and macro_environments
post_request <- httr::GET(
  url = paste0(base_product_url, "common/fund_segments"),
  add_headers(.headers = c("X-BLOBR-KEY" = primary_api_key))
  )
fund_segments <- unlist(content(post_request, "parsed"))
print(fund_segments)
post_request <- httr::GET(url = paste0(base_product_url, "common/macro_environments"))
macro_environments <- unlist(content(post_request, "parsed"))
print(macro_environments)

# Choose one of these three endpoints
endpoint <- "air_nowcaster/short_term_return_nowcast"
endpoint <- "air_nowcaster/sdf_price_range"
endpoint <- "air_nowcaster/nav_discount"

download.air.nowcast <- function(endpoint) {
  
  # Define the request body
  if (endpoint == "air_nowcaster/short_term_return_nowcast") {
    request_body <- list(
      fund_segment = fund_segments[1],
      number_funds = 2
    )
  } else if (endpoint == "air_nowcaster/sdf_price_range") {
    request_body <- list(
      list_input = list(
        list(cash_flow_amount=100, exit_time=1), # example cash flow stream
        list(cash_flow_amount=150, exit_time=2), # example cash flow stream
        list(cash_flow_amount=220, exit_time=3) # example cash flow stream
      ),
      fund_segment= fund_segments[1],
      macro_environment= macro_environments[1],
      rf_rate= 0
    )
  } else if (endpoint == "air_nowcaster/nav_discount") {
    request_body = list(
      nav = 100, # current fund net asset value
      age = 10, # current fund age
      fund_segment = fund_segments[1]
    )
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
  
  # Plot data.fame containing results
  if (endpoint == "air_nowcaster/short_term_return_nowcast") {
    quarter <- 4
    df.q <- df[1:(nrow(df)-1), ]
    x <- as.numeric(sub("quantile_", "", rownames(df.q)))
    y <- df.q[, paste0("quarter_", quarter)]
    plot(x, y, type="h", 
         xlab = "Quantiles", ylab = "Return", 
         main = paste("Cumulative return quantiles after", quarter, "quarter(s)")
         )
    abline(h = df["mean", paste0("quarter_", quarter)], col = "blue", lwd = 2, lty = 3)
    legend("bottomright", bty = "n", legend = "expected return", col = "blue", lwd = 2, lty = 3)
  } else if (endpoint == "air_nowcaster/sdf_price_range") {
    # Define mean and standard deviation
    m <- df$price_mean  # Mean
    s <- df$price_stdv  # Standard deviation
    
    # Generate x-values for the plot
    x <- seq(m - 4 * s, m + 4 * s, length = 1000)
    
    # Calculate the PDF values for the given mean and standard deviation
    pdf_values <- dnorm(x, mean = m, sd = s)
    
    # Create the plot
    plot(x, pdf_values, type = "l", col = "blue", lwd = 2,
         xlab = "Fund Price (discounted cash flows)", 
         ylab = "PDF", main = "Fund Price Range")
    abline(h=0, col="grey")
    abline(v=m, col="green", lwd=2)
    legend("topright", bty="n", legend = "expected price", col="green", lwd=2, lty=1)
  } else if (endpoint == "air_nowcaster/nav_discount") {
    barplot(as.matrix(df), 
            xlab ="Net Asset Value", 
            main = "NAV Discount Analysis",
            ylim = c(0, max(df) *1.1))
  }
  
  return(df)
}

df <- download.air.nowcast(endpoint = "air_nowcaster/short_term_return_nowcast")
df <- download.air.nowcast(endpoint = "air_nowcaster/sdf_price_range")
df <- download.air.nowcast(endpoint = "air_nowcaster/nav_discount")

