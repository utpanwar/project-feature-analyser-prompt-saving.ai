# Copilot Toolkit - Project-Level Installer (Windows PowerShell)
# Downloads toolkit files from GitHub directly into the current project's .github/ folder.
# Usage: irm https://raw.githubusercontent.com/utpanwar/project-feature-analyser-prompt-saving.ai/main/project-init.ps1 | iex

$ErrorActionPreference = "Stop"

# --- Configuration -----------------------------------------------------------
$RepoOwner = if ($env:PFA_OWNER) { $env:PFA_OWNER } else { "utpanwar" }
$RepoName  = if ($env:PFA_REPO)  { $env:PFA_REPO }  else { "project-feature-analyser-prompt-saving.ai" }
$Branch    = if ($env:PFA_BRANCH) { $env:PFA_BRANCH } else { "main" }
$BaseUrl   = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch"

# --- Helper Functions --------------------------------------------------------
function Write-Info    { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn    { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }

function Get-ToolkitFile {
    param(
        [string]$Source,
        [string]$Destination
    )
    $destDir = Split-Path -Parent $Destination
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    try {
        Invoke-WebRequest -Uri "$BaseUrl/$Source" -OutFile $Destination -UseBasicParsing -ErrorAction Stop
        Write-Success "Downloaded: $Destination"
        return $true
    }
    catch {
        Write-Warn "Failed to download: $Destination (skipped)"
        return $false
    }
}

# --- Main --------------------------------------------------------------------
Write-Host ""
Write-Host "+==========================================+" -ForegroundColor Cyan
Write-Host "|  Copilot Toolkit v2.0 - Project Install  |" -ForegroundColor Cyan
Write-Host "+==========================================+" -ForegroundColor Cyan
Write-Host ""

Write-Info "Installing into: $(Get-Location)"

# Files to download
$files = @{
    ".github/instructions/prompt-logger.instructions.md" = ".github\instructions\prompt-logger.instructions.md"
    ".github/instructions/auto-docs.instructions.md"     = ".github\instructions\auto-docs.instructions.md"
    ".github/prompts/scaffold-project.prompt.md"         = ".github\prompts\scaffold-project.prompt.md"
    ".github/prompts/analyze-project.prompt.md"          = ".github\prompts\analyze-project.prompt.md"
    ".github/prompts/setup-toolkit.prompt.md"            = ".github\prompts\setup-toolkit.prompt.md"
    ".github/copilot-toolkit-config.json"                = ".github\project-feature-analyser-prompt-saving.ai-config.json"
    "templates/feature-config-template.md"               = "templates\feature-config-template.md"
}

$installed = 0
$failed = 0

foreach ($entry in $files.GetEnumerator()) {
    $result = Get-ToolkitFile -Source $entry.Key -Destination $entry.Value
    if ($result) { $installed++ } else { $failed++ }
}

# --- Update .gitignore -------------------------------------------------------
$gitignoreEntries = @(
    ".github/project-feature-analyser-prompt-saving.ai-config.json"
    "prompt-log.md"
    "coding-fixes-log.md"
    "functional-fixes-log.md"
    "feature-config.md"
    "functionality-config.md"
)

$gitignorePath = ".gitignore"

if (Test-Path $gitignorePath) {
    $content = Get-Content $gitignorePath -Raw
    foreach ($entry in $gitignoreEntries) {
        if ($content -notmatch [regex]::Escape($entry)) {
            Add-Content -Path $gitignorePath -Value $entry
            Write-Info "Added '$entry' to .gitignore"
        }
    }
}
else {
    $gitignoreEntries | Set-Content -Path $gitignorePath
    Write-Info "Created .gitignore with toolkit entries"
}

# --- Summary -----------------------------------------------------------------
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host "  Files installed: $installed" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "  Files failed: $failed" -ForegroundColor Yellow
}
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

Write-Host @"
Quick Start:
  1. Open this project in VS Code
  2. Type /scaffold-project in Copilot Chat to generate a feature checklist
  3. Type /analyze-project to scan existing code and detect features
  4. Type /setup-toolkit to configure all feature toggles

Features (v2.0):
  - Prompt logging       -> prompt-log.md
  - Coding fixes log     -> coding-fixes-log.md (training-oriented)
  - Functional fixes log -> functional-fixes-log.md (training-oriented)
  - Auto README/docs     -> auto-updates README.md + project-details.md
  - Feature config       -> technical feature matrix (any language)
  - Functionality config -> user-facing functionality matrix

Config: .github\project-feature-analyser-prompt-saving.ai-config.json

Docs: https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai#readme
"@