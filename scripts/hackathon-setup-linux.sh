#!/bin/bash

# Hackathon Environment Setup Script
# For complete beginners - Linux version (Ubuntu/Debian)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}🚀 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        DISTRO="unknown"
    fi
}

# Main setup function
main() {
    clear
    echo "================================================="
    echo "🎯 HACKATHON ENVIRONMENT SETUP"
    echo "This will install everything you need to code!"
    echo "Estimated time: 5-10 minutes"
    echo "================================================="
    echo ""
    
    # Detect distribution
    detect_distro
    print_status "Detected Linux distribution: $DISTRO"
    echo ""

    # Get user information upfront
    echo "First, let's get you set up with Git:"
    read -p "What's your full name? " user_name
    read -p "What's your email address? " user_email
    echo ""

    # Step 1: Update package manager
    print_status "Updating package manager..."
    case $DISTRO in
        ubuntu|debian)
            sudo apt update
            INSTALL_CMD="sudo apt install -y"
            ;;
        fedora)
            sudo dnf update -y
            INSTALL_CMD="sudo dnf install -y"
            ;;
        arch|manjaro)
            sudo pacman -Sy
            INSTALL_CMD="sudo pacman -S --noconfirm"
            ;;
        *)
            print_warning "Unknown distribution. Assuming apt-based system."
            sudo apt update || {
                print_error "Could not update package manager. Please run this script with sudo."
                exit 1
            }
            INSTALL_CMD="sudo apt install -y"
            ;;
    esac
    print_success "Package manager updated!"

    # Step 2: Install Git
    print_status "Installing Git..."
    if ! command_exists git; then
        $INSTALL_CMD git
    fi
    print_success "Git ready!"

    # Step 3: Configure Git
    print_status "Configuring Git with your information..."
    git config --global user.name "$user_name"
    git config --global user.email "$user_email"
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    print_success "Git configured!"

    # Step 4: Install Python
    print_status "Installing Python..."
    if ! command_exists python3; then
        case $DISTRO in
            ubuntu|debian)
                $INSTALL_CMD python3 python3-pip python3-venv
                ;;
            fedora)
                $INSTALL_CMD python3 python3-pip
                ;;
            arch|manjaro)
                $INSTALL_CMD python python-pip
                ;;
            *)
                $INSTALL_CMD python3 python3-pip
                ;;
        esac
    fi
    print_success "Python ready!"

    # Step 5: Install Node.js
    print_status "Installing Node.js..."
    if ! command_exists node; then
        case $DISTRO in
            ubuntu|debian)
                # Install Node.js 18.x LTS
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                $INSTALL_CMD nodejs
                ;;
            fedora)
                $INSTALL_CMD nodejs npm
                ;;
            arch|manjaro)
                $INSTALL_CMD nodejs npm
                ;;
            *)
                $INSTALL_CMD nodejs npm
                ;;
        esac
    fi
    print_success "Node.js ready!"

    # Step 6: Install Cursor IDE
    print_status "Installing Cursor IDE..."
    if ! command_exists cursor; then
        # Download and install Cursor AppImage
        print_status "Downloading Cursor IDE..."
        cursor_url="https://downloader.cursor.sh/linux/appImage/x64"
        cursor_file="$HOME/Applications/Cursor.AppImage"
        
        # Create Applications directory if it doesn't exist
        mkdir -p "$HOME/Applications"
        
        # Download Cursor
        wget -O "$cursor_file" "$cursor_url" || {
            print_warning "Could not download Cursor automatically. Please download from https://cursor.sh"
        }
        
        # Make it executable
        chmod +x "$cursor_file" 2>/dev/null || true
        
        # Create desktop entry
        mkdir -p "$HOME/.local/share/applications"
        cat > "$HOME/.local/share/applications/cursor.desktop" << EOF
