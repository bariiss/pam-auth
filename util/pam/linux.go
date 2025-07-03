//go:build linux && pam
// +build linux,pam

package pam

import (
	"fmt"
	"os"
	"runtime"

	"github.com/msteinert/pam"
)

// Global variables to track usage (will be set from main package)
var UseRealPAM bool
var UseBiometric bool
var ClearBioCache bool

// AuthenticateWithRealPAM performs real PAM authentication on Linux
func AuthenticateWithRealPAM(username, password string) bool {
	if runtime.GOOS != "linux" {
		fmt.Println("Real PAM authentication is only available on Linux")
		return false
	}

	fmt.Printf("🔐 Attempting real PAM authentication for user: %s\n", username)

	// Start PAM transaction
	t, err := pam.StartFunc("login", username, func(s pam.Style, msg string) (string, error) {
		switch s {
		case pam.PromptEchoOff:
			// Password prompt
			return password, nil
		case pam.PromptEchoOn:
			// Username prompt
			return username, nil
		case pam.ErrorMsg:
			fmt.Printf("PAM Error: %s\n", msg)
			return "", nil
		case pam.TextInfo:
			fmt.Printf("PAM Info: %s\n", msg)
			return "", nil
		}
		return "", fmt.Errorf("unknown PAM style: %v", s)
	})

	if err != nil {
		fmt.Printf("❌ PAM Start failed: %v\n", err)
		return false
	}

	// Perform authentication
	err = t.Authenticate(0)
	if err != nil {
		fmt.Printf("❌ PAM Authentication failed: %v\n", err)
		return false
	}

	// Account management check
	err = t.AcctMgmt(0)
	if err != nil {
		fmt.Printf("❌ PAM Account management failed: %v\n", err)
		return false
	}

	fmt.Println("✅ Real PAM authentication successful!")
	return true
}

// IsPAMAvailable checks if PAM authentication is available on the system
func IsPAMAvailable() bool {
	if runtime.GOOS != "linux" {
		return false
	}

	// Check if PAM is available by looking for PAM modules
	_, err := os.Stat("/etc/pam.d/login")
	if err != nil {
		return false
	}

	// Check if we have sufficient permissions
	// This is a basic check - real PAM requires appropriate privileges
	return true
}

// CheckPAMPermissions checks if the current user has permissions for PAM
func CheckPAMPermissions() bool {
	// Check if running as root or with appropriate capabilities
	if os.Geteuid() == 0 {
		return true
	}

	// Check for CAP_AUDIT_WRITE capability (simplified check)
	// In a real implementation, you'd check for proper capabilities
	return false
}

// Darwin-specific function stubs for Linux builds
// AuthenticateWithDSCL stub for Linux (not available)
func AuthenticateWithDSCL(username, password string) bool {
	fmt.Printf("macOS authentication is only available on Darwin (current: %s)\n", runtime.GOOS)
	return false
}

// IsBiometricAvailable stub for Linux (not available)
func IsBiometricAvailable() bool {
	return false
}

// CheckTouchIDStatus stub for Linux (not available)
func CheckTouchIDStatus() bool {
	return false
}

// AuthenticateWithBiometrics stub for Linux (not available)
func AuthenticateWithBiometrics(username string) bool {
	fmt.Printf("Biometric authentication is only available on macOS (current: %s)\n", runtime.GOOS)
	return false
}

// AuthenticateWithSecurityFramework stub for Linux (not available)
func AuthenticateWithSecurityFramework(username string) bool {
	fmt.Printf("Security framework authentication is only available on macOS (current: %s)\n", runtime.GOOS)
	return false
}

// AuthenticateWithAuthServices stub for Linux (not available)
func AuthenticateWithAuthServices(username string) bool {
	fmt.Printf("Authorization services authentication is only available on macOS (current: %s)\n", runtime.GOOS)
	return false
}
