import http.server
import json
import os
import threading

import psycopg2

CONN = psycopg2.connect(os.getenv("DATABASE_CONNECTION_URI")) 

def init_db():
    with CONN.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS hit_counter (
                id SERIAL PRIMARY KEY,
                count INTEGER NOT NULL
            );
        """)
        cur.execute("SELECT count(*) FROM hit_counter;")
        if cur.fetchone()[0] == 0:
            cur.execute("INSERT INTO hit_counter (count) VALUES (0);")
    CONN.commit()

def increment_hit():
    with CONN.cursor() as cur:
        cur.execute("UPDATE hit_counter SET count = count + 1 WHERE id = 1 RETURNING count;")
        count = cur.fetchone()[0]
    CONN.commit()
    return count

class HitHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        count = increment_hit()
        response = json.dumps({"hits": count}).encode()

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(response)


if __name__ == "__main__":
    init_db()
    server = http.server.HTTPServer(("0.0.0.0", 8080), HitHandler)
    server.serve_forever()
