from fastapi import APIRouter, Form, Request
from fastapi.responses import RedirectResponse

from database import execute, fetch_all
from main import templates

router = APIRouter()


def admin(request):
    return request.session.get("role") == "admin"


@router.get("/admin/disasters")
def list_disasters(request: Request):
    if not admin(request):
        return RedirectResponse("/admin/login")
    rows = fetch_all("SELECT * FROM disasters ORDER BY reported_at DESC")
    return templates.TemplateResponse("table.html", {"request": request, "title": "Disasters", "rows": rows,
        "headers": ["disaster_id", "name", "type", "district", "status", "severity", "reported_at"],
        "create_url": "/admin/disasters/new"})


@router.get("/admin/disasters/new")
def disaster_form(request: Request):
    if not admin(request):
        return RedirectResponse("/admin/login")
    return templates.TemplateResponse("form.html", {"request": request, "title": "Add Disaster",
        "action": "/admin/disasters/new", "fields": [("name", "Disaster name", "text"), ("type", "Type", "text"),
        ("district", "District", "text"), ("status", "Status", "text"), ("description", "Description", "textarea")]})


@router.post("/admin/disasters/new")
def create_disaster(request: Request, name: str = Form(...), type: str = Form(...),
                    district: str = Form(...), status: str = Form(...), description: str = Form("")):
    if not admin(request):
        return RedirectResponse("/admin/login")
    execute("INSERT INTO disasters (name, disaster_type, district, status, description) VALUES (%s,%s,%s,%s,%s)",
            (name.strip(), type.strip(), district.strip(), status.strip(), description.strip()))
    return RedirectResponse("/admin/disasters", status_code=303)
