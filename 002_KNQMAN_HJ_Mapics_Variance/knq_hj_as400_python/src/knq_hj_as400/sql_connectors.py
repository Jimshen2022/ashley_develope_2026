from __future__ import annotations

from dataclasses import dataclass

import pandas as pd
import pyodbc


@dataclass(frozen=True)
class SqlServerConnector:
    server: str
    database: str
    driver: str = "ODBC Driver 17 for SQL Server"
    trusted_connection: bool = True
    username: str = ""
    password: str = ""
    encrypt: bool = False
    trust_server_certificate: bool = True
    timeout_seconds: int = 0

    def connection_string(self) -> str:
        parts = [
            f"DRIVER={{{self.driver}}}",
            f"SERVER={self.server}",
            f"DATABASE={self.database}",
        ]
        if self.trusted_connection:
            parts.append("Trusted_Connection=yes")
        else:
            parts.append(f"UID={self.username}")
            parts.append(f"PWD={self.password}")
        parts.append(f"Encrypt={'yes' if self.encrypt else 'no'}")
        parts.append(
            f"TrustServerCertificate={'yes' if self.trust_server_certificate else 'no'}"
        )
        return ";".join(parts) + ";"

    def read_sql(self, query: str) -> pd.DataFrame:
        with pyodbc.connect(self.connection_string(), timeout=self.timeout_seconds) as connection:
            return pd.read_sql_query(query, connection)


@dataclass(frozen=True)
class OdbcConnector:
    connection_string_value: str
    timeout_seconds: int = 0

    def read_sql(self, query: str) -> pd.DataFrame:
        with pyodbc.connect(self.connection_string_value, timeout=self.timeout_seconds) as connection:
            return pd.read_sql_query(query, connection)
