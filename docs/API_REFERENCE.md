# API Reference

## Base URLs

- **Development (Docker Compose)**: `http://localhost:5000`
- **Development (Direct)**:
  - Auth Service: `http://localhost:5001`
  - User Service: `http://localhost:5002`
  - Product Service: `http://localhost:5003`
- **Production (Kubernetes)**: `http://kubernetes-api-gateway`

## Authentication

All requests to User and Product services should include JWT token in Authorization header:

```
Authorization: Bearer <jwt_token>
```

### Getting a Token

1. Register or login via `/auth/login`
2. Store token in localStorage
3. Include in all subsequent requests

---

## Auth Service (Port: 5001)

### 1. Register User

Create a new user account.

**Endpoint**: `POST /auth/register`

**Request**:
```bash
curl -X POST http://localhost:5001/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "securepassword123"
  }'
```

**Response**:
```json
{
  "message": "User registered successfully",
  "user_id": 3
}
```

**Status Codes**:
- `201`: User created successfully
- `400`: Missing email or password
- `409`: User already exists

---

### 2. Login User

Login with email and password to receive JWT token.

**Endpoint**: `POST /auth/login`

**Request**:
```bash
curl -X POST http://localhost:5001/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user1@example.com",
    "password": "password123"
  }'
```

**Response**:
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user_id": 1,
  "email": "user1@example.com"
}
```

**Status Codes**:
- `200`: Login successful
- `400`: Missing email or password
- `401`: Invalid credentials

---

### 3. Verify Token

Verify if a JWT token is valid.

**Endpoint**: `POST /auth/verify`

**Request**:
```bash
curl -X POST http://localhost:5001/auth/verify \
  -H "Authorization: Bearer <token>"
```

**Response**:
```json
{
  "message": "Token is valid",
  "user_id": 1,
  "email": "user1@example.com"
}
```

**Status Codes**:
- `200`: Token is valid
- `401`: Token is missing or invalid

---

### 4. Refresh Token

Generate a new JWT token using an existing valid token.

**Endpoint**: `POST /auth/refresh`

**Request**:
```bash
curl -X POST http://localhost:5001/auth/refresh \
  -H "Authorization: Bearer <token>"
