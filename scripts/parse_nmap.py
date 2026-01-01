diff --git a/scripts/parse_nmap.py b/scripts/parse_nmap.py
new file mode 100644
index 0000000000000000000000000000000000000000..a07709c44304c6cc567de325c86645ab67fed9b2
--- /dev/null
+++ b/scripts/parse_nmap.py
@@ -0,0 +1,57 @@
+#!/usr/bin/env python3
+import argparse
+import csv
+import xml.etree.ElementTree as ET
+
+
+def parse_args() -> argparse.Namespace:
+    parser = argparse.ArgumentParser(description="Parse Nmap XML into a CSV summary.")
+    parser.add_argument("--input", required=True, help="Path to Nmap XML output file")
+    parser.add_argument("--output", required=True, help="Path to CSV output file")
+    return parser.parse_args()
+
+
+def parse_nmap_xml(xml_path: str) -> list[dict[str, str]]:
+    tree = ET.parse(xml_path)
+    root = tree.getroot()
+    rows: list[dict[str, str]] = []
+
+    for host in root.findall("host"):
+        address_elem = host.find("address")
+        if address_elem is None:
+            continue
+        host_ip = address_elem.get("addr", "unknown")
+        ports = host.find("ports")
+        if ports is None:
+            continue
+        for port in ports.findall("port"):
+            state_elem = port.find("state")
+            service_elem = port.find("service")
+            row = {
+                "host": host_ip,
+                "port": port.get("portid", ""),
+                "protocol": port.get("protocol", ""),
+                "state": state_elem.get("state", "") if state_elem is not None else "",
+                "service": service_elem.get("name", "") if service_elem is not None else "",
+            }
+            rows.append(row)
+
+    return rows
+
+
+def write_csv(rows: list[dict[str, str]], output_path: str) -> None:
+    fieldnames = ["host", "port", "protocol", "state", "service"]
+    with open(output_path, "w", newline="", encoding="utf-8") as csvfile:
+        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
+        writer.writeheader()
+        writer.writerows(rows)
+
+
+def main() -> None:
+    args = parse_args()
+    rows = parse_nmap_xml(args.input)
+    write_csv(rows, args.output)
+
+
+if __name__ == "__main__":
+    main()
