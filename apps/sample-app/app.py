import http.server
import json
import os

import psycopg2

CONN = None

def connect():
    global CONN
    if CONN is None or CONN.closed:
        CONN = psycopg2.connect(os.getenv("DATABASE_CONNECTION_URI"))
    return CONN

def discard():
    global CONN
    if CONN is not None:
        try:
            CONN.close()
        except psycopg2.Error:
            pass
        CONN = None

def run(statements):
    """Retry once on a stale connection, since the first failure is what closes it."""
    for attempt in (0, 1):
        conn = connect()
        try:
            result = statements(conn)
            conn.commit()
            return result
        except psycopg2.Error:
            discard()
            if attempt:
                raise

def init_db():
    def statements(conn):
        with conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS hit_counter (
                    id SERIAL PRIMARY KEY,
                    count INTEGER NOT NULL
                );
            """)
            cur.execute("SELECT count(*) FROM hit_counter;")
            if cur.fetchone()[0] == 0:
                cur.execute("INSERT INTO hit_counter (count) VALUES (0);")
    run(statements)

def increment_hit():
    def statements(conn):
        with conn.cursor() as cur:
            cur.execute("UPDATE hit_counter SET count = count + 1 WHERE id = 1 RETURNING count;")
            return cur.fetchone()[0]
    return run(statements)

class HitHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/":
            self.send_error(404)
            return

        try:
            count = increment_hit()
        except psycopg2.Error:
            self.send_error(503, "Database unavailable")
            return

        response = json.dumps({"hits": count}).encode()

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(response)


if __name__ == "__main__":
    init_db()
    server = http.server.HTTPServer(("0.0.0.0", 8080), HitHandler)
    server.serve_forever()
