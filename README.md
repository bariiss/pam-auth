# PAM Authentication Tool

A cross-platform system authentication tool that supports both password and biometric authentication methods.

## Features

- ✅ System user existence check
- ✅ Cross-platform support (macOS, Linux)
- ✅ Secure password input (hidden in terminal)
- ✅ Detailed user information display
- ✅ User group information
- ✅ Cross-platform authentication system
- ✅ Cobra CLI framework for command handling
- 🔐 TouchID/FaceID biometric authentication (macOS only)
- 🔄 Automatic fallback from biometric to password
- 🔑 Real PAM authentication support (Linux only)

## Installation

### Quick Start (Any Platform)
```bash
# Run directly from GitHub (no local installation needed)
go run github.com/bariiss/pam-auth@latest

# With flags
go run github.com/bariiss/pam-auth@latest --biometric
go run github.com/bariiss/pam-auth@latest --help
```

### Local Development Setup
```bash
# Clone the repository
git clone https://github.com/bariiss/pam-auth.git
cd pam-auth

# Install dependencies
make install

# Build the application
make build

# Run the application
./pam-auth
```

### Linux PAM Support (Optional)
For real PAM authentication on Linux, install PAM development libraries:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install libpam0g-dev

# CentOS/RHEL
sudo yum install pam-devel

# Fedora
sudo dnf install pam-devel

# Then rebuild with PAM support
go build -tags pam -v
```

**Note**: The application works on Linux without PAM libraries, but will use basic authentication instead of real system authentication.

## Usage

### Using Makefile (Recommended)
```bash
# Show all available commands
make help

# Run without building
make run

# Run with biometric authentication
make run-bio

# Run with PAM authentication (Linux)
make run-pam

# Build and run
make dev

# Run tests
make test
make test-comprehensive
make test-all
```

### Direct Usage
```bash
./pam-auth
```

### Biometric Authentication (macOS only)
```bash
./pam-auth --biometric
```

### Real PAM Authentication (Linux only)
```bash
./pam-auth --real-pam
```

### Help
```bash
./pam-auth --help
```

### Version Information
```bash
./pam-auth version
```

## Example Usage

```bash
$ ./pam-auth
System Authentication Tool
===========================
Platform: darwin/arm64

🔐 TouchID/FaceID is available on this device
💡 Use --biometric flag to enable TouchID/FaceID authentication

Username: user.name
Password: [hidden]
✅ Password authentication successful for user: user.name

User Information:
=================
Username: user.name
User ID: 501
Group ID: 20
Home Directory: /Users/user.name
Name: User Name
Authentication Time: 2025-07-03 15:52:30
Operating System: darwin
Architecture: arm64

Groups for user user.name:
Groups: staff everyone localaccounts _appserverusr admin _appserveradm
```

## Authentication Methods

### Password Authentication
The default authentication method uses system password verification.

**Features:**
- Secure password input (hidden in terminal)
- Cross-platform support
- System user validation
- Automatic user information display

### TouchID/Biometric Authentication (macOS)

**Features:**
- 🔐 Automatic TouchID detection
- 👆 Seamless biometric authentication  
- 🔄 Automatic fallback to password if TouchID fails
- ⚙️ Works with both TouchID and FaceID

**Requirements:**
- macOS with TouchID/FaceID hardware
- TouchID configured in System Preferences
- Terminal with appropriate permissions
- Physical Mac (not supported in virtual machines)

### Real PAM Authentication (Linux)

**Features:**
- 🔑 Real system password authentication via PAM
- 🔐 Full integration with Linux authentication stack
- ⚙️ Support for various PAM modules
- 🛡️ Enhanced security for production use

**Requirements:**
- Linux operating system
- PAM libraries installed
- Appropriate permissions (may require sudo)
- PAM configuration

### Usage Examples

#### Standard Authentication
```bash
$ ./pam-auth
System Authentication Tool
===========================
🔐 TouchID/FaceID is available on this device
💡 Use --biometric flag to enable TouchID/FaceID authentication

Username: user.name
Password: [hidden]
✅ Password authentication successful for user: user.name
```

#### Biometric Authentication (macOS)
```bash
$ ./pam-auth --biometric
System Authentication Tool
===========================
🔐 TouchID/FaceID is available on this device
👆 Biometric authentication will be used

