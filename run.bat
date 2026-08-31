@echo off
setlocal
cd /d "%~dp0"
if exist "venv\Scripts\python.exe" (
  "venv\Scripts\python.exe" --version >nul 2>&1
  if not errorlevel 1 set "PYTHON=venv\Scripts\python.exe"
)
if not defined PYTHON if exist ".venv\Scripts\python.exe" (
  ".venv\Scripts\python.exe" --version >nul 2>&1
  if not errorlevel 1 set "PYTHON=.venv\Scripts\python.exe"
)
if not defined PYTHON if exist "%LocalAppData%\Programs\Python\Python314\python.exe" set "PYTHON=%LocalAppData%\Programs\Python\Python314\python.exe"
if not defined PYTHON set "PYTHON=py -3"
start "" http://127.0.0.1:8000
%PYTHON% -m uvicorn main:app --reload
