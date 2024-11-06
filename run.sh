set -x
set -e

# Load everything from the private.env
cat $SECURE_FILE
set -a
# . $SECURE_FILE
set +a

# Try to fetch a quote
# The argument report_data accepts binary data encoding in hex string.
# The actual report_data passing the to the underlying TDX driver is sha2_256(report_data).
PAYLOAD="{\"report_data\": \"$(echo -n $X_USERNAME | od -A n -t x1 | tr -d ' \n')\"}"
curl -X POST --unix-socket /var/run/tappd.sock -d "$PAYLOAD" http://localhost/prpc/Tappd.TdxQuote?json | jq .

# Run the nous agent
pushd agent
python3 run_pipeline.py
popd
