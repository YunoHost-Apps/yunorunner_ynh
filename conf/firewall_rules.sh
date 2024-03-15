#!/bin/bash

iptables -t filter -A INPUT -i incusbr0 -p udp -d 255.255.255.255 --dport 67 -j ACCEPT
