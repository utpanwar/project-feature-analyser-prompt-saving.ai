# Copilot Toolkit - Project-Level Installer (Windows PowerShell)
# Installs toolkit files into the current project's .github/ folder.
# Priority: copies from user-level VS Code prompts folder first, falls back to GitHub download.
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

# --- Detect user-level prompts folder ----------------------------------------
$userPromptsFolder = $null
foreach ($candidate in @("$env:APPDATA\Code\User\prompts", "$env:APPDATA\Code - Insiders\User\prompts")) {
    if (Test-Path "$candidate\prompts\scaffold-project.prompt.md") {
        $userPromptsFolder = $candidate
        break
    }
}

# --- Main --------------------------------------------------------------------
Write-Host ""
Write-Host "+==========================================+" -ForegroundColor Cyan
Write-Host "|  Copilot Toolkit v2.0 - Project Install  |" -ForegroundColor Cyan
Write-Host "+==========================================+" -ForegroundColor Cyan
Write-Host ""

Write-Info "Installing into: $(Get-Location)"

# Check if this is a re-install (upgrade)
$isUpgrade = Test-Path ".github\prompts\scaffold-project.prompt.md"
if ($isUpgrade) {
    Write-Info "Existing toolkit detected - upgrading to latest version"
}

if ($userPromptsFolder) {
    Write-Info "Source: user-level prompts ($userPromptsFolder)"
} else {
    Write-Info "Source: GitHub ($BaseUrl)"
}

# File mappings: user-level source | github source | project destination
$fileMappings = @(
    @{ UserSrc = "instructions\prompt-logger.instructions.md"; GhSrc = ".github/instructions/prompt-logger.instructions.md"; Dst = ".github\instructions\prompt-logger.instructions.md"; IsConfig = $false }
    @{ UserSrc = "instructions\auto-docs.instructions.md";     GhSrc = ".github/instructions/auto-docs.instructions.md";     Dst = ".github\instructions\auto-docs.instructions.md";     IsConfig = $false }
    @{ UserSrc = "prompts\scaffold-project.prompt.md";         GhSrc = ".github/prompts/scaffold-project.prompt.md";         Dst = ".github\prompts\scaffold-project.prompt.md";         IsConfig = $false }
    @{ UserSrc = "prompts\analyze-project.prompt.md";          GhSrc = ".github/prompts/analyze-project.prompt.md";          Dst = ".github\prompts\analyze-project.prompt.md";          IsConfig = $false }
    @{ UserSrc = "prompts\setup-toolkit.prompt.md";            GhSrc = ".github/prompts/setup-toolkit.prompt.md";            Dst = ".github\prompts\setup-toolkit.prompt.md";            IsConfig = $false }
    @{ UserSrc = "project-feature-analyser-prompt-saving.ai-config.json"; GhSrc = ".github/copilot-toolkit-config.json";     Dst = ".github\project-feature-analyser-prompt-saving.ai-config.json"; IsConfig = $true }
    @{ UserSrc = "templates\feature-config-template.md";       GhSrc = "templates/feature-config-template.md";               Dst = "templates\feature-config-template.md";               IsConfig = $false }
)

$installed = 0
$skipped = 0
$failed = 0

foreach ($mapping in $fileMappings) {
    $dstPath = $mapping.Dst
    $dstDir = Split-Path -Parent $dstPath
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }

    # Config file: merge instead of overwrite
    if ($mapping.IsConfig -and (Test-Path $dstPath)) {
        try {
            $existingConfig = Get-Content $dstPath -Raw | ConvertFrom-Json
            # Determine source config
            $sourceConfig = $null
            if ($userPromptsFolder) {
                $srcPath = Join-Path $userPromptsFolder $mapping.UserSrc
                if (Test-Path $srcPath) {
                    $sourceConfig = Get-Content $srcPath -Raw | ConvertFrom-Json
                }
            }
            if (-not $sourceConfig) {
                $tempFile = [System.IO.Path]::GetTempFileName()
                try {
                    Invoke-WebRequest -Uri "$BaseUrl/$($mapping.GhSrc)" -OutFile $tempFile -UseBasicParsing -ErrorAction Stop
                    $sourceConfig = Get-Content $tempFile -Raw | ConvertFrom-Json
                } catch { }
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            }
            if ($sourceConfig) {
                # Merge: add new keys from source, keep existing values
                $merged = $existingConfig
                foreach ($prop in $sourceConfig.PSObject.Properties) {
                    if (-not ($merged.PSObject.Properties.Name -contains $prop.Name)) {
                        $merged | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value
                    }
                }
                # Always update version to latest
                if ($sourceConfig.PSObject.Properties.Name -contains 'version') {
                    $merged.version = $sourceConfig.version
                }
                $merged | ConvertTo-Json -Depth 10 | Set-Content $dstPath -Encoding UTF8
                Write-Success "Merged config: $dstPath (preserved your settings, added new keys)"
                $installed++
            } else {
                Write-Warn "Could not fetch source config - kept existing: $dstPath"
                $skipped++
            }
        }
        catch {
            Write-Warn "Config merge failed - kept existing: $dstPath"
            $skipped++
        }
        continue
    }

    # Non-config files: try user-level first, then GitHub
    $copied = $false
    if ($userPromptsFolder) {
        $srcPath = Join-Path $userPromptsFolder $mapping.UserSrc
        if (Test-Path $srcPath) {
            Copy-Item -Path $srcPath -Destination $dstPath -Force
            Write-Success "Copied: $dstPath (from user-level)"
            $copied = $true
            $installed++
        }
    }
    if (-not $copied) {
        $result = Get-ToolkitFile -Source $mapping.GhSrc -Destination $dstPath
        if ($result) { $installed++ } else { $failed++ }
    }
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
    $existingContent = Get-Content $gitignorePath -Raw
    foreach ($entry in $gitignoreEntries) {
        if ($existingContent -notmatch [regex]::Escape($entry)) {
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
if ($isUpgrade) {
    Write-Host "  Upgrade complete!" -ForegroundColor Green
} else {
    Write-Host "  Installation complete!" -ForegroundColor Green
}
Write-Host "  Files installed: $installed" -ForegroundColor Green
if ($skipped -gt 0) {
    Write-Host "  Files skipped: $skipped" -ForegroundColor Yellow
}
if ($failed -gt 0) {
    Write-Host "  Files failed: $failed" -ForegroundColor Yellow
}
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

Write-Host @"
Quick Start:
  1. Open this project in VS Code (reload if already open)
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