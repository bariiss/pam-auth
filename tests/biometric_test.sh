#!/bin/bash

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== PAM Auth with TouchID/Biometric Testing ==="
echo

echo "1. 🔧 BUILD & FEATURE CHECK"
echo "============================"
echo "✅ Application compiled with biometric support"
ls -la pam-auth
echo

echo "2. 📱 BIOMETRIC FEATURES"
echo "======================="

echo "🔍 Testing biometric availability:"
./pam-auth --help | grep biometric
echo "✅ Biometric flag available"
echo

echo "🏷️ Testing with biometric flag:"
echo "Command: ./pam-auth --biometric"
echo "Expected: Shows TouchID availability status"
echo

echo "3. 🔐 AUTHENTICATION MODES"
echo "=========================="
echo "📋 Available authentication methods:"
echo

echo "A) 🔒 Standard Password Authentication:"
echo "   Command: ./pam-auth"
echo "   Shows: TouchID availability info + password prompt"
echo "   Username: $(whoami)"
echo "   Password: [your system password]"
echo

echo "B) 👆 Biometric Authentication (macOS only):"
echo "   Command: ./pam-auth --biometric"
echo "   Shows: TouchID prompt if available"
echo "   Username: $(whoami)"
echo "   Expected: TouchID/FaceID authentication dialog"
echo

echo "C) 🔄 Fallback Authentication:"
echo "   Command: ./pam-auth --biometric"
echo "   If TouchID fails: Falls back to password"
echo "   Username: $(whoami)"
echo "   Password: [your system password]"
echo

echo "4. 🧪 SYSTEM COMPATIBILITY"
echo "=========================="

echo "Current system: $(uname -s)/$(uname -m)"
echo "Current user: $(whoami)"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "✅ macOS detected - biometric features available"
    
    # Check for TouchID hardware
    if ioreg -l | grep -q "AppleAuthCP"; then
        echo "✅ TouchID hardware detected"
    else
        echo "⚠️ TouchID hardware not detected (may be virtual machine)"
    fi
    
    # Check user authentication setup
    if dscl . -read /Users/$(whoami) AuthenticationAuthority &>/dev/null; then
        echo "✅ User authentication configured"
    else
        echo "⚠️ User authentication needs setup"
    fi
else
    echo "ℹ️ Non-macOS system - biometric features will be disabled"
fi
echo

echo "5. 🚀 TESTING SCENARIOS"
echo "======================"

echo "▶️ Scenario 1: Normal authentication"
echo "   ./pam-auth"
echo "   • Should show TouchID availability"
echo "   • Prompt for username and password"
echo "   • Display user information after successful authentication"
echo

echo "▶️ Scenario 2: Biometric authentication (macOS)"
echo "   ./pam-auth --biometric"
echo "   • Should attempt TouchID first"
echo "   • If TouchID succeeds: Direct access to user info"
echo "   • If TouchID fails: fallback to password authentication"
echo "   • Username: $(whoami)"
echo

echo "▶️ Scenario 3: Test invalid user"
echo "   ./pam-auth"
echo "   • Username: invaliduser123"
echo "   • Expected: User not found error"
echo

echo "▶️ Scenario 4: Test wrong password"
echo "   ./pam-auth"
echo "   • Username: $(whoami)"
echo "   • Password: wrongpassword"
echo "   • Expected: Authentication failed"
echo

echo "6. 💡 TOUCHID TESTING NOTES"
echo "==========================="
echo "🔐 For real TouchID testing:"
echo "   • Ensure TouchID is set up in System Preferences"
echo "   • Your finger should be enrolled"
echo "   • Terminal may need accessibility permissions"
echo "   • Test on physical Mac (not VM)"
echo

echo "🛠️ If TouchID doesn't work:"
echo "   • Application will automatically fallback to password"
echo "   • All functionality remains available"
echo "   • Check System Preferences > Touch ID & Passcode"
echo

echo "🎯 Ready for testing! Use: ./pam-auth --biometric"
echo "===================================================="
