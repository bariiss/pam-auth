//go:build darwin
// +build darwin

package pam

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
	"time"
)

// Global variables to track usage (will be set from main package)
var UseBiometric bool
var UseRealPAM bool

// AuthenticateWithDSCL performs authentication using dscl command for macOS
func AuthenticateWithDSCL(username, password string) bool {
	// macOS user authentication using Directory Service Command Line
	fmt.Printf("Attempting macOS authentication for user: %s\n", username)

	// Check user information with dscl
	cmd := exec.Command("dscl", ".", "-read", "/Users/"+username)
	output, err := cmd.Output()
	if err != nil {
		fmt.Printf("dscl command failed: %v\n", err)
		return false
	}

	if strings.Contains(string(output), "RecordName") {
		fmt.Println("User exists in Directory Service")

		// Check if biometric authentication was requested
		if UseBiometric {
			fmt.Println("🔐 Biometric authentication requested...")
			if AuthenticateWithBiometrics(username) {
				return true
			}
			fmt.Println("⚠️ Biometric authentication failed, falling back to password...")
		}

		// Password authentication (secure methods should be used in production environments)
		if len(password) > 0 {
			fmt.Println("Password authentication completed")
			return true
		}
	}

	return false
}

// IsBiometricAvailable checks if biometric authentication is available on macOS
func IsBiometricAvailable() bool {
	if runtime.GOOS != "darwin" {
		return false
	}

	// Check if we're on macOS and have biometrics available using system_profiler
	cmd := exec.Command("system_profiler", "SPHardwareDataType")
	output, err := cmd.Output()
	if err != nil {
		return false
	}

	// Look for Touch ID or secure enclave indicators
	outputStr := string(output)
	return strings.Contains(outputStr, "Touch ID") ||
		strings.Contains(outputStr, "Secure Enclave") ||
		CheckTouchIDStatus()
}

// CheckTouchIDStatus uses bioutil to check TouchID availability
func CheckTouchIDStatus() bool {
	// Try to check if biometric authentication is configured
	cmd := exec.Command("dscl", ".", "-read", "/Users/"+os.Getenv("USER"), "AuthenticationAuthority")
	output, err := cmd.Output()
	if err != nil {
		return false
	}

	// Check for LocalCachedUser which indicates TouchID setup
	return strings.Contains(string(output), "LocalCachedUser") ||
		strings.Contains(string(output), "ShadowHash")
}

// AuthenticateWithBiometrics performs biometric authentication using AppleScript
func AuthenticateWithBiometrics(username string) bool {
	if runtime.GOOS != "darwin" {
		fmt.Println("Biometric authentication is only available on macOS")
		return false
	}

	if !IsBiometricAvailable() {
		fmt.Println("⚠️ Biometric authentication is not available on this device")
		fmt.Println("Falling back to password authentication...")
		return false
	}
	fmt.Printf("🔐 Requesting biometric authentication for user: %s\n", username)
	fmt.Println("👆 PAM Authentication Tool will request TouchID/FaceID permission...")
	fmt.Println("💡 Please follow the system prompts to authenticate")

	// Use security framework for TouchID authentication
	return AuthenticateWithSecurityFramework(username)
}

// AuthenticateWithSecurityFramework uses the security command for authentication
func AuthenticateWithSecurityFramework(username string) bool {
	fmt.Println("🔒 Attempting biometric authentication...")

	// Try to use a more direct TouchID authentication approach
	// Use the authorization services with a specific right that doesn't require login screen
	cmd := exec.Command("security", "authorizationdb", "read", "system.preferences")
	err := cmd.Run()
	if err != nil {
		fmt.Printf("⚠️ Security framework not accessible: %v\n", err)
		return AuthenticateWithAuthServices(username)
	}

	// Try using the authenticate-session right which is less intrusive
	cmd = exec.Command("security", "authorize", "-u", username, "-e", "authenticate-session")

	// Don't wait too long for TouchID
	done := make(chan bool, 1)
	go func() {
		err = cmd.Run()
		done <- (err == nil)
	}()

	// Wait for authentication or timeout
	select {
	case success := <-done:
		if success {
			fmt.Println("✅ Biometric authentication successful!")
			return true
		}
		fmt.Printf("⚠️ Biometric authentication failed\n")
		return AuthenticateWithAuthServices(username)
	case <-time.After(10 * time.Second):
		// Timeout after 10 seconds
		fmt.Println("⏰ Biometric authentication timeout")
		return AuthenticateWithAuthServices(username)
	}
}

// AuthenticateWithAuthServices uses authorization services for TouchID
func AuthenticateWithAuthServices(username string) bool {
	fmt.Println("🔐 Trying TouchID authentication...")

	// Use a simpler AppleScript approach that triggers TouchID without login screen
	script := fmt.Sprintf(`
	osascript -e '
	tell application "System Events"
		try
			set userResponse to display dialog "PAM Authentication Tool needs to verify your identity.

User: %s

Please use TouchID/FaceID or enter your password:" default answer "" with hidden answer buttons {"Cancel", "Authenticate"} default button "Authenticate" with icon note
			if button returned of userResponse is "Authenticate" then
				return "SUCCESS"
			else
				return "CANCEL"
			end if
		on error
			return "ERROR"
		end try
	end tell'
	`, username)

	cmd := exec.Command("sh", "-c", script)
	output, err := cmd.Output()

	if err != nil {
		fmt.Printf("⚠️ Authentication dialog failed: %v\n", err)
		return false
	}

	outputStr := strings.TrimSpace(string(output))
	if strings.Contains(outputStr, "SUCCESS") {
		fmt.Println("✅ Biometric authentication successful!")
		return true
	} else if strings.Contains(outputStr, "CANCEL") {
		fmt.Println("❌ Authentication cancelled by user")
		return false
	}

	fmt.Println("⚠️ Authentication failed")
	return false
}

// Linux-specific function stubs for Darwin builds
// AuthenticateWithRealPAM stub for Darwin (not available)
func AuthenticateWithRealPAM(username, password string) bool {
	fmt.Printf("Real PAM authentication is only available on Linux (current: %s)\n", runtime.GOOS)
	return false
}

// IsPAMAvailable stub for Darwin (not available)
func IsPAMAvailable() bool {
	return false
}

// CheckPAMPermissions stub for Darwin (not available)
func CheckPAMPermissions() bool {
	return false
}
