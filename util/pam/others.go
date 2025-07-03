//go:build !linux && !darwin
// +build !linux,!darwin

package pam

import (
	"fmt"
	"runtime"
)

// Global variables placeholders (not used on other platforms)
var UseBiometric bool
var UseRealPAM bool
var ClearBioCache bool

// AuthenticateWithRealPAM stub for non-Linux platforms
func AuthenticateWithRealPAM(username, password string) bool {
	fmt.Printf("Real PAM authentication is only available on Linux (current: %s)\n", runtime.GOOS)
	return false
}

// IsPAMAvailable stub for non-Linux platforms
func IsPAMAvailable() bool {
	return false
}

// CheckPAMPermissions stub for non-Linux platforms
func CheckPAMPermissions() bool {
	return false
}

// AuthenticateWithDSCL stub for non-Darwin platforms
func AuthenticateWithDSCL(username, password string) bool {
	fmt.Printf("macOS authentication is only available on Darwin (current: %s)\n", runtime.GOOS)
	return false
}

// IsBiometricAvailable stub for non-Darwin platforms
func IsBiometricAvailable() bool {
	return false
}

// CheckTouchIDStatus stub for non-Darwin platforms
func CheckTouchIDStatus() bool {
	return false
}

// AuthenticateWithBiometrics stub for non-Darwin platforms
func AuthenticateWithBiometrics(username string) bool {
	fmt.Printf("Biometric authentication is only available on macOS (current: %s)\n", runtime.GOOS)
	return false
}

// AuthenticateWithSecurityFramework stub for non-Darwin platforms
func AuthenticateWithSecurityFramework(username string) bool {
	fmt.Printf("Security framework authentication is only available on macOS (current: %s)\n", runtime.GOOS)
	return false
}

// AuthenticateWithAuthServices stub for non-Darwin platforms
func AuthenticateWithAuthServices(username string) bool {
	fmt.Printf("Authorization services authentication is only available on macOS (current: %s)\n", runtime.GOOS)
	return false
}
