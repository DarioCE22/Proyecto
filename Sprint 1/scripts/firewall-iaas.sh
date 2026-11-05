#!/bin/bash
iptables -F
iptables -t nat -F
iptables -X

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -s 10.10.10.0/24 -d 10.10.20.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -s 10.10.10.0/24 -d 10.10.30.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -s 10.10.10.0/24 -p icmp -j ACCEPT

iptables -A FORWARD -s 10.10.20.0/24 -d 10.10.30.0/24 -j DROP
iptables -A FORWARD -s 10.10.30.0/24 -d 10.10.20.0/24 -j DROP

iptables -A INPUT -s 10.10.20.0/24 -p tcp --dport 22 -j DROP
iptables -A INPUT -s 10.10.30.0/24 -p tcp --dport 22 -j DROP

iptables -A FORWARD -i ens19 -o ens18 -j ACCEPT
iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE

iptables -t nat -A PREROUTING -i ens18 -p tcp --dport 80 -j DNAT --to-destination 10.10.20.101:80
iptables -A FORWARD -i ens18 -d 10.10.20.101 -p tcp --dport 80 -j ACCEPT

iptables -t nat -A PREROUTING -i ens18 -p tcp --dport 25565 -j DNAT --to-destination 10.10.30.101:25565
iptables -t nat -A PREROUTING -i ens18 -p udp --dport 25565 -j DNAT --to-destination 10.10.30.101:25565
iptables -A FORWARD -i ens18 -d 10.10.30.101 -p tcp --dport 25565 -j ACCEPT
iptables -A FORWARD -i ens18 -d 10.10.30.101 -p udp --dport 25565 -j ACCEPT
