# PAM Authentication Tool Makefile
# ===================================

# Variables
GO_MODULE = github.com/bariiss/pam-auth
BINARY_NAME = pam-auth
MAIN_FILE = main.go

# Go build flags
BUILD_FLAGS = -v
RELEASE_FLAGS = -ldflags="-s -w"
DEBUG_FLAGS = -gcflags="-N -l"

# Colors for output
GREEN = \033[32m
YELLOW = \033[33m
RED = \033[31m
BLUE = \033[34m
RESET = \033[0m

.PHONY: help build run test clean install dev

# Default target
help:
	@echo "$(GREEN)PAM Authentication Tool - Makefile Commands$(RESET)"
	@echo "=================================================="
	@echo "$(YELLOW)Build Commands:$(RESET)"
	@echo "  make build         - Build the application binary"
	@echo "  make build-release - Build optimized release binary"
	@echo "  make build-debug   - Build debug binary with symbols"
	@echo ""
	@echo "$(YELLOW)Run Commands:$(RESET)"
	@echo "  make run           - Run with go run (no build)"
	@echo "  make run-bio       - Run with biometric authentication"
	@echo "  make run-bio-clear - Run with biometric authentication (cache cleared)"
	@echo "  make run-pam       - Run with real PAM authentication (Linux)"
	@echo "  make run-pam       - Run with real PAM authentication (Linux)"
	@echo "  make run-help      - Show application help"
	@echo "  make run-version   - Show application version"
	@echo ""
	@echo "$(YELLOW)Test Commands:$(RESET)"
	@echo "  make test          - Run basic test suite"
	@echo "  make test-bio      - Run biometric test suite"
	@echo "  make test-comprehensive - Run comprehensive test suite"
	@echo "  make test-interactive    - Run interactive test"
	@echo "  make test-all      - Run all test suites"
	@echo ""
	@echo "$(YELLOW)Development Commands:$(RESET)"
	@echo "  make dev           - Start development server (build + run)"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make install       - Install dependencies"
	@echo "  make format        - Format Go code"
	@echo "  make lint          - Run linter"
	@echo "  make vet           - Run go vet"

# Build commands
build:
	@echo "$(BLUE)Building $(BINARY_NAME)...$(RESET)"
	go build $(BUILD_FLAGS) -o $(BINARY_NAME) $(MAIN_FILE)
	@echo "$(GREEN)✅ Build completed: $(BINARY_NAME)$(RESET)"

build-release:
	@echo "$(BLUE)Building release version...$(RESET)"
	go build $(BUILD_FLAGS) $(RELEASE_FLAGS) -o $(BINARY_NAME) $(MAIN_FILE)
	@echo "$(GREEN)✅ Release build completed$(RESET)"

build-debug:
	@echo "$(BLUE)Building debug version...$(RESET)"
	go build $(BUILD_FLAGS) $(DEBUG_FLAGS) -o $(BINARY_NAME)-debug $(MAIN_FILE)
	@echo "$(GREEN)✅ Debug build completed$(RESET)"

# Run commands (using go run - no build required)
run:
	@echo "$(BLUE)Running PAM Auth Tool (go run)...$(RESET)"
	go run $(MAIN_FILE)

run-bio:
	@echo "$(BLUE)Running with biometric authentication...$(RESET)"
	go run $(MAIN_FILE) --biometric

run-bio-clear:
	@echo "$(BLUE)Running with biometric authentication (cache cleared)...$(RESET)"
	go run $(MAIN_FILE) --biometric --clear-cache

run-pam:
	@echo "$(BLUE)Running with real PAM authentication...$(RESET)"
	go run $(MAIN_FILE) --real-pam

run-help:
	@echo "$(BLUE)Showing help...$(RESET)"
	go run $(MAIN_FILE) --help

run-version:
	@echo "$(BLUE)Showing version...$(RESET)"
	go run $(MAIN_FILE) version

# Test commands
test:
	@echo "$(BLUE)Running basic test suite...$(RESET)"
	chmod +x tests/test.sh
	./tests/test.sh

test-bio:
	@echo "$(BLUE)Running biometric test suite...$(RESET)"
	chmod +x tests/biometric_test.sh
	./tests/biometric_test.sh

test-comprehensive:
	@echo "$(BLUE)Running comprehensive test suite...$(RESET)"
	chmod +x tests/comprehensive_test.sh
	./tests/comprehensive_test.sh

test-interactive:
	@echo "$(BLUE)Running interactive test...$(RESET)"
	chmod +x tests/interactive_test.sh
	./tests/interactive_test.sh

test-all: test test-bio test-comprehensive
	@echo "$(GREEN)✅ All tests completed$(RESET)"

# Development commands
dev: build run

install:
	@echo "$(BLUE)Installing dependencies...$(RESET)"
	go mod download
	go mod tidy
	@echo "$(GREEN)✅ Dependencies installed$(RESET)"

format:
	@echo "$(BLUE)Formatting Go code...$(RESET)"
	go fmt ./...
	@echo "$(GREEN)✅ Code formatted$(RESET)"

lint:
	@echo "$(BLUE)Running golint...$(RESET)"
	golint ./...

vet:
	@echo "$(BLUE)Running go vet...$(RESET)"
	go vet ./...

clean:
	@echo "$(BLUE)Cleaning build artifacts...$(RESET)"
	rm -f $(BINARY_NAME)
	rm -f $(BINARY_NAME)-debug
	go clean
	@echo "$(GREEN)✅ Clean completed$(RESET)"

# Platform specific targets
macos-bio:
	@echo "$(BLUE)Running macOS biometric authentication...$(RESET)"
	go run $(MAIN_FILE) --biometric

linux-pam:
	@echo "$(BLUE)Running Linux PAM authentication...$(RESET)"
	go run $(MAIN_FILE) --real-pam
