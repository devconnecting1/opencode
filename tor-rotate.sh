#!/usr/bin/env bash
# Tor-based IP rotation for OpenCode
# More reliable than free proxies

set -e

echo "=== OpenCode Tor IP Rotation ==="
echo ""

# Check if Tor is installed
if ! command -v tor &> /dev/null; then
    echo "Installing Tor..."
    sudo apt-get update && sudo apt-get install -y tor
fi

# Check if Tor service is running
if ! pgrep -x "tor" > /dev/null; then
    echo "Starting Tor service..."
    sudo service tor start
    sleep 3
fi

echo "Tor is running"
echo ""

# Function to rotate Tor circuit (new IP)
rotate_tor() {
    echo "Rotating IP (new Tor circuit)..."
    sudo service tor restart
    sleep 3
    
    # Get new IP
    NEW_IP=$(curl --socks5-hostname 127.0.0.1:9050 -s https://check.torproject.org/api/ip 2>/dev/null | grep -o '"IP":"[^"]*"' | cut -d'"' -f4)
    echo "New IP: $NEW_IP"
    echo ""
}

# Initial rotation
rotate_tor

# Set Tor proxy
export https_proxy="socks5h://127.0.0.1:9050"
export http_proxy="socks5h://127.0.0.1:9050"
export all_proxy="socks5h://127.0.0.1:9050"

echo "Starting OpenCode with Tor..."
echo "Press Ctrl+C to rotate IP"
echo ""

# Trap Ctrl+C to rotate
trap 'rotate_tor' INT

# Run opencode
opencode "$@"
