# Credit: https://github.com/jpetazzo/dockvpn
# Credit: https://github.com/kylemanna/docker-openvpn

FROM ubuntu:22.04
MAINTAINER "2stacks@2stacks.net"

# Image details
LABEL net.2stacks.name="2stacks" \
      net.2stacks.license="MIT" \
      net.2stacks.description="Dockerfile for autobuilds" \
      net.2stacks.url="http://www.2stacks.net" \
      net.2stacks.vcs-type="Git" \
      net.2stacks.version="1.5" \
      net.2stacks.ovpn.version="2.4.7"

# Install OpenVPN
RUN apt-get -y update && apt-get install -y \
                                              apt-transport-https \
                                              ca-certificates \
                                              curl \
	                                          iptables \
                                              software-properties-common && \
    curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] http://build.openvpn.net/debian/openvpn/release/2.4 xenial main" && \
    apt-get -y update && apt-get install -y \
                                              easy-rsa \
                                              openvpn \
	                                          openvpn-auth-radius \
                                              freeradius-utils \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Add Scripts to Configure and Run OpenVPN
ADD ./bin /usr/local/sbin
RUN chmod 755 /usr/local/sbin/*

# Create Mount Point for OpenVPN Config Files
VOLUME /etc/openvpn

# Expose Container Ports to Host
EXPOSE 443/tcp 1194/udp

# Allow run time config of options
ENV RADIUS_KEY=testing123
ENV RADIUS_HOST=freeradius
ENV DNS_HOST1=1.1.1.1
ENV DNS_HOST2=1.0.0.1

# Execute 'run' Script
CMD run
