import os
import requests
import pandas as pd

# Define the API root URL
api_root = "www.enter-url-to-api.com"
from api_root import api_root

# TAKAHASHI ALEXANDER (2002) MODEL
model = "ta_02"

endpoints = [
    "cash_flow_expectations",
    "commitment_planner",
]

# Define the data to be sent in the request body (as a dictionary)
request_body_cash_flow_expectations = {
    "rate_of_contribution": 0.3,
    "investment_period_end": 5,
    "fund_lifetime": 13,
    "growth_rate": 0.1,
    "annual_yield": 0,
    "bow_factor": 2.5,
    "cumulative_output": True,
    "commitment": 100,
}

request_body_commitment_planner = {
    "rate_of_contribution": 0.3,
    "investment_period_end": 5,
    "fund_lifetime": 13,
    "growth_rate": 0.1,
    "annual_yield": 0,
    "bow_factor": 2.5,
    "cumulative_output": True,
    "future_commitment_list": [
        {"time": 0, "commitment": 100},
        {"time": 1, "commitment": 50},
        {"time": 2, "commitment": 200},
        {"time": 3, "commitment": 44.23},
    ],
}


for endpoint in endpoints:
    # Build API URL
    url = os.path.join(api_root, model, endpoint)

    # Send the POST request
    if endpoint == "cash_flow_expectations":
        request_body = request_body_cash_flow_expectations
    elif endpoint == "commitment_planner":
        request_body = request_body_commitment_planner
    else:
        raise ValueError(f"endpoint {endpoint} not defined.")
    response = requests.post(url, json=request_body)

    # Check the response status code
    if response.status_code == 200:
        # Request was successful
        print(f"POST request successful: {url}")
        print("Response JSON:", response.json())
    else:
        # Request failed
        print("POST request failed with status code:", response.status_code)

    # Convert dict to pd.DataFrame
    df = pd.DataFrame(response.json())
    df.index.name = "horizon_in_years"
    # print("df", df.columns, df)

    # Save pd.DataFrame to .csv file
    df.to_csv(f"takahashi_alexander---{endpoint}.csv")
    # plot = df.plot(title="My Plot")
