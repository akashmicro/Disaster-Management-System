"""Apply the MySQL schema scripts using the same configuration as the app."""
import glob
import os
import sys

import mysql.connector
from dotenv import dotenv_values


def split_sql_script(sql):
    """Split scripts containing MySQL DELIMITER blocks into executable statements."""
    delimiter = ";"
    statement = []
    for line in sql.splitlines():
        stripped = line.strip()
        if stripped.upper().startswith("DELIMITER "):
            delimiter = stripped.split(None, 1)[1]
            continue
        statement.append(line)
        if line.rstrip().endswith(delimiter):
            text = "\n".join(statement).rstrip()
            yield text[:-len(delimiter)].rstrip()
            statement = []
    if "\n".join(statement).strip():
        yield "\n".join(statement).strip()


def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    files = sorted(
        path for path in glob.glob(os.path.join(base_dir, "database", "*.sql"))
        if os.path.basename(path) not in {"08_queries.sql", "09_test_queries.sql"}
    )
    if not files:
        print("No SQL files found in database/; skipping SQL execution")
        return

    config = dotenv_values(os.path.join(base_dir, ".env"))
    connection_config = {
        "host": config.get("DB_HOST", "localhost"),
        "user": config.get("DB_USER", "root"),
        "password": config.get("DB_PASSWORD", ""),
        "port": int(config.get("DB_PORT", "3306")),
    }

    try:
        cnx = mysql.connector.connect(**connection_config)
        cur = cnx.cursor()
        for path in files:
            print("Running", os.path.basename(path))
            for statement in split_sql_script(open(path, encoding="utf-8-sig").read()):
                cur.execute(statement)
                if cur.with_rows:
                    cur.fetchall()
            cnx.commit()
        cur.close()
        cnx.close()
        print("All SQL scripts executed successfully")
    except Exception as exc:
        print("ERROR while executing SQL scripts:", exc)
        sys.exit(1)


if __name__ == "__main__":
    main()
