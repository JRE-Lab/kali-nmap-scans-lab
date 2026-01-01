diff --git a/scripts/nmap_lab.sh b/scripts/nmap_lab.sh
new file mode 100755
index 0000000000000000000000000000000000000000..e3ca60fb62532bd82c9053795679988dfed401d1
--- /dev/null
+++ b/scripts/nmap_lab.sh
@@ -0,0 +1,73 @@
+#!/usr/bin/env bash
+set -euo pipefail
+
+usage() {
+  cat <<'USAGE'
+Usage: ./scripts/nmap_lab.sh --subnet <CIDR> --output <DIR>
+
+Options:
+  --subnet   Target subnet in CIDR notation (e.g., 192.168.56.0/24)
+  --output   Output directory for scan artifacts
+  --help     Show this help text
+USAGE
+}
+
+subnet=""
+output_dir=""
+
+while [[ $# -gt 0 ]]; do
+  case "$1" in
+    --subnet)
+      subnet="${2:-}"
+      shift 2
+      ;;
+    --output)
+      output_dir="${2:-}"
+      shift 2
+      ;;
+    --help)
+      usage
+      exit 0
+      ;;
+    *)
+      echo "Unknown option: $1" >&2
+      usage
+      exit 1
+      ;;
+  esac
+done
+
+if [[ -z "$subnet" || -z "$output_dir" ]]; then
+  echo "Both --subnet and --output are required." >&2
+  usage
+  exit 1
+fi
+
+mkdir -p "$output_dir"
+log_file="$output_dir/scan.log"
+
+{
+  echo "Starting Nmap lab run"
+  echo "Subnet: $subnet"
+  echo "Output: $output_dir"
+  echo "Timestamp: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
+} | tee "$log_file"
+
+# Host discovery
+nmap -sn "$subnet" -oG "$output_dir/host-discovery.gnmap" | tee -a "$log_file"
+
+# TCP SYN scan (top 1000 ports)
+nmap -sS "$subnet" -oX "$output_dir/tcp-syn.xml" | tee -a "$log_file"
+
+# Service/version detection (targeting live hosts only)
+# Extract live hosts from the greppable output
+live_hosts=$(awk '/Status: Up/ {print $2}' "$output_dir/host-discovery.gnmap" | tr '\n' ' ')
+
+if [[ -n "$live_hosts" ]]; then
+  nmap -sV $live_hosts -oX "$output_dir/service-version.xml" | tee -a "$log_file"
+  nmap -O $live_hosts -oX "$output_dir/os-detect.xml" | tee -a "$log_file"
+else
+  echo "No live hosts detected; skipping service/version and OS detection scans." | tee -a "$log_file"
+fi
+
+echo "Nmap lab run complete." | tee -a "$log_file"
