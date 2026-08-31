from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse
from database import fetch_all
from main import templates

router = APIRouter()

@router.get("/emergency")
def emergency(request: Request):
    return templates.TemplateResponse("table.html", {"request": request, "title": "Emergency Help",
        "rows": fetch_all("SELECT name, phone FROM emergency_contacts ORDER BY name"), "headers": ["name","phone"], "create_url": None})

@router.get("/admin/emergency")
def admin_emergency(request: Request):
    if request.session.get("role") != "admin": return RedirectResponse("/admin/login")
    return emergency(request)
