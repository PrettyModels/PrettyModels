Cash Flow Terminator
================

## Introduction

This document explains how to use the Cash Flow Terminator endpoints of
the **Private Equity Model API** provided by
[prettymodels.ai](https://prettymodels.ai). Our proprietary model is
based on publications by [De Malherbe
(2004)](https://doi.org/10.1142/S0219024904002359) and [Buchner
(2017)](https://doi.org/10.21314/JOR.2017.363).

## Set API Base URL & API keys

``` r
base_product_url <- "https://monkfish-app-xcac2.ondigitalocean.app/"
primary_api_key <- "needed-for-authentication"
secondary_api_key <- "needed-for-authentication"
```

## Get fund segments and macro environments

``` r
post_request <- httr::GET(url = paste0(base_product_url, "common/fund_segments"))
fund_segments <- unlist(content(post_request, "parsed"))
# print(fund_segments)
post_request <- httr::GET(url = paste0(base_product_url, "common/macro_environments"))
macro_environments <- unlist(content(post_request, "parsed"))
# print(macro_environments)
```

## Define the API request body

Our Cash Flow Terminator model has the following parameters:

Specify your input parameters in the request body:

- Performance:
  - **fund_segment**: choose from \[BO, VC, PE, RE, PD, INF, NATRES,
    FOF\]
  - **macro_environment**: choose from \[average, medium, super, good,
    bad, evil\]
  - **annualized_alpha**: systematic fund outperformance (0.01
    corresponds to 1% annual excess return)
- Timing:
  - **start_age**: between 0 and 20 years
  - **expected_investment_period**: usually investment period ends after
    4-6 years
  - **expected_fund_age**: usually PE funds are liquidated after 10-15
    years
- Commitment:
  - **commitment**: non-negative float
  - **open_commitment**: non-negative float
  - **recallable**: non-negative float
  - **overdraw_percentage**: how many percentage of the commitment are
    additionally called
  - **recallable_percentage**: how many percentage of the commitment can
    be maximally recalled
- Start Cash Flows:
  - **cum_contributions**: non-negative float
  - **cum_distributions**: non-negative float
  - **net_cash_flow**: non-negative float
  - **nav** (net asset value): non-negative float

**Please enter your own parameter assumptions!**

``` r
# Define the request body

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
```

## Function to connect to the Cash Flow Terminator API endpoints

This endpoint generates generic cash flow paths for a single private
equity fund.

``` r
download.plot.cft <- function(endpoint) {
  
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
  
  # Plot data.fame containing results
  color <- "red"
  par(col = color, col.axis = color, col.lab = color, col.main = color, col.sub = color, fg = color)

  matplot(
    rownames(df), df, 
    type = "l", lty = 1, 
    xlab = "Time", ylab = "Value", 
    col = 1:ncol(df), lwd=2,
    main=endpoint
    )
  
  abline(h=0, col="grey", lty=3, lwd=2)

  if (!(endpoint == "cft_23/user_assumptions/cash_flow_paths")) {
      legend(
    "bottomright", bty="n", legend = colnames(df), 
      col = 1:ncol(df), lty=1, cex=0.5, lwd=2
    )
  }
  
  return(df)
}
```

## Send API request

``` r
df <- download.plot.cft(endpoint = "cft_23/user_assumptions/cash_flow_quantiles?quantile=0.1")
```

![](cash_flow_expectations_files/figure-gfm/send%20API%20requests-1.png)<!-- -->

``` r
df <- download.plot.cft(endpoint = "cft_23/user_assumptions/cash_flow_quantiles?quantile=0.9")
```

![](cash_flow_expectations_files/figure-gfm/send%20API%20requests-2.png)<!-- -->

``` r
df <- download.plot.cft(endpoint = "cft_23/user_assumptions/cash_flow_quantiles?quantile=0.5")
```

![](cash_flow_expectations_files/figure-gfm/send%20API%20requests-3.png)<!-- -->

``` r
df <- download.plot.cft(endpoint = "cft_23/user_assumptions/cash_flow_paths")
```

![](cash_flow_expectations_files/figure-gfm/send%20API%20requests-4.png)<!-- -->

``` r
df <- download.plot.cft(endpoint = "cft_23/user_assumptions/cash_flow_expectations")
```

![](cash_flow_expectations_files/figure-gfm/send%20API%20requests-5.png)<!-- -->
