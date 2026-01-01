diff --git a/kali_nmap_scans_lab.md b/kali_nmap_scans_lab.md
new file mode 100644
index 0000000000000000000000000000000000000000..2ec0642cc7c3c5be62ced03f20e9f0a82c5c25e2
--- /dev/null
+++ b/kali_nmap_scans_lab.md
@@ -0,0 +1,95 @@
+# Kali Nmap Scans Lab (Hands-on)
+
+This lab turns the existing Nmap walkthrough into a repeatable, automated workflow. It includes a shell runner and a small parser to summarize results from XML output.
+
+> **Safety note**: Only scan systems you own or have explicit permission to test. The sample commands below assume a local lab subnet.
+
+## Learning goals
+
+- Verify Kali is updated and Nmap is installed.
+- Discover your local subnet and live hosts.
+- Run targeted scans (SYN, service/version, OS fingerprinting).
+- Save scan results for later analysis.
+- Produce a compact summary report from XML output.
+
+## Prerequisites
+
+- Kali Linux VM (or bare metal) with network access.
+- Nmap installed.
+
+```bash
+sudo apt update && sudo apt install -y nmap python3
+```
+
+## Repository assets
+
+- `scripts/nmap_lab.sh` — runs a sequence of safe, common scans and saves results.
+- `scripts/parse_nmap.py` — parses an Nmap XML file and generates a summary table.
+
+## Step 1: Identify your subnet
+
+```bash
+ip route | awk '/default/ {print $3}'
+```
+
+If your gateway is `192.168.56.1`, your subnet is likely `192.168.56.0/24`.
+
+## Step 2: Run the automated lab script
+
+The script uses a target subnet and creates an output directory with timestamped artifacts.
+
+```bash
+chmod +x scripts/nmap_lab.sh
+./scripts/nmap_lab.sh --subnet 192.168.56.0/24 --output ./scan-results
+```
+
+The output directory will contain:
+
+- `host-discovery.gnmap`
+- `tcp-syn.xml`
+- `service-version.xml`
+- `os-detect.xml`
+- `scan.log`
+
+## Step 3: Review live hosts
+
+```bash
+grep "Status: Up" scan-results/host-discovery.gnmap
+```
+
+## Step 4: Parse results into a summary
+
+```bash
+python3 scripts/parse_nmap.py --input scan-results/tcp-syn.xml --output scan-results/summary.csv
+```
+
+Example output:
+
+```text
+host,port,protocol,state,service
+192.168.56.101,22,tcp,open,ssh
+192.168.56.101,80,tcp,open,http
+```
+
+## Step 5: Interpret findings
+
+- Confirm open ports align with expected services.
+- Re-scan individual hosts with a tighter scope when needed:
+
+```bash
+nmap -sV -p 22,80 192.168.56.101 -oX scan-results/host-192.168.56.101.xml
+```
+
+## Optional extensions
+
+- Add UDP scans for specific ports using `-sU`.
+- Compare `service-version.xml` and `os-detect.xml` output to validate asset inventories.
+- Store results in a version-controlled folder for change tracking.
+
+## Cleanup
+
+Remove old scan output if needed:
+
+```bash
+rm -rf scan-results
+```