Username: user.name
🔐 Attempting biometric authentication for user: user.name
✅ Biometric authentication successful for user: user.name
```

#### Biometric Fallback (macOS)
```bash
$ ./pam-auth --biometric
Username: user.name
🔐 Attempting biometric authentication for user: user.name
⚠️ Biometric authentication failed, falling back to password...
Password: [hidden]
✅ Password authentication successful for user: user.name
```

#### Real PAM Authentication (Linux)
```bash
$ ./pam-auth --real-pam
System Authentication Tool
===========================
🔐 PAM authentication is available on this system
🔑 Real PAM authentication will be used

Username: user.name
Password: [hidden]
✅ Password authentication successful for user: user.name
```

## Security Notice

⚠️ **WARNING**: This application is for educational and testing purposes only. Use appropriate caution in production environments.

- Always use the `--real-pam` flag on Linux for production authentication
- Biometric authentication requires proper system configuration
- Test thoroughly before deploying in sensitive environments

## Technical Details

### Architecture

The application uses a clean, platform-specific architecture with build tags for optimal code organization:

#### File Structure
```
├── main.go              # Core application logic and CLI interface
├── util/
│   └── pam/             # Platform-specific authentication package
│       ├── darwin.go    # macOS-specific authentication (TouchID/FaceID)
│       ├── linux.go     # Linux-specific authentication (PAM integration)  
│       └── others.go    # Stub implementations for other platforms
├── go.mod               # Go module dependencies
└── README.md           # Documentation
```

#### Platform-Specific Build Tags
- **`util/pam/darwin.go`**: `//go:build darwin` - macOS TouchID/FaceID authentication
- **`util/pam/linux.go`**: `//go:build linux` - Real PAM authentication support
- **`util/pam/others.go`**: `//go:build !linux && !darwin` - Stub implementations

#### Authentication Flow
1. **Platform Detection**: Automatically detects macOS, Linux, or other platforms
2. **Feature Availability**: Checks for TouchID (macOS) or PAM (Linux) support
3. **Authentication Methods**: 
   - macOS: TouchID/FaceID → Password fallback
   - Linux: Real PAM → Standard authentication fallback
   - Others: Standard authentication only
4. **User Information**: Cross-platform user data retrieval and display

#### Package Organization
The `util/pam` package provides a clean separation of platform-specific authentication logic:

- **Exported Functions**: All authentication functions are capitalized (e.g., `AuthenticateWithDSCL`) for external use
- **Global Variables**: `UseBiometric` and `UseRealPAM` are set by the main package to control authentication behavior
- **Build Constraints**: Each file targets specific platforms using Go build tags
- **Error Handling**: Consistent error reporting across all platforms

### System Requirements
- Go 1.24.4 or higher
- macOS or Linux operating system
- Terminal access

### Dependencies
- `github.com/spf13/cobra` - CLI framework
- `golang.org/x/term` - Secure password input

### Platform Support

#### macOS
- User verification with `dscl` command
- Directory Service integration
- TouchID/FaceID biometric authentication
- User group information
- Automatic biometric availability detection

#### Linux
- User verification with `getent` command
- Real PAM authentication support
- `/etc/passwd` file verification
- Group information with `groups` command
- PAM permission checking

#### Other Platforms
- Basic user verification
- Standard authentication methods
- Cross-platform compatibility

## Development

### Testing
```bash
# Test the application
go run main.go

# Test with interactive input
./pam-auth
```

### Build Flags
```bash
# Debug build
go build -gcflags="-N -l" -o pam-auth-debug

# Release build
go build -ldflags="-s -w" -o pam-auth
```

### CLI Commands
```bash
# Show help
./pam-auth --help

# Show version
./pam-auth version

# Run authentication
./pam-auth

# Generate shell completion (bash, zsh, fish, powershell)
./pam-auth completion bash > /etc/bash_completion.d/pam-auth
./pam-auth completion zsh > "${fpath[1]}/_pam-auth"
```

### Cobra CLI Features

This application uses the Cobra CLI framework which provides:

- **Automatic help generation**: `--help` flag for commands
- **Shell completion**: Support for bash, zsh, fish, and PowerShell
- **Nested commands**: Organized command structure
- **Flag parsing**: Automatic flag and argument handling
- **Usage templates**: Consistent help formatting

## License

This project is licensed under the MIT License.
