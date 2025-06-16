#!/bin/bash

# Hackathon Environment Setup Script
# For complete beginners - macOS version
# Sets up DWY Tool Calling LLM Agent project

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

# Main setup function
main() {
    clear
    echo "================================================="
    echo "🎯 DWY TOOL CALLING LLM AGENT SETUP"
    echo "Setting up your AI agent development environment!"
    echo "Estimated time: 5-10 minutes"
    echo "================================================="
    echo ""
    
    # Get user information upfront
    echo "First, let's get you set up with Git:"
    read -p "What's your full name? " user_name
    read -p "What's your email address? " user_email
    echo ""

    # Step 1: Install Homebrew (if not present)
    if ! command_exists brew; then
        print_status "Installing Homebrew (Mac package manager)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            print_error "Failed to install Homebrew. Please try manual installation."
            exit 1
        }
        print_success "Homebrew installed!"
    else
        print_success "Homebrew already installed!"
    fi

    # Step 2: Install Git
    print_status "Installing Git..."
    if ! command_exists git; then
        brew install git
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
        brew install node
    else
        # Check Node.js version
        node_version=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
        if [ "$node_version" -lt 18 ]; then
            print_warning "Node.js version is too old. Installing latest version..."
            brew upgrade node
        fi
    fi
    print_success "Node.js ready!"

    # Step 5: Install Python (still useful for some components)
    print_status "Installing Python..."
    if ! command_exists python3; then
        brew install python
    fi
    print_success "Python ready!"

    # Step 6: Install Cursor IDE
    print_status "Installing Cursor IDE..."
    if [ ! -d "/Applications/Cursor.app" ]; then
        brew install --cask cursor
    fi
    print_success "Cursor IDE ready!"

    # Step 7: Install GitHub CLI for easier authentication
    print_status "Installing GitHub CLI..."
    if ! command_exists gh; then
        brew install gh
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
    echo "2. Open Cursor and select your project folder"
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
        open -a Cursor "$project_dir"
    fi
    
    print_success "You're all set to build AI agents! 🤖🎯"
}

# Error handling
trap 'print_error "Setup interrupted. You can run this script again to continue."' INT

# Run main function
main