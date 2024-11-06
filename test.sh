#!/bin/bash
set -x
set -e

# Configure to the IP address of the container
REPL=172.24.0.2:4001
AGENT=172.24.0.3:5001

# Configure the API keys from host.env
curl -X POST -H "Content-Type: text/plain" --data-binary @host.env http://$AGENT/configure
curl http://$AGENT/status

# Refresh credentials
curl -X POST http://$AGENT/refresh
curl http://$AGENT/status

# Save private data (not needed after refresh)
# curl -X POST http://$AGENT/save
# curl http://$AGENT/status

# How did it go?
cat $SECURE_FILE

# Load private data
curl -X POST http://$AGENT/load
curl http://$AGENT/status

# Run the Bot
# curl -X POST http://$AGENT/start_bot
# curl http://$AGENT/status
