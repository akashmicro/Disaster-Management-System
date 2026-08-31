from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse
from database import fetch_all
from main import templates

router = APIRouter()

@router.get("/admin/shelters")
def shelters(request: Request):
    if request.session.get("role") != "admin": return RedirectResponse("/admin/login")
    return templates.TemplateResponse("table.html", {"request": request, "title": "Shelters",
        "rows": fetch_all("SELECT * FROM shelters ORDER BY shelter_id DESC"),
        "headers": ["shelter_id", "shelter_name", "district", "total_capacity", "occupied_capacity", "status"],
        "create_url": None})

@router.get("/shelters")
def public_shelters(request: Request):
    return templates.TemplateResponse("table.html", {"request": request, "title": "Available Shelters",
        "rows": fetch_all("SELECT * FROM shelters WHERE status='Open'"), "headers": ["shelter_name","district","total_capacity","occupied_capacity","status"], "create_url": None})
