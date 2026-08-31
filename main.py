import logging
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.responses import RedirectResponse
from fastapi.staticfiles import StaticFiles
from mysql.connector import Error
from starlette.middleware.sessions import SessionMiddleware
from starlette.templating import Jinja2Templates

from config import SECRET_KEY
from database import fetch_all, fetch_one

BASE_DIR = Path(__file__).resolve().parent


class DmsTemplates(Jinja2Templates):
    def TemplateResponse(self, name_or_request, context=None, **kwargs):
        if isinstance(name_or_request, str):
            return super().TemplateResponse(context["request"], name_or_request, context, **kwargs)
        return super().TemplateResponse(name_or_request, context, **kwargs)


app = FastAPI(title="Disaster Management System")
app.add_middleware(SessionMiddleware, secret_key=SECRET_KEY)
app.mount("/static", StaticFiles(directory=BASE_DIR / "static"), name="static")
templates = DmsTemplates(directory=BASE_DIR / "templates")


def dashboard_stats(user_id=None):
    queries = {
        "total_users": "SELECT COUNT(*) AS value FROM users WHERE role='user'",
        "total_hospitals": "SELECT COUNT(*) AS value FROM hospitals",
        "total_ambulances": "SELECT COUNT(*) AS value FROM ambulances",
        "available_ambulances": "SELECT COUNT(*) AS value FROM ambulances WHERE status='Available'",
        "total_shelters": "SELECT COUNT(*) AS value FROM shelters",
        "available_shelters": "SELECT COUNT(*) AS value FROM shelters WHERE status='Open' AND occupied_capacity < total_capacity",
        "total_disasters": "SELECT COUNT(*) AS value FROM disasters",
        "active_disasters": "SELECT COUNT(*) AS value FROM disasters WHERE status <> 'Resolved'",
        "critical_disasters": "SELECT COUNT(*) AS value FROM disasters WHERE severity_level='CRITICAL'",
        "total_victims": "SELECT COUNT(*) AS value FROM victims",
        "rescued_persons": "SELECT COUNT(*) AS value FROM victims WHERE rescue_status='Rescued'",
        "missing_persons": "SELECT COUNT(*) AS value FROM missing_persons WHERE status='Missing'",
        "available_blood_donors": "SELECT COUNT(*) AS value FROM blood_donors WHERE is_available=1",
        "total_donations": "SELECT COUNT(*) AS value FROM donations",
        "total_donation_amount": "SELECT COALESCE(SUM(amount),0) AS value FROM donations",
    }
    if user_id:
        queries.update({
            "my_donations": "SELECT COUNT(*) AS value FROM donations WHERE user_id=%s",
            "my_total_donation": "SELECT COALESCE(SUM(amount),0) AS value FROM donations WHERE user_id=%s",
        })
    result = {}
    for key, sql in queries.items():
        row = fetch_one(sql, (user_id,)) if "%s" in sql else fetch_one(sql)
        result[key] = row["value"] if row else 0
    return result


@app.get("/")
def home(request: Request):
    if request.session.get("user_id"):
        return RedirectResponse("/admin/dashboard" if request.session.get("role") == "admin" else "/user/dashboard")
    try:
        overview = {
            "active_disasters": fetch_one("SELECT COUNT(*) AS value FROM disasters WHERE status <> 'Resolved'")["value"],
            "open_shelters": fetch_one("SELECT COUNT(*) AS value FROM shelters WHERE status='Open' AND occupied_capacity < total_capacity")["value"],
            "available_ambulances": fetch_one("SELECT COUNT(*) AS value FROM ambulances WHERE status='Available'")["value"],
            "blood_donors": fetch_one("SELECT COUNT(*) AS value FROM blood_donors WHERE is_available=1")["value"],
        }
        recent = fetch_all(
            "SELECT d.disaster_name AS name, dt.type_name AS disaster_type, l.district_name AS district, d.severity_level AS severity "
            "FROM disasters d "
            "LEFT JOIN disaster_types dt ON d.disaster_type_id = dt.disaster_type_id "
            "LEFT JOIN locations l ON d.location_id = l.location_id "
            "WHERE d.status <> 'Resolved' ORDER BY d.reported_at DESC LIMIT 5"
        )
        error = None
    except Error:
        overview, recent = {}, []
        error = "MySQL is unavailable. Start MySQL and verify the .env settings."
    return templates.TemplateResponse("home.html", {"request": request, "overview": overview, "recent": recent, "error": error})


@app.get("/admin/dashboard")
def admin_dashboard(request: Request):
    if request.session.get("role") != "admin":
        return RedirectResponse("/admin/login", status_code=303)
    try:
        stats = dashboard_stats()
        recent = fetch_all(
            "SELECT d.disaster_name AS name, dt.type_name AS disaster_type, l.district_name AS district, d.status AS status, d.severity_level AS severity "
            "FROM disasters d "
            "LEFT JOIN disaster_types dt ON d.disaster_type_id = dt.disaster_type_id "
            "LEFT JOIN locations l ON d.location_id = l.location_id "
            "ORDER BY d.reported_at DESC LIMIT 8"
        )
        error = None
    except Error:
        stats, recent = {}, []
        error = "MySQL is unavailable. Start MySQL and verify the .env settings."
    return templates.TemplateResponse("dashboard.html", {"request": request, "admin": True, "stats": stats, "recent": recent, "error": error})


@app.get("/user/dashboard")
def user_dashboard(request: Request):
    if not request.session.get("user_id"):
        return RedirectResponse("/login", status_code=303)
    try:
        stats = dashboard_stats(request.session["user_id"])
        recent = fetch_all("SELECT name, disaster_type, district, severity FROM disasters WHERE status <> 'Resolved' ORDER BY reported_at DESC LIMIT 6")
        error = None
    except Error:
        stats, recent = {}, []
        error = "MySQL is unavailable. Start MySQL and verify the .env settings."
    return templates.TemplateResponse("dashboard.html", {"request": request, "admin": False, "stats": stats, "recent": recent, "error": error})


from routers import analytics, auth, donation, health, resources, submissions, users

app.include_router(auth.router)
app.include_router(analytics.router)
app.include_router(health.router)
app.include_router(users.router)
app.include_router(donation.router)
app.include_router(submissions.router)
app.include_router(resources.router)


@app.exception_handler(Exception)
async def friendly_error(request: Request, exc: Exception):
    logging.getLogger("dms").exception("Request failed", exc_info=exc)
    return templates.TemplateResponse(
        "error.html",
        {"request": request, "message": "The request could not be completed. Check MySQL and try again."},
        status_code=500,
    )
