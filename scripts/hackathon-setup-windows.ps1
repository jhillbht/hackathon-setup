# Hackathon Environment Setup Script for Windows
# PowerShell script for complete beginners

# Set execution policy for this session
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Colors for output
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

function Write-StatusMessage {
    param([string]$Message)
    Write-Host "🚀 $Message" -ForegroundColor Blue
}

function Write-SuccessMessage {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-WarningMessage {
    param([string]$Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Main setup function
function Start-HackathonSetup {
    Clear-Host
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host "🎯 HACKATHON ENVIRONMENT SETUP FOR WINDOWS" -ForegroundColor Cyan
    Write-Host "This will install everything you need to code!" -ForegroundColor Cyan
    Write-Host "Estimated time: 10-15 minutes" -ForegroundColor Cyan
    Write-Host "=================================================" -ForegroundColor Cyan
    Write-Host ""

    # Check if running as administrator
    if (-not (Test-IsAdmin)) {
        Write-WarningMessage "This script needs administrator privileges to install software."
        Write-Host "Please right-click on PowerShell and select 'Run as Administrator'"
        Write-Host "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    # Get user information upfront
    Write-Host "First, let's get you set up with Git:" -ForegroundColor White
    $userName = Read-Host "What's your full name?"
    $userEmail = Read-Host "What's your email address?"
    Write-Host ""

    try {
        # Step 1: Install Chocolatey (Windows package manager)
        if (-not (Test-CommandExists choco)) {
            Write-StatusMessage "Installing Chocolatey (Windows package manager)..."
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            
            # Refresh environment variables
            $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
            Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
            refreshenv
            
            Write-SuccessMessage "Chocolatey installed!"
        } else {
            Write-SuccessMessage "Chocolatey already installed!"
        }

        # Step 2: Install Git
        Write-StatusMessage "Installing Git..."
        if (-not (Test-CommandExists git)) {
            choco install git -y
            refreshenv
        }
        Write-SuccessMessage "Git ready!"

        # Step 3: Install Python
        Write-StatusMessage "Installing Python..."
        if (-not (Test-CommandExists python)) {
            choco install python -y
            refreshenv
        }
        Write-SuccessMessage "Python ready!"

        # Step 4: Install Node.js
        Write-StatusMessage "Installing Node.js..."
        if (-not (Test-CommandExists node)) {
            choco install nodejs -y
            refreshenv
        }
        Write-SuccessMessage "Node.js ready!"

        # Step 5: Install Cursor IDE
        Write-StatusMessage "Installing Cursor IDE..."
        try {
            $cursorPath = "${env:LOCALAPPDATA}\Programs\cursor\Cursor.exe"
            if (-not (Test-Path $cursorPath)) {
                # Download and install Cursor
                $cursorUrl = "https://downloader.cursor.sh/windows/nsis/x64"
                $cursorInstaller = "$env:TEMP\cursor-installer.exe"
                
                Write-StatusMessage "Downloading Cursor IDE..."
                Invoke-WebRequest -Uri $cursorUrl -OutFile $cursorInstaller
                
                Write-StatusMessage "Installing Cursor IDE..."
                Start-Process -FilePath $cursorInstaller -ArgumentList "/S" -Wait
                Remove-Item $cursorInstaller
            }
            Write-SuccessMessage "Cursor IDE ready!"
        } catch {
            Write-WarningMessage "Could not install Cursor automatically. Please download from https://cursor.sh"
        }

        # Step 6: Configure Git
        Write-StatusMessage "Configuring Git with your information..."
        git config --global user.name "$userName"
        git config --global user.email "$userEmail"
        git config --global init.defaultBranch main
        git config --global pull.rebase false
        Write-SuccessMessage "Git configured!"

        # Step 7: Install essential Python packages
        Write-StatusMessage "Installing essential Python packages..."
        python -m pip install --upgrade pip
        pip install requests numpy pandas openai python-dotenv flask fastapi
        Write-SuccessMessage "Python packages ready!"

        # Step 8: Install GitHub CLI
        Write-StatusMessage "Installing GitHub CLI..."
        if (-not (Test-CommandExists gh)) {
            choco install gh -y
            refreshenv
        }
        Write-SuccessMessage "GitHub CLI ready!"

        # Step 9: Create starter project
        Write-StatusMessage "Creating your hackathon project..."
        
        $projectDir = "$env:USERPROFILE\hackathon-project"
        if (Test-Path $projectDir) {
            Write-WarningMessage "Project directory already exists. Creating backup..."
            $backupDir = "$projectDir-backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
            Move-Item $projectDir $backupDir
        }
        
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
        Set-Location $projectDir

        # Initialize git repository
        git init

        # Create starter files
        @"
# My Hackathon Project 🚀

Welcome to your hackathon project! This is where your amazing ideas come to life.

## Getting Started

1. Open this folder in Cursor
2. Start coding in `main.py` or `app.py`
3. Have fun and build something awesome!

## Useful Commands

- Run Python: `python main.py`
- Install packages: `pip install package-name`
- Git commands: `git add .` then `git commit -m "your message"`

Good luck! 🎯
"@ | Out-File -FilePath "README.md" -Encoding UTF8

        @"
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
"@ | Out-File -FilePath "main.py" -Encoding UTF8

        @"
requests>=2.28.0
numpy>=1.21.0
pandas>=1.5.0
openai>=1.0.0
python-dotenv>=0.19.0
flask>=2.0.0
fastapi>=0.68.0
"@ | Out-File -FilePath "requirements.txt" -Encoding UTF8

        @"
# Copy this file to .env and add your API keys
OPENAI_API_KEY=your_openai_api_key_here
# Add other environment variables as needed
"@ | Out-File -FilePath ".env.example" -Encoding UTF8

        # Create a simple batch file to run the project
        @"
@echo off
echo 🚀 Running your hackathon project...
python main.py
pause
"@ | Out-File -FilePath "run.bat" -Encoding ASCII

        # Initial git commit
        git add .
        git commit -m "Initial hackathon project setup 🚀"
        
        Write-SuccessMessage "Starter project created!"

        # Step 10: Final instructions
        Write-Host ""
        Write-Host "=================================================" -ForegroundColor Green
        Write-SuccessMessage "🎉 SETUP COMPLETE!"
        Write-Host "=================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "📍 Your project is located at: $projectDir" -ForegroundColor White
        Write-Host ""
        Write-Host "🚀 Next steps:" -ForegroundColor White
        Write-Host "1. Authenticate with GitHub: 'gh auth login'" -ForegroundColor White
        Write-Host "2. Open Cursor and select your project folder" -ForegroundColor White
        Write-Host "3. Start coding in main.py" -ForegroundColor White
        Write-Host "4. Test your setup: double-click 'run.bat'" -ForegroundColor White
        Write-Host ""
        Write-Host "💡 Need help? Ask a mentor or volunteer!" -ForegroundColor Yellow
        Write-Host ""
        
        # Offer to open project in File Explorer and Cursor
        $openFiles = Read-Host "Would you like to open your project folder now? (y/n)"
        if ($openFiles -match "^[Yy]$") {
            Write-StatusMessage "Opening project folder..."
            explorer $projectDir
            
            # Try to open in Cursor if installed
            $cursorPath = "${env:LOCALAPPDATA}\Programs\cursor\Cursor.exe"
            if (Test-Path $cursorPath) {
                Start-Process -FilePath $cursorPath -ArgumentList "`"$projectDir`""
            }
        }
        
        Write-SuccessMessage "You're all set! Happy hacking! 🎯"
        
    } catch {
        Write-ErrorMessage "An error occurred during setup: $($_.Exception.Message)"
        Write-Host "Please ask a volunteer for help or try the manual setup instructions."
    }

    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Run the main setup function
Start-HackathonSetup