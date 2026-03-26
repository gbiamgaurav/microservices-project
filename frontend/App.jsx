import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

// Service endpoints
const AUTH_URL = 'http://localhost:5001';
const USER_URL = 'http://localhost:5002';
const PRODUCT_URL = 'http://localhost:5003';

function App() {
  const [activeTab, setActiveTab] = useState('login');
  const [authToken, setAuthToken] = useState(localStorage.getItem('authToken') || '');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [users, setUsers] = useState([]);
  const [products, setProducts] = useState([]);
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState('info');

  useEffect(() => {
    if (authToken) {
      fetchUsers();
      fetchProducts();
    }
  }, [authToken]);

  const showMessage = (msg, type = 'info') => {
    setMessage(msg);
    setMessageType(type);
    setTimeout(() => setMessage(''), 3000);
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(`${AUTH_URL}/auth/login`, {
        email,
        password
      });
      const token = response.data.token;
      setAuthToken(token);
      localStorage.setItem('authToken', token);
      showMessage('Login successful!', 'success');
      setEmail('');
      setPassword('');
      setActiveTab('dashboard');
    } catch (error) {
      showMessage('Login failed: ' + (error.response?.data?.message || 'Unknown error'), 'error');
    }
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    try {
      await axios.post(`${AUTH_URL}/auth/register`, {
        email,
        password
      });
      showMessage('Registration successful! Please login.', 'success');
      setEmail('');
      setPassword('');
      setActiveTab('login');
    } catch (error) {
      showMessage('Registration failed: ' + (error.response?.data?.message || 'Unknown error'), 'error');
    }
  };

  const fetchUsers = async () => {
    try {
      const response = await axios.get(`${USER_URL}/users`, {
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      setUsers(response.data.data);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const fetchProducts = async () => {
    try {
      const response = await axios.get(`${PRODUCT_URL}/products`, {
        headers: { 'Authorization': `Bearer ${authToken}` }
      });
      setProducts(response.data.data);
    } catch (error) {
      console.error('Error fetching products:', error);
    }
  };

  const handleLogout = () => {
    setAuthToken('');
    localStorage.removeItem('authToken');
    setUsers([]);
    setProducts([]);
    setActiveTab('login');
    showMessage('Logged out successfully', 'success');
  };

  if (!authToken) {
    return (
      <div className="container">
        <div className="card">
          <h1>Microservices Demo</h1>
          
          <div className="tabs">
            <button 
              className={`tab-button ${activeTab === 'login' ? 'active' : ''}`}
              onClick={() => setActiveTab('login')}
            >
              Login
            </button>
            <button 
              className={`tab-button ${activeTab === 'register' ? 'active' : ''}`}
              onClick={() => setActiveTab('register')}
            >
              Register
            </button>
          </div>

          {message && <div className={`message ${messageType}`}>{message}</div>}

          {activeTab === 'login' && (
            <form onSubmit={handleLogin}>
              <h2>Login</h2>
              <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <button type="submit">Login</button>
              <p className="hint">Demo: user1@example.com / password123</p>
            </form>
          )}

          {activeTab === 'register' && (
            <form onSubmit={handleRegister}>
              <h2>Register</h2>
              <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <button type="submit">Register</button>
            </form>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="container">
      <div className="header">
        <h1>Microservices Dashboard</h1>
        <button onClick={handleLogout} className="logout-btn">Logout</button>
      </div>

      {message && <div className={`message ${messageType}`}>{message}</div>}

      <div className="dashboard">
        <div className="panel">
          <h2>Users</h2>
          {users.length > 0 ? (
            <div className="list">
              {users.map(user => (
                <div key={user.id} className="item">
                  <p><strong>{user.name}</strong></p>
                  <p>{user.email}</p>
                  <p className="role">Role: {user.role}</p>
                </div>
              ))}
            </div>
          ) : (
            <p>No users found</p>
          )}
          <button onClick={fetchUsers} className="refresh-btn">Refresh Users</button>
        </div>

        <div className="panel">
          <h2>Products</h2>
          {products.length > 0 ? (
            <div className="list">
              {products.map(product => (
                <div key={product.id} className="item">
                  <p><strong>{product.name}</strong></p>
                  <p>Price: ${product.price}</p>
                  <p>Stock: {product.stock}</p>
                  <p className="category">Category: {product.category}</p>
                </div>
              ))}
            </div>
          ) : (
            <p>No products found</p>
          )}
          <button onClick={fetchProducts} className="refresh-btn">Refresh Products</button>
        </div>
      </div>
    </div>
  );
}

export default App;
