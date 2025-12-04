from fastapi import FastAPI, Depends, Request, Form
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session
from database import SessionLocal, engine , Base
from models import User

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Innovatech HR App")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/", response_class=HTMLResponse)
def home(db: Session = Depends(get_db)):
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
      </body>
    </html>
    """
@app.get("/create-user", response_class=HTMLResponse)
def create_user_form():
    return """
    <html>
      <head><title>Create User</title></head>
      <body>
        <h1>Create a new user</h1>
        <form action="/create-user" method="post">
          First name: <input type="text" name="firstname"><br>
          Last name: <input type="text" name="lastname"><br>
          Email: <input type="email" name="email"><br>
          <input type="submit" value="Create User">
        </form>
        <p><a href="/">Back to Home</a></p>
      </body>
    </html>
    """
@app.post("/create-user", response_class=HTMLResponse)
def create_user_post(firstname: str = Form(...), lastname: str = Form(...), email: str = Form(...), db: Session = Depends(get_db)):
    user = User(firstname=firstname, lastname=lastname, email=email)
    db.add(user)
    db.commit()
    db.refresh(user)
    return f"""
    <html>
      <head><title>User Created</title></head>
      <body>
        <h1>User created successfully!</h1>
        <p>{user.firstname} {user.lastname} ({user.email})</p>
        <p><a href="/">Back to Home</a></p>
        <p><a href="/create-user">Create Another User</a></p>
      </body>
    </html>
    """

@app.get("/delete-user", response_class=HTMLResponse)
def delete_user_form():
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
def delete_user_post(user_id: int = Form(...), db: Session = Depends(get_db)):
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