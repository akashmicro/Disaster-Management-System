from fastapi.responses import RedirectResponse

from main import templates


def is_admin(request):
    return request.session.get("role") == "admin"


def require_admin(request):
    if not is_admin(request):
        return RedirectResponse("/admin/login", status_code=303)
    return None


def render(request, name, **context):
    return templates.TemplateResponse(name, {"request": request, **context})
