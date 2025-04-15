import psycopg2

# Connection details
DB_HOST = "njn7djisyj.fvepwqywe3.tsdb.cloud.timescale.com"
DB_PORT = 33601
DB_NAME = "tsdb"
DB_USER = "tsdbadmin"
DB_SSL_MODE = "require"

# Construct the connection string
DB_CONNECTION_STRING = f"postgres://tsdbadmin@njn7djisyj.fvepwqywe3.tsdb.cloud.timescale.com:33601/tsdb?sslmode=require"

try:
    # Connect to TimescaleDB
    conn = psycopg2.connect(DB_CONNECTION_STRING)
    cursor = conn.cursor()

    # Create table
    create_table_query = """
    CREATE TABLE IF NOT EXISTS tf_table (
        id SERIAL PRIMARY KEY,
        timestamp TIMESTAMPTZ DEFAULT now(),
        value DOUBLE PRECISION
    );
    """
    cursor.execute(create_table_query)
    conn.commit()
    print("Table 'tf_table' created successfully.")

except Exception as e:
    print("Error:", e)

finally:
    if conn:
        cursor.close()
        conn.close()
