#!/usr/bin/env bash
#
# stress-test.sh
# Generates CPU and memory load to validate that Prometheus, Grafana, and
# Alertmanager correctly detect and report threshold breaches.
#
# Usage:
#   ./stress-test.sh cpu        Run a 60s CPU stress test (4 cores)
#   ./stress-test.sh mem        Run a 60s memory stress test
#   ./stress-test.sh all        Run both tests back to back
#
# Requires the `stress` package: sudo apt install stress -y

set -euo pipefail

MODE="${1:-all}"

run_cpu_test() {
  echo "[*] Starting CPU stress test (4 cores, 60s)..."
  stress --cpu 4 --timeout 60s
  echo "[*] CPU stress test complete. Check Grafana 'Node Exporter Full' dashboard for the spike."
}

run_mem_test() {
  echo "[*] Starting memory stress test (2 workers, ~1GB each, 60s)..."
  stress --vm 2 --vm-bytes 1024M --timeout 60s
  echo "[*] Memory stress test complete. Check Grafana for the memory spike and watch for HighMemoryUsage alerts."
}

case "$MODE" in
  cpu) run_cpu_test ;;
  mem) run_mem_test ;;
  all) run_cpu_test; run_mem_test ;;
  *)
    echo "Usage: $0 {cpu|mem|all}"
    exit 1
    ;;
esac

echo "[*] Done. Expected observations:"
echo "    - Grafana dashboard shows CPU/Memory spike to 80-100%"
echo "    - Alertmanager fires HighCPUUsage / HighMemoryUsage"
echo "    - Alert state visible at http://<ubuntu-ip>:9090/alerts"
echo "    - Email notification received if SMTP is configured"
