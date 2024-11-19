set -e

LOG_FILE="/var/log/payload_stderr.log"
ROTATE_INTERVAL=20m

# Rotate on an interval
echo "START" > /var/log/payload_lasthash
(
    while true; do
	sleep $ROTATE_INTERVAL
	echo "Calling logrotate"
	logrotate logrotate.conf
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
pushd agent
python3 run_pipeline.py  2>&1 | tee -a "$LOG_FILE"
#generate_stderr_output  2>&1 | tee -a "$LOG_FILE"
popd
