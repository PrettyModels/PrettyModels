import os
import requests
import pandas as pd

# Define the API root URL
api_root = "www.enter-url-to-api.com"
from api_root import api_root

# AI RETURN NOWCASTER MODEL
model = "air_nowcaster"

endpoints = [
    "short_term_return_nowcast",
    "sdf_price_range",
    "nav_discount",
]

# Define the data to be sent in the request body (as a dictionary)
fund_segments = requests.get(os.path.join(api_root, "common/fund_segments"))
print("fund_segments", fund_segments.json())
macro_environments = requests.get(os.path.join(api_root, "common/macro_environments"))
print("macro_environments", macro_environments.json())

request_body_short_term_return_nowcast = {
    "fund_segment": fund_segments.json()[0],
    "number_funds": 1,
}

request_body_sdf_price_range = {
    "list_input": [
        {"cash_flow_amount": 100, "exit_time": 1},
        {"cash_flow_amount": 150, "exit_time": 2},
    ],
    "fund_segment": fund_segments.json()[0],
    "macro_environment": macro_environments.json()[0],
    "rf_rate": 0,
}

request_body_nav_discount = {
    "fund_segment": fund_segments.json()[0],
    "nav": 100,
    "age": 10,
}


for endpoint in endpoints:
    # Build API URL
    url = os.path.join(api_root, model, endpoint)

    # Send the POST request
    if endpoint == "short_term_return_nowcast":
        request_body = request_body_short_term_return_nowcast
    elif endpoint == "sdf_price_range":
        request_body = request_body_sdf_price_range
    elif endpoint == "nav_discount":
        request_body = request_body_nav_discount
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
    if endpoint == "sdf_price_range":
        df = pd.DataFrame(response.json(), index=["price_now"])
    elif endpoint == "nav_discount":
        df = pd.DataFrame(response.json(), index=["nav_now"])
    else:
        df = pd.DataFrame(response.json())
    # df.index.name = "horizon_in_years"
    # print("df", df.columns, df)

    # Save pd.DataFrame to .csv file
    df.to_csv(f"ai_return_nowcaster---{endpoint}.csv")
    # plot = df.plot(title="My Plot")
