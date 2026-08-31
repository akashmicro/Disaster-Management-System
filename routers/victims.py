from fastapi import APIRouter, Form, Request
from fastapi.responses import RedirectResponse
from database import execute, fetch_all
from main import templates

router = APIRouter()

@router.get("/admin/victims")
def victims(request: Request):
    if request.session.get("role") != "admin": return RedirectResponse("/admin/login")
    return templates.TemplateResponse("table.html", {"request": request, "title": "Victims",
        "rows": fetch_all("SELECT * FROM victims ORDER BY victim_id DESC"),
        "headers": ["victim_id", "full_name", "age", "gender", "condition_status", "rescue_status"],
        "create_url": "/admin/victims/new"})

@router.get("/admin/victims/new")
def victim_form(request: Request):
    if request.session.get("role") != "admin": return RedirectResponse("/admin/login")
    return templates.TemplateResponse("form.html", {"request": request, "title": "Add Victim", "action": "/admin/victims/new",
        "fields": [("full_name","Name","text"),("age","Age","number"),("gender","Gender","text"),("condition_status","Condition","text")]})

@router.post("/admin/victims/new")
def create_victim(request: Request, full_name: str = Form(...), age: int = Form(...),
                  gender: str = Form(...), condition_status: str = Form(...)):
    if request.session.get("role") != "admin": return RedirectResponse("/admin/login")
    execute("INSERT INTO victims (full_name,age,gender,condition_status) VALUES (%s,%s,%s,%s)",
            (full_name.strip(), age, gender, condition_status))
    return RedirectResponse("/admin/victims", status_code=303)
