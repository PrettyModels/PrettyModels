############################################
# Plot Cash Flow Terminator Endpoint Results
############################################
# if(sys.nframe() == 0L) rm(list = ls())

# install & load httr
install.packages("httr")
library(httr)

# Define the API URL -----
source(api_root.R)
endpoint <- "cft_23/user_assumptions/cash_flow_quantiles?quantile=0.5"
endpoint <- "cft_23/user_assumptions/cash_flow_paths"
endpoint <- "cft_23/user_assumptions/cash_flow_expectations"

api_url <- paste0(api_root, endpoint)

# Define the request body
request_body <- list(
  fund_segment = "BO",
  start_age = 0,
  macro_environment = "average",
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

# Create the POST request
post_request <- POST(url = api_url,
                     body = request_body,
                     encode = "json")
print(post_request)

# OPTIONAL: add header
#post_request <- post_request %>%
#  add_headers(Authorization = "Bearer YourAuthToken")

# Send the POST Request:
response <- content(post_request, "parsed")
print(response)

# Convert to data.frame
df <- data.frame(lapply(response, unlist))

# Plot data.fame containing results
matplot(rownames(df), df, type = "l", lty = 1, xlab = "Time", ylab = "Value", col = 1:ncol(df), lwd=2,
        main=endpoint)
legend("bottomright", bty="n", legend = colnames(df),  col = 1:ncol(df), lty=1, cex=0.5, lwd=2)
abline(h=0, col="grey", lty=3, lwd=2)
