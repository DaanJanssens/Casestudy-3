
import boto3
from fastapi import FastAPI, Depends, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from sqlalchemy.orm import Session
from starlette.middleware.session import SessionMiddleware
from database import SessionLocal, engine , Base
from models import User


Base.metadata.create_all(bind=engine)

def create_default_user():
    db = SessionLocal()
    try:
        existing = db.query(User).filter(User.email == "d.janssens@test.com").first()
        if not existing:
            user = User(
                firstname="Daan",
                lastname="Janssens",
                email="d.janssens@test.com",
                department="HR",
                state="Active"
            )
            db.add(user)
            db.commit()
            db.refresh(user)
            print("Default user created: Daan Janssens")
        else:
            print("Default user already exists.")
    finally:
        db.close()

create_default_user()

app = FastAPI(title="Innovatech HR App")

app.add_middleware(SessionMiddleware, secret_key="SUPER_SECRET_KEY")

def get_iam_departments():
    iam = boto3.client("iam")
    try:
        response =iam.list_groups()
        groups = response.get("Groups", [])
        department_names = [g["GroupName"] for g in groups]

        return department_names
    
    except Exception as e:
        print("Error fetching IAM groups:", e)
        return["HR", "IT", "Finance"]

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def require_login(request: Request):
    return "user" in request.session

@app.get("/login", response_class=HTMLResponse)
def login_form():
    return """
    <html>
      <head><title>Login</title></head>
      <body>
        <h1>Login</h1>
        <form action="/login" method="post">
          Email: <input type="email" name="email" required><br><br>
          <input type="submit" value="Login">
        </form>
      </body>
    </html>
    """

@app.post("/login", response_class=HTMLResponse)
def login(request: Request, email: str = Form(...), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == email).first()

    if not user:
        return """
        <h1>Invalid email</h1>
        <a href='/login'>Try again</a>
        """

    if user.department not in ["HR", "IT"]:
        return """
        <h1>Access denied</h1>
        <p>Your department does not have access.</p>
        <a href='/login'>Go back</a>
        """

    request.session["user"] = {
        "email": user.email,
        "department": user.department
        }
    
    return RedirectResponse("/", status_code=302)

@app.get("/", response_class=HTMLResponse)
def home(request: Request, db: Session = Depends(get_db)):
    if not require_login(request):
        return RedirectResponse("/login")
    users = db.query(User).all()
    users_list = "".join(f"<li>{u.id}: {u.firstname} {u.lastname} ({u.email})</li>" for u in users)
    return f"""
    <html>
      <head><title>HR App</title></head>
      <body>
        <h1>Welcome to the HR App</h1>
        <h2>Users:</h2>
        <ul>{users_list}</ul>
        <p><a href="/create-user">Create User</a></p>
        <p><a href="/delete-user">Delete User</a></p>
        <p><a href="/logout">Logout</a></p>
      </body>
    </html>
    """
@app.get("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse("/login", status_code=302)

@app.get("/create-user", response_class=HTMLResponse)
def create_user_form(request: Request):
    if not require_login(request):
        return RedirectResponse("/login")
    if request.session["user"]["department"] != "HR":
        return RedirectResponse("/")
    departments = get_iam_departments()

    department_options = "\n".join(
        [f"<option value='{d}'>{d}</option>" for d in departments]
    )
    return f"""
    <html>
      <head><title>Create User</title></head>
      <body>
        <h1>Create a new user</h1>
        <form action="/create-user" method="post">
          First name: <input type="text" name="firstname"><br>
          Last name: <input type="text" name="lastname"><br>
          Email: <input type="email" name="email"><br>
          Department:
          <select name="department" required>
            {department_options}
          </select><br><br>
          Status:
          <select name="state" required>
            <option value="Active">Active</option>
            <option value="Suspended">Suspended</option>
          </select><br><br>
          <input type="submit" value="Create User">
        </form>
        <p><a href="/">Back to Home</a></p>
      </body>
    </html>
    """
@app.post("/create-user", response_class=HTMLResponse)
def create_user_post(
    request: Request,
    firstname: str = Form(...),
    lastname: str = Form(...),
    email: str = Form(...),
    department: str = Form(...),
    state: str = Form(...),
    db: Session = Depends(get_db)
):
    if not require_login(request):
        return RedirectResponse("/login")

    if request.session["user"]["department"] != "HR":
        return RedirectResponse("/")

    user = User(
        firstname=firstname,
        lastname=lastname,
        email=email,
        department=department,
        state=state
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return f"""
    <html>
      <head><title>User Created</title></head>
      <body>
        <h1>User created successfully!</h1>
        <p>{user.firstname} {user.lastname} ({user.email})</p>
        <p>Department: {user.department}</p>
        <p>Status: {user.state}</p>
        <p><a href="/">Back to Home</a></p>
        <p><a href="/create-user">Create Another User</a></p>
      </body>
    </html>
    """

@app.get("/delete-user", response_class=HTMLResponse)
def delete_user_form(request: Request):
    if not require_login(request):
        return RedirectResponse("/login")
    
    if request.session["user"]["department"] != "IT":
        return RedirectResponse("/")
    return """
    <html>
      <head><title>Delete User</title></head>
      <body>
        <h1>Delete a user</h1>
        <form action="/delete-user" method="post">
          User ID: <input type="number" name="user_id"><br>
          <input type="submit" value="Delete User">
        </form>
        <p><a href="/">Back to Home</a></p>
      </body>
    </html>
    """

@app.post("/delete-user", response_class=HTMLResponse)
def delete_user_post(request: Request, user_id: int = Form(...), db: Session = Depends(get_db)):
    if not require_login(request):
        return RedirectResponse("/login")

    if request.session["user"]["department"] != "IT":
        return RedirectResponse("/")
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return f"""
        <html>
          <body>
            <h1>User not found</h1>
            <p><a href="/delete-user">Try Again</a></p>
            <p><a href="/">Back to Home</a></p>
          </body>
        </html>
        """
    db.delete(user)
    db.commit()
    return f"""
    <html>
      <body>
        <h1>User deleted successfully</h1>
        <p>{user.firstname} {user.lastname} ({user.email})</p>
        <p><a href="/delete-user">Delete Another User</a></p>
        <p><a href="/">Back to Home</a></p>
      </body>
    </html>
    """