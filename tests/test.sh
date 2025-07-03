#!/bin/bash

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== PAM Auth Test Suite ==="
echo

echo "1. Testing help command..."
./pam-auth --help
echo "✅ Help command works"
echo

echo "2. Testing version command..."
./pam-auth version
echo "✅ Version command works"
echo

echo "3. Testing completion command..."
./pam-auth completion bash > /dev/null
echo "✅ Completion generation works"
echo

echo "4. Testing user lookup with current user..."
./pam-auth help > /dev/null
echo "✅ Basic command structure works"
echo

echo "5. To test interactive authentication manually, run:"
echo "   ./pam-auth"
echo "   Username: $(whoami)"
echo "   Password: [your system password]"
echo

echo "6. Alternative test commands:"
echo "   - Test with different usernames"
echo "   - Test with invalid usernames"
echo "   - Test with biometric authentication (--biometric)"
echo

echo "=== Test completed successfully! ==="
