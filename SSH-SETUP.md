# SSH Setup Guide for GitHub Access

This repository provides tools and documentation for setting up SSH keys to access GitHub from VS Code Web Dev or SSH clients.

## Validation Tool

Validate your existing SSH keys to ensure they're in the correct format:

```bash
./validate-ssh-key.sh
# or check a specific key
./validate-ssh-key.sh ~/.ssh/id_ed25519.pub
```

## Quick Start

### Automatic SSH Key Generation

Use the provided script to generate SSH keys in the correct OpenSSH format:

```bash
./generate-ssh-key.sh -e your-email@example.com
```

### Manual SSH Key Generation

If you prefer to generate keys manually:

#### For Ed25519 Keys (Recommended)
```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

#### For RSA Keys (Alternative)
```bash
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

## Adding SSH Key to GitHub

1. Copy your public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   # or
   cat ~/.ssh/id_rsa.pub
   ```

2. Go to [GitHub Settings → SSH and GPG keys](https://github.com/settings/keys)

3. Click **"New SSH key"**

4. Give your key a descriptive title (e.g., "VS Code Web Dev", "My Laptop")

5. Paste your **public key** (the content from step 1)

6. Click **"Add SSH key"**

## Testing SSH Connection

Test your SSH connection to GitHub:

```bash
ssh -T git@github.com
```

You should see a message like:
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

## Common Issues and Solutions

### "Key is invalid. You must supply a key in OpenSSH public key format"

This error occurs when:
- You're trying to use a private key instead of a public key
- The key format is incorrect
- The key file is corrupted

**Solution:**
1. Make sure you're copying the **public key** (`.pub` file)
2. Validate your key format: `./validate-ssh-key.sh`
3. Use our script to generate a properly formatted key:
   ```bash
   ./generate-ssh-key.sh -e your-email@example.com
   ```

### SSH Key Not Working

1. **Check SSH agent:**
   ```bash
   ssh-add -l
   ```

2. **Add key to SSH agent:**
   ```bash
   ssh-add ~/.ssh/id_ed25519
   # or
   ssh-add ~/.ssh/id_rsa
   ```

3. **Check SSH configuration:**
   ```bash
   cat ~/.ssh/config
   ```

### Permission Issues

Set correct permissions on SSH files:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

## VS Code Web Dev Setup

### Using SSH Keys with VS Code Web Dev

1. Generate SSH key using the script above
2. Add the public key to GitHub
3. In VS Code Web Dev, use SSH URLs for git operations:
   ```
   git@github.com:username/repository.git
   ```

### Cloning Repositories

```bash
# SSH (recommended after setup)
git clone git@github.com:username/repository.git

# HTTPS (fallback)
git clone https://github.com/username/repository.git
```

## SSH Configuration File

Create or edit `~/.ssh/config` for easier GitHub access:

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

## Security Best Practices

1. **Use Ed25519 keys** when possible (more secure and faster)
2. **Use strong passphrases** for your SSH keys
3. **Regularly rotate keys** (at least annually)
4. **Use different keys** for different services/machines
5. **Keep private keys secure** and never share them

## Troubleshooting Commands

### Check SSH key fingerprint
```bash
ssh-keygen -lf ~/.ssh/id_ed25519.pub
```

### Verbose SSH connection test
```bash
ssh -vT git@github.com
```

### List SSH keys in agent
```bash
ssh-add -l
```

### Remove all keys from agent
```bash
ssh-add -D
```

## Script Options

### SSH Key Generator

The `generate-ssh-key.sh` script supports various options:

```bash
# Basic usage
./generate-ssh-key.sh -e your-email@example.com

# Custom key name
./generate-ssh-key.sh -e your-email@example.com -n my_custom_key

# RSA key with custom size
./generate-ssh-key.sh -e your-email@example.com -t rsa -s 4096

# Show help
./generate-ssh-key.sh --help
```

### SSH Key Validator

The `validate-ssh-key.sh` script helps check your keys:

```bash
# Check all common SSH key locations
./validate-ssh-key.sh

# Check a specific key file
./validate-ssh-key.sh ~/.ssh/id_ed25519.pub

# Show help
./validate-ssh-key.sh --help
```

## Support

If you encounter issues:

1. Check the [GitHub SSH documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
2. Verify your key format using the provided script
3. Test SSH connection with verbose output: `ssh -vT git@github.com`

---

**Note:** Always use your **public key** (`.pub` file) when adding to GitHub. Never share your private key.