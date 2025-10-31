#!/bin/bash

# MarkD Service Stopper
# Stops backend and frontend services

set -e

echo "🛑 Stopping MarkD Service..."

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

# Create logs directory if it doesn't exist
mkdir -p logs

# Stop backend
if [ -f "logs/backend.pid" ]; then
    BACKEND_PID=$(cat logs/backend.pid)
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        print_step "Stopping backend (PID: $BACKEND_PID)..."
        kill $BACKEND_PID
        sleep 2
        
        # Force kill if still running
        if ps -p $BACKEND_PID > /dev/null 2>&1; then
            print_warning "Force killing backend..."
            kill -9 $BACKEND_PID
        fi
        
        print_status "✅ Backend stopped"
    else
        print_warning "Backend process not found"
    fi
    rm -f logs/backend.pid
else
    print_warning "Backend PID file not found"
fi

# Stop frontend
if [ -f "logs/frontend.pid" ]; then
    FRONTEND_PID=$(cat logs/frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        print_step "Stopping frontend (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID
        sleep 2
        
        # Force kill if still running
        if ps -p $FRONTEND_PID > /dev/null 2>&1; then
            print_warning "Force killing frontend..."
            kill -9 $FRONTEND_PID
        fi
        
        print_status "✅ Frontend stopped"
    else
        print_warning "Frontend process not found"
    fi
    rm -f logs/frontend.pid
else
    print_warning "Frontend PID file not found"
fi

# Additional cleanup: kill any remaining uvicorn or npm processes
print_step "Cleaning up remaining processes..."

# Kill any uvicorn processes on port 8000
pkill -f "uvicorn.*:8000" 2>/dev/null || true

# Kill any npm dev processes on port 5173
pkill -f "npm.*dev.*5173" 2>/dev/null || true

print_status "✅ Cleanup completed"

echo ""
echo -e "${GREEN}🎉 MarkD services stopped successfully!${NC}"
echo ""
echo "📝 Logs are still available in:"
echo "   Backend: logs/backend.log"
echo "   Frontend: logs/frontend.log"
echo ""
echo "🚀 To restart services:"
echo "   ./start.sh"
echo ""