[Desktop Entry]
Name=Cursor
Comment=AI-powered code editor
Exec=$cursor_file
Icon=cursor
Terminal=false
Type=Application
Categories=Development;IDE;
EOF
        
        # Create symlink for command line access
        mkdir -p "$HOME/.local/bin"
        ln -sf "$cursor_file" "$HOME/.local/bin/cursor"
        
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi
    print_success "Cursor IDE ready!"

    # Step 7: Install essential Python packages
    print_status "Installing essential Python packages..."
    python3 -m pip install --user --upgrade pip
    python3 -m pip install --user requests numpy pandas openai python-dotenv flask fastapi
    print_success "Python packages ready!"

    # Step 8: Setup GitHub CLI for easier authentication
    print_status "Installing GitHub CLI..."
    if ! command_exists gh; then
        case $DISTRO in
            ubuntu|debian)
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt update
                $INSTALL_CMD gh
                ;;
            fedora)
                sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                $INSTALL_CMD gh
                ;;
            arch|manjaro)
                $INSTALL_CMD github-cli
                ;;
            *)
                print_warning "GitHub CLI installation not configured for this distribution. Please install manually."
                ;;
        esac
    fi
    print_success "GitHub CLI ready!"

    # Step 9: Create starter project
    print_status "Creating your hackathon project..."
    
    # Create project directory
    project_dir="$HOME/hackathon-project"
    if [ -d "$project_dir" ]; then
        print_warning "Project directory already exists. Creating backup..."
        mv "$project_dir" "$project_dir-backup-$(date +%s)"
    fi
    
    mkdir -p "$project_dir"
    cd "$project_dir"

    # Initialize git repository
    git init
    
    # Create starter files
    cat > README.md << 'EOF'
# My Hackathon Project 🚀

Welcome to your hackathon project! This is where your amazing ideas come to life.

## Getting Started

1. Open this folder in Cursor
2. Start coding in `main.py` or `app.py`
3. Have fun and build something awesome!

## Useful Commands

- Run Python: `python3 main.py`
- Install packages: `pip3 install --user package-name`
- Git commands: `git add .` then `git commit -m "your message"`

Good luck! 🎯
EOF

    cat > main.py << 'EOF'
#!/usr/bin/env python3
"""
Your hackathon project starts here!
This is a simple starter template.
"""

def main():
    print("🎯 Welcome to your hackathon project!")
    print("🚀 Ready to build something amazing?")
    
    # Your code goes here
    name = input("What's your name? ")
    print(f"Hello {name}! Let's start coding! 💻")

if __name__ == "__main__":
    main()
EOF

    cat > requirements.txt << 'EOF'
requests>=2.28.0
numpy>=1.21.0
pandas>=1.5.0
openai>=1.0.0
python-dotenv>=0.19.0
flask>=2.0.0
fastapi>=0.68.0
EOF

    cat > .env.example << 'EOF'
# Copy this file to .env and add your API keys
OPENAI_API_KEY=your_openai_api_key_here
# Add other environment variables as needed
EOF

    # Create run script
    cat > run.sh << 'EOF'
#!/bin/bash
echo "🚀 Running your hackathon project..."
python3 main.py
EOF
    chmod +x run.sh

    # Initial git commit
    git add .
    git commit -m "Initial hackathon project setup 🚀"
    
    print_success "Starter project created!"

    # Step 10: Final instructions
    echo ""
    echo "================================================="
    print_success "🎉 SETUP COMPLETE!"
    echo "================================================="
    echo ""
    echo "📍 Your project is located at: $project_dir"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Authenticate with GitHub: 'gh auth login'"
    echo "2. Open Cursor: 'cursor $project_dir' or use the desktop icon"
    echo "3. Start coding in main.py"
    echo "4. Test your setup: 'python3 main.py' or './run.sh'"
    echo ""
    echo "💡 Need help? Ask a mentor or volunteer!"
    echo ""
    
    # Offer to open project in Cursor
    read -p "Would you like to open your project in Cursor now? (y/n): " open_cursor
    if [[ $open_cursor =~ ^[Yy]$ ]]; then
        print_status "Opening Cursor..."
        if command_exists cursor; then
            cursor "$project_dir" &
        else
            "$HOME/Applications/Cursor.AppImage" "$project_dir" &
        fi
    fi
    
    print_success "You're all set! Happy hacking! 🎯"
    echo ""
    echo "Note: You may need to restart your terminal or run 'source ~/.bashrc' for all changes to take effect."
}

# Error handling
trap 'print_error "Setup interrupted. You can run this script again to continue."' INT

# Run main function
main