Title: Security Hardening
Authors: Nigel Bowden

# Security Hardening

### WLAN Pi
Wiperf employs the following security mechanisms in an attempt to harden the WLAN Pi when deployed in wiperf mode:

- No forwarding is allowed between network interfaces
- The internal UFW firewall is configured to only allow incoming connectivity on port 22 on the wlan0 & eth0 interfaces
