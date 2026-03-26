# System Architecture

## Overview

This microservices architecture demonstrates a scalable, production-ready application structure with clear separation of concerns.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Frontend (React)                        │
│                    Port: 3000                                │
│  - User Interface                                           │
│  - Client-side State Management                             │
│  - REST API Integration                                     │
└────────┬────────────────────────────────────────────────────┘
         │
         │ HTTP/REST
         ▼
┌─────────────────────────────────────────────────────────────┐
│                   API Gateway / Router                       │
│              (Could be Ingress/Kong/Envoy)                  │
│  - Request Routing                                          │
│  - Load Balancing                                           │
│  - Rate Limiting (Future)                                   │
└─────────────────────────────────────────────────────────────┘
         │
    ┌────┼────┬──────────┐
    │    │    │          │
    ▼    ▼    ▼          ▼
┌─────────┐ ┌──────────┐ ┌──────────────┐
│  Auth   │ │  User    │ │   Product    │
│Service  │ │ Service  │ │   Service    │
│5001     │ │  5002    │ │    5003      │
└─────────┘ └──────────┘ └──────────────┘
   │           │              │
   └───────────┴──────────────┘
         │
         ▼
   ┌──────────────────┐
   │  Shared Storage  │
   │  (Future)        │
   └──────────────────┘
```

## Layered Architecture

### 1. Presentation Layer (Frontend)
- **Framework**: React with Vite
- **Port**: 3000
- **Features**:
  - User authentication UI
  - User list display
  - Product catalog display
  - Responsive design
  - Environment-based API URL configuration

**Key Files**:
- `App.jsx` - Main component with state management
- `App.css` - Styling
- `vite.config.js` - Build configuration

### 2. API Layer (Microservices)

#### Auth Service
- **Port**: 5001
- **Responsibilities**:
  - User registration
  - User login
  - JWT token generation
  - Token verification and refresh
- **Dependencies**: PyJWT, Flask, Flask-CORS
- **Database**: Mock (in-memory)

#### User Service
- **Port**: 5002
- **Responsibilities**:
  - User profile management
  - User CRUD operations
  - User profile retrieval
- **Dependencies**: Flask, Flask-CORS
- **Database**: Mock (in-memory)

#### Product Service
- **Port**: 5003
- **Responsibilities**:
  - Product catalog management
  - Product CRUD operations
  - Inventory management
  - Stock checking
- **Dependencies**: Flask, Flask-CORS
- **Database**: Mock (in-memory)

### 3. Container Layer

All services are containerized using Docker:
- **Base Image**: Python 3.11-slim (backend), Node 18-alpine (frontend)
- **Multi-stage builds**: Reduces image size
- **Health checks**: Ensures container health

### 4. Orchestration Layer

#### Docker Compose (Development)
- Service discovery via service names
- Network isolation
- Environment variable management
- Health checks
- Automatic restart policies

#### Kubernetes (Production)
- Pod management
- Service discovery
- Load balancing
- Self-healing
- Rolling updates
- Resource quotas
- Health probes (liveness & readiness)
- Ingress routing

## Data Flow

### Authentication Flow
```
1. User enters credentials
2. Frontend sends POST /auth/login
3. Auth Service validates credentials
4. Auth Service generates JWT token
5. Frontend stores token in localStorage
6. Frontend includes token in Authorization header for future requests
```

### Service Request Flow
```
1. Frontend requests data from a service
2. Request includes JWT token in Authorization header
3. Service receives request via Ingress/Routing layer
4. Service processes request
5. Service returns response
6. Frontend displays data
```

## Service Communication

### Synchronous Communication (HTTP/REST)
- Direct HTTP calls between services
- Used in this project for simplicity
- Suitable for learning and low-latency operations

### Asynchronous Communication (Message Queues)
- Not implemented in this learning project
- Would use RabbitMQ, Kafka, or similar in production
- For decoupled, event-driven architectures

## Security Architecture

### Authentication
- JWT tokens with 24-hour expiration
- Token refresh endpoint
- Secure secret key (hardcoded for demo, should use secrets manager)

### Authorization
- Role-based access control (future enhancement)
- User roles stored in database

### Transport Security
- HTTPS in production (not configured in learning project)
- CORS headers to prevent unauthorized cross-origin requests

## Scalability Considerations

### Horizontal Scaling
- Stateless services allow multiple replicas
- Kubernetes ReplicaSets manage pod count
- Load balancer distributes traffic

### Vertical Scaling
- Resource limits per container
- Memory and CPU quotas
- Request/limit configurations in K8s

### Database Scaling
- In-memory mock data in this project
- Production: Implement database sharding, replication
- Consider caching layer (Redis)

## Deployment Models

### Development (Docker Compose)
- Single machine deployment
- Fast feedback loop
- Mimics production setup

### Production (Kubernetes)
- Multi-node cluster
- High availability
- Auto-scaling
- Self-healing
- Infrastructure as Code (IaC)

## Resilience Patterns

### Health Checks
```yaml
- Liveness Probe: Determines if pod should restart
- Readiness Probe: Determines if pod can receive traffic
```

### Retry Policies
- Kubernetes automatically restarts failed pods
- Service has restart policy: `unless-stopped`
- Health checks trigger pod replacement if failed

### Graceful Degradation
- Services fail independently
- Frontend gracefully handles service failures
- Timeouts prevent cascading failures

## Monitoring & Observability

### Logging
- Container logs via `docker logs` or `kubectl logs`
- Centralized logging in production (ELK, etc.)

### Health Checks
- HTTP endpoint: `/health`
- Returns service status
- Used by orchestrators for health determination

### Metrics (Future Enhancement)
- Add Prometheus for metrics collection
- Grafana for visualization
- alertmanager for alerting

## Best Practices Implemented

✓ Containerization (Docker)
✓ Service isolation
✓ Health checks
✓ Resource limits
✓ Stateless services
✓ Environment configuration
✓ Graceful shutdown handling
✓ Multi-stage Docker builds
✓ Kubernetes best practices
✓ Namespace isolation

## Future Enhancements

1. **Database Layer**: PostgreSQL, MongoDB
2. **Caching**: Redis for session and data caching
3. **Message Queue**: RabbitMQ for async operations
4. **API Gateway**: Kong or Envoy for advanced routing
5. **Service Mesh**: Istio for advanced traffic management
6. **Monitoring**: Prometheus + Grafana
7. **Logging**: ELK Stack or Loki
8. **Tracing**: Jaeger for distributed tracing
9. **CI/CD**: Jenkins, GitLab CI, or GitHub Actions
10. **Package Management**: Helm charts for K8s deployment

---

**Next Step**: Review the [DOCKER_GUIDE.md](DOCKER_GUIDE.md) for detailed Docker setup instructions.
