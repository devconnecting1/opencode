# Quick IP Rotation for OpenCode (PowerShell)
# Right-click → Run with PowerShell

$proxies = @(
    "socks5://184.178.172.28:15294",
    "socks5://192.111.139.165:19402",
    "socks5://184.178.172.18:15284",
    "socks5://72.210.252.134:4145",
    "socks5://184.178.172.22:15288"
)

# Pick random proxy
$selectedProxy = $proxies | Get-Random

Write-Host "Using proxy: $selectedProxy" -ForegroundColor Green
Write-Host "Starting OpenCode with rotated IP..." -ForegroundColor Yellow
Write-Host ""

# Set proxy environment
$env:https_proxy = $selectedProxy
$env:http_proxy = $selectedProxy
$env:all_proxy = $selectedProxy

# Run opencode
& opencode @args
