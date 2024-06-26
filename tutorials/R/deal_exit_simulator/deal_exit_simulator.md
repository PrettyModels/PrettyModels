Deal Exit Simulator
================

## Introduction

This document explains how to use the Deal Exit Simulator endpoints of
the **Private Equity Model API** provided by
[prettymodels.ai](https://prettymodels.ai). Our model is based on
[Tausch, Buchner, Schlüchtermann
(2022)](https://doi.org/10.21314/JOR.2022.029)

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

Specify your input parameters in the request body:

- Performance:
  - **fund_segment**: choose from \[BO, VC, PE, RE, PD, INF, NATRES,
    FOF\]
  - **macro_environment**: choose from \[average, medium, super, good,
    bad, evil\]
- Timing:
  - **deal_age**: current deal age (in years)
  - **fund_age_at_entry**: fund age at deal entry (in years)
- Current Deal Multiples:
  - **current_deal_fmv**: current deal fmv (fair market value), all exit
    cash flow take this fmv as basis
  - **current_deal_rvpi**: current residual-value-to-paid-in ratio of
    the deal, i.e., fmv/cost

**Please enter your own parameter assumptions!**

``` r
# Define the request body

request_body <- list(
  fund_segment = fund_segments[1],
  macro_environment = macro_environments[1],
  deal_age = 0,
  fund_age_at_entry = 0,
  current_deal_fmv = 1,
  current_deal_rvpi = 1
)
```

## Function to connect to the Deal Exit Simulator API endpoints

This endpoint generates generic cash flow paths for a single private
equity deal.

``` r
download.plot.tbs_22 <- function(endpoint) {
  
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
  
  if (endpoint == "tbs_22/cash_flow_paths") {
    # Scatter Plot
    plot(df$timing, df$multiple, pch=20, 
         xlab = "Exit Time", ylab = "Exit Multiple",
         main=endpoint)
  } else if (endpoint == "tbs_22/exit_timing_multiple_mean_stdv") {
    print(df)

    x <- seq(-10, 20, 0.1)
    
    color <- "red"
    par(mfrow = c(1, 2),
        col = color, col.axis = color, col.lab = color, col.main = color, col.sub = color, fg = color)

    plot(x, dnorm(x, mean= df["timing", "mean"], sd = df["timing", "stdv"]), 
         ylab = "density", main = "Timing", type = "l", lty = 3)
    abline(v = df["timing", "mean"], col = "blue", lwd = 2)
    plot(x, dnorm(x, mean= df["multiple", "mean"], sd = df["multiple", "stdv"]), 
         ylab = "density", main = "Multiple", type = "l", lty = 3)
    abline(v = df["multiple", "mean"], col = "blue", lwd = 2)

    par(mfrow = c(1, 1))

  } else {
    df <- data.frame(t(df))
    rownames(df) <- as.numeric(sub("X", "", rownames(df)))
    
    # Plot data.fame containing results
    color <- "red"
    par(col = color, col.axis = color, col.lab = color, col.main = color, col.sub = color, fg = color)

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
```

## Send API request for cash flows

``` r
df <- download.plot.tbs_22(endpoint = "tbs_22/cash_flow_quantiles?quantile=0.3")
```

![](deal_exit_simulator_files/figure-gfm/send%20API%20requests%20cash%20flows-1.png)<!-- -->

``` r
df <- download.plot.tbs_22(endpoint = "tbs_22/cash_flow_quantiles?quantile=0.9")
```

![](deal_exit_simulator_files/figure-gfm/send%20API%20requests%20cash%20flows-2.png)<!-- -->

``` r
df <- download.plot.tbs_22(endpoint = "tbs_22/cash_flow_quantiles?quantile=0.5")
```

![](deal_exit_simulator_files/figure-gfm/send%20API%20requests%20cash%20flows-3.png)<!-- -->

``` r
df <- download.plot.tbs_22(endpoint = "tbs_22/cash_flow_paths")
```

![](deal_exit_simulator_files/figure-gfm/send%20API%20requests%20cash%20flows-4.png)<!-- -->

``` r
df <- download.plot.tbs_22(endpoint = "tbs_22/cash_flow_expectations")
```

![](deal_exit_simulator_files/figure-gfm/send%20API%20requests%20cash%20flows-5.png)<!-- -->

## Send API request for mean and standard deviation

Note that our model **does not assume a normal distribution** for the
deal exit multiple or timing! For the exit timing we assume a dynamic
proportional hazard rate model with Weibull base hazard function. For
the exit multiple we assume a Generalized Linear Model (GLM) with a
Gamma distributed error term.

``` r
df <- download.plot.tbs_22(endpoint = "tbs_22/exit_timing_multiple_mean_stdv")
```

    ##              mean     stdv
    ## timing   6.393275 3.861017
    ## multiple 2.358328 5.116420

![](deal_exit_simulator_files/figure-gfm/send%20API%20requests%20mean%20stdv-1.png)<!-- -->
