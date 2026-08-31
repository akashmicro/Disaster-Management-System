# Disaster Management System

Simple Windows desktop development project using Python, FastAPI, MySQL, HTML, CSS, JavaScript, and Bootstrap-compatible server-rendered templates.

## Run on Windows

1. Install Python 3.11+ and MySQL 8.
2. Open this folder in VS Code.
3. Open a terminal and run `python -m venv venv`.
4. Activate it with `venv\Scripts\activate`.
5. Install packages with `pip install -r requirements.txt`.
6. In MySQL Workbench, run `database/schema.sql`.
7. Copy `.env.example` to `.env` and set the MySQL password.
8. Populate the development database with `python database\seed_demo.py`.
9. Double-click `run.bat`, or run `uvicorn main:app --reload`.
10. Open http://127.0.0.1:8000.

## XAMPP / phpMyAdmin

1. Open XAMPP Control Panel and start **Apache** and **MySQL**.
2. Open http://localhost/phpmyadmin.
3. Import or run `database/schema.sql` in phpMyAdmin. It creates the `disaster_management` database.
4. The included `.env` uses standard XAMPP MySQL settings: host `127.0.0.1`, port `3306`, user `root`, and an empty password.
5. If you changed the XAMPP root password or MySQL port, update `DB_PASSWORD` or `DB_PORT` in `.env`, then restart the application.

Admin login: username `masudrana33666`, password `1111111`. There is no admin registration page.

Demo users use emails such as `user01@dms.local` with passwords such as `User@0123`.
Set `DEBUG_OTP=1` in `.env` for local password-reset testing; the generated OTP is then shown on the verification page.

## User features

- The home page shows live MySQL totals for active disasters, open shelters, available ambulances, and blood donors.
- Logged-in users can report a disaster, register a shelter, register as a blood donor, and submit Money or Material donations.
- Admins can review and edit those records from the management pages.
- Money donations require an amount; Material donations require an item, quantity, and unit.

## Common errors

- **MySQL not running:** Start the MySQL80 Windows service.
- **Wrong password:** Check `DB_USER` and `DB_PASSWORD` in `.env`.
- **Database does not exist:** Run `database/schema.sql` in MySQL Workbench.
- **Port 8000 in use:** Stop the other process or run `python -m uvicorn main:app --port 8001`.

All application data is stored in MySQL. No SQLite, JSON database, Node.js, Docker, Flask, or Django is required.
