#!/bin/bash

# MarkD Service Launcher
# Simple script to start backend and frontend services

set -e

echo "🚀 Starting MarkD Service..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "backend/main.py" ] || [ ! -f "frontend/package.json" ]; then
    print_error "Please run this script from the MarkD root directory"
    exit 1
fi

# Step 1: Check Python
print_step "Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is required but not installed"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
print_status "Python version: $PYTHON_VERSION"

# Step 2: Check Node.js
print_step "Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    print_error "Node.js is required but not installed"
    exit 1
fi

NODE_VERSION=$(node --version)
print_status "Node.js version: $NODE_VERSION"

# Step 3: Check MySQL
print_step "Checking MySQL connection..."
if ! command -v mysql &> /dev/null; then
    print_warning "MySQL client not found, but server might be running"
fi

# Step 4: Backend setup
print_step "Setting up backend..."
cd backend

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    print_status "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Install Python dependencies
print_status "Installing Python dependencies..."
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt > /dev/null 2>&1

# Check .env file
if [ ! -f ".env" ]; then
    print_warning ".env file not found, creating from template..."
    cp .env.example .env
    print_warning "Please edit backend/.env with your database configuration"
fi

# Step 5: Frontend setup
print_step "Setting up frontend..."
cd ../frontend

# Install Node dependencies
if [ ! -d "node_modules" ]; then
    print_status "Installing Node.js dependencies..."
    npm install
fi

# Step 6: Database setup (optional)
print_step "Checking database..."
cd ..

if [ -f "backend/.env" ]; then
    # Try to check database connection
    source backend/.env 2>/dev/null || true
    
    if [ ! -z "$MYSQL_DATABASE" ] && [ ! -z "$MYSQL_USER" ]; then
        print_status "Database: $MYSQL_DATABASE, User: $MYSQL_USER"
        
        # Ask if user wants to setup database
        read -p "Do you want to setup/import the database now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Importing database schema..."
            mysql -u "$MYSQL_USER" -p "$MYSQL_DATABASE" < database/install.sql 2>/dev/null || print_warning "Database import failed (check credentials)"
        fi
    fi
fi

# Step 7: Start services
print_step "Starting services..."

# Create logs directory
mkdir -p logs

# Start backend in background
print_status "Starting backend on port 8000..."
cd backend
source venv/bin/activate
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > ../logs/backend.log 2>&1 &
BACKEND_PID=$!
echo $BACKEND_PID > ../logs/backend.pid

# Wait a moment for backend to start
sleep 3

# Start frontend in background
print_status "Starting frontend on port 5173..."
cd ../frontend
nohup npm run dev > ../logs/frontend.log 2>&1 &
FRONTEND_PID=$!
echo $FRONTEND_PID > ../logs/frontend.pid

# Step 8: Wait and verify
print_step "Verifying services..."
sleep 5

# Check backend
if curl -s http://localhost:8000/ > /dev/null; then
    print_status "✅ Backend is running on http://localhost:8000"
else
    print_error "❌ Backend failed to start"
    tail -10 ../logs/backend.log
fi

# Check frontend
if curl -s http://localhost:5173/ > /dev/null; then
    print_status "✅ Frontend is running on http://localhost:5173"
else
    print_error "❌ Frontend failed to start"
    tail -10 ../logs/frontend.log
fi

# Step 9: Final instructions
echo ""
echo -e "${GREEN}🎉 MarkD is starting up!${NC}"
echo ""
echo "📍 Access URLs:"
echo "   Frontend: http://localhost:5173"
echo "   Backend API: http://localhost:8000"
echo "   API Documentation: http://localhost:8000/docs"
echo ""
echo "📝 Logs:"
echo "   Backend: logs/backend.log"
echo "   Frontend: logs/frontend.log"
echo ""
echo "🛑 To stop services:"
echo "   ./stop.sh"
echo ""
echo "🔐 Default credentials:"
echo "   Username: admin"
echo "   Password: admin"
echo "   ⚠️  Change immediately after first login!"
echo ""
echo -e "${BLUE}Happy documenting! 📚${NC}"
