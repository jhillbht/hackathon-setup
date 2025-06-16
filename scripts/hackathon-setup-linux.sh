#!/bin/bash

# DWY Tool Calling LLM Agent Setup Script
# For complete beginners - Linux version (Ubuntu/Debian/Fedora/Arch)

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
    echo "🎯 DWY TOOL CALLING LLM AGENT SETUP"
    echo "Setting up your AI agent development environment!"
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

    # Step 4: Install Node.js (required for the AI agent)
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
    else
        # Check Node.js version
        node_version=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
        if [ "$node_version" -lt 18 ]; then
            print_warning "Node.js version is too old. Please install Node.js 18+ manually."
        fi
    fi
    print_success "Node.js ready!"

    # Step 5: Install Python (still useful for some components)
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

    # Step 7: Setup GitHub CLI for easier authentication
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

    # Step 8: Clone the DWY Tool Calling LLM Agent project
    print_status "Setting up your DWY Tool Calling LLM Agent project..."
    
    # Create project directory
    project_dir="$HOME/dwy-hackathon-project"
    if [ -d "$project_dir" ]; then
        print_warning "Project directory already exists. Creating backup..."
        mv "$project_dir" "$project_dir-backup-$(date +%s)"
    fi
    
    # Clone the repository
    git clone https://github.com/Organized-AI/DWY-Tool-Calling-LLM-Agent.git "$project_dir"
    cd "$project_dir"
    
    print_success "DWY Agent project cloned!"

    # Step 9: Set up the complete agent
    print_status "Installing project dependencies..."
    cd reference-implementation/complete-agent
    
    # Install dependencies
    npm install
    
    # Copy environment template
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_success "Environment file created (.env)"
    fi
    
    print_success "Project dependencies installed!"

    # Step 10: Final instructions
    echo ""
    echo "================================================="
    print_success "🎉 DWY AGENT SETUP COMPLETE!"
    echo "================================================="
    echo ""
    echo "📍 Your project is located at: $project_dir"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Authenticate with GitHub: 'gh auth login'"
    echo "2. Open Cursor: 'cursor $project_dir' or use the desktop icon"
    echo "3. Read the README.md to choose your learning path:"
    echo "   • Complete Beginner: Start with docs/beginner-setup-guide.md"
    echo "   • Some Experience: Try reference-implementation/complete-agent/"
    echo "   • Experienced Dev: Jump into the workshops/ directory"
    echo ""
    echo "4. To run the AI agent: 'cd reference-implementation/complete-agent && npm start'"
    echo ""
    echo "💡 Need help? Check the docs/ directory or ask a mentor!"
    echo ""
    
    # Show learning paths
    echo "🎓 Choose your learning path:"
    echo "   [1] Complete Beginner - Never coded before"
    echo "   [2] Some Programming Experience"
    echo "   [3] Experienced Developer"
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
    
    print_success "You're all set to build AI agents! 🤖🎯"
    echo ""
    echo "Note: You may need to restart your terminal or run 'source ~/.bashrc' for all changes to take effect."
}

# Error handling
trap 'print_error "Setup interrupted. You can run this script again to continue."' INT

# Run main function
main