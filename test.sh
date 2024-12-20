#!/bin/bash
set -x
set -e

# Configure to the IP address of the container
AGENT=172.24.1.3:5001

# Configure the API keys from host.env
curl -X POST -H "Content-Type: text/plain" --data-binary @host.env http://$AGENT/configure
curl http://$AGENT/status

# Configure the API keys on replicatoor
curl -X POST -H "Content-Type: text/plain" --data-binary @host.env http://$AGENT/replicatoor/configure
curl http://$AGENT/replicatoor/status

curl -X POST \
     -F "defaultCharacter.ts=@private-prompts/defaultCharacter.ts" \
     -F "prompts.ts=@private-prompts/prompts.ts" \
     http://$AGENT/upload

# Bootstrap credentials (generate new private key for wallet)
# curl -X POST http://$AGENT/bootstrap
# curl http://$AGENT/status

# Refresh credentials (log in to twitter)
# curl -X POST http://$AGENT/refresh
# curl http://$AGENT/status

# Load private data
# curl -X POST http://$AGENT/load
# curl http://$AGENT/status

# Save private data (not needed after refresh)
# curl -X POST http://$AGENT/save
# curl http://$AGENT/status

# Request the key
# curl -s -X POST http://$REPL/requestKey > request.out
# PUBK=$(cat request.out | jq -r .pubk)
# QUOTE=$(cat request.out | jq -r .quote)

# Prepare the encrypted state file
# curl -s -X POST -d "pubk=$PUBK" -d "quote=$QUOTE"  http://$REPL/onboard > onboard.out

# Post the encrypted state file
#curl -X POST -H "Content-Type: text/plain" --data-binary @onboard.out http://$REPL/receiveKey
#curl http://$REPL/status

# Load private data
# curl -X POST http://$AGENT/load
# curl http://$AGENT/status

# Run the Bot
curl -X POST http://$AGENT/start_bot
curl http://$AGENT/status
