from flask import Flask, request, jsonify, make_response

app = Flask(__name__)

# Dummy data for the sake of example
users = {
    "admin": "pwd1",
    "guest": "pwd2"
}

def check_auth(username, password):
    """This function is called to check if a username /
    password combination is valid."""
    return username in users and users[username] == password

def authenticate():
    """Sends a 401 response that enables basic auth"""
    return make_response(
        'Could not verify your access level for that URL.\n'
        'You have to login with proper credentials', 401,
        {'WWW-Authenticate': 'Basic realm="Login Required"'})

@app.route('/api')
def api():
    auth = request.authorization
    if not auth or not check_auth(auth.username, auth.password):
        return authenticate()

    return jsonify(message="Hello, {}!".format(auth.username))

if __name__ == '__main__':
    app.run(debug=True)
