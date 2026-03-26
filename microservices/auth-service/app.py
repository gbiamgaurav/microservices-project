"""
Auth Service Microservice
Handles user authentication and JWT token generation
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime, timedelta
import jwt
import os
from functools import wraps

# Configuration
SECRET_KEY = os.getenv('SECRET_KEY', 'your-secret-key-change-in-production')
JWT_EXPIRATION_HOURS = 24

app = Flask(__name__)
CORS(app)

# Mock user database (in production, use a real database)
mock_users = {
    'user1@example.com': {'password': 'password123', 'id': 1},
    'user2@example.com': {'password': 'password456', 'id': 2}
}


def generate_token(user_id, email):
    """Generate JWT token"""
    payload = {
        'user_id': user_id,
        'email': email,
        'exp': datetime.utcnow() + timedelta(hours=JWT_EXPIRATION_HOURS),
        'iat': datetime.utcnow()
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
    return token


def verify_token(f):
    """Decorator to verify JWT token"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]
            except IndexError:
                return jsonify({'message': 'Invalid token format'}), 401

        if not token:
            return jsonify({'message': 'Token is missing'}), 401

        try:
            data = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
            current_user = data
        except jwt.ExpiredSignatureError:
            return jsonify({'message': 'Token has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'message': 'Token is invalid'}), 401

        return f(current_user, *args, **kwargs)
    return decorated


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'Auth Service is running'}), 200


@app.route('/auth/register', methods=['POST'])
def register():
    """Register a new user"""
    data = request.json
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'message': 'Email and password are required'}), 400

    if email in mock_users:
        return jsonify({'message': 'User already exists'}), 409

    # In production, hash the password
    user_id = len(mock_users) + 1
    mock_users[email] = {'password': password, 'id': user_id}

    return jsonify({
        'message': 'User registered successfully',
        'user_id': user_id
    }), 201


@app.route('/auth/login', methods=['POST'])
def login():
    """Login user and return JWT token"""
    data = request.json
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'message': 'Email and password are required'}), 400

    user = mock_users.get(email)
    if not user or user['password'] != password:
        return jsonify({'message': 'Invalid credentials'}), 401

    token = generate_token(user['id'], email)
    return jsonify({
        'message': 'Login successful',
        'token': token,
        'user_id': user['id'],
        'email': email
    }), 200


@app.route('/auth/verify', methods=['POST'])
@verify_token
def verify(current_user):
    """Verify JWT token"""
    return jsonify({
        'message': 'Token is valid',
        'user_id': current_user['user_id'],
        'email': current_user['email']
    }), 200


@app.route('/auth/refresh', methods=['POST'])
@verify_token
def refresh(current_user):
    """Refresh JWT token"""
    new_token = generate_token(current_user['user_id'], current_user['email'])
    return jsonify({
        'message': 'Token refreshed successfully',
        'token': new_token
    }), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
