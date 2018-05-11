## OpenVPN Server in Docker Container

Builds an OpenVPN server that uses Freeradius/MySQL for backend authentication.
Server listens for connections on both UDP 1194 and TCP 443.  The server will look
for key material in '$PWD/config/ovpn'

## Supported tags
-   1.1, latest
-   0.1b

## The following key materials are required to launch the server.

-   ca.crt  
-   site.crt  
-   site.dh  
-   site.key  
-   ta.key

## Environment Variables

-   RADIUS_HOST=freeradius
-   RADIUS_KEY=testing123
-   DNS_HOST1=1.1.1.1
-   DNS_HOST2=1.0.0.1
-   OVPN_DEBUG=yes

Note: Setting OVPN_DEBUG ENV to anything will enable server logging to /tmp

## Build the docker container
```bash
  docker build --pull -t 2stacks/docker-ovpn .
```

## Run OpenVPN Container
```bash
docker run -itd \
  -h openvpn \
  --restart=always \
  --name openvpn \
  --network=vpn \
  --cap-add=NET_ADMIN \
  -e "RADIUS_HOST=freeradius" \
  -e "RADIUS_KEY=testing123" \
  -e "DNS_HOST1=1.1.1.1" \
  -e "DNS_HOST2=1.0.0.1" \
  -p 1194:1194/udp \
  -p 443:443 \
  -v /$PWD/configs/ovpn:/etc/openvpn \
  2stacks/docker-ovpn
```

## Run using Docker Compose (can be used to launch freeradius and mysql)
```bash
docker-compose -f docker-compose.yml up -d
```
```bash
    version: '3.2'

    services:

      ovpn:
        image: "2stacks/docker-ovpn:latest"
        ports:
          - "443:443"
          - "1194:1194/udp"
        volumes:
          - "./configs/ovpn:/etc/openvpn"
        environment:
          #- RADIUS_HOST=freeradius
          #- RADIUS_KEY=testing123
          #- DNS_HOST1=1.1.1.1
          #- DNS_HOST2=1.0.0.1
          - OVPN_DEBUG=yes
        cap_add:
          - NET_ADMIN
        restart: always
        networks:
          - vpn

    networks:
      vpn:
        ipam:
          config:
            - subnet: 10.0.1.0/24
```
