#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "=== proxit setup ==="
echo ""

command -v docker >/dev/null 2>&1 || { echo "Error: docker required"; exit 1; }

# 1. WireGuard config
echo "Step 1: Proton VPN WireGuard config"
echo "  Get it from: https://account.protonvpn.com/downloads#wireguard-configuration"
echo ""

if [[ -f wg.conf ]]; then
    echo "  Found wg.conf ✓"
else
    read -p "  Press Enter to open editor, paste your config, save, and exit..."
    "${VISUAL:-${EDITOR:-vi}}" wg.conf </dev/tty >/dev/tty
    [[ ! -s wg.conf ]] && { echo "  ✗ wg.conf is empty"; exit 1; }
    echo "  Saved wg.conf ✓"
fi
echo ""

# 2. Tailscale
echo "Step 2: Tailscale auth key"
echo "  Get it from: https://login.tailscale.com/admin/settings/keys"
echo ""

if [[ -f .env ]] && grep -q "^TS_AUTHKEY=tskey-" .env; then
    echo "  Found existing key ✓"
else
    read -p "  Auth key: " TS_AUTHKEY
    read -p "  Hostname [proton-exit]: " TS_HOSTNAME
    TS_HOSTNAME="${TS_HOSTNAME:-proton-exit}"
    cat > .env <<EOF
TS_AUTHKEY=$TS_AUTHKEY
TS_HOSTNAME=$TS_HOSTNAME
EOF
    echo "  Saved .env ✓"
fi
echo ""

# 3. Start
echo "Starting containers..."
docker compose up -d --quiet-pull

echo -n "Connecting"
for i in {1..30}; do
    if ip=$(docker compose exec -T gluetun cat /tmp/gluetun/ip 2>/dev/null) && [[ -n "$ip" ]]; then
        echo " ✓ $ip"
        echo ""
        echo "Done! Approve exit node at: https://login.tailscale.com/admin/machines"
        exit 0
    fi
    echo -n "."
    sleep 2
done

echo " ✗ Failed - check: docker compose logs gluetun"
exit 1
