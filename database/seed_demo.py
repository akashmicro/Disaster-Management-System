"""Reset and seed the local MySQL demo database with consistent Bangladesh data."""

from datetime import date, timedelta
from pathlib import Path
import sys

import mysql.connector
from passlib.hash import bcrypt

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from config import DB_HOST, DB_NAME, DB_PASSWORD, DB_PORT, DB_USER

DISTRICTS = [
    "Dhaka", "Chattogram", "Sylhet", "Rajshahi", "Khulna", "Barishal",
    "Rangpur", "Mymensingh", "Cumilla", "Gazipur", "Narayanganj",
    "Cox's Bazar", "Bogura", "Jessore", "Tangail", "Feni", "Noakhali",
    "Dinajpur", "Faridpur", "Kushtia",
]
NAMES = [
    "Arif Hossain", "Nusrat Jahan", "Sabbir Ahmed", "Maliha Rahman",
    "Tanvir Hasan", "Raisa Karim", "Imran Kabir", "Farzana Akter",
    "Nayeem Chowdhury", "Samia Sultana", "Rafiul Islam", "Jannatul Ferdous",
    "Mehedi Hasan", "Tasmia Haque", "Shakil Mahmud", "Lubna Yasmin",
    "Fahim Rahman", "Mim Akter", "Sajidul Alam", "Sohana Parvin",
]
TODAY = date.today()


def rows():
    users = [
        ("Masud Rana", "masudrana33666", "admin@dms.local", "01700000001", bcrypt.hash("1111111"), "admin"),
    ]
    users += [
        (NAMES[i], f"user{i + 1:02d}", f"user{i + 1:02d}@dms.local", f"0171000{i + 1:04d}",
         bcrypt.hash(f"User@{i + 1:02d}23"), "user")
        for i in range(20)
    ]

    disasters = [
        (f"{d} Monsoon Response {i + 1}", ["Flood", "Cyclone", "River Erosion", "Landslide"][i % 4],
         d, ["Active Response", "Under Assessment", "Reported", "Resolved"][i % 4],
         ["High", "Critical", "Medium", "Low"][i % 4],
         f"Coordinated response operation for affected communities in {d}.")
        for i, d in enumerate(DISTRICTS)
    ]
    victims = [
        (NAMES[i], 12 + (i * 3) % 65, ["Female", "Male", "Other"][i % 3],
         ["Safe", "Injured", "Critical", "Hospitalized"][i % 4],
         ["Rescued", "In Progress", "Not Rescued"][i % 3])
        for i in range(20)
    ]
    teams = [
        (f"{d} Rapid Response Team", ["Medical", "Flood Rescue", "Search and Rescue"][i % 3],
         NAMES[i], f"0181000{i + 1:04d}", d, ["Available", "Deployed", "Standby"][i % 3])
        for i, d in enumerate(DISTRICTS)
    ]
    missing = [
        (NAMES[i], 8 + i * 2, f"{d} Bus Terminal", d, TODAY - timedelta(days=i + 1),
         f"0191000{i + 1:04d}", ["Missing", "Located", "Missing"][i % 3])
        for i, d in enumerate(DISTRICTS)
    ]
    shelters = [
        (f"{d} Community Shelter {i + 1}", d, f"{d} Ward {i % 9 + 1}",
         180 + i * 12, 30 + (i * 7) % 100, f"0161000{i + 1:04d}",
         ["Open", "Open", "Full"][i % 3])
        for i, d in enumerate(DISTRICTS)
    ]
    blood = [
        (NAMES[i], ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"][i % 8],
         f"0151000{i + 1:04d}", d, 1 if i % 4 else 0)
        for i, d in enumerate(DISTRICTS)
    ]
    inventory = [
        (f"{['Rice', 'Water', 'Blanket', 'First Aid Kit'][i % 4]} Stock {i + 1}", ["Food", "Water", "Shelter", "Medical"][i % 4],
         100 + i * 25, ["kg", "litre", "piece", "box"][i % 4], d)
        for i, d in enumerate(DISTRICTS)
    ]
    vehicles = [
        (f"DMV-{d[:3].upper()}-{i + 1:02d}", ["Rescue Van", "Supply Truck", "Boat"][i % 3],
         f"Bangladesh Relief Unit {i + 1}", d, ["Available", "On Mission", "Maintenance"][i % 3])
        for i, d in enumerate(DISTRICTS)
    ]
    missions = [
        (f"{d} Rapid Response Mission", 1 + i, 1 + i, 1 + i, d, TODAY - timedelta(days=i % 12),
         ["Planned", "Active", "Completed"][i % 3])
        for i, d in enumerate(DISTRICTS)
    ]
    emergency = [
        ("National Emergency Service", "999", "National", "Dhaka", "Police, fire and ambulance coordination", "Active"),
        ("Fire Service", "102", "Fire", "Dhaka", "Fire and rescue dispatch", "Active"),
        ("Health Information", "16263", "Health", "Dhaka", "Government health information service", "Active"),
    ]
    emergency += [
        (f"{d} District Control Room", f"0132000{i + 1:04d}", "District Help", d,
         f"Verified emergency coordination desk for {d}", "Active")
        for i, d in enumerate(DISTRICTS[:18])
    ]
    ambulances = [
        (f"AMB-{d[:3].upper()}-{i + 1:02d}", f"{d} Emergency Care Foundation",
         NAMES[i], f"0192000{i + 1:04d}", d, f"{d} Central Hospital Gate",
         f"0172000{i + 1:04d}", ["Available", "On Mission", "Busy", "Maintenance", "Offline"][i % 5])
        for i, d in enumerate(DISTRICTS)
    ]
    hospitals = [
        (f"{d} General Hospital", ["District Hospital", "Medical College Hospital", "Specialized Hospital"][i % 3],
         f"02-900{i + 1:04d}", f"02-901{i + 1:04d}", d, f"{d} Sadar",
         f"Hospital Road, Ward {i % 8 + 1}, {d}", 20 + i * 4, 1 if i % 4 else 0,
         ["Open", "Open", "Busy"][i % 3])
        for i, d in enumerate(DISTRICTS)
    ]
    donations = [
        (1 + (i % 20), NAMES[i], f"user{i + 1:02d}@dms.local", f"0173000{i + 1:04d}",
         ["Money", "Material"][i % 2], 5000 + i * 750 if i % 2 == 0 else 0,
         ["Emergency food support", "Shelter supplies"][i % 2],
         "" if i % 2 == 0 else "Family Relief Pack", "" if i % 2 == 0 else "Relief",
         0 if i % 2 == 0 else 15, "" if i % 2 == 0 else "pack",
         DISTRICTS[i], TODAY - timedelta(days=i), "Mobile Banking" if i % 2 == 0 else "",
         f"TXN-DMS-{i + 1:04d}" if i % 2 == 0 else "", "Verified demo contribution")
        for i in range(20)
    ]
    health = [
        (1 + (i % 20), "I have fever and cough.", "General education: rest, drink safe fluids, monitor symptoms, and contact a doctor if symptoms worsen. Emergency help is needed for breathing difficulty or chest pain.")
        for i in range(20)
    ]
    return locals()


