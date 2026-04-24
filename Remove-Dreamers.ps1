<#
.SYNOPSIS
    Removes the Dreamers system from the user's global ~/.claude directory.

.DESCRIPTION
    Removes only Dreamers-managed files (agents, commands, refs, templates).
    Does not touch other files in ~/.claude/.

    Strips only the marked Dreamers section from CLAUDE.md - your personal
    instructions remain intact.

.PARAMETER ClaudeHome
    Override the target Claude home directory. Defaults to ~/.claude.

.PARAMETER DryRun
    Preview what would be removed without deleting anything.

.EXAMPLE
    .\Remove-Dreamers.ps1
    .\Remove-Dreamers.ps1 -DryRun
    .\Remove-Dreamers.ps1 -ClaudeHome "D:\custom\.claude"
#>
[CmdletBinding()]
param(
    [string]$ClaudeHome = (Join-Path $HOME ".claude"),
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$RepoRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$Source = Join-Path $RepoRoot ".claude"

# Build list of Dreamers-owned files from the repo
$dreamersFiles = @{
    agents = @()
    commands = @()
    "dreamers/refs" = @()
    "dreamers/templates" = @()
}

foreach ($key in $dreamersFiles.Keys) {
    $sourcePath = Join-Path $Source $key
    if (Test-Path $sourcePath) {
        $dreamersFiles[$key] = (Get-ChildItem $sourcePath -File).Name
    }
}

function Remove-Files {
    param(
        [string]$TargetDir,
        [string[]]$FileNames,
        [string]$Label
    )
    $count = 0
    foreach ($name in $FileNames) {
        $path = Join-Path $TargetDir $name
        if (Test-Path $path) {
            if ($DryRun) {
                Write-Host "  WOULD REMOVE: $name" -ForegroundColor Yellow
            } else {
                Remove-Item $path -Force
                Write-Host "  REMOVED: $name" -ForegroundColor Green
            }
            $count++
        }
    }
    return $count
}

Write-Host "`nDreamers Uninstaller (Claude Code)" -ForegroundColor Cyan
Write-Host "Target:  $ClaudeHome"
if ($DryRun) { Write-Host "Mode:    DRY RUN`n" -ForegroundColor Yellow }
else { Write-Host "" }

$total = 0

# Agents
Write-Host "[agents]" -ForegroundColor Cyan
$total += Remove-Files -TargetDir (Join-Path $ClaudeHome "agents") -FileNames $dreamersFiles["agents"] -Label "agents"

# Commands
Write-Host "[commands]" -ForegroundColor Cyan
$total += Remove-Files -TargetDir (Join-Path $ClaudeHome "commands") -FileNames $dreamersFiles["commands"] -Label "commands"

# Dreamers refs
Write-Host "[dreamers/refs]" -ForegroundColor Cyan
$total += Remove-Files -TargetDir (Join-Path $ClaudeHome "dreamers" "refs") -FileNames $dreamersFiles["dreamers/refs"] -Label "refs"

# Dreamers templates
Write-Host "[dreamers/templates]" -ForegroundColor Cyan
$total += Remove-Files -TargetDir (Join-Path $ClaudeHome "dreamers" "templates") -FileNames $dreamersFiles["dreamers/templates"] -Label "templates"

# CLAUDE.md (strip marked section)
Write-Host "[CLAUDE.md]" -ForegroundColor Cyan
$targetInstructions = Join-Path $ClaudeHome "CLAUDE.md"
$startMarker = "<!-- DREAMERS-START"
$endMarker = "<!-- DREAMERS-END -->"

if (Test-Path $targetInstructions) {
    $content = Get-Content $targetInstructions -Raw
    if ($content -match [regex]::Escape($startMarker)) {
        $pattern = "(?s)$([regex]::Escape($startMarker)).*?$([regex]::Escape($endMarker))\r?\n?"
        if ($DryRun) {
            Write-Host "  WOULD STRIP: Dreamers section from CLAUDE.md" -ForegroundColor Yellow
        } else {
            $stripped = [regex]::Replace($content, $pattern, "")
            # Clean up extra blank lines
            $stripped = $stripped -replace "(\r?\n){3,}", "`n`n"
            Set-Content $targetInstructions $stripped.TrimEnd() -NoNewline
            Write-Host "  STRIPPED: Dreamers section from CLAUDE.md" -ForegroundColor Green
        }
        $total++
    } else {
        Write-Host "  SKIP: No Dreamers markers found in CLAUDE.md" -ForegroundColor Yellow
    }
} else {
    Write-Host "  SKIP: CLAUDE.md not found" -ForegroundColor Yellow
}

if ($DryRun) {
    Write-Host "`nWould remove $($total) file(s)/section(s).`n" -ForegroundColor Yellow
} else {
    Write-Host "`nRemoved $($total) file(s)/section(s).`n" -ForegroundColor Cyan
}
