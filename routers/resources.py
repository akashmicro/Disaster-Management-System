from datetime import date

from fastapi import APIRouter, Form, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error

from database import execute, fetch_all, fetch_one
from routers.common import is_admin, render, require_admin

router = APIRouter()

DISTRICTS = (
    "Bagerhat", "Bandarban", "Barguna", "Barishal", "Bhola", "Bogura",
    "Brahmanbaria", "Chandpur", "Chattogram", "Chuadanga", "Cox's Bazar",
    "Cumilla", "Dhaka", "Dinajpur", "Faridpur", "Feni", "Gaibandha",
    "Gazipur", "Gopalganj", "Habiganj", "Jamalpur", "Jashore", "Jhalokathi",
    "Jhenaidah", "Joypurhat", "Khagrachhari", "Khulna", "Kishoreganj",
    "Kurigram", "Kushtia", "Lakshmipur", "Lalmonirhat", "Madaripur",
    "Magura", "Manikganj", "Meherpur", "Moulvibazar",
    "Munshiganj", "Mymensingh", "Naogaon", "Narail", "Narayanganj",
    "Narsingdi", "Natore", "Netrokona", "Nilphamari", "Noakhali",
    "Pabna", "Panchagarh", "Patuakhali", "Pirojpur", "Rajbari", "Rajshahi",
    "Rangamati", "Rangpur", "Satkhira", "Shariatpur", "Sherpur",
    "Sirajganj", "Sunamganj", "Sylhet", "Tangail", "Thakurgaon",
)