def main():
    connection = mysql.connector.connect(host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASSWORD)
    cursor = connection.cursor()
    cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{DB_NAME}`")
    cursor.execute(f"USE `{DB_NAME}`")
    drop_order = ["password_otps", "health_ai_chats", "donations", "missions", "ambulances", "hospitals",
                  "emergency_contacts", "vehicles", "relief_inventory", "blood_donors", "shelters",
                  "missing_persons", "victims", "rescue_teams", "disasters", "users"]
    for table in drop_order:
        cursor.execute(f"DROP TABLE IF EXISTS `{table}`")
    schema = (Path(__file__).with_name("schema.sql")).read_text(encoding="utf-8-sig")
    for statement in schema.split(";"):
        if statement.strip() and not statement.strip().upper().startswith(("CREATE DATABASE", "USE ")):
            cursor.execute(statement)
    data = rows()
    inserts = {
        "users": ("INSERT INTO users (full_name,username,email,phone,password_hash,role) VALUES (%s,%s,%s,%s,%s,%s)", data["users"]),
        "disasters": ("INSERT INTO disasters (name,disaster_type,district,status,severity,description) VALUES (%s,%s,%s,%s,%s,%s)", data["disasters"]),
        "victims": ("INSERT INTO victims (full_name,age,gender,condition_status,rescue_status) VALUES (%s,%s,%s,%s,%s)", data["victims"]),
        "rescue_teams": ("INSERT INTO rescue_teams (team_name,team_type,leader_name,phone,district,status) VALUES (%s,%s,%s,%s,%s,%s)", data["teams"]),
        "missing_persons": ("INSERT INTO missing_persons (full_name,age,last_seen_location,district,missing_date,contact_phone,status) VALUES (%s,%s,%s,%s,%s,%s,%s)", data["missing"]),
        "shelters": ("INSERT INTO shelters (shelter_name,district,location,total_capacity,occupied_capacity,contact_phone,status) VALUES (%s,%s,%s,%s,%s,%s,%s)", data["shelters"]),
        "blood_donors": ("INSERT INTO blood_donors (full_name,blood_group,phone,district,is_available) VALUES (%s,%s,%s,%s,%s)", data["blood"]),
        "relief_inventory": ("INSERT INTO relief_inventory (item_name,category,quantity,unit,district) VALUES (%s,%s,%s,%s,%s)", data["inventory"]),
        "vehicles": ("INSERT INTO vehicles (vehicle_number,vehicle_type,organization,district,status) VALUES (%s,%s,%s,%s,%s)", data["vehicles"]),
        "missions": ("INSERT INTO missions (mission_name,disaster_id,team_id,vehicle_id,district,start_date,status) VALUES (%s,%s,%s,%s,%s,%s,%s)", data["missions"]),
        "emergency_contacts": ("INSERT INTO emergency_contacts (name,phone,category,district,description,status) VALUES (%s,%s,%s,%s,%s,%s)", data["emergency"]),
        "ambulances": ("INSERT INTO ambulances (ambulance_number,organization,driver_name,driver_phone,district,location,emergency_phone,status) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)", data["ambulances"]),
        "hospitals": ("INSERT INTO hospitals (hospital_name,hospital_type,phone,emergency_phone,district,location,address,available_beds,emergency_available,status) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", data["hospitals"]),
        "donations": ("INSERT INTO donations (user_id,donor_name,email,phone,donation_type,amount,purpose,item_name,category,quantity,unit,disaster,donation_date,payment_method,transaction_reference,remarks) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", data["donations"]),
        "health_ai_chats": ("INSERT INTO health_ai_chats (user_id,question,answer) VALUES (%s,%s,%s)", data["health"]),
    }
    for table, (statement, values) in inserts.items():
        cursor.executemany(statement, values)
        print(f"{table}: {len(values)}")
    connection.commit()
    cursor.close()
    connection.close()


if __name__ == "__main__":
    main()
