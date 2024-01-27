# conda install faker -y

import pandas as pd
import numpy as np
from faker import Faker

def swap_digits(n):
    n_str = str(n)
    # Swap pairs of digits (e.g., 1234 becomes 2143)
    swapped = ''.join(n_str[i + 1] + n_str[i] if i % 2 == 0 else '' for i in range(len(n_str) - 1))
    # If there's an odd number of digits, add the last digit back in
    if len(n_str) % 2 != 0:
        swapped += n_str[-1]
    return int(swapped)

# Modular addition for further obfuscation
MOD_VALUE = 100000
def modular_addition(n):
    return (n + 12345) % MOD_VALUE

# Function to create SQL statement for a row
def create_insert_statement(row):
    return f"INSERT INTO usersTb (user_id, name, email, password, password_salt, position_type, titles, profession_id, department_id) SELECT {row['user_id']}, '{row['Name']}', '{row['email']}', 'password001', 'salt001', {row['positionType']}, '{row['titles']}', profession_id, '{row['Department_id']}' FROM professionTb WHERE profession_en='{row['Profession_eng']}'"
# Function to create SQL statement for a row
def create_insert_statement_for_dfProfessions(row):
    return f"INSERT INTO professionTb (profession_cz, profession_en) VALUES ('{row['Profesion_cz']}', '{row['Profession_eng']}')"
    # ('Rektor', 'internal auditor'),

if __name__=='__main__':

    ## read excel into pandas dataframe
    file_path = r"C:\Users\student\Downloads\tabulky pro db.xlsm"
    
    sheet_name = 'Users_Tb'
    dfUsers = pd.read_excel(file_path, sheet_name=sheet_name, engine='openpyxl')

    sheet_name = 'Profession_TB'
    dfProfessions = pd.read_excel(file_path, sheet_name=sheet_name, engine='openpyxl')

    '''
    dfProfessions
    '''

    ## Escape apostrophes by replacing them with two apostrophes
    for col in dfProfessions.columns:
        dfProfessions[col] = dfProfessions[col].astype(str).str.replace("'", "''")

    ## create insert statements for professions
    dfProfessions['insertStatement_professionTb'] = dfProfessions.apply(create_insert_statement_for_dfProfessions, axis=1)
    
    ## export to xlsx
    dfProfessions.to_excel(r"C:\Users\student\Downloads\dfProfessions.xlsx")

    '''
    dfUsers + dfProfessions --> dfMerged
    '''
    ## Escape apostrophes by replacing them with two apostrophes
    for col in dfUsers.columns:
        dfUsers[col] = dfUsers[col].astype(str).str.replace("'", "''")

    ## merge the dataframes
    df = pd.merge(dfUsers, dfProfessions, left_on='profession_id', right_on='Profession_id')
    df = df.sort_values(by=['Name'])
    
    ## obfuscate user_ids
    #df['user_id_original'] = df['user_id']
    df['user_id'] = df['user_id'].apply(lambda x: modular_addition(swap_digits(x)))

    ## obfuscate names
    #df['Name_original'] = df['Name']
    fake = Faker()
    df['Name'] = df['Name'].apply(lambda _: fake.name())

    ## replace NaN with empty string ('')
    for col in df:
        df[col] = df[col].fillna('')
        df[col] = df[col].replace('nan', '')

    ## create query for sql insert statement
    df['insertStatement_usersTb'] = df.apply(create_insert_statement, axis=1)

    ## export to xlsx
    df.to_excel(r"C:\Users\student\Downloads\dfUsers.xlsx")
    print('hold debugger here')