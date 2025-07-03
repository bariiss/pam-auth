#!/bin/bash

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== Linux PAM Authentication Testing Guide ==="
echo

echo "1. 🔧 SYSTEM REQUIREMENTS"
echo "========================="
echo "For real PAM authentication on Linux, you need:"
echo "• Linux operating system"
echo "• PAM development libraries: sudo apt-get install libpam0g-dev"
echo "• Root privileges or appropriate capabilities"
echo "• User account with valid password"
echo

echo "2. 📱 AUTHENTICATION MODES"
echo "=========================="

echo "🔍 Available authentication methods:"
echo

echo "A) 🔒 Demo Password Authentication (All platforms):"
echo "   Command: ./pam-auth"
echo "   Uses demo passwords: demo123, password"
echo "   Works on: macOS, Linux, Windows"
echo

echo "B) 👆 TouchID Authentication (macOS only):"
echo "   Command: ./pam-auth --biometric"
echo "   Uses TouchID/FaceID if available"
echo "   Fallback to password if fails"
echo

echo "C) 🔑 Real PAM Authentication (Linux only):"
echo "   Command: ./pam-auth --real-pam"
echo "   Uses actual system passwords"
echo "   Requires proper permissions"
echo

echo "D) 🔄 Combined Authentication:"
echo "   Command: ./pam-auth --biometric --real-pam"
echo "   Uses biometric on macOS, real PAM on Linux"
echo

echo "3. 🐧 LINUX SETUP INSTRUCTIONS"
echo "==============================="

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "✅ Linux detected!"
    echo
    echo "Installation commands:"
    echo "# Update package list"
    echo "sudo apt-get update"
    echo
    echo "# Install PAM development libraries"
    echo "sudo apt-get install libpam0g-dev"
    echo
    echo "# Download PAM Go module (when building)"
    echo "go get github.com/msteinert/pam"
    echo
    echo "# Build for Linux"
    echo "GOOS=linux go build -o pam-auth-linux"
    echo
    
    # Check if PAM is available
    if [ -f "/etc/pam.d/login" ]; then
        echo "✅ PAM configuration found at /etc/pam.d/login"
    else
        echo "⚠️ PAM configuration not found"
    fi
    
    # Check for PAM dev libraries
    if pkg-config --exists pam 2>/dev/null; then
        echo "✅ PAM development libraries are installed"
    else
        echo "⚠️ PAM development libraries not found"
        echo "   Install with: sudo apt-get install libpam0g-dev"
    fi
    
else
    echo "ℹ️ Current system: $OSTYPE"
    echo "Real PAM authentication is only available on Linux"
    echo
    echo "For Linux testing, use:"
    echo "• Ubuntu/Debian: sudo apt-get install libpam0g-dev"
    echo "• CentOS/RHEL: sudo yum install pam-devel"
    echo "• Fedora: sudo dnf install pam-devel"
fi
echo

echo "4. 🧪 TESTING SCENARIOS"
echo "======================"

echo "▶️ Scenario 1: Basic authentication test"
echo "   ./pam-auth"
echo "   • Works on all platforms"
echo "   • Shows available authentication methods"
echo "   • Use demo passwords: demo123, password"
echo

echo "▶️ Scenario 2: Real PAM test (Linux + sudo)"
echo "   sudo ./pam-auth --real-pam"
echo "   • Linux only"
echo "   • Uses actual system passwords"
echo "   • Validates against /etc/shadow"
echo

echo "▶️ Scenario 3: Permission test"
echo "   ./pam-auth --real-pam"
echo "   • Should show permission warning"
echo "   • Falls back to demo authentication"
echo

echo "▶️ Scenario 4: Cross-platform test"
echo "   # On macOS"
echo "   ./pam-auth --biometric"
echo "   # On Linux"
echo "   sudo ./pam-auth --real-pam"
echo

echo "5. 🔐 SECURITY NOTES"
echo "==================="
echo "⚠️ Real PAM Authentication:"
echo "   • Requires root privileges"
echo "   • Uses actual system passwords"
echo "   • Logs authentication attempts"
echo "   • Production security implications"
echo

echo "✅ Demo Authentication:"
echo "   • Safe for testing"
echo "   • No system impact"
echo "   • Educational purposes"
echo

echo "🛡️ Best Practices:"
echo "   • Test in isolated environment"
echo "   • Don't use real passwords in logs"
echo "   • Monitor authentication logs"
echo "   • Use proper capability management"
echo

echo "6. 🚀 READY FOR TESTING!"
echo "========================"
echo "Current platform: $(uname -s)/$(uname -m)"
echo

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Linux commands:"
    echo "   Demo auth:  ./pam-auth"
    echo "   Real PAM:   sudo ./pam-auth --real-pam"
    echo "   Check logs: sudo journalctl -u systemd-logind"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 macOS commands:"
    echo "   Demo auth:  ./pam-auth"
    echo "   TouchID:    ./pam-auth --biometric"
    echo "   Real PAM:   ./pam-auth --real-pam (shows not available)"
else
    echo "🖥️ Other platform commands:"
    echo "   Demo auth:  ./pam-auth"
    echo "   Real PAM:   ./pam-auth --real-pam (shows not available)"
fi

echo
echo "🎯 Start testing with your platform-specific commands above!"
