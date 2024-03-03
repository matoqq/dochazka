import requests
import json
import pyodbc # for SQL queries
from datetime import datetime
import logging
log_format = "%(levelname)-8s %(name)-10s %(lineno)-5d %(message)s"
logging.basicConfig(level=logging.INFO, format=log_format)

def open_connection():
    connection_string = f"SERVER={config['server']};" \
                        f"DATABASE={config['database']};" \
                        f"UID={config['username']};" \
                        f"PWD={config['password']}"
    if config['options']['encrypt']:
        connection_string += ";Encrypt=yes"
    if config['options']['enableArithAbort']:
        connection_string += ";EnableArithAbort=on"

    cnxn = pyodbc.connect(connection_string)
    logging.info('Connected to Azure SQL Database')
    return cnxn
def fetch_data_from_db(table_name):
    try:
        cnxn = open_connection()
        cursor = cnxn.cursor()
        query = f"SELECT * FROM {table_name}"
        cursor.execute(query)
        rows = cursor.fetchall()
        return [dict(zip([column[0] for column in cursor.description], row)) for row in rows]
    except Exception as e:
        logging.error('Error fetching data:', e)
        raise
    finally:
        cnxn.close()
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
def loadDbLoginCredentials():
    with open('dbLoginCredentials.json', 'r') as file:
        credentials = json.load(file)
    return credentials['server'], credentials['user'], credentials['password'], credentials['database']

def main():
    """
    ## connecting  to Aktion API
    user_login, api_key = loadApiLoginCredentials()
    api_url="https://next.vstecb.cz/AktionNEXT/API"

    token = getToken(api_url, 'login', user_login, api_key)
    assert bool(token), f"Problem getting token."

    ''' API documentation: https://next.vstecb.cz/AktionNEXT/API '''

    ''' Retrieve all passage data for requested time range, personId, Sensor and passage type. '''
    current_time = datetime.now()
    passAll = fetchFromApi(
        api_url=api_url,
        api_function='attendance/getPassAll',
        token=token,
        params={
            'TimeFrom':    '2024-02-26T08:00:00',
            'TimeTo':      '2024-02-27T08:00:00',#current_time.strftime('%Y-%m-%dT%H:%M:%S')
        },
    )
    ## [record for record in passAll['Passes'] if record['PersonId']=='31442']
    logging.debug(passAll)
    """

    """ Connecting to Database """

    dbServer, dbUserName, dbPassword, dbName = loadDbLoginCredentials()
    
    ''' connecting to db using  pmsql (loading to rows line by line) '''
    # import pymssql
    # conn = pymssql.connect(server=dbServer, 
    #                        user=dbUserName, 
    #                        password=dbPassword, 
    #                        database=dbName)
    # cursor = conn.cursor()
    # cursor.execute('SELECT * FROM usersTb')
    # for row in cursor:
    #     print(row)
    # conn.close()

    import pandas as pd
    sql_query = "SELECT user_id, sensor_name, note, CONVERT(VARCHAR, entry_time, 127) as entry_time FROM attendanceTb"
    ''' connecting to db using pymsql (loading to dataframe) '''
    # import pymssql
    # conn = pymssql.connect(server=dbServer, user=dbUserName, password=dbPassword, database=dbName)
    # df = pd.read_sql_query(sql_query, conn)

    ''' connecting to db using  '''
    from sqlalchemy import create_engine
    engine = create_engine(f"mssql+pymssql://{dbUserName}:{dbPassword}@{dbServer}/{dbName}")
    df = pd.read_sql_query(sql="SELECT * FROM attendanceTb", con=engine)
    logging.debug('hold debugger here')


if __name__ == "__main__":
    logging.info("Starting script")
    main()
    logging.info("Script finished")