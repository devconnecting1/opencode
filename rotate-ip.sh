#!/usr/bin/env bash
# IP Rotation Proxy for OpenCode
# Rotates IPs to bypass rate limits on api.opencode.ai

set -e

PROXY_PORT="${PROXY_PORT:-8080}"
PROXY_HOST="${PROXY_HOST:-127.0.0.1}"

echo "Starting IP rotation proxy on $PROXY_HOST:$PROXY_PORT"

# Function to get a random free proxy
get_random_proxy() {
    # List of free SOCKS5 proxies (update these as needed)
    local proxies=(
        "socks5://184.178.172.28:15294"
        "socks5://192.111.139.165:19402"
        "socks5://184.178.172.18:15284"
        "socks5://72.210.252.134:4145"
        "socks5://184.178.172.22:15288"
    )
    
    # Pick a random proxy
    local index=$((RANDOM % ${#proxies[@]}))
    echo "${proxies[$index]}"
}

# Function to check if proxy is working
check_proxy() {
    local proxy=$1
    local test_url="https://api.opencode.ai/"
    
    if curl -s --proxy "$proxy" --connect-timeout 5 --max-time 10 "$test_url" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Main rotation logic
current_proxy=""
request_count=0
max_requests_before_rotate=50

rotate_proxy() {
    local attempts=0
    local max_attempts=10
    
    while [ $attempts -lt $max_attempts ]; do
        current_proxy=$(get_random_proxy)
        echo "Trying proxy: $current_proxy"
        
        if check_proxy "$current_proxy"; then
            echo "✓ Using proxy: $current_proxy"
            return 0
        fi
        
        attempts=$((attempts + 1))
    done
    
    echo "No working proxy found, using direct connection"
    current_proxy=""
    return 0
}

# Start with a working proxy
rotate_proxy

# Set up environment for opencode
export https_proxy="$current_proxy"
export http_proxy="$current_proxy"
export all_proxy="$current_proxy"
export no_proxy="localhost,127.0.0.1"

echo ""
echo "=== OpenCode IP Rotation Proxy ==="
echo "Proxy: $current_proxy"
echo "Port: $PROXY_PORT"
echo ""
echo "Usage:"
echo "  1. Run this script: ./rotate-ip.sh"
echo "  2. In another terminal, run opencode normally"
echo "  3. When rate limited, press Ctrl+C and restart"
echo ""
echo "Or set proxy manually:"
echo "  export https_proxy=$current_proxy"
echo "  export http_proxy=$current_proxy"
echo "  opencode"
echo ""

# Keep script running and rotate on SIGINT
trap 'echo "Rotating IP..."; rotate_proxy; export https_proxy="$current_proxy"; export http_proxy="$current_proxy"; export all_proxy="$current_proxy"' INT

while true; do
    sleep 60
    request_count=$((request_count + 1))
    
    # Rotate every max_requests_before_rotate
    if [ $request_count -ge $max_requests_before_rotate ]; then
        echo "Rotating IP after $request_count requests..."
        rotate_proxy
        export https_proxy="$current_proxy"
        export http_proxy="$current_proxy"
        export all_proxy="$current_proxy"
        request_count=0
    fi
done
