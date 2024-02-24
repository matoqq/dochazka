import requests
import json

def getToken(api_url, user_login, api_key):
    data = {
        "Result": None,
        "UserLogin": user_login,
        "ApiKey": api_key
    }
    headers = {"Content-Type": "application/json"}
    response = requests.post(api_url, data=json.dumps(data), headers=headers)
    if response.status_code == 200:
        print("Login Successful")
        return response.json().get("Token")
    else:
        print("Login Failed:", response.status_code, response.text)
        return None
def fetchFromApi(api_url: str, token: str, time_from: str, time_to: str):
    params = {
        "Token": token,
        "TimeFrom": time_from,
        "TimeTo": time_to
    }
    headers = {
        "Accept": "application/json"
    }
    response = requests.get(api_url, headers=headers, params=params)
    if response.status_code == 200:
        print("Fetch Successful")
        return response.json()
    else:
        print("Fetch Failed:", response.status_code, response.text)
        return None
def main(user_login: str, api_key: str):
    token = getToken(
        api_url="https://next.vstecb.cz/AktionNEXT/API/login",
        user_login=user_login,
        api_key=api_key
    )
    if token:
        apiData = fetchFromApi(
            api_url="https://next.vstecb.cz/AktionNEXT/API/attendance/getPassAll",
            token=token,
            time_from="2023-11-20T08:00:00",
            time_to="2023-11-20T08:01:00"
        )
        print(apiData)
    else:
        print("Failed to retrieve token.")
def loadApiLoginCredentials():
    with open('apiLoginCredentials.json', 'r') as file:
        credentials = json.load(file)
    return credentials['user_login'], credentials['api_key']
if __name__ == "__main__":

    # Load credentials from JSON file
    user_login, api_key = loadApiLoginCredentials()
    main(user_login, api_key)