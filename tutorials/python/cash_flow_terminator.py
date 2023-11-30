import os
import requests
import pandas as pd

# Define the API root URL
base_product_url = "https://base-product-url.app"
primary_api_key = "needed-for-authentication"
secondary_api_key = "needed-for-authentication"

from api_root import primary_api_key, secondary_api_key, base_product_url

# CASH FLOW TERMINATOR MODEL
model = "cft_23/user_assumptions"

endpoints = [
    "cash_flow_expectations",
    "cash_flow_quantiles?quantile=0.1",
    "cash_flow_quantiles?quantile=0.5",
    "cash_flow_quantiles?quantile=0.9",
    "cash_flow_paths",
]

# Check available fund_segments and macro_environments
fund_segments = requests.get(os.path.join(base_product_url, "common/fund_segments"))
print("fund_segments", fund_segments.json())
macro_environments = requests.get(
    os.path.join(base_product_url, "common/macro_environments")
)
print("macro_environments", macro_environments.json())

# Define the data to be sent in the request body (as a dictionary)
request_body = {
    "fund_segment": fund_segments.json()[0],
    "start_age": 0,
    "macro_environment": macro_environments.json()[0],
    "cum_contributions": 0,
    "cum_distributions": 0,
    "net_cash_flow": 0,
    "nav": 0,
    "commitment": 100,
    "open_commitment": 100,
    "annualized_alpha": 0,
    "overdraw_percentage": 0,
    "recallable_percentage": 0,
    "recallable": 0,
    "expected_investment_period": 5,
    "expected_fund_age": 12,
}


for endpoint in endpoints:
    # Build API URL
    url = os.path.join(base_product_url, model, endpoint)

    # Set header for authentication
    headers = {"X-BLOBR-KEY": primary_api_key}

    # Send the POST request
    response = requests.post(url, json=request_body, headers=headers)

    if response.status_code == 401:
        # needed for API Key Rotation
        # More info: https://www.blobr.io/post/api-keys-best-practices
        headers = {"X-BLOBR-KEY": secondary_api_key}
        response = requests.post(url, json=request_body, headers=headers)

    # Check the response status code
    if response.status_code == 200:
        # Request was successful
        print(f"POST request successful: {url}")
        # print("Response JSON:", response.json())
    else:
        # Request failed
        print("POST request failed with status code:", response.status_code)

    # Convert dict to pd.DataFrame
    df = pd.DataFrame(response.json())
    df.index.name = "horizon_in_years"
    # print("df", df.columns, df)

    # Save pd.DataFrame to .csv file
    df.to_csv(f"cash_flow_terminator---{endpoint}.csv")
    # plot = df.plot(title="My Plot")
