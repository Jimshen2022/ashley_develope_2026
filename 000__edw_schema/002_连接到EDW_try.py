import os
from sqlalchemy import create_engine
import urllib

# It is recommended to use environment variables for security
# Comments are in English as per your preference
client_id = os.getenv("AZURE_CLIENT_ID", "ed4fb8e4-fb86-4e03-90b4-96777df975c1")
client_secret = os.getenv("AZURE_CLIENT_SECRET", "XDN8Q~6juTofWBtJl7oV6gQkszEk1nI5n_cLRcba")
tenant_id = os.getenv("AZURE_TENANT_ID", "5a9d9cfd-c32e-4ac1-a9ed-fe83df4f9e4d")
server = "ashley-edw.database.windows.net"
database = "ASHLEY_EDW"

# Construct the connection string for Service Principal authentication
connection_string = (
    f"Driver={{ODBC Driver 17 for SQL Server}};"
    f"Server=tcp:{server},1433;"
    f"Database={database};"
    f"Uid={client_id};"
    f"Pwd={client_secret};"
    f"Authentication=ActiveDirectoryServicePrincipal;"
    f"Encrypt=yes;"
    f"TrustServerCertificate=no;"
    f"Connection Timeout=300;"
)

# Encode the string for SQLAlchemy
params = urllib.parse.quote_plus(connection_string)
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# Test connection
try:
    with engine.connect() as conn:
        print("Successfully connected to Azure SQL using Service Principal!")
except Exception as e:
    print(f"Connection failed: {e}")