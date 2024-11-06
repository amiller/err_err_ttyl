set -x
set -e

# Load everything from the private.env
set -a
. $SECURE_FILE
set +a

# Try to fetch a quote
# The argument report_data accepts binary data encoding in hex string.
# The actual report_data passing the to the underlying TDX driver is sha2_256(report_data).
PAYLOAD="{\"report_data\": \"$(echo -n $TWITTER_ACCOUNT | od -A n -t x1 | tr -d ' \n')\"}"
curl -X POST --unix-socket /var/run/tappd.sock -d "$PAYLOAD" http://localhost/prpc/Tappd.TdxQuote?json | jq .

# Start the oauth client to receive the callback
# pushd client
# RUST_LOG=info cargo run --release --bin helper &
# SERVER=$!
# popd

# Do the twitter login, storing the auth tokens
# python3 scripts/tee.py
# . cookies.env
# export X_AUTH_TOKENS
# wait $SERVER

# Update the environment variables
. client/updated.env
export X_ACCESS_TOKEN
export X_ACCESS_TOKEN_SECRET
[
# Run the nous
pushd agent
python3 run_pipeline.py
popd
