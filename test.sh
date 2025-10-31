#!/bin/bash

# MarkD Test Script
# Tests if all services are working correctly

set -e

echo "🧪 Testing MarkD Installation"
echo "=============================="

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

# Test results
PASSED=0
FAILED=0

# Function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((FAILED++))
    fi
}

# Check if we're in the right directory
if [ ! -f "backend/main.py" ] || [ ! -f "frontend/package.json" ]; then
    print_error "Please run this script from the MarkD root directory"
    exit 1
fi

echo ""

# Test 1: Backend API is running
run_test "Backend API" "curl -s http://localhost:8000/"

# Test 2: Frontend is running
run_test "Frontend" "curl -s http://localhost:5173/"

# Test 3: API Documentation
run_test "API Documentation" "curl -s http://localhost:8000/docs"

# Test 4: Backend health endpoint
run_test "Backend Health" "curl -s http://localhost:8000/ | grep -q 'MarkD'"

# Test 5: Frontend HTML
run_test "Frontend HTML" "curl -s http://localhost:5173/ | grep -q '<!DOCTYPE html>'"

# Test 6: Database connection (if .env exists)
if [ -f "backend/.env" ]; then
    source backend/.env 2>/dev/null || true
    if [ ! -z "$MYSQL_DATABASE" ] && [ ! -z "$MYSQL_USER" ]; then
        run_test "Database Connection" "mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e 'SELECT 1' 2>/dev/null"
    fi
fi

# Test 7: Backend virtual environment
run_test "Python Virtual Environment" "test -d backend/venv"

# Test 8: Frontend dependencies
run_test "Node Dependencies" "test -d frontend/node_modules"

# Test 9: Log directory
run_test "Log Directory" "test -d logs"

# Test 10: Configuration file
run_test "Backend Config" "test -f backend/.env"

echo ""
echo "📊 Test Results:"
echo "================"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo "Total:  $((PASSED + FAILED))"

echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! MarkD is working correctly.${NC}"
    echo ""
    echo "📍 Next steps:"
    echo "   1. Open http://localhost:5173 in your browser"
    echo "   2. Login with admin/admin"
    echo "   3. Change the default password"
    echo "   4. Start creating documents!"
else
    echo -e "${RED}❌ Some tests failed. Please check the following:${NC}"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "   • Run './status.sh' to check service status"
    echo "   • Check logs in 'logs/' directory"
    echo "   • Make sure ports 8000 and 5173 are available"
    echo "   • Verify database configuration in backend/.env"
fi

echo ""
echo "🚀 Quick commands:"
echo "   Start services:  ./start.sh"
echo "   Stop services:   ./stop.sh"
echo "   Check status:    ./status.sh"
echo ""

exit $FAILED
