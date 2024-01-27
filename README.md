# Dochazka

# Setup virtual environment
create and activate virtual environment
```bash
bash setup_env.sh
```

# creating Database
database must first be created using the template in `poorMansDbTemplate.zip`\
The table-schema and filling tables with data is done using sql script `createDb.sql`\
This script can be updated (manually) by running `tableObfuscator.py` which will read tables in excel and export new ones with queries so that they can be copy-pasted into the `createDb.sql`.



# API server
### Running the server
run script `server.py`
```python
python server.py
```

in another terminal, you can authentificate yourself as
- username: admin; password: pwd1
- username: guest; password: pwd2
```bash
curl -u admin:pwd1 http://127.0.0.1:5000/api
```

