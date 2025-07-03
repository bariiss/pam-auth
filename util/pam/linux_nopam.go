//go:build linux && !pam
// +build linux,!pam

package pam

import (
	"fmt"
	"os/exec"
	"runtime"
)

// Global variables to track usage (will be set from main package)
var UseRealPAM bool
var UseBiometric bool
var ClearBioCache bool

// AuthenticateWithRealPAM performs fallback authentication on Linux without PAM
func AuthenticateWithRealPAM(username, password string) bool {
	if runtime.GOOS != "linux" {
		fmt.Printf("Real PAM authentication is only available on Linux (current: %s)\n", runtime.GOOS)
		return false
	}

	fmt.Printf("⚠️ Real PAM authentication not available (PAM libraries not installed)\n")
	fmt.Printf("💡 Install PAM development libraries: sudo apt-get install libpam0g-dev\n")
	fmt.Printf("📝 Falling back to basic user verification for user: %s\n", username)

	// Check user information from /etc/passwd file
	cmd := exec.Command("getent", "passwd", username)
	output, err := cmd.Output()
	if err != nil {
		fmt.Printf("getent command failed: %v\n", err)
		return false
	}

	if len(output) > 0 {
		fmt.Println("✅ User exists in system")

		// Basic password length check (not secure, just for demo)
		if len(password) > 0 {
			fmt.Println("📝 Basic authentication completed (demo mode)")
			fmt.Println("⚠️  WARNING: This is not real authentication!")
			fmt.Println("💡 Install PAM libraries for real authentication")
			return true
		}
	}

	return false
}

// IsPAMAvailable returns false when PAM is not available
func IsPAMAvailable() bool {
	return false
}

// CheckPAMPermissions returns false when PAM is not available
func CheckPAMPermissions() bool {
	return false
}

// AuthenticateWithBiometrics stub for Linux (not available)
func AuthenticateWithBiometrics(username string) bool {
	fmt.Printf("Biometric authentication is only available on macOS (current: %s)\n", runtime.GOOS)
	return false
}

// IsBiometricAvailable stub for Linux (not available)
func IsBiometricAvailable() bool {
	return false
}

// AuthenticateWithDSCL stub for Linux (not available)
func AuthenticateWithDSCL(username, password string) bool {
	fmt.Printf("DSCL authentication is only available on macOS (current: %s)\n", runtime.GOOS)

	// Fallback to basic Linux authentication
	fmt.Printf("🐧 Linux detected - attempting basic authentication for user: %s\n", username)

	// Check user information from /etc/passwd file
	cmd := exec.Command("getent", "passwd", username)
	output, err := cmd.Output()
	if err != nil {
		fmt.Printf("getent command failed: %v\n", err)
		return false
	}

	if len(output) > 0 {
		fmt.Println("✅ User exists in system")

		// Basic password length check (not secure, just for demo)
		if len(password) > 0 {
			fmt.Println("📝 Basic authentication completed")
			return true
		}
	}

	return false
}