CONFIG = {
    "disasters": {
        "table": "disasters", "title": "Disasters", "id": "disaster_id",
        "columns": ["disaster_name", "disaster_type_id", "location_id", "severity_level", "status", "reported_at"],
        "fields": [
            ("disaster_name", "Name", "text"),
            ("disaster_type_id", "Disaster type ID", "number"),
            ("location_id", "Location ID", "number"),
            ("severity_level", "Severity", "text"),
            ("status", "Status", "text"),
            ("description", "Description", "textarea"),
        ],
        "search": ["disaster_name", "severity_level", "status"],
    },
    "victims": {
        "table": "victims", "title": "Victims", "id": "victim_id",
        "columns": ["disaster_id", "area_id", "full_name", "age", "gender", "condition_status", "medical_priority", "rescue_status"],
        "fields": [
            ("disaster_id", "Disaster ID", "number"),
            ("area_id", "Area ID", "number"),
            ("full_name", "Name", "text"),
            ("age", "Age", "number"),
            ("gender", "Gender", "text"),
            ("condition_status", "Condition", "text"),
            ("medical_priority", "Medical priority", "text"),
            ("rescue_status", "Rescue status", "text"),
        ],
        "search": ["full_name", "condition_status", "rescue_status"],
    },
    "rescue-teams": {
        "table": "rescue_teams", "title": "Rescue Teams", "id": "team_id",
        "columns": ["team_name", "team_type", "specialization", "team_leader", "member_count", "current_location_id", "availability_status", "contact_number"],
        "fields": [
            ("team_name", "Team name", "text"),
            ("team_type", "Team type", "text"),
            ("specialization", "Specialization", "text"),
            ("team_leader", "Team leader", "text"),
            ("member_count", "Members", "number"),
            ("current_location_id", "Current location ID", "number"),
            ("availability_status", "Availability", "text"),
            ("contact_number", "Contact number", "tel"),
        ],
        "search": ["team_name", "team_type", "specialization", "availability_status"],
    },
    "missing-persons": {
        "table": "missing_persons", "title": "Missing Persons", "id": "missing_id",
        "columns": ["full_name", "age", "gender", "last_seen_location", "missing_date", "description", "status", "disaster_id", "area_id"],
        "fields": [
            ("disaster_id", "Disaster ID", "number"),
            ("area_id", "Area ID", "number"),
            ("full_name", "Name", "text"),
            ("age", "Age", "number"),
            ("gender", "Gender", "text"),
            ("last_seen_location", "Last seen", "text"),
            ("missing_date", "Missing date", "date"),
            ("description", "Description", "textarea"),
            ("status", "Status", "text"),
        ],
        "search": ["full_name", "last_seen_location", "status"],
    },
    "shelters": {
        "table": "shelters", "title": "Shelters", "id": "shelter_id",
        "columns": ["shelter_name", "location_id", "total_capacity", "occupied_capacity", "has_medical_facility", "has_water", "has_food", "shelter_status"],
        "fields": [
            ("shelter_name", "Shelter name", "text"),
            ("location_id", "Location ID", "number"),
            ("total_capacity", "Capacity", "number"),
            ("occupied_capacity", "Occupancy", "number"),
            ("has_medical_facility", "Medical facility (1/0)", "number"),
            ("has_water", "Has water (1/0)", "number"),
            ("has_food", "Has food (1/0)", "number"),
            ("shelter_status", "Status", "text"),
        ],
        "search": ["shelter_name", "shelter_status"],
    },
    "blood-donors": {
        "table": "blood_donors", "title": "Blood Donors", "id": "donor_id",
        "columns": ["full_name", "blood_group", "phone", "location_id", "is_available", "last_donation_date"],
        "fields": [
            ("full_name", "Name", "text"),
            ("blood_group", "Blood group", "text"),
            ("phone", "Phone", "tel"),
            ("location_id", "Location ID", "number"),
            ("is_available", "Available (1/0)", "number"),
            ("last_donation_date", "Last donation date", "date"),
        ],
        "search": ["full_name", "blood_group", "phone"],
    },
    "relief-inventory": {
        "table": "relief_inventory", "title": "Relief Inventory", "id": "item_id",
        "columns": ["item_name", "category", "quantity", "unit", "district", "updated_at"],
        "fields": [("item_name", "Item", "text"), ("category", "Category", "text"), ("quantity", "Quantity", "number"), ("unit", "Unit", "text"), ("district", "District", "text")],
        "search": ["item_name", "category", "district"],
    },
    "vehicles": {
        "table": "vehicles", "title": "Vehicles", "id": "vehicle_id",
        "columns": ["vehicle_number", "vehicle_type", "organization", "district", "status"],
        "fields": [("vehicle_number", "Vehicle number", "text"), ("vehicle_type", "Type", "text"), ("organization", "Organization", "text"), ("district", "District", "text"), ("status", "Status", "text")],
        "search": ["vehicle_number", "vehicle_type", "organization", "district", "status"],
    },
    "missions": {
        "table": "missions", "title": "Missions", "id": "mission_id",
        "columns": ["mission_name", "district", "start_date", "status"],
        "fields": [("mission_name", "Mission", "text"), ("district", "District", "text"), ("start_date", "Start date", "date"), ("status", "Status", "text")],
        "search": ["mission_name", "district", "status"],
    },
    "ambulances": {
        "table": "ambulances", "title": "Ambulances", "id": "ambulance_id",
        "columns": ["ambulance_number", "organization", "driver_name", "driver_phone", "district", "location", "emergency_phone", "status"],
        "fields": [("ambulance_number", "Ambulance number", "text"), ("organization", "Organization", "text"), ("driver_name", "Driver name", "text"), ("driver_phone", "Driver phone", "tel"), ("district", "District", "text"), ("location", "Location", "text"), ("emergency_phone", "Emergency phone", "tel"), ("status", "Status", "text")],
        "search": ["ambulance_number", "organization", "driver_name", "district", "location", "status"],
    },
    "hospitals": {
        "table": "hospitals", "title": "Hospitals", "id": "hospital_id",
        "columns": ["hospital_name", "hospital_type", "phone", "emergency_phone", "district", "location", "address", "available_beds", "emergency_available", "status"],
        "fields": [("hospital_name", "Hospital name", "text"), ("hospital_type", "Type", "text"), ("phone", "Phone", "tel"), ("emergency_phone", "Emergency phone", "tel"), ("district", "District", "text"), ("location", "Location", "text"), ("address", "Address", "text"), ("available_beds", "Available beds", "number"), ("emergency_available", "Emergency available (1/0)", "number"), ("status", "Status", "text")],
        "search": ["hospital_name", "hospital_type", "district", "location", "status"],
    },
    "emergency": {
        "table": "emergency_contacts", "title": "Emergency Contacts", "id": "contact_id",
        "columns": ["name", "phone", "category", "district", "description", "status"],
        "fields": [("name", "Name", "text"), ("phone", "Phone", "tel"), ("category", "Category", "text"), ("district", "District", "text"), ("description", "Description", "textarea"), ("status", "Status", "text")],
        "search": ["name", "phone", "category", "district", "status"],
    },
    "donations": {
        "table": "donations", "title": "Donations", "id": "donation_id",
        "columns": ["donor_name", "donation_type", "amount", "purpose", "item_name", "quantity", "unit", "disaster", "donation_date", "payment_method", "transaction_reference"],
        "fields": [("donor_name", "Donor name", "text"), ("email", "Email", "email"), ("phone", "Phone", "tel"), ("donation_type", "Type", "text"), ("amount", "Amount", "number"), ("purpose", "Purpose", "text"), ("item_name", "Item", "text"), ("category", "Category", "text"), ("quantity", "Quantity", "number"), ("unit", "Unit", "text"), ("disaster", "Disaster", "text"), ("donation_date", "Date", "date"), ("payment_method", "Payment method", "text"), ("transaction_reference", "Reference", "text"), ("remarks", "Remarks", "textarea")],
        "search": ["donor_name", "email", "donation_type", "purpose", "disaster"],
    },
}


