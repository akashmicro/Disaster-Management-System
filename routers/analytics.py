from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse
from database import fetch_all
from main import templates

router = APIRouter()


@router.get("/admin/analytics")
def analytics(request: Request):
    if request.session.get("role") != "admin":
        return RedirectResponse("/admin/login")
    stats = {
        "disasters_by_type": fetch_all("SELECT disaster_type AS label, COUNT(*) AS value FROM disasters GROUP BY disaster_type ORDER BY value DESC"),
        "disasters_by_district": fetch_all("SELECT district AS label, COUNT(*) AS value FROM disasters GROUP BY district ORDER BY value DESC"),
        "victims_by_rescue_status": fetch_all("SELECT rescue_status AS label, COUNT(*) AS value FROM victims GROUP BY rescue_status ORDER BY value DESC"),
        "shelter_occupancy": fetch_all("SELECT district AS label, COALESCE(SUM(occupied_capacity),0) AS value FROM shelters GROUP BY district ORDER BY value DESC"),
        "missions_by_status": fetch_all("SELECT status AS label, COUNT(*) AS value FROM missions GROUP BY status ORDER BY value DESC"),
        "donations_by_month": fetch_all("SELECT DATE_FORMAT(donation_date,'%Y-%m') AS label, SUM(amount) AS value FROM donations GROUP BY label ORDER BY label"),
        "top_donors": fetch_all("SELECT donor_name AS label, SUM(amount) AS value FROM donations WHERE amount > 0 GROUP BY donor_name ORDER BY value DESC LIMIT 10"),
        "ambulances_by_status": fetch_all("SELECT status AS label, COUNT(*) AS value FROM ambulances GROUP BY status"),
    }
    return templates.TemplateResponse("analytics.html", {"request": request, "stats": stats})
