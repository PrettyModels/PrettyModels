AI Return Nowcaster - Short-term Return Nowcast
================

## Introduction

This document explains how to use the AI Return Nowcaster **Short-term
Return Nowcast** endpoint of the **Private Equity Model API** provided
by [prettymodels.ai](https://prettymodels.ai). Our Short-term Return
Nowcast endpoint is based on our proprietary AI/ML engine for simulating
private equity fund returns.

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

Our model has the following parameters:

Specify your input parameters in the request body:

- **fund_segment**: choose from \[BO, VC, PE, RE, PD, INF, NATRES, FOF\]
- **number_funds**: number of funds in the portfolio

**Please enter your own parameter assumptions!**

``` r
# Define the request body

request_body <- list(
  fund_segment = fund_segments[1],
  number_funds = 2
)
```

## Send endpoint request

This endpoint provides a short-term return nowcast for a portfolio of
private capital funds.

``` r
endpoint <- "air_nowcaster/short_term_return_nowcast"

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
```

![](short_term_return_nowcast_files/figure-gfm/send%20endpoint%20request-1.png)<!-- -->
