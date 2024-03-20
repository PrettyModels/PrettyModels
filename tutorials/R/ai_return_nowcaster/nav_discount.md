AI Return Nowcaster - NAV Discount
================

## Introduction

This document explains how to use the AI Return Nowcaster **Short-term
Return Nowcast** endpoint of the **Private Equity Model API** provided
by [prettymodels.ai](https://prettymodels.ai). Our NAV discount endpoint
is based on the paper of [Nadauld, Sensoy, Vorkink, Weisbach
(2019)](https://doi.org/10.1016/j.jfineco.2018.11.007).

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

- **fund_segment**: choose from \[BO, VC, PE, RE, PD, INF, NATRES, FOF\]
- **nav**: current fund Net Asset Value (NAV)
- **age**: current fund age (in years)

**Please enter your own parameter assumptions!**

``` r
# Define the request body

request_body = list(
  nav = 100, # current fund net asset value
  age = 10, # current fund age
  fund_segment = fund_segments[1]
)
```

## Send endpoint request

This endpoint provides a short-term return nowcast for a portfolio of
private capital funds.

``` r
# Select endpoint 
endpoint <- "air_nowcaster/nav_discount"

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

barplot(as.matrix(df), 
        xlab ="Net Asset Value", 
        main = "NAV Discount Analysis",
        ylim = c(0, max(df) *1.1))
```

![](nav_discount_files/figure-gfm/send%20endpoint%20request-1.png)<!-- -->
