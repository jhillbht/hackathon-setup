#!/bin/bash

# Hackathon Environment Setup Script
# For complete beginners - macOS version

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
    echo "🎯 HACKATHON ENVIRONMENT SETUP"
    echo "This will install everything you need to code!"
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

    # Step 4: Install Python
    print_status "Installing Python..."
    if ! command_exists python3; then
        brew install python
    fi
    print_success "Python ready!"

    # Step 5: Install Node.js
    print_status "Installing Node.js..."
    if ! command_exists node; then
        brew install node
    fi
    print_success "Node.js ready!"

    # Step 6: Install Cursor IDE
    print_status "Installing Cursor IDE..."
    if [ ! -d "/Applications/Cursor.app" ]; then
        brew install --cask cursor
    fi
    print_success "Cursor IDE ready!"

    # Step 7: Install essential Python packages
    print_status "Installing essential Python packages..."
    pip3 install --user requests numpy pandas openai python-dotenv flask fastapi
    print_success "Python packages ready!"

    # Step 8: Setup GitHub CLI for easier authentication
    print_status "Installing GitHub CLI..."
    if ! command_exists gh; then
        brew install gh
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
- Install packages: `pip3 install package-name`
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
    echo "2. Open Cursor and select your project folder"
    echo "3. Start coding in main.py"
    echo "4. Test your setup: 'python3 main.py'"
    echo ""
    echo "💡 Need help? Ask a mentor or volunteer!"
    echo ""
    
    # Offer to open project in Cursor
    read -p "Would you like to open your project in Cursor now? (y/n): " open_cursor
    if [[ $open_cursor =~ ^[Yy]$ ]]; then
        print_status "Opening Cursor..."
        open -a Cursor "$project_dir"
    fi
    
    print_success "You're all set! Happy hacking! 🎯"
}

# Error handling
trap 'print_error "Setup interrupted. You can run this script again to continue."' INT

# Run main function
main