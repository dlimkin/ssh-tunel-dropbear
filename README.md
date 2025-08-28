# SSH Tunnel Dropbear for Docker / Swarm

This repository provides a minimal Docker setup to run a **Dropbear SSH server** for reverse SSH tunneling.  
It allows your **local machine** to expose a local service (e.g., `localhost:80`) to a **Docker Swarm cluster**, while Kong or other services can access it via a fixed port.

---

# Funding 
If you find this project useful, consider supporting its development through cryptocurrency donations:
- BTC: `bc1qsrl63vcuqnmp6drl3f6uhcvnky2t5vqlg2r2jq` [QR code](https://www.blockchain.com/btc/address/bc1qsrl63vcuqnmp6drl3f6uhcvnky2t5vqlg2r2jq)
- ETH or (ERC-20): `0xd1ce59aD3615cdbFCc8cc2C496E9CB0E10CD543B` [QR code](https://etherscan.io/address/0xd1ce59aD3615cdbFCc8cc2C496E9CB0E10CD543B)
- TRON or (TRC-20): `TZ84vr4XcuKcQZAsEJUdyvq5FT6LG66NjX` [QR code](https://tronscan.org/#/address/TZ84vr4XcuKcQZAsEJUdyvq5FT6LG66NjX)
- SOLANA: `BE3hxHZfbk7qpgPtG7hARXJrGJjpwbd1eu9geYtUZNob`  [QR code](https://solscan.io/account/BE3hxHZfbk7qpgPtG7hARXJrGJjpwbd1eu9geYtUZNob)

---

## Features

- Lightweight Dropbear SSH server on Alpine Linux
- Configurable username via environment variable (`USER_NAME`, default: `tunnel`)
- Mount `authorized_keys` via Docker secret or volume
- Exposes SSH and HTTP ports (configurable, default `22` for SSH, `80` for HTTP)
- Works in Docker, Compose, and Swarm

---

## 1️⃣ Docker Example

### Run container
```bash
docker run -e USER_NAME=tunnel \
  -p 22:22 \
  -p 80:80 \
  -v /path/to/authorized_keys:/home/tunnel/.ssh/authorized_keys:ro \
  dlimkin/ssh-tunnel-dropbear
```

### Connect from local machine
```bash
ssh -p 22 -N -R 80:localhost:80 tunnel@<docker-host>
```

## 2️⃣ Docker Compose Example
### docker-compose.yml (optional Traefik labels)
```yaml
version: "3.9"

services:
  tunnel-server:
    build: .
    image: dlimkin/ssh-tunnel-dropbear
    environment:
      USER_NAME: mycustomuser # optional, default is 'tunnel', and change in volume target below
    ports:
      - "22:22"
    volumes:
        - /path/to/authorized_keys:/home/mycustomuser/.ssh/authorized_keys:ro
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.tunnel-server.rule=Host(`tunnel.example.com`)"
      - "traefik.http.services.tunnel-server.loadbalancer.server.port=80"
```

## 3️⃣ Docker Swarm Stack Example
### docker-stack.yml  (optional Traefik labels)
```yaml
version: "3.9"

services:
  tunnel-server:
    image: ssh-tunnel-dropbear
    environment:
      USER_NAME: mycustomuser # optional, default is 'tunnel', and change in secret target below
    ports:
      - "22:22"
      - "80:80"
    secrets:
      - source: ssh_pub_key
        target: /home/mycustomuser/.ssh/authorized_keys
    deploy:
      replicas: 1
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.tunnel-server.rule=Host(`tunnel.example.com`)"
      - "traefik.http.services.tunnel-server.loadbalancer.server.port=80"

secrets:
  ssh_pub_key:
    external: true
````
