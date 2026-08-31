from datetime import date
from fastapi import APIRouter, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error
from database import execute
from main import templates

router = APIRouter()
FIELDS = [
    ("donor_name", "Donor name", "text"), ("email", "Email", "email"), ("phone", "Phone", "tel"),
    ("donation_type", "Type (Money or Material)", "text"), ("amount", "Amount", "number"),
    ("purpose", "Purpose", "text"), ("item_name", "Item name", "text"), ("category", "Category", "text"),
    ("quantity", "Quantity", "number"), ("unit", "Unit", "text"), ("disaster", "Disaster", "text"),
    ("donation_date", "Date", "date"), ("payment_method", "Payment method", "text"),
    ("transaction_reference", "Transaction reference", "text"), ("remarks", "Remarks", "textarea"),
]

def _form(request, message=None, values=None):
    return templates.TemplateResponse("donation.html", {"request": request, "message": message,
        "values": values or {}, "admin": False})

@router.get("/donate")
def donation_form(request: Request):
    if not request.session.get("user_id"):
        return RedirectResponse("/login", status_code=303)
    return _form(request)

@router.post("/donate")
async def create_donation(request: Request):
    user_id = request.session.get("user_id")
    if not user_id:
        return RedirectResponse("/login", status_code=303)
    form = await request.form()
    values = {name: str(form.get(name, "")).strip() for name, _, _ in FIELDS}
    required = ("donor_name", "email", "phone", "donation_type", "purpose", "disaster", "donation_date")
    if any(not values[name] for name in required):
        return _form(request, "Please complete all donor, type, purpose, disaster, and date fields.", values)
    if values["donation_type"] not in {"Money", "Material"}:
        return _form(request, "Donation type must be Money or Material.", values)
    try:
        values["amount"] = float(values["amount"] or 0)
        values["quantity"] = float(values["quantity"] or 0)
    except ValueError:
        return _form(request, "Amount and quantity must be valid numbers.", values)
    if values["donation_type"] == "Money" and values["amount"] <= 0:
        return _form(request, "Money donations must have an amount greater than zero.", values)
    if values["donation_type"] == "Material" and (not values["item_name"] or values["quantity"] <= 0 or not values["unit"]):
        return _form(request, "Material donations require item, quantity, and unit.", values)
    try:
        execute(
            "INSERT INTO donations (user_id,donor_name,email,phone,donation_type,amount,purpose,item_name,category,quantity,unit,disaster,donation_date,payment_method,transaction_reference,remarks) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
            (user_id, values["donor_name"], values["email"], values["phone"], values["donation_type"],
             values["amount"], values["purpose"], values["item_name"], values["category"], values["quantity"],
             values["unit"], values["disaster"], values["donation_date"], values["payment_method"],
             values["transaction_reference"], values["remarks"]),
        )
    except (Error, ValueError) as exc:
        return _form(request, f"Donation could not be saved: {exc}", values)
    return RedirectResponse("/my-donations", status_code=303)
