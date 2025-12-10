# Gym Management System
The Gym Management System (GMS) is a way to manage gym operations by integrating member management, fitness tracking, class scheduling, product sales, and personalized recommendations. The system combines hardware components (barcode readers, subscription card readers, face recognition) with software services (mobile app, AI-based recommendations, social media management) to enhance member experience, optimize gym management and generate additional revenue through data-driven insights and targeted marketing. 

## Table of Contents
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Development](#development)
- [Docker Support](#docker-support)
- [CI/CD Pipeline](#cicd-pipeline)
- [Deployment](#deployment)
- [Branch Strategy](#branch-strategy)

## Tech Stack
| Technology | Purpose |
|-----------|---------|
| **HTML5** | Structure |
| **CSS** | Styling |
| **JavaScript** | Interactive functionality |
| **Docker** | Containerization and deployment |
| **nginx** | Web server for production |
| **GitHub Actions** | CI/CD automation |


## Project Structure
```
gym-management-system/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml           # Main CI/CD pipeline
│       ├── release.yml         # Release automation
│       └── dependency-check.yml # Weekly dependency checks
├── src/
│   ├── index.html              # Main application file
│   └── config.js               # Feature flags
├── scripts/
│   ├── deploy-ftp.sh           # FTP deployment script
│   ├── emergency-rollback.sh  # Emergency rollback script
│   └── swap-traffic.sh         # Blue-Green traffic switch
├── Dockerfile                  # Docker container definition
├── docker-compose.yml          # Docker Compose configuration
├── nginx.conf                  # nginx web server config
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

## Development

```bash
# Checkout develop branch
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name

# Make changes to src/index.html
# ...

# Commit changes
git add .
git commit -m "feat: add your feature description"

# Push to GitHub
git push -u origin feature/your-feature-name
```

### Feature Flags

To enable/disable features without deploying new code, edit `src/config.js`:

```javascript
const FEATURE_FLAGS = {
  AI_RECOMMENDATIONS: true,
  FACE_CHECKIN: false,
  ADVANCED_ANALYTICS: false,
  PAYMENT_GATEWAY: false
};
```

## Docker Support

### Building the Docker Image

```bash
# Build image 
docker build -f docker/Dockerfile -t gym-management:latest .

# Run container
docker run -d -p 8080:80 --name gym-app gym-management:latest

# View logs
docker logs gym-app

# Stop container
docker stop gym-app
```

### Using Docker Compose

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

The application will be available at `http://localhost:8080`

### Health Check

```bash
# Check container health
curl http://localhost:8080/health

# Expected response: "healthy"
```

## CI/CD Pipeline

The project uses GitHub Actions for automated testing and deployment.

### Pipeline Stages
<img width="2465" height="9293" alt="devops" src="https://github.com/user-attachments/assets/fbad434d-7a1b-4b1e-b70b-af53a7d14c48" />


### Triggering the Pipeline

The pipeline automatically triggers on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch

## Deployment
### Deployment Environments

| Environment | Branch | URL | Auto-Deploy |
|------------|--------|-----|-------------|
| **Development** | feature/* | localhost:8080 |
| **Staging** | develop | staging.gymtest.com |
| **Production** | main | gymtest.com |

### Blue-Green Deployment

The system maintains two identical production environments:

- **Blue Environment**: Current production serving live traffic
- **Green Environment**: New version for testing before going live

**Deployment Process:**
1. New version deploys to Green environment
2. Automated smoke tests run on Green
3. If tests pass, traffic switches from Blue to Green
4. Blue becomes standby for next deployment
5. If issues occur, instant rollback to Blue

<img width="8803" height="3223" alt="devops1" src="https://github.com/user-attachments/assets/b3250d5a-3820-4e0e-94c0-dacc28228d3d" />

### Manual Deployment

```bash
# Deploy to staging via FTP
./scripts/deploy-ftp.sh staging

# Deploy to production
./scripts/deploy-ftp.sh production
```

### Environment Variables

Configure deployment via environment variables:

```bash
export FTP_HOST="ftp.gymtest.com"
export FTP_USER="your_username"
export FTP_PASS="your_password"
export FTP_DIR="/public_html"
```

## 🌳 Branch Strategy
```
main (production)
├── develop (integration)
│   ├── feature/payment-integration
│   ├── feature/ai-recommendations
│   ├── bugfix/mobile-layout
│   └── hotfix/security-patch
└── release/v1.2.0
```

### Branch Types

| Branch Type | Naming | Purpose | Merges To |
|------------|--------|---------|-----------|
| **Feature** | `feature/description` | New features | develop |
| **Bugfix** | `bugfix/description` | Bug fixes | develop |
| **Hotfix** | `hotfix/description` | Critical production fixes | main & develop |
| **Release** | `release/vX.Y.Z` | Release preparation | main & develop |

### Workflow Example

```bash
# 1. Start new feature
git checkout develop
git checkout -b feature/new-dashboard

# 2. Develop feature
git add .
git commit -m "feat: add new dashboard metrics"

# 3. Push and create PR
git push -u origin feature/new-dashboard
# Create Pull Request on GitHub: feature/new-dashboard → develop

# 4. After approval, merge to develop
# Automatically deploys to staging

# 5. Create release when ready
git checkout develop
git checkout -b release/v1.1.0
echo "1.1.0" > version.txt
git commit -am "chore: bump version to 1.1.0"

# 6. Merge release to main
# Create Pull Request: release/v1.1.0 → main
# Automatically deploys to production
```

## 🔄 Rollback Strategy

### Automatic Rollback Triggers

- Error rate exceeds 5%
- Page load time exceeds 2 seconds
- Health check failures
- Manual emergency trigger

### Rollback Methods

**1. Traffic Switch (30 seconds)**
```bash
./scripts/emergency-rollback.sh
# Immediately switches traffic back to Blue environment
```

**2. Git Revert (5 minutes)**
```bash
git revert HEAD
git push origin main
# Pipeline automatically deploys reverted code
```

**3. Tag Rollback (10 minutes)**
```bash
git checkout v1.0.5
git checkout -b hotfix/rollback-to-1.0.5
git push origin hotfix/rollback-to-1.0.5
# Create fast-track PR to main
```

### Post-Rollback Checklist

- [ ] Verify old version is deployed
- [ ] Test core functionality
- [ ] Check error rates and latency
- [ ] Test critical user paths
- [ ] Notify team of rollback
- [ ] Document rollback reason
- [ ] Plan fix for next release
