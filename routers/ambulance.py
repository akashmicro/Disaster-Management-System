from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse
from database import fetch_all
from main import templates

router = APIRouter()

@router.get("/ambulances")
def ambulances(request: Request):
    return templates.TemplateResponse("table.html", {"request": request, "title": "Available Ambulances",
        "rows": fetch_all("SELECT ambulance_number,organization,driver_name,driver_phone,district,location,emergency_phone,status FROM ambulances WHERE status='Available'"),
        "headers": ["ambulance_number","organization","driver_name","driver_phone","district","location","emergency_phone","status"], "create_url": None})

@router.get("/admin/ambulances")
def admin_ambulances(request: Request):
    if request.session.get("role") != "admin": return RedirectResponse("/admin/login")
    return ambulances(request)
