#!/usr/bin/env python3
"""
Vulnerable Service - Demonstrates multiple exploitation vectors
"""

import os
import pickle
import subprocess
import socket
import json
import sys

class VulnerableConfig:
    """Vulnerable configuration loader"""
    def __init__(self):
        self.data = {}
    
    def load_pickle(self, filepath):
        """VULNERABLE: Insecure pickle deserialization"""
        try:
            with open(filepath, 'rb') as f:
                self.data = pickle.load(f)
            return self.data
        except Exception as e:
            print(f"Error loading config: {e}")
            return None
    
    def execute_command(self, cmd):
        """VULNERABLE: Command injection"""
        # Unsafe command execution
        result = os.system(f"echo {cmd}")
        return result
    
    def sql_query(self, query):
        """VULNERABLE: SQL injection ready"""
        # Query would be executed without sanitization
        print(f"Executing: {query}")
        return None

class NetworkService:
    """Vulnerable network service"""
    def __init__(self, port=9000):
        self.port = port
        self.socket = None
    
    def start(self):
        """Start vulnerable service"""
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind(('0.0.0.0', self.port))
        self.socket.listen(1)
        print(f"[*] Service listening on port {self.port}")
    
    def handle_client(self, conn):
        """Handle client connection - VULNERABLE to multiple attacks"""
        try:
            data = conn.recv(1024).decode()
            
            # VULNERABLE: Direct command execution
            if data.startswith("exec:"):
                cmd = data.split(":", 1)[1]
                result = subprocess.getoutput(cmd)
                conn.send(result.encode())
            
            # VULNERABLE: Unsafe JSON deserialization
            elif data.startswith("json:"):
                json_data = data.split(":", 1)[1]
                parsed = json.loads(json_data)
                conn.send(str(parsed).encode())
            
            else:
                conn.send(b"Invalid request")
        
        except Exception as e:
            conn.send(f"Error: {e}".encode())
        finally:
            conn.close()

def main():
    """Main function"""
    if len(sys.argv) > 1 and sys.argv[1] == "service":
        service = NetworkService(9000)
        service.start()
        while True:
            try:
                conn, addr = service.socket.accept()
                print(f"[+] Connection from {addr}")
                service.handle_client(conn)
            except KeyboardInterrupt:
                break
    else:
        # Config loader test
        config = VulnerableConfig()
        print("[*] Vulnerable Service Ready")
        print("[*] Service paths:")
        print("    - Pickle loader: /tmp/app.config")
        print("    - Command execution: execute_command()")
        print("    - Network service on port 9000")

if __name__ == "__main__":
    main()
