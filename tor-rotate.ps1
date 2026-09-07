# Tor IP Rotation for OpenCode (PowerShell)
# Right-click → Run with PowerShell

Write-Host "=== OpenCode Tor IP Rotation ===" -ForegroundColor Cyan
Write-Host ""

# Check if Tor is installed
if (-not (Get-Command tor -ErrorAction SilentlyContinue)) {
    Write-Host "Tor not found. Install from: https://www.torproject.org/download/" -ForegroundColor Red
    Write-Host "Or use: winget install TorProject.Tor" -ForegroundColor Yellow
    exit 1
}

# Check if Tor is running
$torProcess = Get-Process tor -ErrorAction SilentlyContinue
if (-not $torProcess) {
    Write-Host "Starting Tor..." -ForegroundColor Yellow
    Start-Process tor -WindowStyle Hidden
    Start-Sleep -Seconds 5
}

Write-Host "Tor is running" -ForegroundColor Green
Write-Host ""

# Function to rotate Tor circuit
function Rotate-Tor {
    Write-Host "Rotating IP (new Tor circuit)..." -ForegroundColor Yellow
    
    # Restart Tor to get new circuit
    Stop-Process -Name tor -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process tor -WindowStyle Hidden
    Start-Sleep -Seconds 5
    
    # Get new IP
    try {
        $ip = (Invoke-WebRequest -Uri "https://check.torproject.org/api/ip" -Proxy "socks5://127.0.0.1:9050" -TimeoutSec 10).Content | ConvertFrom-Json
        Write-Host "New IP: $($ip.IP)" -ForegroundColor Green
    } catch {
        Write-Host "Could not verify IP" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Initial rotation
Rotate-Tor

# Set Tor proxy
$env:https_proxy = "socks5h://127.0.0.1:9050"
$env:http_proxy = "socks5h://127.0.0.1:9050"
$env:all_proxy = "socks5h://127.0.0.1:9050"

Write-Host "Starting OpenCode with Tor..." -ForegroundColor Cyan
Write-Host "Press Enter to rotate IP, or Ctrl+C to exit" -ForegroundColor Yellow
Write-Host ""

# Run opencode in background
$job = Start-Job -ScriptBlock {
    & opencode @args
}

# Wait for user input to rotate
while ($job.State -eq "Running") {
    if ([Console]::KeyAvailable) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq "Enter") {
            Rotate-Tor
        }
        if ($key.Key -eq "Escape") {
            break
        }
    }
    Start-Sleep -Milliseconds 100
}

# Cleanup
Stop-Job -Job $job -ErrorAction SilentlyContinue
Remove-Job -Job $job -ErrorAction SilentlyContinue
