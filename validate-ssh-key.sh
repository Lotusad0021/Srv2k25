#!/bin/bash

# SSH Key Validator for GitHub
# This script validates SSH key format and provides helpful feedback

set -e

echo "=== SSH Key Validator for GitHub ==="
echo ""

# Function to display usage
usage() {
    echo "Usage: $0 [KEY_FILE]"
    echo ""
    echo "Validates SSH public key format for GitHub compatibility"
    echo ""
    echo "If no key file is specified, this script will look for common key locations:"
    echo "  ~/.ssh/id_ed25519.pub"
    echo "  ~/.ssh/id_rsa.pub"
    echo "  ~/.ssh/github_ssh_key.pub"
    echo ""
    echo "Examples:"
    echo "  $0                           # Check common key locations"
    echo "  $0 ~/.ssh/my_key.pub         # Check specific key file"
    exit 1
}

# Function to validate a single key file
validate_key() {
    local key_file="$1"
    
    if [[ ! -f "$key_file" ]]; then
        echo "❌ Key file not found: $key_file"
        return 1
    fi
    
    echo "🔍 Checking: $key_file"
    
    # Check if file is readable
    if [[ ! -r "$key_file" ]]; then
        echo "❌ Cannot read key file (permission denied)"
        return 1
    fi
    
    # Check if file is empty
    if [[ ! -s "$key_file" ]]; then
        echo "❌ Key file is empty"
        return 1
    fi
    
    # Check key format using ssh-keygen
    if ssh-keygen -lf "$key_file" &>/dev/null; then
        local key_info
        key_info=$(ssh-keygen -lf "$key_file")
        echo "✅ Valid OpenSSH public key format"
        echo "   $key_info"
        
        # Show the key content
        echo ""
        echo "📋 Key content (copy this to GitHub):"
        echo "----------------------------------------"
        cat "$key_file"
        echo "----------------------------------------"
        echo ""
        
        # Check key type recommendations
        local key_type
        key_type=$(echo "$key_info" | grep -o '([^)]*)'  | tr -d '()')
        
        case "$key_type" in
            "ED25519")
                echo "💯 Excellent! Ed25519 keys are recommended for GitHub"
                ;;
            "RSA")
                local key_size
                key_size=$(echo "$key_info" | awk '{print $1}')
                if [[ $key_size -ge 4096 ]]; then
                    echo "✅ Good! RSA key with $key_size bits is acceptable"
                elif [[ $key_size -ge 2048 ]]; then
                    echo "⚠️  RSA key with $key_size bits works but consider using 4096 bits or Ed25519"
                else
                    echo "❌ RSA key with $key_size bits is too weak. Use at least 2048 bits or Ed25519"
                fi
                ;;
            *)
                echo "⚠️  Key type $key_type is valid but Ed25519 or RSA are recommended"
                ;;
        esac
        
        return 0
    else
        echo "❌ Invalid key format"
        echo ""
        echo "🔧 Common issues:"
        echo "   • Make sure you're using the PUBLIC key (.pub file)"
        echo "   • The file should start with ssh-rsa, ssh-ed25519, etc."
        echo "   • The key should be on a single line"
        echo ""
        echo "💡 Generate a new key with: ./generate-ssh-key.sh -e your-email@example.com"
        return 1
    fi
}

# Parse command line arguments
if [[ $# -eq 1 && "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Check specific key file if provided
if [[ $# -eq 1 ]]; then
    validate_key "$1"
    exit $?
fi

# Check common key locations
SSH_DIR="$HOME/.ssh"
FOUND_KEYS=0

echo "🔍 Scanning for SSH keys in $SSH_DIR..."
echo ""

# Common key file patterns
KEY_FILES=(
    "$SSH_DIR/id_ed25519.pub"
    "$SSH_DIR/id_rsa.pub"
    "$SSH_DIR/github_ssh_key.pub"
    "$SSH_DIR/id_ecdsa.pub"
    "$SSH_DIR/id_dsa.pub"
)

for key_file in "${KEY_FILES[@]}"; do
    if [[ -f "$key_file" ]]; then
        validate_key "$key_file"
        echo ""
        ((FOUND_KEYS++))
    fi
done

# Also check for any other .pub files
while IFS= read -r -d '' pub_file; do
    # Skip already checked files
    local already_checked=false
    for checked_file in "${KEY_FILES[@]}"; do
        if [[ "$pub_file" == "$checked_file" ]]; then
            already_checked=true
            break
        fi
    done
    
    if [[ "$already_checked" == false ]]; then
        validate_key "$pub_file"
        echo ""
        ((FOUND_KEYS++))
    fi
done < <(find "$SSH_DIR" -name "*.pub" -type f -print0 2>/dev/null)

if [[ $FOUND_KEYS -eq 0 ]]; then
    echo "❌ No SSH public keys found in $SSH_DIR"
    echo ""
    echo "🚀 Generate a new SSH key with:"
    echo "   ./generate-ssh-key.sh -e your-email@example.com"
    exit 1
else
    echo "✅ Found and validated $FOUND_KEYS SSH key(s)"
    echo ""
    echo "📚 Next steps:"
    echo "1. Copy the key content above"
    echo "2. Go to GitHub → Settings → SSH and GPG keys"
    echo "3. Click 'New SSH key'"
    echo "4. Paste the key and add a title"
    echo "5. Test with: ssh -T git@github.com"
fi