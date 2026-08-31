from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse

from database import fetch_all
from main import templates

router = APIRouter()


@router.get("/admin/users")
def users_page(request: Request):
    if request.session.get("role") != "admin":
        return RedirectResponse("/admin/login")
    return templates.TemplateResponse("table.html", {"request": request, "title": "Users",
        "rows": fetch_all("SELECT user_id,full_name,email,phone,role,created_at FROM users ORDER BY user_id DESC"),
        "headers": ["user_id", "full_name", "email", "phone", "role", "created_at"], "create_url": None,
        "config": None, "slug": None, "q": "", "message": None})


@router.get("/profile")
def profile(request: Request):
    user_id = request.session.get("user_id")
    if not user_id:
        return RedirectResponse("/login", status_code=303)
    row = fetch_all("SELECT user_id,full_name,email,phone,role,created_at FROM users WHERE user_id=%s", (user_id,))
    return templates.TemplateResponse("table.html", {"request": request, "title": "My Profile", "rows": row,
        "headers": ["user_id", "full_name", "email", "phone", "role", "created_at"],
        "create_url": None, "config": None, "slug": None, "q": "", "message": None})


@router.get("/user/profile")
def legacy_profile(request: Request):
    return profile(request)


@router.get("/my-donations")
def my_donations(request: Request):
    user_id = request.session.get("user_id")
    if not user_id:
        return RedirectResponse("/login", status_code=303)
    rows = fetch_all(
        "SELECT donation_id,donor_name,donation_type,amount,purpose,disaster,donation_date,payment_method "
        "FROM donations WHERE user_id=%s ORDER BY donation_id DESC", (user_id,))
    return templates.TemplateResponse("table.html", {"request": request, "title": "My Donations", "rows": rows,
        "headers": ["donation_id", "donor_name", "donation_type", "amount", "purpose", "disaster", "donation_date", "payment_method"],
        "create_url": "/donate", "config": None, "slug": None, "q": "", "message": None})


@router.get("/user/donations")
def legacy_donations(request: Request):
    return my_donations(request)


@router.get("/admin/sql-reports")
def sql_reports(request: Request):
    if request.session.get("role") != "admin":
        return RedirectResponse("/admin/login", status_code=303)
    rows = fetch_all("SELECT table_name, table_rows FROM information_schema.tables WHERE table_schema = DATABASE() ORDER BY table_name")
    return templates.TemplateResponse("table.html", {"request": request, "title": "SQL Reports", "rows": rows,
        "headers": ["table_name", "table_rows"], "create_url": None, "config": None, "slug": None, "q": "", "message": None})
