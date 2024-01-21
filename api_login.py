import requests
import json

def login(api_url, user_login, api_key):
    data = {
        "Result": None,
        "UserLogin": user_login,
        "ApiKey": api_key
    }
    headers = {"Content-Type": "application/json"}
    response = requests.post(api_url, data=json.dumps(data), headers=headers)

    if response.status_code == 200:
        print("Login Successful")
        return response.json()
    else:
        print("Login Failed:", response.status_code, response.text)
        return None

def main(user_login, api_key):
    api_url = "http://dochazka.efg.cz/aktionnext/api/login"

    token_info = login(api_url, user_login, api_key)
    if token_info:
        print("Token:", token_info.get("Token"))
        print("Expires in:", token_info.get("ExpireInSec"), "seconds")

if __name__ == "__main__":
    main(user_login="dochazka-ext", api_key="hDn/LFXIPESM036W+s7VKg==") ## priklad hesla z dokumentace {"Message":"UserLogin or ApiKey are unknown or user is blocked","Code":1003}