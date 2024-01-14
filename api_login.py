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

def main():
    api_url = "http://dochazka.efg.cz/aktionnext/api/login"
    user_login = "usernameXXX"
    api_key = "passwordYYY"

    token_info = login(api_url, user_login, api_key)
    if token_info:
        print("Token:", token_info.get("Token"))
        print("Expires in:", token_info.get("ExpireInSec"), "seconds")

if __name__ == "__main__":
    print(''.join(['\n' for _ in range(50)]))
    main()
