import re
import secrets
from datetime import datetime, timedelta

from fastapi import APIRouter, Form, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error
from passlib.hash import bcrypt

from config import DEBUG_OTP
from database import execute, fetch_one
from routers.common import render

router = APIRouter()
OTP_MINUTES = 10
RESEND_SECONDS = 60


def valid_email(value):
    return bool(re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", value.strip()))


def verify_password(password, password_hash):
    try:
        return bcrypt.verify(password, password_hash)
    except (ValueError, TypeError):
        return False


@router.get("/login")
def login_page(request: Request):
    return render(request, "login.html", admin=False, message=None)


@router.post("/login")
def login(request: Request, email: str = Form(...), password: str = Form(...)):
    try:
        user = fetch_one("SELECT * FROM users WHERE LOWER(email)=LOWER(%s) AND role='user' AND is_active=1", (email.strip(),))
    except Error:
        return render(request, "login.html", admin=False, message="MySQL is unavailable. Check .env and start MySQL.")
    if not user or not verify_password(password, user["password_hash"]):
        return render(request, "login.html", admin=False, message="Invalid email or password.")
    request.session.clear()
    request.session.update(user_id=user["user_id"], role="user", full_name=user["full_name"], email=user["email"])
    return RedirectResponse("/user/dashboard", status_code=303)


@router.get("/admin/login")
def admin_login_page(request: Request):
    return render(request, "login.html", admin=True, message=None)


@router.post("/admin/login")
def admin_login(request: Request, username: str = Form(...), password: str = Form(...)):
    if username.strip() != "masudrana33666" or password != "1111111":
        return render(request, "login.html", admin=True, message="Invalid admin username or password.")
    try:
        admin = fetch_one("SELECT user_id,full_name,email FROM users WHERE username=%s AND role='admin'", (username.strip(),))
        if not admin:
            execute("INSERT INTO users (full_name,username,email,phone,password_hash,role) VALUES (%s,%s,%s,%s,%s,'admin')",
                    ("Masud Rana", "masudrana33666", "admin@dms.local", "01700000001", bcrypt.hash("1111111")))
            admin = fetch_one("SELECT user_id,full_name,email FROM users WHERE username=%s", (username.strip(),))
    except Error:
        return render(request, "login.html", admin=True, message="MySQL schema is unavailable. Run database/schema.sql and seed_demo.py.")
    request.session.clear()
    request.session.update(user_id=admin["user_id"], role="admin", full_name=admin["full_name"], email=admin["email"])
    return RedirectResponse("/admin/dashboard", status_code=303)


@router.get("/register")
def register_page(request: Request):
    return render(request, "register.html", message=None)


@router.post("/register")
def register(request: Request, full_name: str = Form(...), email: str = Form(...),
             phone: str = Form(...), password: str = Form(...), confirm_password: str = Form(...)):
    if not full_name.strip() or not valid_email(email) or not phone.strip():
        return render(request, "register.html", message="Enter a valid name, email, and phone.")
    if len(password) < 8 or password != confirm_password:
        return render(request, "register.html", message="Passwords must match and contain at least 8 characters.")
    try:
        if fetch_one("SELECT user_id FROM users WHERE LOWER(email)=LOWER(%s)", (email.strip(),)):
            return render(request, "register.html", message="An account with that email already exists.")
        username = "user_" + secrets.token_hex(5)
        execute("INSERT INTO users (full_name,username,email,phone,password_hash,role) VALUES (%s,%s,%s,%s,%s,'user')",
                (full_name.strip(), username, email.strip().lower(), phone.strip(), bcrypt.hash(password)))
    except Error:
        return render(request, "register.html", message="Unable to create the account. Check MySQL and try again.")
    return RedirectResponse("/login?registered=1", status_code=303)


@router.get("/forgot-password")
def forgot_page(request: Request):
    return render(request, "forgot_password.html", message=None, debug_otp=request.session.pop("debug_otp", None))


@router.post("/forgot-password")
def forgot_password(request: Request, email: str = Form(...)):
    email = email.strip().lower()
    try:
        user = fetch_one("SELECT user_id,email FROM users WHERE LOWER(email)=LOWER(%s) AND role='user'", (email,))
    except Error:
        return render(request, "forgot_password.html", message="MySQL is unavailable. Check your database settings.", debug_otp=None)
    if not user:
        return render(request, "forgot_password.html", message="No account was found for that email.", debug_otp=None)
    try:
        latest = fetch_one("SELECT created_at FROM password_otps WHERE user_id=%s ORDER BY otp_id DESC LIMIT 1", (user["user_id"],))
        if latest and latest["created_at"] > datetime.now() - timedelta(seconds=RESEND_SECONDS):
            return render(request, "forgot_password.html", message="Please wait before requesting another OTP.", debug_otp=None)
        code = f"{secrets.randbelow(1_000_000):06d}"
        execute("INSERT INTO password_otps (user_id,otp_hash,expires_at) VALUES (%s,%s,%s)",
                (user["user_id"], bcrypt.hash(code), datetime.now() + timedelta(minutes=OTP_MINUTES)))
    except Error:
        return render(request, "forgot_password.html", message="OTP service is unavailable. Run database/schema.sql first.", debug_otp=None)
    request.session.update(reset_user_id=user["user_id"], reset_email=user["email"])
    if DEBUG_OTP:
        request.session["debug_otp"] = code
    return RedirectResponse("/verify-otp", status_code=303)


@router.get("/verify-otp")
def verify_page(request: Request):
    if not request.session.get("reset_user_id"):
        return RedirectResponse("/forgot-password", status_code=303)
    return render(request, "verify_otp.html", message=None, debug_otp=request.session.pop("debug_otp", None))


@router.post("/verify-otp")
def verify_otp(request: Request, otp: str = Form(...)):
    user_id = request.session.get("reset_user_id")
    if not user_id or not re.fullmatch(r"\d{6}", otp.strip()):
        return render(request, "verify_otp.html", message="Enter the six-digit OTP.", debug_otp=None)
    record = fetch_one("SELECT * FROM password_otps WHERE user_id=%s AND used_at IS NULL ORDER BY otp_id DESC LIMIT 1", (user_id,))
    if not record or datetime.now() > record["expires_at"] or not verify_password(otp.strip(), record["otp_hash"]):
        return render(request, "verify_otp.html", message="The OTP is invalid or expired.", debug_otp=None)
    execute("UPDATE password_otps SET used_at=NOW() WHERE otp_id=%s", (record["otp_id"],))
    request.session["otp_verified"] = True
    return RedirectResponse("/reset-password", status_code=303)


@router.post("/resend-otp")
def resend_otp(request: Request):
    user_id = request.session.get("reset_user_id")
    if not user_id:
        return RedirectResponse("/forgot-password", status_code=303)
    user = fetch_one("SELECT email FROM users WHERE user_id=%s", (user_id,))
    if user:
        return forgot_password(request, user["email"])
    return RedirectResponse("/forgot-password", status_code=303)


@router.get("/reset-password")
def reset_page(request: Request):
    if not request.session.get("otp_verified"):
        return RedirectResponse("/forgot-password", status_code=303)
    return render(request, "reset_password.html", message=None)


@router.post("/reset-password")
def reset_password(request: Request, password: str = Form(...), confirm_password: str = Form(...)):
    user_id = request.session.get("reset_user_id")
    if not request.session.get("otp_verified") or not user_id:
        return RedirectResponse("/forgot-password", status_code=303)
    if len(password) < 8 or password != confirm_password:
        return render(request, "reset_password.html", message="Passwords must match and contain at least 8 characters.")
    try:
        execute("UPDATE users SET password_hash=%s WHERE user_id=%s", (bcrypt.hash(password), user_id))
    except Error:
        return render(request, "reset_password.html", message="Password could not be updated. Check the MySQL connection.")
    request.session.pop("reset_user_id", None)
    request.session.pop("reset_email", None)
    request.session.pop("otp_verified", None)
    return RedirectResponse("/login?reset=1", status_code=303)


@router.get("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse("/login", status_code=303)
