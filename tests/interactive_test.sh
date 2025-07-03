#!/bin/bash

# Change to project root directory
cd "$(dirname "$0")/.."

echo "=== PAM Auth Interactive Test ==="
echo
echo "Testing authentication with current user..."
echo "This will test the interactive authentication flow."
echo

# Manuel test için kullanıcıya açıklama
echo "Now testing the interactive authentication..."
echo "Username will be: $(whoami)"
echo "Password to use: demo123"
echo

# Create a temporary expect script for automated testing
cat > test_auth.exp << EOF
#!/usr/bin/expect -f
set timeout 10

spawn ./pam-auth

expect "Username: "
send "$(whoami)\r"

expect "Password: "
send "demo123\r"

expect eof
EOF

# Check if expect is available
if command -v expect > /dev/null 2>&1; then
    echo "Running automated test with expect..."
    chmod +x test_auth.exp
    ./test_auth.exp
    rm -f test_auth.exp
else
    echo "expect not found. Please run manual test:"
    echo "1. Run: ./pam-auth"
    echo "2. Enter username: $(whoami)"
    echo "3. Enter password: demo123"
    echo
    echo "Expected output should show:"
    echo "- User found message"
    echo "- Authentication successful"
    echo "- User information display"
fi

echo
echo "=== Test Instructions ==="
echo "To manually test the authentication:"
echo "./pam-auth"
echo "Username: $(whoami)"
echo "Password: demo123 (or 'password')"
echo
echo "To test with non-existent user:"
echo "./pam-auth"
echo "Username: nonexistentuser"
echo "Password: demo123"
echo
echo "To test invalid password:"
echo "./pam-auth" 
echo "Username: $(whoami)"
echo "Password: wrongpassword"
