Takahashi Alexander - Cash Flow Expectations
================

## Introduction

This document explains how to use the Takahashi Alexander endpoints of
the **Private Equity Model API** provided by
[prettymodels.ai](https://prettymodels.ai). The original model has been
published by [Takahashi and Alexander
(2002)](https://doi.org/10.3905/jpm.2002.319836) in the *Journal of
Portfolio Management* article titled ‘Illiquid Alternative Asset Fund
Modeling’.

## Set API Base URL & API keys

``` r
base_product_url <- "https://monkfish-app-xcac2.ondigitalocean.app/"
primary_api_key <- "needed-for-authentication"
secondary_api_key <- "needed-for-authentication"
```

## Define the API request bodies

The Takahashi Alexander (2002) model has the following parameters:

- **rate_of_contribution**: how fast should the fund draw the open
  commitment at the fund start
- **investment_period_end**: how long can the fund call the open fund
  commitmennt
- **fund_lifetime**: when will the fund be completetely liquidtated
- **growth_rate**: what is the annual fund return (i.e., internal rate
  of return)
- **annual_yield**: what is the minimum distribution percentage per
  period
- **bow_factor**: how are the distributions distributed over the fund
  life time (higher bow_factor -\> later distributions, lower bow_factor
  -\> earlier distributions)

**Please enter your own parameter assumptions!**

``` r
# Define the request body

request_body <- list(
  rate_of_contribution = 0.3,
  investment_period_end = 5,
  fund_lifetime = 13,
  growth_rate = 0.1,
  annual_yield = 0,
  bow_factor = 2.5,
  cumulative_output = TRUE,
  commitment = 100
)
```

## Send API request

This endpoint generates generic cash flow paths for a single private
equity fund.

``` r
# Choose one of these three endpoints
endpoint <- "ta_02/cash_flow_expectations"

# Build API URL
api_url <- paste0(base_product_url, endpoint)

# Create the POST request
post_request <- httr::POST(api_url,
                           add_headers(.headers = c("X-BLOBR-KEY" = primary_api_key)),
                           body = request_body,
                           encode = "json")
# print(post_request)

# Send the POST Request:
response <- httr::content(post_request, "parsed")
# print(response)

# Convert to data.frame
df <- data.frame(lapply(response, unlist))
# print(df)

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
  col = 1:ncol(df), lty=1, cex=1, lwd=2
)
abline(h=0, col="grey", lty=3, lwd=2)
```

![](cash_flow_expectations_files/figure-gfm/define%20download%20function-1.png)<!-- -->
