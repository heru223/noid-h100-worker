#!/usr/bin/env python3
import http.server, socketserver, json, os

PORT = int(os.environ.get("PORT", 8080))
LOG_FILE = "/tmp/miner.log"

class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path in ("/", "/health", "/healthz"):
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            resp = {
                "status": "healthy",
                "service": "noid-h100-worker",
                "worker": os.environ.get("WORKER_NAME", "h100-01"),
                "pool": os.environ.get("POOL_ADDRESS", "stratum+ssl://hk.innovlab.cc:19601"),
                "wallet": os.environ.get("WALLET_ADDRESS", "o1xlq6vc67ljt4khf2e7m2m66lu78a4j8my2nd0y7xyyfmfrrvzc0qlh5f7h")
            }
            self.wfile.write(json.dumps(resp, indent=2).encode("utf-8"))
        elif self.path == "/logs":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            if os.path.exists(LOG_FILE):
                with open(LOG_FILE, "r", errors="ignore") as f:
                    lines = f.readlines()
                    self.wfile.write("".join(lines[-100:]).encode("utf-8"))
            else:
                self.wfile.write(b"Waiting for NOBD worker initialization...\n")
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not Found")

    def log_message(self, format, *args):
        return

if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), HealthHandler) as httpd:
        print(f"⚡ Healthcheck HTTP Web Server listening on port {PORT}...")
        httpd.serve_forever()