# Copilot Toolkit — User-Level Installer (Windows PowerShell)
# Installs toolkit files to the VS Code user prompts folder so they're available in ALL workspaces.
# Usage: ./install.ps1 [-Exclude <component>] [-Interactive]

param(
    [string[]]$Exclude = @(),
    [switch]$Interactive
)

$ErrorActionPreference = "Stop"

# ─── Detect VS Code Prompts Folder ──────────────────────────────────────────
$vscodePaths = @(
    "$env:APPDATA\Code\User\prompts"
    "$env:APPDATA\Code - Insiders\User\prompts"
)

$promptsFolder = $null
foreach ($path in $vscodePaths) {
    $parentDir = Split-Path -Parent $path
    if (Test-Path $parentDir) {
        $promptsFolder = $path
        break
    }
}

if (-not $promptsFolder) {
    Write-Host "[ERR] Could not find VS Code user folder. Is VS Code installed?" -ForegroundColor Red
    Write-Host "      Expected: $($vscodePaths -join ' or ')" -ForegroundColor Red
    exit 1
}

# ─── Interactive Mode ────────────────────────────────────────────────────────
$components = @{
    "promptLogger"   = @{ File = "instructions\prompt-logger.instructions.md"; Desc = "Prompt Logger (auto-logs implementation prompts)" }
    "scaffolder"     = @{ File = "prompts\scaffold-project.prompt.md";         Desc = "Project Scaffolder (/scaffold-project)" }
    "analyzer"       = @{ File = "prompts\analyze-project.prompt.md";          Desc = "Project Analyzer (/analyze-project)" }
    "setup"          = @{ File = "prompts\setup-toolkit.prompt.md";            Desc = "Setup Toolkit (/setup-toolkit)" }
    "config"         = @{ File = "project-feature-analyser-prompt-saving.ai-config.json";                Desc = "Toolkit Configuration" }
    "template"       = @{ File = "templates\feature-config-template.md";       Desc = "Feature Config Template" }
}

if ($Interactive) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  Copilot Toolkit — Interactive Install   ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Select components to install:" -ForegroundColor Yellow
    Write-Host ""

    $selectedExclude = @()
    foreach ($comp in $components.GetEnumerator()) {
        $response = Read-Host "  Install $($comp.Value.Desc)? [Y/n]"
        if ($response -eq 'n' -or $response -eq 'N') {
            $selectedExclude += $comp.Key
        }
    }
    $Exclude = $selectedExclude
    Write-Host ""
}

# ─── Helper Functions ────────────────────────────────────────────────────────
function Write-Info    { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host "[OK]   $msg" -ForegroundColor Green }
function Write-Warn    { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }

# ─── Main ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Copilot Toolkit — User-Level Installer  ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Info "Target: $promptsFolder"
Write-Host ""

# Ensure script is run from the repo root
$repoRoot = $PSScriptRoot
if (-not (Test-Path "$repoRoot\.github\prompts")) {
    Write-Host "[ERR] Run this script from the project-feature-analyser-prompt-saving.ai repo root." -ForegroundColor Red
    exit 1
}

# Map source files to destinations
$fileMappings = @(
    @{ Src = ".github\instructions\prompt-logger.instructions.md"; Dst = "instructions\prompt-logger.instructions.md"; Comp = "promptLogger" }
    @{ Src = ".github\prompts\scaffold-project.prompt.md";         Dst = "prompts\scaffold-project.prompt.md";         Comp = "scaffolder" }
    @{ Src = ".github\prompts\analyze-project.prompt.md";          Dst = "prompts\analyze-project.prompt.md";          Comp = "analyzer" }
    @{ Src = ".github\prompts\setup-toolkit.prompt.md";            Dst = "prompts\setup-toolkit.prompt.md";            Comp = "setup" }
    @{ Src = ".github\project-feature-analyser-prompt-saving.ai-config.json";                Dst = "project-feature-analyser-prompt-saving.ai-config.json";                Comp = "config" }
    @{ Src = "templates\feature-config-template.md";               Dst = "templates\feature-config-template.md";       Comp = "template" }
)

$installed = 0
$skipped = 0

foreach ($mapping in $fileMappings) {
    # Check exclusions
    if ($Exclude -contains $mapping.Comp) {
        Write-Warn "Skipped: $($mapping.Dst) (excluded: $($mapping.Comp))"
        $skipped++
        continue
    }

    $srcPath = Join-Path $repoRoot $mapping.Src
    $dstPath = Join-Path $promptsFolder $mapping.Dst
    $dstDir  = Split-Path -Parent $dstPath

    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }

    if (Test-Path $srcPath) {
        Copy-Item -Path $srcPath -Destination $dstPath -Force
        Write-Success "Installed: $($mapping.Dst)"
        $installed++
    }
    else {
        Write-Warn "Source not found: $($mapping.Src)"
    }
}

# ─── Summary ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "══════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host "  Files installed: $installed" -ForegroundColor Green
if ($skipped -gt 0) {
    Write-Host "  Files skipped: $skipped" -ForegroundColor Yellow
}
Write-Host "  Location: $promptsFolder" -ForegroundColor Green
Write-Host "══════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Write-Host @"
Available Slash Commands (in any VS Code workspace):
  /scaffold-project  — Generate or build from feature checklist
  /analyze-project   — Scan existing project and detect features
  /setup-toolkit     — Re-run this installer from VS Code

To disable prompt logging:
  Edit: $promptsFolder\project-feature-analyser-prompt-saving.ai-config.json
  Set:  "promptLogger": false

To uninstall:
  Delete the folder: $promptsFolder

Docs: https://github.com/utpanwar/project-feature-analyser-prompt-saving.ai#readme
"@
