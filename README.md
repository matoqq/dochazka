# Dochazka

### Setup virtual environment
create and activate virtual environment
```bash
bash setup_env.sh
```

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