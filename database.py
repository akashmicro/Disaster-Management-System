from contextlib import contextmanager

import mysql.connector
from mysql.connector import Error

from config import DB_HOST, DB_NAME, DB_PASSWORD, DB_PORT, DB_USER


def connect():
    # Use the project's config values to connect to MySQL (XAMPP)
    return mysql.connector.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        auth_plugin="mysql_native_password",
    )


@contextmanager
def cursor():
    connection = None
    db_cursor = None
    try:
        connection = connect()
        db_cursor = connection.cursor(dictionary=True)
        yield connection, db_cursor
        connection.commit()
    except Error:
        if connection and connection.is_connected():
            connection.rollback()
        raise
    finally:
        if db_cursor:
            db_cursor.close()
        if connection and connection.is_connected():
            connection.close()


def fetch_all(sql, params=()):
    with cursor() as (_, db_cursor):
        db_cursor.execute(sql, params)
        return db_cursor.fetchall()


def fetch_one(sql, params=()):
    with cursor() as (_, db_cursor):
        db_cursor.execute(sql, params)
        return db_cursor.fetchone()


def execute(sql, params=()):
    with cursor() as (_, db_cursor):
        db_cursor.execute(sql, params)
        return db_cursor.lastrowid
