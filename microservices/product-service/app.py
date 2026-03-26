"""
Product Service Microservice
Manages product catalog and inventory
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

# Mock product database
mock_products_db = {
    1: {'id': 1, 'name': 'Laptop', 'price': 999.99, 'stock': 50, 'category': 'Electronics'},
    2: {'id': 2, 'name': 'Mouse', 'price': 29.99, 'stock': 200, 'category': 'Accessories'},
    3: {'id': 3, 'name': 'Keyboard', 'price': 79.99, 'stock': 150, 'category': 'Accessories'},
    4: {'id': 4, 'name': 'Monitor', 'price': 299.99, 'stock': 75, 'category': 'Electronics'}
}


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'Product Service is running'}), 200


@app.route('/products', methods=['GET'])
def get_products():
    """Get all products"""
    category = request.args.get('category')
    products = list(mock_products_db.values())
    
    if category:
        products = [p for p in products if p['category'].lower() == category.lower()]
    
    return jsonify({
        'message': 'Products retrieved successfully',
        'count': len(products),
        'data': products
    }), 200


@app.route('/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Get product by ID"""
    product = mock_products_db.get(product_id)
    
    if not product:
        return jsonify({'message': 'Product not found'}), 404
    
    return jsonify({
        'message': 'Product retrieved successfully',
        'data': product
    }), 200


@app.route('/products', methods=['POST'])
def create_product():
    """Create a new product"""
    data = request.json
    product_id = max(mock_products_db.keys()) + 1
    
    new_product = {
        'id': product_id,
        'name': data.get('name'),
        'price': data.get('price'),
        'stock': data.get('stock', 0),
        'category': data.get('category')
    }
    
    mock_products_db[product_id] = new_product
    
    return jsonify({
        'message': 'Product created successfully',
        'data': new_product
    }), 201


@app.route('/products/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    """Update product"""
    product = mock_products_db.get(product_id)
    
    if not product:
        return jsonify({'message': 'Product not found'}), 404
    
    data = request.json
    if 'name' in data:
        product['name'] = data['name']
    if 'price' in data:
        product['price'] = data['price']
    if 'stock' in data:
        product['stock'] = data['stock']
    if 'category' in data:
        product['category'] = data['category']
    
    return jsonify({
        'message': 'Product updated successfully',
        'data': product
    }), 200


@app.route('/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    """Delete product"""
    if product_id not in mock_products_db:
        return jsonify({'message': 'Product not found'}), 404
    
    deleted_product = mock_products_db.pop(product_id)
    return jsonify({
        'message': 'Product deleted successfully',
        'data': deleted_product
    }), 200


@app.route('/products/<int:product_id>/stock', methods=['GET'])
def check_stock(product_id):
    """Check product stock"""
    product = mock_products_db.get(product_id)
    
    if not product:
        return jsonify({'message': 'Product not found'}), 404
    
    return jsonify({
        'product_id': product_id,
        'stock': product['stock'],
        'available': product['stock'] > 0
    }), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003, debug=True)
