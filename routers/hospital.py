from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse
from database import fetch_all
from main import templates

router = APIRouter()

@router.get("/hospitals")
def hospitals(request: Request):
    return templates.TemplateResponse("table.html", {"request": request, "title": "Hospitals",
        "rows": fetch_all("SELECT hospital_name,hospital_type,phone,emergency_phone,district,location,available_beds,status FROM hospitals"),
        "headers": ["hospital_name","hospital_type","phone","emergency_phone","district","location","available_beds","status"], "create_url": None})

@router.get("/admin/hospitals")
def admin_hospitals(request: Request):
    if request.session.get("role") != "admin": return RedirectResponse("/admin/login")
    return hospitals(request)
