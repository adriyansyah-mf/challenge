#!/bin/bash

# SecureCorp Challenge Startup Script
# This script starts the entire challenge environment

echo "🎯 Starting SecureCorp Challenge Environment..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "⚠️  Warning: Running as root. Consider using a non-root user with sudo access."
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker service first."
    echo "   sudo systemctl start docker"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install docker-compose first."
    exit 1
fi

echo "🧹 Cleaning up any existing containers..."
docker-compose down -v 2>/dev/null

echo "🏗️ Building and starting services..."
docker-compose up -d --build

# Wait for services to start
echo "⏳ Waiting for services to initialize..."
sleep 30

# Check service status
echo "🔍 Checking service status..."

services=("securecorp_portal" "securecorp_db" "securecorp_elastic" "securecorp_kibana")
all_healthy=true

for service in "${services[@]}"; do
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "$service.*Up"; then
        echo "✅ $service is running"
    else
        echo "❌ $service is not running properly"
        all_healthy=false
    fi
done

# Test web application
echo "🌐 Testing web application..."
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ Web application is accessible at http://localhost:8080"
else
    echo "❌ Web application is not responding"
    all_healthy=false
fi

# Test database
echo "🗄️ Testing database connection..."
if docker exec securecorp_db mysql -u webapp -pw3bp@ss123 -e "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ Database is accessible"
else
    echo "❌ Database connection failed"
    all_healthy=false
fi

# Test Elasticsearch
echo "🔍 Testing Elasticsearch..."
sleep 10  # Give ES more time to start
if curl -s http://localhost:9200 > /dev/null; then
    echo "✅ Elasticsearch is accessible at http://localhost:9200"
else
    echo "⚠️ Elasticsearch may still be starting up. Check in a few minutes."
fi

# Test Kibana
echo "📊 Testing Kibana..."
if curl -s http://localhost:5601 > /dev/null; then
    echo "✅ Kibana is accessible at http://localhost:5601"
else
    echo "⚠️ Kibana may still be starting up. Check in a few minutes."
fi

echo ""
echo "🎊 Challenge Environment Status:"
if $all_healthy; then
    echo "✅ All core services are running successfully!"
else
    echo "⚠️ Some services may need more time to start or have issues."
    echo "   Check logs with: docker-compose logs"
fi

echo ""
echo "🎯 Challenge Access Points:"
echo "   📱 Web Application: http://localhost:8080"
echo "   📊 Kibana Dashboard: http://localhost:5601"  
echo "   🗄️ MySQL Database: localhost:3306"
echo "   🔍 Elasticsearch: http://localhost:9200"
echo ""
echo "🔐 Default Credentials:"
echo "   Web App: admin/admin123 or try SQL injection"
echo "   MySQL: webapp/w3bp@ss123"
echo "   MySQL Root: root/r00tp@ss123"
echo ""
echo "📚 Quick Start:"
echo "   1. Red Team: Start with reconnaissance on port 8080"
echo "   2. Blue Team: Setup monitoring via Kibana dashboard"
echo "   3. Read CHALLENGE_GUIDE.md for detailed instructions"
echo ""
echo "⚠️ Security Notice:"
echo "   This environment contains intentional vulnerabilities!"
echo "   Only use in isolated lab environments!"
echo ""
echo "🎮 Good luck and happy hacking/defending!"

# Create a simple status check script
cat > check-status.sh << 'EOF'
#!/bin/bash
echo "🔍 SecureCorp Challenge Status Check"
echo "=================================="
docker-compose ps
echo ""
echo "📊 Service Health:"
services=("securecorp_portal:8080" "securecorp_elastic:9200" "securecorp_kibana:5601")
for service in "${services[@]}"; do
    name=${service%:*}
    port=${service#*:}
    if curl -s http://localhost:$port > /dev/null; then
        echo "✅ $name (http://localhost:$port)"
    else
        echo "❌ $name (http://localhost:$port)"
    fi
done
EOF

chmod +x check-status.sh
echo "📋 Status check script created: ./check-status.sh"
