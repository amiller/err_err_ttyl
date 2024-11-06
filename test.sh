#!/bin/bash
set -x
set -e

# Configure to the IP address of the container
REPL=172.24.0.2:4001
AGENT=172.24.0.3:5001

# Configure the API keys from host.env
curl -X POST -H "Content-Type: text/plain" --data-binary @host.env http://$AGENT/configure
curl http://$AGENT/status

# Run the Bot
curl -X POST http://$AGENT/start_bot
curl http://$AGENT/status
