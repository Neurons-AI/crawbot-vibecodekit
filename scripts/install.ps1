param(
  [string]$Target = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Copy-WithBackup($Src, $Dest) {
  $Parent = Split-Path -Parent $Dest
  if (!(Test-Path $Parent)) { New-Item -ItemType Directory -Force -Path $Parent | Out-Null }
  if (Test-Path $Dest) { Copy-Item $Dest "$Dest.bak-$Stamp" -Force }
  Copy-Item $Src $Dest -Force
}

Copy-WithBackup "$Root/templates/AGENTS.md" "$Target/AGENTS.md"
Copy-WithBackup "$Root/templates/HEARTBEAT.md" "$Target/HEARTBEAT.md"
Copy-WithBackup "$Root/templates/vibe-workflow.md" "$Target/docs/vibe-workflow.md"
New-Item -ItemType Directory -Force -Path "$Target/tmp" | Out-Null

Write-Host "Installed CrawBot VibeCode Kit into: $Target"
Write-Host "Run: node $Root/scripts/doctor.mjs --target `"$Target`""
