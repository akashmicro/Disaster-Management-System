from datetime import date

from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error

from database import execute
from main import templates

router = APIRouter()

FORMS = {
    "report-disaster": {
        "title": "Report a Disaster",
        "table": "disasters",
        "fields": [("name", "Disaster name", "text"), ("disaster_type", "Type", "text"), ("district", "District", "text"),
                   ("status", "Status", "text"), ("severity", "Severity", "text"), ("description", "Description", "textarea")],
        "columns": "name,disaster_type,district,status,severity,description",
        "redirect": "/disasters",
        "options": {
            "disaster_type": ("Flood", "Cyclone", "Earthquake", "Landslide", "Fire", "Storm", "Other"),
            "district": ("Bagerhat", "Bandarban", "Barguna", "Barishal", "Bhola", "Bogura", "Brahmanbaria",
                         "Chandpur", "Chattogram", "Cumilla", "Dhaka", "Dinajpur", "Faridpur", "Feni",
                         "Gazipur", "Jashore", "Khulna", "Kushtia", "Mymensingh", "Narayanganj", "Noakhali",
                         "Rajshahi", "Rangpur", "Satkhira", "Sylhet", "Tangail"),
            "status": ("Reported", "Under Assessment", "Active Response", "Resolved"),
            "severity": ("Low", "Medium", "High", "Critical"),
        },
    },
    "register-shelter": {
        "title": "Register a Shelter",
        "table": "shelters",
        "fields": [("shelter_name", "Shelter name", "text"), ("district", "District", "text"), ("location", "Location", "text"),
                   ("total_capacity", "Total capacity", "number"), ("occupied_capacity", "Current occupancy", "number"),
                   ("contact_phone", "Contact phone", "tel"), ("status", "Status", "text")],
        "columns": "shelter_name,district,location,total_capacity,occupied_capacity,contact_phone,status",
        "redirect": "/shelters",
        "options": {
            "district": ("Bagerhat", "Bandarban", "Barishal", "Chattogram", "Dhaka", "Dinajpur", "Feni",
                         "Khulna", "Kushtia", "Mymensingh", "Noakhali", "Rajshahi", "Rangpur", "Sylhet", "Tangail"),
            "status": ("Open", "Full", "Closed"),
        },
    },
    "become-blood-donor": {
        "title": "Register as a Blood Donor",
        "table": "blood_donors",
        "fields": [("full_name", "Full name", "text"), ("blood_group", "Blood group", "text"), ("phone", "Phone", "tel"),
                   ("district", "District", "text"), ("is_available", "Available (1/0)", "number")],
        "columns": "full_name,blood_group,phone,district,is_available",
        "redirect": "/blood-donors",
        "options": {
            "blood_group": ("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"),
            "district": ("Bagerhat", "Bandarban", "Barishal", "Chattogram", "Dhaka", "Dinajpur", "Feni",
                         "Khulna", "Kushtia", "Mymensingh", "Noakhali", "Rajshahi", "Rangpur", "Sylhet", "Tangail"),
            "is_available": ("1", "0"),
        },
    },
}


def _page(request, config, message=None, values=None):
    return templates.TemplateResponse("form.html", {
        "request": request, "title": config["title"], "action": request.url.path,
        "fields": config["fields"], "values": values or {}, "message": message, "admin": False,
        "options": config.get("options", {}),
    })


def _valid_values(config, form):
    values = []
    for name, label, kind in config["fields"]:
        value = str(form.get(name, "")).strip()
        if not value:
            raise ValueError(f"{label} is required.")
        if kind == "number":
            value = float(value) if "." in value else int(value)
        values.append(value)
    return values


for _slug, _config in FORMS.items():
    def make_get(config):
        def endpoint(request: Request):
            if not request.session.get("user_id"):
                return RedirectResponse("/login", status_code=303)
            return _page(request, config)
        return endpoint

    def make_post(config):
        async def endpoint(request: Request):
            if not request.session.get("user_id"):
                return RedirectResponse("/login", status_code=303)
            form = await request.form()
            try:
                values = _valid_values(config, form)
                execute(
                    f"INSERT INTO {config['table']} ({config['columns']}) VALUES ({','.join(['%s'] * len(values))})",
                    tuple(values),
                )
            except (ValueError, Error) as exc:
                return _page(request, config, str(exc), dict(form))
            return RedirectResponse(config["redirect"], status_code=303)
        return endpoint

    router.add_api_route(f"/{_slug}", make_get(_config), methods=["GET"], name=f"{_slug}_form")
    router.add_api_route(f"/{_slug}", make_post(_config), methods=["POST"], name=f"{_slug}_submit")
