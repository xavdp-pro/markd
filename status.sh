#!/bin/bash

# MarkD Service Status Checker
# Shows the status of backend and frontend services

set -e

echo "📊 MarkD Service Status"
echo "======================="

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

echo ""

# Backend status
echo "🔧 Backend Service:"
echo "-------------------"

if [ -f "logs/backend.pid" ]; then
    BACKEND_PID=$(cat logs/backend.pid)
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        echo -e "Status: ${GREEN}RUNNING${NC} (PID: $BACKEND_PID)"
        
        # Check if backend is responding
        if curl -s http://localhost:8000/ > /dev/null 2>&1; then
            echo -e "Health: ${GREEN}✅ Responding${NC} on http://localhost:8000"
        else
            echo -e "Health: ${RED}❌ Not responding${NC} on http://localhost:8000"
        fi
        
        # Show memory usage
        MEMORY=$(ps -p $BACKEND_PID -o rss= 2>/dev/null | tr -d ' ')
        if [ ! -z "$MEMORY" ]; then
            MEMORY_MB=$((MEMORY / 1024))
            echo "Memory: ${MEMORY_MB} MB"
        fi
    else
        echo -e "Status: ${RED}STOPPED${NC} (PID file exists but process not found)"
    fi
else
    echo -e "Status: ${RED}STOPPED${NC} (No PID file)"
fi

echo ""

# Frontend status
echo "🎨 Frontend Service:"
echo "--------------------"

if [ -f "logs/frontend.pid" ]; then
    FRONTEND_PID=$(cat logs/frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        echo -e "Status: ${GREEN}RUNNING${NC} (PID: $FRONTEND_PID)"
        
        # Check if frontend is responding
        if curl -s http://localhost:5173/ > /dev/null 2>&1; then
            echo -e "Health: ${GREEN}✅ Responding${NC} on http://localhost:5173"
        else
            echo -e "Health: ${RED}❌ Not responding${NC} on http://localhost:5173"
        fi
        
        # Show memory usage
        MEMORY=$(ps -p $FRONTEND_PID -o rss= 2>/dev/null | tr -d ' ')
        if [ ! -z "$MEMORY" ]; then
            MEMORY_MB=$((MEMORY / 1024))
            echo "Memory: ${MEMORY_MB} MB"
        fi
    else
        echo -e "Status: ${RED}STOPPED${NC} (PID file exists but process not found)"
    fi
else
    echo -e "Status: ${RED}STOPPED${NC} (No PID file)"
fi

echo ""

# Port check
echo "🔌 Port Usage:"
echo "--------------"

if command -v netstat &> /dev/null; then
    if netstat -tuln 2>/dev/null | grep ":8000" > /dev/null; then
        echo -e "Port 8000 (Backend): ${GREEN}IN USE${NC}"
    else
        echo -e "Port 8000 (Backend): ${RED}FREE${NC}"
    fi
    
    if netstat -tuln 2>/dev/null | grep ":5173" > /dev/null; then
        echo -e "Port 5173 (Frontend): ${GREEN}IN USE${NC}"
    else
        echo -e "Port 5173 (Frontend): ${RED}FREE${NC}"
    fi
else
    echo "netstat not available, cannot check ports"
fi

echo ""

# Recent logs
echo "📝 Recent Logs (last 5 lines each):"
echo "--------------------------------------"

if [ -f "logs/backend.log" ]; then
    echo "Backend:"
    tail -5 logs/backend.log | sed 's/^/  /'
else
    echo "Backend: No log file"
fi

echo ""

if [ -f "logs/frontend.log" ]; then
    echo "Frontend:"
    tail -5 logs/frontend.log | sed 's/^/  /'
else
    echo "Frontend: No log file"
fi

echo ""

# Quick actions
echo "🚀 Quick Actions:"
echo "----------------"
echo "Start services:  ./start.sh"
echo "Stop services:   ./stop.sh"
echo "View logs:       tail -f logs/backend.log"
echo "API docs:        http://localhost:8000/docs"
echo "Frontend:        http://localhost:5173"

echo ""