def _where(config, q):
    if not q:
        return "", ()
    clauses = " OR ".join(f"LOWER({column}) LIKE LOWER(%s)" for column in config["search"])
    return f" WHERE {clauses}", tuple(f"%{q}%" for _ in config["search"])


def _load(config, q=""):
    where, params = _where(config, q)
    columns = ", ".join([config["id"], *config["columns"]])
    return fetch_all(f"SELECT {columns} FROM {config['table']}{where} ORDER BY {config['id']} DESC", params)


def _form_options(config):
    options = {"district": DISTRICTS}
    try:
        district_rows = fetch_all(
            "SELECT DISTINCT district FROM ("
            "SELECT district FROM relief_inventory UNION ALL SELECT district FROM vehicles "
            "UNION ALL SELECT district FROM missions UNION ALL SELECT district FROM ambulances "
            "UNION ALL SELECT district FROM hospitals UNION ALL SELECT district FROM emergency_contacts"
            ") districts WHERE district IS NOT NULL AND district <> '' ORDER BY district"
        )
        options["district"] = tuple(dict.fromkeys(
            [*DISTRICTS, *(row["district"] for row in district_rows)]
        ))
        disaster_rows = fetch_all("SELECT disaster_name AS name FROM disasters ORDER BY disaster_name")
        options["disaster"] = [row["name"] for row in disaster_rows]
    except Error:
        options["disaster"] = ()
    if config["table"] == "disasters":
        options["severity_level"] = ("LOW", "MEDIUM", "HIGH", "CRITICAL")
        options["status"] = ("Reported", "Under Assessment", "Active Response", "Partially Controlled", "Resolved")
    elif config["table"] == "victims":
        options["gender"] = ("Male", "Female", "Other")
        options["condition_status"] = ("Safe", "Injured", "Critical", "Hospitalized", "Rescued", "Deceased")
        options["medical_priority"] = ("None", "Low", "Medium", "High")
        options["rescue_status"] = ("Not Rescued", "In Progress", "Rescued")
    elif config["table"] == "missing_persons":
        options["gender"] = ("Male", "Female", "Other")
        options["status"] = ("Missing", "Located", "Rescued", "Reunited")
    elif config["table"] == "blood_donors":
        options["blood_group"] = ("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")
        options["is_available"] = ("1", "0")
    elif config["table"] == "shelters":
        options["has_medical_facility"] = ("1", "0")
        options["has_water"] = ("1", "0")
        options["has_food"] = ("1", "0")
        options["shelter_status"] = ("Open", "Full", "Closed")
    elif config["table"] == "rescue_teams":
        options["specialization"] = ("Flood Rescue", "Medical Rescue", "Fire Rescue", "Mountain Rescue", "Search & Rescue", "Emergency Medical Team")
        options["availability_status"] = ("Available", "Deployed", "Unavailable")
    elif config["table"] == "missions":
        options["status"] = ("Planned", "Active", "Completed", "Cancelled")
    elif config["table"] in {"vehicles", "ambulances", "hospitals", "emergency_contacts"}:
        options["status"] = ("Available", "Active", "Open", "Closed", "Planned", "On Mission", "Busy", "Maintenance", "Offline")
    if config["table"] == "hospitals":
        options["emergency_available"] = ("1", "0")
    return options


def _context(config, rows, q, request, message=None, slug=None):
    return dict(title=config["title"], rows=rows, headers=config["columns"], create_url=f"/admin/{slug or config['table']}/new",
                q=q, config=config, message=message, admin=is_admin(request))


def _values(config, form):
    values = []
    for name, _, kind in config["fields"]:
        value = form.get(name, "").strip()
        if not value:
            raise ValueError(f"{name.replace('_', ' ').title()} is required.")
        if kind == "number":
            value = float(value) if "." in value else int(value)
        values.append(value)
    return values


