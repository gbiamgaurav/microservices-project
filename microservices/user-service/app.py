"""
User Service Microservice
Manages user profiles and information
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

# Mock user database
mock_users_db = {
    1: {'id': 1, 'name': 'John Doe', 'email': 'user1@example.com', 'role': 'admin'},
    2: {'id': 2, 'name': 'Jane Smith', 'email': 'user2@example.com', 'role': 'user'}
}


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'User Service is running'}), 200


@app.route('/users', methods=['GET'])
def get_users():
    """Get all users"""
    users = list(mock_users_db.values())
    return jsonify({
        'message': 'Users retrieved successfully',
        'count': len(users),
        'data': users
    }), 200


@app.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    """Get user by ID"""
    user = mock_users_db.get(user_id)
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    return jsonify({
        'message': 'User retrieved successfully',
        'data': user
    }), 200


@app.route('/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    """Update user information"""
    user = mock_users_db.get(user_id)
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    data = request.json
    if 'name' in data:
        user['name'] = data['name']
    if 'role' in data:
        user['role'] = data['role']
    
    return jsonify({
        'message': 'User updated successfully',
        'data': user
    }), 200


@app.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    """Delete user"""
    if user_id not in mock_users_db:
        return jsonify({'message': 'User not found'}), 404
    
    deleted_user = mock_users_db.pop(user_id)
    return jsonify({
        'message': 'User deleted successfully',
        'data': deleted_user
    }), 200


@app.route('/users/profile/<int:user_id>', methods=['GET'])
def get_user_profile(user_id):
    """Get user profile with additional details"""
    user = mock_users_db.get(user_id)
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    profile = {
        **user,
        'profile_completion': 100,
        'created_at': '2024-01-01',
        'updated_at': '2024-03-26'
    }
    
    return jsonify({
        'message': 'Profile retrieved successfully',
        'data': profile
    }), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)
