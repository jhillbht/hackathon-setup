# DWY Tool Calling LLM Agent Setup Script for Windows
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
    Write-Host "🎯 DWY TOOL CALLING LLM AGENT SETUP" -ForegroundColor Cyan
    Write-Host "Setting up your AI agent development environment!" -ForegroundColor Cyan
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

        # Step 3: Install Node.js (required for the AI agent)
        Write-StatusMessage "Installing Node.js..."
        if (-not (Test-CommandExists node)) {
            choco install nodejs -y
            refreshenv
        } else {
            # Check Node.js version
            $nodeVersionOutput = node -v
            $nodeVersion = [int]($nodeVersionOutput -replace 'v(\d+)\..*', '$1')
            if ($nodeVersion -lt 18) {
                Write-WarningMessage "Node.js version is too old. Installing latest version..."
                choco upgrade nodejs -y
                refreshenv
            }
        }
        Write-SuccessMessage "Node.js ready!"

        # Step 4: Install Python (still useful for some components)
        Write-StatusMessage "Installing Python..."
        if (-not (Test-CommandExists python)) {
            choco install python -y
            refreshenv
        }
        Write-SuccessMessage "Python ready!"

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

        # Step 7: Install GitHub CLI
        Write-StatusMessage "Installing GitHub CLI..."
        if (-not (Test-CommandExists gh)) {
            choco install gh -y
            refreshenv
        }
        Write-SuccessMessage "GitHub CLI ready!"

        # Step 8: Clone the DWY Tool Calling LLM Agent project
        Write-StatusMessage "Setting up your DWY Tool Calling LLM Agent project..."
        
        $projectDir = "$env:USERPROFILE\dwy-hackathon-project"
        if (Test-Path $projectDir) {
            Write-WarningMessage "Project directory already exists. Creating backup..."
            $backupDir = "$projectDir-backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
            Move-Item $projectDir $backupDir
        }
        
        # Clone the repository
        git clone https://github.com/Organized-AI/DWY-Tool-Calling-LLM-Agent.git $projectDir
        Set-Location $projectDir
        
        Write-SuccessMessage "DWY Agent project cloned!"

        # Step 9: Set up the complete agent
        Write-StatusMessage "Installing project dependencies..."
        Set-Location "reference-implementation\complete-agent"
        
        # Install dependencies
        npm install
        
        # Copy environment template
        if (Test-Path ".env.example") {
            Copy-Item ".env.example" ".env"
            Write-SuccessMessage "Environment file created (.env)"
        }
        
        Write-SuccessMessage "Project dependencies installed!"

        # Step 10: Final instructions
        Write-Host ""
        Write-Host "=================================================" -ForegroundColor Green
        Write-SuccessMessage "🎉 DWY AGENT SETUP COMPLETE!"
        Write-Host "=================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "📍 Your project is located at: $projectDir" -ForegroundColor White
        Write-Host ""
        Write-Host "🚀 Next steps:" -ForegroundColor White
        Write-Host "1. Authenticate with GitHub: 'gh auth login'" -ForegroundColor White
        Write-Host "2. Open Cursor and select your project folder" -ForegroundColor White
        Write-Host "3. Read the README.md to choose your learning path:" -ForegroundColor White
        Write-Host "   • Complete Beginner: Start with docs\beginner-setup-guide.md" -ForegroundColor White
        Write-Host "   • Some Experience: Try reference-implementation\complete-agent\" -ForegroundColor White
        Write-Host "   • Experienced Dev: Jump into the workshops\ directory" -ForegroundColor White
        Write-Host ""
        Write-Host "4. To run the AI agent: 'cd reference-implementation\complete-agent && npm start'" -ForegroundColor White
        Write-Host ""
        Write-Host "💡 Need help? Check the docs\ directory or ask a mentor!" -ForegroundColor Yellow
        Write-Host ""
        
        # Show learning paths
        Write-Host "🎓 Choose your learning path:" -ForegroundColor Cyan
        Write-Host "   [1] Complete Beginner - Never coded before" -ForegroundColor White
        Write-Host "   [2] Some Programming Experience" -ForegroundColor White
        Write-Host "   [3] Experienced Developer" -ForegroundColor White
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
        
        Write-SuccessMessage "You're all set to build AI agents! 🤖🎯"
        
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