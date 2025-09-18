# Srv2k25
This work for server

## SSH Setup for GitHub Access

This repository includes tools and documentation for setting up SSH keys to access GitHub from VS Code Web Dev or SSH clients.

### Quick Start

Generate SSH keys in the correct OpenSSH format:

```bash
./generate-ssh-key.sh -e your-email@example.com
```

### Documentation

- [📖 Complete SSH Setup Guide](SSH-SETUP.md) - Comprehensive guide for SSH key generation and GitHub configuration
- [🔧 SSH Key Generator Script](generate-ssh-key.sh) - Automated tool for creating properly formatted SSH keys
- [✅ SSH Key Validator Script](validate-ssh-key.sh) - Tool to validate existing SSH keys and check OpenSSH format

### Common Issue Fix

If you're getting "Key is invalid. You must supply a key in OpenSSH public key format" error:

1. Use the provided script to generate a properly formatted key: `./generate-ssh-key.sh -e your-email@example.com`
2. Validate your existing key format: `./validate-ssh-key.sh`
3. Make sure you're copying the **public key** (`.pub` file) to GitHub
4. Follow the step-by-step guide in [SSH-SETUP.md](SSH-SETUP.md)
