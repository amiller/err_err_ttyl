#!/bin/bash
set -e

# Start the oauth client to receive the callback
pushd client
RUST_LOG=info cargo run --release --bin helper &
SERVER=$!
popd

# Do the twitter login, storing the auth tokens
python3 scripts/tee.py
. cookies.env
export X_AUTH_TOKENS
wait $SERVER

# Update the environment variables
. client/updated.env
export X_ACCESS_TOKEN
export X_ACCESS_TOKEN_SECRET

cat client/updated.env > $SECURE_FILE
cat cookies.env  >> $SECURE_FILE
echo X_PASSWORD=$X_PASSWORD >> $SECURE_FILE
echo PROTONMAIL_PASSWORD=$PROTONMAIL_PASSWORD >> $SECURE_FILE
echo AGENT_WALLET_PRIVATE_KEY=$AGENT_WALLET_PRIVATE_KEY >> $SECURE_FILE
