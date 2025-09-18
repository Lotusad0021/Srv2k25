#!/bin/bash

# SSH Key Generator for GitHub Access
# This script generates SSH keys in the correct OpenSSH format for GitHub

set -e

echo "=== SSH Key Generator for GitHub Access ==="
echo ""

# Default values
KEY_TYPE="ed25519"
KEY_SIZE=""
EMAIL=""
KEY_NAME="github_ssh_key"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --email EMAIL       Email address for the SSH key (required)"
    echo "  -n, --name NAME         Name for the SSH key file (default: github_ssh_key)"
    echo "  -t, --type TYPE         Key type: ed25519 (default) or rsa"
    echo "  -s, --size SIZE         Key size for RSA keys (default: 4096)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -e user@example.com"
    echo "  $0 -e user@example.com -n my_github_key -t rsa -s 4096"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--email)
            EMAIL="$2"
            shift 2
            ;;
        -n|--name)
            KEY_NAME="$2"
            shift 2
            ;;
        -t|--type)
            KEY_TYPE="$2"
            shift 2
            ;;
        -s|--size)
            KEY_SIZE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [[ -z "$EMAIL" ]]; then
    echo "Error: Email address is required"
    echo "Use -e or --email to specify your email address"
    exit 1
fi

# Validate key type
if [[ "$KEY_TYPE" != "ed25519" && "$KEY_TYPE" != "rsa" ]]; then
    echo "Error: Key type must be either 'ed25519' or 'rsa'"
    exit 1
fi

# Set default key size for RSA
if [[ "$KEY_TYPE" == "rsa" && -z "$KEY_SIZE" ]]; then
    KEY_SIZE="4096"
fi

# Create .ssh directory if it doesn't exist
SSH_DIR="$HOME/.ssh"
if [[ ! -d "$SSH_DIR" ]]; then
    echo "Creating .ssh directory: $SSH_DIR"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Set key file paths
PRIVATE_KEY="$SSH_DIR/$KEY_NAME"
PUBLIC_KEY="$SSH_DIR/$KEY_NAME.pub"

# Check if key already exists
if [[ -f "$PRIVATE_KEY" ]]; then
    echo "Warning: SSH key already exists at $PRIVATE_KEY"
    read -p "Do you want to overwrite it? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Generate SSH key
echo "Generating SSH key..."
echo "Key type: $KEY_TYPE"
echo "Email: $EMAIL"
echo "Key file: $PRIVATE_KEY"

if [[ "$KEY_TYPE" == "ed25519" ]]; then
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$PRIVATE_KEY" -N ""
else
    ssh-keygen -t rsa -b "$KEY_SIZE" -C "$EMAIL" -f "$PRIVATE_KEY" -N ""
fi

# Set correct permissions
chmod 600 "$PRIVATE_KEY"
chmod 644 "$PUBLIC_KEY"

echo ""
echo "=== SSH Key Generated Successfully ==="
echo "Private key: $PRIVATE_KEY"
echo "Public key: $PUBLIC_KEY"
echo ""

# Display public key
echo "=== Your Public Key (Copy this to GitHub) ==="
echo ""
cat "$PUBLIC_KEY"
echo ""

# Add instructions
echo "=== Next Steps ==="
echo "1. Copy the public key above"
echo "2. Go to GitHub → Settings → SSH and GPG keys"
echo "3. Click 'New SSH key'"
echo "4. Paste the public key and give it a title"
echo "5. Test the connection with: ssh -T git@github.com"
echo ""

# Offer to add to SSH agent
read -p "Do you want to add this key to the SSH agent? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Start SSH agent if not running
    if ! pgrep -x "ssh-agent" > /dev/null; then
        eval "$(ssh-agent -s)"
    fi
    
    # Add key to SSH agent
    ssh-add "$PRIVATE_KEY"
    echo "Key added to SSH agent."
fi

# Offer to test GitHub connection
read -p "Do you want to test the GitHub SSH connection now? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Testing GitHub SSH connection..."
    echo "Note: You need to add the public key to GitHub first!"
    ssh -T git@github.com || echo "Connection test completed. If you see authentication errors, make sure you've added the public key to GitHub."
fi

echo ""
echo "SSH key setup completed!"