import os
import requests
import pandas as pd

# Define the API root URL
base_product_url = "https://monkfish-app-xcac2.ondigitalocean.app/"
primary_api_key = "needed-for-authentication"
secondary_api_key = "needed-for-authentication"

# DEAL EXIT SIMULATOR MODEL
model = "tbs_22"

endpoints = [
    "cash_flow_expectations",
    "cash_flow_quantiles?quantile=0.1",
    "cash_flow_quantiles?quantile=0.5",
    "cash_flow_quantiles?quantile=0.9",
    "cash_flow_paths",
]

# Define the data to be sent in the request body (as a dictionary)
fund_segments = requests.get(os.path.join(base_product_url, "common/fund_segments"))
print("fund_segments", fund_segments.json())
macro_environments = requests.get(
    os.path.join(base_product_url, "common/macro_environments")
)
print("macro_environments", macro_environments.json())

request_body = {
    "macro_environment": macro_environments.json()[0],
    "fund_segment": fund_segments.json()[0],
    "deal_age": 0,
    "fund_age_at_entry": 0,
    "current_deal_fmv": 1,
    "current_deal_rvpi": 1,
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
    if endpoint == "cash_flow_paths":
        df = pd.DataFrame.from_dict(response.json())
        df.index.name = "path_number"
    else:
        df = pd.DataFrame(response.json(), index=["cash_flow"]).T
        df.index.name = "horizon_in_years"
    # print("df", df.columns, df)

    # Save pd.DataFrame to .csv file
    df.to_csv(f"deal_exit_simulator---{endpoint}.csv")
    # plot = df.plot(title="My Plot")
