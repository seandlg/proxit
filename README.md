# proxit

Use your Proton VPN subscription as a Tailscale exit node.

```
┌─────────────────────────────────────────────────────────────┐
│ Docker Host                                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ gluetun (VPN tunnel + kill switch)                   │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │ tailscale (exit node)                          │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
         │                                │
         ▼                                ▼
    Proton VPN                     Your Tailnet
    (WireGuard)                      Devices
```

All Tailscale traffic routes through Proton VPN. The firewall acts as a kill switch - if the VPN connection drops, traffic stops.

## Prerequisites

- Docker & Docker Compose
- [Proton VPN](https://protonvpn.com) subscription (Plus or higher)
- [Tailscale](https://tailscale.com) account

## Setup

```bash
git clone https://github.com/seandlg/proxit.git
cd proxit
./setup.sh
```

The script opens your editor to paste the WireGuard config (from [Proton VPN](https://account.protonvpn.com/downloads#wireguard-configuration)), then asks for your Tailscale auth key.

Finally, approve the exit node at [Tailscale Machines](https://login.tailscale.com/admin/machines).

### Tailnet Lock

If you have [Tailnet Lock](https://tailscale.com/kb/1226/tailnet-lock) enabled, you need a **pre-signed auth key**. On a trusted node, run:

```bash
tailscale lock sign <your-auth-key>
```

Use the output as your auth key in `./setup.sh`. Alternatively, you can approve the Tailscale node manually at [Tailscale Machines](https://login.tailscale.com/admin/machines).

## Troubleshooting

```bash
docker compose logs -f gluetun    # VPN connection
docker compose logs -f tailscale  # Exit node registration
```
