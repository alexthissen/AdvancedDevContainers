#!/bin/sh

devproxy cert ensure
sudo openssl pkcs12 -in $HOME/.config/dev-proxy/rootCert.pfx -nokeys -nodes \
  -out /usr/local/share/ca-certificates/devproxy-ca.crt -passin pass:
sudo update-ca-certificates