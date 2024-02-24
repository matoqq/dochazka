import requests
import json

def getToken(api_url: str, api_function: str,  user_login: str, api_key: str):
    data = {
        "Result": None,
        "UserLogin": user_login,
        "ApiKey": api_key
    }
    headers = {"Content-Type": "application/json"}
    response = requests.post('/'.join([api_url, api_function]), data=json.dumps(data), headers=headers)
    assert response.status_code==200, f"Login Failed:\n{response.status_code}\n{response.text}"
    return response.json().get("Token")
def fetchFromApi(api_url: str, api_function: str, token: str, params={}):
    params["Token"] = token
    headers = {"Accept": "application/json"}
    response = requests.get('/'.join([api_url, api_function]), headers=headers, params=params)
    assert response.status_code==200, f"Fetch Failed:\n{response.status_code}\n{response.text}"
    return response.json()
def loadApiLoginCredentials():
    with open('apiLoginCredentials.json', 'r') as file:
        credentials = json.load(file)
    return credentials['user_login'], credentials['api_key']

def main():
    user_login, api_key = loadApiLoginCredentials()
    api_url="https://next.vstecb.cz/AktionNEXT/API"

    token = getToken(api_url, 'login', user_login, api_key)
    assert bool(token), f"Problem getting token."

    ''' API documentation: https://next.vstecb.cz/AktionNEXT/API '''

    ''' Retrieve all passage data for requested time range, personId, Sensor and passage type. '''
    passAll = fetchFromApi(
        api_url=api_url,
        api_function='attendance/getPassAll',
        token=token,
        params={
            'TimeFrom':    '2023-11-20T08:00:00',
            'TimeTo':      '2023-11-20T08:01:00'
        },
    )    
    print(passAll)
if __name__ == "__main__":
    main()