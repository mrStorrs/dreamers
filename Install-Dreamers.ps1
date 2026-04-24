<#
.SYNOPSIS
    Installs the Dreamers system into the user's global ~/.claude directory.

.DESCRIPTION
    Copies agents, commands, and dreamers refs/templates from this repo
    into the corresponding ~/.claude/ locations.

    Only manages Dreamers-owned files. Does not touch other agents, commands, or
    configs already in ~/.claude/.

.PARAMETER ClaudeHome
    Override the target Claude home directory. Defaults to ~/.claude.

.PARAMETER Force
    Overwrite existing files without prompting.

.EXAMPLE
    .\Install-Dreamers.ps1
    .\Install-Dreamers.ps1 -Force
    .\Install-Dreamers.ps1 -ClaudeHome "D:\custom\.claude"
#>
[CmdletBinding()]
param(
    [string]$ClaudeHome = (Join-Path $HOME ".claude"),
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$RepoRoot = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }

function Copy-Files {
    param(
        [string]$From,
        [string]$To,
        [string]$Label
    )
    if (-not (Test-Path $From)) {
        Write-Warning "Source not found, skipping: $From"
        return 0
    }
    if (-not (Test-Path $To)) {
        New-Item -ItemType Directory -Path $To -Force | Out-Null
    }
    $files = Get-ChildItem $From -File
    $count = 0
    foreach ($f in $files) {
        $dest = Join-Path $To $f.Name
        if ((Test-Path $dest) -and -not $Force) {
            Write-Host "  SKIP (exists): $($f.Name) - use -Force to overwrite" -ForegroundColor Yellow
            continue
        }
        Copy-Item $f.FullName $dest -Force
        Write-Host "  OK: $($f.Name)" -ForegroundColor Green
        $count++
    }
    return $count
}

Write-Host "`nDreamers Installer (Claude Code)" -ForegroundColor Cyan
Write-Host "Source:  $RepoRoot"
Write-Host "Target:  $ClaudeHome`n"

$total = 0

# Agents
Write-Host "[agents]" -ForegroundColor Cyan
$total += Copy-Files -From (Join-Path $RepoRoot "agents") -To (Join-Path $ClaudeHome "agents") -Label "agents"

# Commands (skills)
Write-Host "[commands]" -ForegroundColor Cyan
$total += Copy-Files -From (Join-Path $RepoRoot "commands") -To (Join-Path $ClaudeHome "commands") -Label "commands"

# Dreamers refs
Write-Host "[dreamers/refs]" -ForegroundColor Cyan
$total += Copy-Files -From (Join-Path $RepoRoot "dreamers" "refs") -To (Join-Path $ClaudeHome "dreamers" "refs") -Label "refs"

# Dreamers templates
Write-Host "[dreamers/templates]" -ForegroundColor Cyan
$total += Copy-Files -From (Join-Path $RepoRoot "dreamers" "templates") -To (Join-Path $ClaudeHome "dreamers" "templates") -Label "templates"

# CLAUDE.md (marker-based merge)
Write-Host "[CLAUDE.md]" -ForegroundColor Cyan
$dreamersFragment = Join-Path $RepoRoot "CLAUDE.dreamers.md"
$targetInstructions = Join-Path $ClaudeHome "CLAUDE.md"
$startMarker = "<!-- DREAMERS-START"
$endMarker = "<!-- DREAMERS-END -->"

if (Test-Path $dreamersFragment) {
    $newContent = Get-Content $dreamersFragment -Raw

    if (Test-Path $targetInstructions) {
        $existing = Get-Content $targetInstructions -Raw
        $pattern = "(?s)$([regex]::Escape($startMarker)).*?$([regex]::Escape($endMarker))\r?\n?"

        if ($existing -match [regex]::Escape($startMarker)) {
            # Markers exist - replace the managed section
            $merged = [regex]::Replace($existing, $pattern, $newContent)
            Set-Content $targetInstructions $merged -NoNewline
            Write-Host "  UPDATED: Dreamers section replaced in CLAUDE.md" -ForegroundColor Green
        } else {
            # No markers - file exists but has no managed section
            $merged = $existing.TrimEnd() + "`n`n" + $newContent
            Set-Content $targetInstructions $merged -NoNewline
            Write-Host "  APPENDED: Dreamers section added to CLAUDE.md" -ForegroundColor Green
            if ($existing -match "## Dreamers System") {
                Write-Host ""
                Write-Host "  WARNING: Your CLAUDE.md appears to contain an older" -ForegroundColor Yellow
                Write-Host "  unmarked Dreamers section. Remove the duplicate manually - the new" -ForegroundColor Yellow
                Write-Host "  managed section is between DREAMERS-START / DREAMERS-END markers." -ForegroundColor Yellow
            }
        }
    } else {
        # No file at all - create fresh with just the managed section
        $header = "# Global Instructions`n`n"
        Set-Content $targetInstructions ($header + $newContent) -NoNewline
        Write-Host "  CREATED: CLAUDE.md with Dreamers section" -ForegroundColor Green
    }
    $total++
} else {
    Write-Host "  SKIP: CLAUDE.dreamers.md not found in repo" -ForegroundColor Yellow
}

Write-Host "`nInstalled $($total) file(s).`n" -ForegroundColor Cyan