def resource_page(slug: str, request: Request, q: str = "", admin_only=False):
    config = CONFIG[slug]
    if admin_only:
        denied = require_admin(request)
        if denied:
            return denied
    try:
        rows = _load(config, q)
        message = None
    except Error:
        rows, message = [], "Database unavailable. Check MySQL settings and schema."
    context = _context(config, rows, q, request, message, slug)
    context["slug"] = slug
    return render(request, "table.html", **context)


def public_page(slug, request: Request, q: str = ""):
    return resource_page(slug, request, q, False)


def admin_page(slug, request: Request, q: str = ""):
    return resource_page(slug, request, q, True)


def make_page(slug, admin_only):
    def endpoint(request: Request, q: str = ""):
        return resource_page(slug, request, q, admin_only)
    return endpoint


for _slug in CONFIG:
    router.add_api_route(f"/admin/{_slug}", make_page(_slug, True), methods=["GET"], name=f"admin_{_slug}")

for _slug in ("disasters", "ambulances", "hospitals", "shelters", "emergency", "blood-donors"):
    router.add_api_route(f"/{_slug}", make_page(_slug, False), methods=["GET"], name=f"public_{_slug}")


@router.get("/admin/{slug}/new")
def create_form(slug: str, request: Request):
    denied = require_admin(request)
    if denied:
        return denied
    config = CONFIG.get(slug)
    if not config:
        return RedirectResponse("/admin/dashboard", status_code=303)
    return render(request, "form.html", title=f"Add {config['title']}", action=f"/admin/{slug}/new",
                  fields=config["fields"], values={}, options=_form_options(config), message=None, admin=True)


@router.post("/admin/{slug}/new")
async def create_record(slug: str, request: Request):
    denied = require_admin(request)
    if denied:
        return denied
    config = CONFIG.get(slug)
    if not config:
        return RedirectResponse("/admin/dashboard", status_code=303)
    try:
        form = await request.form()
        values = _values(config, form)
        names = [field[0] for field in config["fields"]]
        placeholders = ", ".join(["%s"] * len(names))
        execute(f"INSERT INTO {config['table']} ({', '.join(names)}) VALUES ({placeholders})", tuple(values))
        return RedirectResponse(f"/admin/{slug}", status_code=303)
    except (ValueError, Error) as exc:
        return render(request, "form.html", title=f"Add {config['title']}", action=f"/admin/{slug}/new",
                      fields=config["fields"], values=dict(form), options=_form_options(config), message=str(exc), admin=True)


@router.get("/admin/{slug}/{record_id}/edit")
def edit_form(slug: str, record_id: int, request: Request):
    denied = require_admin(request)
    config = CONFIG.get(slug)
    if denied:
        return denied
    if not config:
        return RedirectResponse("/admin/dashboard", status_code=303)
    row = fetch_one(f"SELECT {', '.join(field[0] for field in config['fields'])} FROM {config['table']} WHERE {config['id']}=%s", (record_id,))
    if not row:
        return RedirectResponse(f"/admin/{slug}", status_code=303)
    return render(request, "form.html", title=f"Edit {config['title']}", action=f"/admin/{slug}/{record_id}/edit",
                  fields=config["fields"], values=row, options=_form_options(config), message=None, admin=True)


@router.post("/admin/{slug}/{record_id}/edit")
async def edit_record(slug: str, record_id: int, request: Request):
    denied = require_admin(request)
    config = CONFIG.get(slug)
    if denied:
        return denied
    if not config:
        return RedirectResponse("/admin/dashboard", status_code=303)
    form = await request.form()
    try:
        values = _values(config, form)
        names = [field[0] for field in config["fields"]]
        execute(f"UPDATE {config['table']} SET {', '.join(f'{name}=%s' for name in names)} WHERE {config['id']}=%s",
                tuple(values) + (record_id,))
        return RedirectResponse(f"/admin/{slug}", status_code=303)
    except (ValueError, Error) as exc:
        return render(request, "form.html", title=f"Edit {config['title']}", action=f"/admin/{slug}/{record_id}/edit",
                      fields=config["fields"], values=dict(form), options=_form_options(config), message=str(exc), admin=True)


@router.post("/admin/{slug}/{record_id}/delete")
def delete_record(slug: str, record_id: int, request: Request):
    denied = require_admin(request)
    if denied:
        return denied
    config = CONFIG.get(slug)
    if config:
        execute(f"DELETE FROM {config['table']} WHERE {config['id']}=%s", (record_id,))
        return RedirectResponse(f"/admin/{slug}", status_code=303)
    return RedirectResponse("/admin/dashboard", status_code=303)