```

**Response**:
```json
{
  "message": "Token refreshed successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Status Codes**:
- `200`: Token refreshed
- `401`: Invalid or expired token

---

### 5. Health Check

Check if Auth Service is running.

**Endpoint**: `GET /health`

**Request**:
```bash
curl http://localhost:5001/health
```

**Response**:
```json
{
  "status": "Auth Service is running"
}
```

**Status Codes**:
- `200`: Service is healthy

---

## User Service (Port: 5002)

### 1. Get All Users

Retrieve list of all users.

**Endpoint**: `GET /users`

**Request**:
```bash
curl http://localhost:5002/users \
  -H "Authorization: Bearer <token>"
```

**Response**:
```json
{
  "message": "Users retrieved successfully",
  "count": 2,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "user1@example.com",
      "role": "admin"
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "user2@example.com",
      "role": "user"
    }
  ]
}
```

**Status Codes**:
- `200`: Success
- `401`: Invalid or missing token

---

### 2. Get User by ID

Retrieve a specific user by ID.

**Endpoint**: `GET /users/<user_id>`

**Request**:
```bash
curl http://localhost:5002/users/1 \
  -H "Authorization: Bearer <token>"
```

**Response**:
```json
{
  "message": "User retrieved successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "user1@example.com",
    "role": "admin"
  }
}
```

**Status Codes**:
- `200`: Success
- `401`: Invalid or missing token
- `404`: User not found

---

### 3. Update User

Update user information.

**Endpoint**: `PUT /users/<user_id>`

**Request**:
```bash
curl -X PUT http://localhost:5002/users/1 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated",
    "role": "user"
  }'
```

**Response**:
```json
{
  "message": "User updated successfully",
  "data": {
    "id": 1,
    "name": "John Updated",
    "email": "user1@example.com",
    "role": "user"
  }
}
```

**Status Codes**:
- `200`: Success
- `401`: Invalid or missing token
- `404`: User not found

---

### 4. Delete User

Delete a user account.

**Endpoint**: `DELETE /users/<user_id>`

**Request**:
```bash
curl -X DELETE http://localhost:5002/users/1 \
  -H "Authorization: Bearer <token>"
```

**Response**:
```json
{
  "message": "User deleted successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "user1@example.com",
    "role": "admin"
  }
}
```

**Status Codes**:
- `200`: Success
- `401`: Invalid or missing token
- `404`: User not found

---

### 5. Get User Profile

Retrieve detailed user profile information.

**Endpoint**: `GET /users/profile/<user_id>`

**Request**:
```bash
curl http://localhost:5002/users/profile/1 \
  -H "Authorization: Bearer <token>"
```

**Response**:
```json
{
  "message": "Profile retrieved successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "user1@example.com",
    "role": "admin",
    "profile_completion": 100,
    "created_at": "2024-01-01",
    "updated_at": "2024-03-26"
  }
}
```

**Status Codes**:
- `200`: Success
- `401`: Invalid or missing token
- `404`: User not found

---

### 6. Health Check

Check if User Service is running.

**Endpoint**: `GET /health`

**Request**:
```bash
curl http://localhost:5002/health
```

**Response**:
```json
{
  "status": "User Service is running"
}
```

**Status Codes**:
- `200`: Service is healthy

---

## Product Service (Port: 5003)

### 1. Get All Products

Retrieve list of all products with optional filtering.

**Endpoint**: `GET /products`

**Query Parameters**:
- `category` (optional): Filter by category

**Request**:
```bash
# Get all products
curl http://localhost:5003/products \
  -H "Authorization: Bearer <token>"

# Filter by category
curl "http://localhost:5003/products?category=Electronics" \
  -H "Authorization: Bearer <token>"
```

**Response**:
```json
{
  "message": "Products retrieved successfully",
  "count": 4,
  "data": [
    {
      "id": 1,
      "name": "Laptop",
      "price": 999.99,
      "stock": 50,
      "category": "Electronics"
    },
    {
      "id": 2,
      "name": "Mouse",
      "price": 29.99,
      "stock": 200,
      "category": "Accessories"
    }
  ]
}
```

**Status Codes**:
- `200`: Success
- `401`: Invalid or missing token

---

### 2. Get Product by ID

Retrieve a specific product by ID.

**Endpoint**: `GET /products/<product_id>`

**Request**:
```bash
curl http://localhost:5003/products/1 \
  -H "Authorization: Bearer <token>"
```

**Response**:
```json
{
  "message": "Product retrieved successfully",
  "data": {
    "id": 1,
    "name": "Laptop",
    "price": 999.99,
    "stock": 50,
    "category": "Electronics"
  }
}
```

**Status Codes**:
- `200`: Success
- `401`: Invalid or missing token
- `404`: Product not found

---

### 3. Create Product

Create a new product.

**Endpoint**: `POST /products`

**Request**:
```bash
curl -X POST http://localhost:5003/products \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Headphones",
    "price": 149.99,
    "stock": 100,
    "category": "Accessories"
  }'
```

**Response**:
```json
{
  "message": "Product created successfully",
  "data": {
    "id": 5,
    "name": "Headphones",
    "price": 149.99,
    "stock": 100,
    "category": "Accessories"
  }
}
```

**Status Codes**:
- `201`: Product created
- `401`: Invalid or missing token

---

### 4. Update Product

Update product details.

**Endpoint**: `PUT /products/<product_id>`

**Request**:
```bash
curl -X PUT http://localhost:5003/products/1 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "price": 899.99,
    "stock": 45
  }'
```

**Response**:
```json
{
  "message": "Product updated successfully",
  "data": {
    "id": 1,
    "name": "Laptop",
    "price": 899.99,
    "stock": 45,
    "category": "Electronics"
  }
}
```

**Status Codes**:
- `200`: Success
- `401`: Invalid or missing token
- `404`: Product not found

---

### 5. Delete Product

Delete a product.

**Endpoint**: `DELETE /products/<product_id>`

**Request**:
```bash
curl -X DELETE http://localhost:5003/products/1 \
  -H "Authorization: Bearer <token>"
```

**Response**:
```json
{
  "message": "Product deleted successfully",
  "data": {
    "id": 1,
    "name": "Laptop",
    "price": 999.99,
    "stock": 50,
    "category": "Electronics"
  }
}
```

**Status Codes**:
- `200`: Success
- `401`: Invalid or missing token
- `404`: Product not found

---

### 6. Check Stock

Check product stock availability.

**Endpoint**: `GET /products/<product_id>/stock`

**Request**:
```bash
curl http://localhost:5003/products/1/stock \
  -H "Authorization: Bearer <token>"
```

**Response**:
```json
{
  "product_id": 1,
  "stock": 50,
  "available": true
}
```

**Status Codes**:
- `200`: Success
- `401`: Invalid or missing token
- `404`: Product not found

---

### 7. Health Check

Check if Product Service is running.

**Endpoint**: `GET /health`

**Request**:
```bash
curl http://localhost:5003/health
```

**Response**:
```json
{
  "status": "Product Service is running"
}
```

**Status Codes**:
- `200`: Service is healthy

---

## Error Responses

All endpoints return error responses in this format:

```json
{
  "message": "Error description"
}
```

### Common HTTP Status Codes

- `200 OK`: Request successful
- `201 Created`: Resource created
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Invalid or missing authentication
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource already exists
- `500 Internal Server Error`: Server error

---

## Testing with cURL

### Complete Authentication Flow

```bash
# 1. Register
curl -X POST http://localhost:5001/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123"
  }'

# 2. Login
TOKEN=$(curl -X POST http://localhost:5001/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user1@example.com",
    "password": "password123"
  }' | jq -r '.token')

echo $TOKEN

# 3. Use token in request
curl http://localhost:5002/users \
  -H "Authorization: Bearer $TOKEN"
```

### Testing with Postman

1. Create a new collection
2. Add requests for each endpoint
3. Use environment variables for token and base URL
4. Set Authorization header: `Bearer {{token}}`

---

## Rate Limiting (Future Enhancement)

Planned for future versions:
- Rate limit: 100 requests per minute
- Headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`
- Status code: `429 Too Many Requests`

---

**Next Steps**:
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Troubleshoot API issues
- [LEARNING_PATH.md](LEARNING_PATH.md) - Recommended learning sequence
