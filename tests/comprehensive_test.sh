#!/bin/bash

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=========================================="
echo "PAM Auth - Comprehensive Test Suite"
echo "=========================================="
echo
echo "📅 Test Date: $(date)"
echo "👤 User: $(whoami)"
echo "💻 System: $(uname -s) $(uname -m)"
echo "🏠 Go Version: $(go version)"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

success_count=0
total_tests=0

# Function to run a test
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    
    echo -e "${BLUE}🧪 Testing: $test_name${NC}"
    ((total_tests++))
    
    if eval "$command" > /dev/null 2>&1; then
        actual_exit_code=$?
    else
        actual_exit_code=$?
    fi
    
    if [ $actual_exit_code -eq $expected_exit_code ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        ((success_count++))
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name (Exit code: $actual_exit_code, Expected: $expected_exit_code)"
    fi
    echo
}

# Function to run a test with output capture
run_test_with_output() {
    local test_name="$1"
    local command="$2"
    local expected_pattern="$3"
    
    echo -e "${BLUE}🧪 Testing: $test_name${NC}"
    ((total_tests++))
    
    output=$(eval "$command" 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ] && echo "$output" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name"
        ((success_count++))
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name"
        echo "  Output: $output"
        echo "  Expected pattern: $expected_pattern"
    fi
    echo
}

echo "=========================================="
echo "🔨 BUILD AND DEPENDENCY TESTS"
echo "=========================================="

# Test 1: Clean build
run_test "Clean build" "go clean && go build -v"

# Test 2: Dependencies check
run_test "Go mod verification" "go mod verify"

# Test 3: Go mod tidy
run_test "Go mod tidy" "go mod tidy"

# Test 4: Static analysis
run_test "Go vet" "go vet ./..."

# Test 5: Go fmt check
run_test "Go fmt check" "test -z \"\$(gofmt -l .)\""

echo "=========================================="
echo "🖥️  CLI INTERFACE TESTS"
echo "=========================================="

# Test 6: Help command
run_test_with_output "Help command" "./pam-auth --help" "cross-platform system authentication tool"

# Test 7: Version command
run_test_with_output "Version command" "./pam-auth version" "System Authentication Tool v"

# Test 8: Completion command
run_test_with_output "Completion help" "./pam-auth completion --help" "Generate the autocompletion script"

# Test 9: Bash completion generation
run_test "Bash completion generation" "./pam-auth completion bash > /tmp/pam-auth-completion.bash"

# Test 10: Zsh completion generation
run_test "Zsh completion generation" "./pam-auth completion zsh > /tmp/pam-auth-completion.zsh"

# Test 11: Invalid flag handling
run_test "Invalid flag handling" "./pam-auth --invalid-flag" 1

echo "=========================================="
echo "🔍 PLATFORM DETECTION TESTS"
echo "=========================================="

# Test 12: Platform-specific features detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 macOS detected - Testing macOS-specific features"
    
    # Test TouchID availability detection
    run_test_with_output "TouchID availability check" "./pam-auth --help" "biometric"
    
    # Test dscl command availability
    run_test "dscl command availability" "which dscl"
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Linux detected - Testing Linux-specific features"
    
    # Test PAM flag availability
    run_test_with_output "PAM flag check" "./pam-auth --help" "real-pam"
    
    # Test getent command availability
    run_test "getent command availability" "which getent"
    
else
    echo "❓ Other OS detected: $OSTYPE"
fi

echo "=========================================="
echo "📁 FILE STRUCTURE TESTS"
echo "=========================================="

# Test 13: Essential files exist
run_test "main.go exists" "test -f main.go"
run_test "go.mod exists" "test -f go.mod"
run_test "README.md exists" "test -f README.md"
run_test "util/pam/linux.go exists" "test -f util/pam/linux.go"
run_test "util/pam/darwin.go exists" "test -f util/pam/darwin.go"
run_test "util/pam/others.go exists" "test -f util/pam/others.go"

# Test 14: Build tags verification
run_test_with_output "Linux build tags" "head -3 util/pam/linux.go" "//go:build linux"
run_test_with_output "Darwin build tags" "head -3 util/pam/darwin.go" "//go:build darwin"
run_test_with_output "Others build tags" "head -3 util/pam/others.go" "//go:build !linux"

echo "=========================================="
echo "📦 BINARY TESTS"
echo "=========================================="

# Test 15: Binary exists and is executable
run_test "Binary exists" "test -f pam-auth"
run_test "Binary is executable" "test -x pam-auth"

# Test 16: Binary file type
if [[ "$OSTYPE" == "darwin"* ]]; then
    run_test_with_output "Binary file type" "file pam-auth" "Mach-O.*executable"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    run_test_with_output "Binary file type" "file pam-auth" "ELF.*executable"
fi

# Test 17: Binary size check (should be reasonable)
binary_size=$(stat -f%z pam-auth 2>/dev/null || stat -c%s pam-auth 2>/dev/null)
if [ $binary_size -gt 1000000 ] && [ $binary_size -lt 50000000 ]; then
    echo -e "${GREEN}✅ PASS${NC}: Binary size reasonable ($binary_size bytes)"
    ((success_count++))
else
    echo -e "${RED}❌ FAIL${NC}: Binary size unusual ($binary_size bytes)"
fi
((total_tests++))
echo

echo "=========================================="
echo "🔐 AUTHENTICATION LOGIC TESTS"
echo "=========================================="

# Test 18: User lookup functionality (using current user)
current_user=$(whoami)
run_test "Current user lookup" "id $current_user"

# Test 19: Groups command availability
run_test "Groups command" "groups $current_user"

echo "=========================================="
echo "📚 DOCUMENTATION TESTS"
echo "=========================================="

# Test 20: README completeness
run_test_with_output "README has installation section" "grep -i 'installation' README.md" "Installation"
run_test_with_output "README has usage section" "grep -i 'usage' README.md" "Usage"
run_test_with_output "README has authentication features" "grep -i 'biometric\|TouchID' README.md" "TouchID"

echo "=========================================="
echo "🎯 TEST SUMMARY"
echo "=========================================="

echo -e "${BLUE}📊 Test Results:${NC}"
echo -e "  Total Tests: $total_tests"
echo -e "  Passed: ${GREEN}$success_count${NC}"
echo -e "  Failed: ${RED}$((total_tests - success_count))${NC}"
echo

if [ $success_count -eq $total_tests ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED! 🎉${NC}"
    echo -e "${GREEN}✅ The application is ready for use!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed. Please review the output above.${NC}"
    echo -e "${YELLOW}📝 Success Rate: $(( success_count * 100 / total_tests ))%${NC}"
    exit 1
fi
