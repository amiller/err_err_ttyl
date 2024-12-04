set -e

ROTATE_INTERVAL=1m

# Rotate on an interval
echo "START" > /var/log/payload_lasthash
(
    while true; do
	sleep $ROTATE_INTERVAL
	echo "Calling logrotate"
	bash logrotate-post.sh
    done
) &

generate_stderr_output() {
  local line="Sample log entry"
  local iterations=12000
  local delay=1

  for ((i = 1; i <= iterations; i++)); do
      printf "%s\n" "$line" >&2
      sleep "$delay"
  done
}

# Run the nous agent
pushd /app
pnpm dev  2>&1 | tee -a "$LOG_FILE"
popd
