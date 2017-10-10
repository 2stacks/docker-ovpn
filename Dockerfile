# Credit: https://github.com/jpetazzo/dockvpn
# Credit: https://github.com/kylemanna/docker-openvpn

FROM ubuntu:16.04
MAINTAINER "2stacks@2stacks.net"

# Use --build-arg BUILD_DATE='date'
ARG BUILD_DATE

# Image details
LABEL net.2stacks.build-date="$BUILD_DATE" \
      net.2stacks.name="2stacks" \
      net.2stacks.license="MIT" \
      net.2stacks.description="Dockerfile for autobuilds" \
      net.2stacks.url="http://www.2stacks.net" \
      net.2stacks.vcs-type="Git" \
      net.2stacks.version="0.1-Alpha"

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
                                              openvpn \
	                                      openvpn-auth-radius \
                                              freeradius-utils \
    && rm -rf /var/lib/apt/lists/*

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
ENV DNS_HOST1=8.8.8.8
ENV DNS_HOST2=8.8.4.4

# Execute 'run' Script
CMD run
