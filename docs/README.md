## OpenVPN Server in Docker Container

Builds an OpenVPN server that uses Freeradius/MySQL for backend authentication.
Server listens for connections on both UDP 1194 and TCP 443.  The server will look
for key material in '$PWD/config/ovpn'

[![Build Status](https://travis-ci.org/2stacks/docker-ovpn.svg?branch=master)](https://travis-ci.org/2stacks/docker-ovpn)
[![Docker Stars](https://img.shields.io/docker/stars/2stacks/docker-ovpn.svg?style=popout-square)](https://hub.docker.com/r/2stacks/docker-ovpn)
[![Docker Pulls](https://img.shields.io/docker/pulls/2stacks/docker-ovpn.svg?style=popout-square)](https://hub.docker.com/r/2stacks/docker-ovpn)
[![Build Details](https://images.microbadger.com/badges/image/2stacks/docker-ovpn.svg)](https://microbadger.com/images/2stacks/docker-ovpn)

## Supported tags
-   `1.4`, `latest`  [*(Dockerfile)*](https://github.com/2stacks/docker-ovpn/blob/master/Dockerfile)
-   `1.3`  [*(Dockerfile)*](https://github.com/2stacks/docker-ovpn/blob/ec1316eef9b5299010f8ab743007ba1a224a6ec9/Dockerfile)
-   `1.2`  [*(Dockerfile)*](https://github.com/2stacks/docker-ovpn/blob/bfc717e2886aa22e206e64d3cffb8e35f5d34c6d/Dockerfile)
-   `1.1`  [*(Dockerfile)*](https://github.com/2stacks/docker-ovpn/blob/ea86b2ffcd4392d56a0279e695074f8bb70df24d/Dockerfile)

## The following key materials are required to launch the server.

-   ca.crt  
-   site.crt  
-   site.dh  
-   site.key  
-   ta.key

A very basic shell script has been included to generate a set of key material using
EasyRSA.  This key material uses the EasyRSA package default configuration and is not
suitable for use in production.  To generate the keys as well as an example of how
to use the keys in a client configuration run the following;

```
docker run -it --rm -v /$PWD/configs/ovpn:/etc/openvpn 2stacks/docker-ovpn gen-keys
```

All files will be copied to the the local volume mapped to /etc/openvpn.

## Environment Variables

-   RADIUS_HOST=freeradius
-   RADIUS_KEY=testing123
-   DNS_HOST1=1.1.1.1
-   DNS_HOST2=1.0.0.1
-   OVPN_DEBUG=yes

Note: Setting OVPN_DEBUG ENV to anything will enable server logging to /tmp

## Build the OpenVPN Container
```bash
docker build --pull -t 2stacks/docker-ovpn .
```

## Run the OpenVPN Container
```bash
docker run -itd \
  -h openvpn \
  --restart=always \
  --name openvpn \
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

Example 'docker-compose.yml' File

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
      - backend

  freeradius:
    image: "2stacks/freeradius:latest"
    ports:
      - "1812:1812/udp"
      - "1813:1813/udp"
    environment:
      #- DB_NAME=radius
      #- DB_HOST=mysql
      #- DB_USER=radius
      #- DB_PASS=radpass
      #- DB_PORT=3306
      #- RADIUS_KEY=testing123
      #- RAD_CLIENTS=10.0.0.0/22
      - RAD_DEBUG=yes
    depends_on:
      - mysql
    links:
      - mysql
    restart: always
    networks:
      - backend

  mysql:
    image: "mysql:5.7.22"
    command: mysqld --server-id=1
    ports:
      - "127.0.0.1:3306:3306"
    volumes:
      - "./configs/mysql/master/data:/var/lib/mysql"
      - "./configs/mysql/master/conf.d:/etc/mysql/conf.d"
      - "./configs/mysql/radius.sql:/docker-entrypoint-initdb.d/radius.sql"
    environment:
      - MYSQL_ROOT_PASSWORD=radius
      - MYSQL_USER=radius
      - MYSQL_PASSWORD=radpass
      - MYSQL_DATABASE=radius
    restart: always
    networks:
      - backend

networks:
  backend:
    ipam:
      config:
        - subnet: 10.0.0.128/25
```
