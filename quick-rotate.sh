#!/usr/bin/env bash
# Quick IP rotation for OpenCode
# Just run: ./quick-rotate.sh

# Free SOCKS5 proxies (update as needed)
PROXIES=(
    "socks5://184.178.172.28:15294"
    "socks5://192.111.139.165:19402"
    "socks5://184.178.172.18:15284"
    "socks5://72.210.252.134:4145"
    "socks5://184.178.172.22:15288"
)

# Pick random proxy
RANDOM_INDEX=$((RANDOM % ${#PROXIES[@]}))
SELECTED_PROXY="${PROXIES[$RANDOM_INDEX]}"

echo "Using proxy: $SELECTED_PROXY"
echo "Starting OpenCode with rotated IP..."
echo ""

# Set proxy environment
export https_proxy="$SELECTED_PROXY"
export http_proxy="$SELECTED_PROXY"
export all_proxy="$SELECTED_PROXY"

# Run opencode
opencode "$@"
